create table users(
    id serial primary key,
    username varchar(255) unique not null,
    password char(60) not null,
    avatar varchar(500) not null,
    created_at timestamp not null default now()
);
create table notes(
  id serial primary key,
  title varchar(255) not null,
  body text not null,
  created_at timestamp not null default now(),
  updated_at timestamp not null default now(),
  user_id integer not null references users(id)
);
create table tags(
  id serial primary key,
  name varchar(255) not null unique,
  created_at timestamp not null default now()
);
create table notes_tags(
  note_id integer not null references notes(id),
  tag_id integer not null references tags(id)
);
create or replace function add_note (user_id integer, title varchar, body text, tags varchar)
returns integer AS $$
declare

  nid integer;
  tid integer;
  names varchar[];
  tagname varchar;

begin

  -- insert the note
  insert into notes (title, body, user_id) values (title, body, user_id) returning id into nid;
  -- turn string into array
  select string_to_array(tags, ',') into names;
  raise notice 'nid: %', nid;
  raise notice 'names: %', names;
  -- create temp table
  create temp table tagger on commit drop as select nid, t.id as tid, t.name as tname from tags t where t.name = any(names);

  -- looping over all the tags
  foreach tagname in array names
  loop
    tid := (select t.tid from tagger t where t.tname = tagname);
    raise notice 'tid: %', tid;

    -- if the tag does not exist, then insert it
    IF tid is null then
      insert into tags (name) values (tagname) returning id into tid;
      insert into tagger values (nid, tid, tagname);
    end if;
  end loop;

  -- take the temp table and insert it into the join table
  insert into notes_tags select t.nid, t.tid from tagger t;
  -- return the note id
  return nid;

end;
$$ language plpgsql;
CREATE OR REPLACE FUNCTION find_user_notes(userid integer, lmt integer)
RETURNS TABLE("noteId" integer, "title" varchar, "body" text, "updatedAt" timestamp, "tags" varchar[]) AS $$
DECLARE
BEGIN
  CREATE TEMP TABLE tags_by_note ON COMMIT DROP AS
    SELECT n.id AS nid, array_agg(t.name) AS tags
    FROM notes n
    LEFT OUTER JOIN notes_tags nt ON n.id = nt.note_id
    LEFT OUTER JOIN tags t ON nt.tag_id = t.id
    WHERE n.user_id = userid
    GROUP BY n.id
    ORDER BY n.updated_at DESC
    LIMIT lmt;

  RETURN QUERY
    SELECT n.id AS "noteId",n.title,n.body,n.updated_at AS "updatedAt",tg.tags
    FROM notes n
    INNER JOIN tags_by_note tg ON n.id = tg.nid;

END;
$$ LANGUAGE plpgsql;
