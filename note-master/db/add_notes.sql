CREATE OR REPLACE FUNCTION add_note(user_id integer, title varchar, body text, tags varchar)
RETURNS integer AS $$
DECLARE
  nid integer;
  tid integer;
  names varchar[];
  tagname varchar;
BEGIN
  -- insert the new note and save off the new note id into the variable nid
  INSERT INTO notes (title, body, user_id) values (title, body, user_id) RETURNING id INTO nid;
  -- split string into an array stored in variable names
  SELECT string_to_array(tags, ',') INTO names;
  
  -- log out our variables to check what's going on
  RAISE NOTICE 'nid: %', nid;
  RAISE NOTICE 'names: %', names;
  -- creates a table of all the tags currently in the system
  CREATE TEMP TABLE tagger ON COMMIT DROP AS SELECT nid, t.id AS tid, t.name AS tname FROM tags t WHERE t.name = any(names);

  -- For each item in the names array, loop
  FOREACH tagname IN ARRAY names
  LOOP
    tid := (SELECT t.tid FROM tagger t WHERE t.tname = tagname);
    RAISE NOTICE 'tag id: %', tid;
    -- if the tag isn't in the database
    IF tid IS NULL THEN
      -- add it to the database, then add it to our temp table
      INSERT INTO tags (name) VALUES (tagname) RETURNING id INTO tid;
      INSERT INTO tagger VALUES (nid, tid, tagname);
    END IF
  END LOOP;
  
  -- insert the note id & tag id rows from our temp table into the notes_tags table
  INSERT INTO notes-tags SELECT t.nid, t.tid from tagger t;
  
  -- return the note id of the new note
  RETURN nid;
END;
$$ LANGUAGE plpgsql;

select add_note(2,'Test Note A', 'A1', 'javascript,angular,sql,hapi');

SELECT * FROM notes;
/*
DELETE FROM notes_tags;
DELETE FROM notes;
DELETE FROM tags;
*/