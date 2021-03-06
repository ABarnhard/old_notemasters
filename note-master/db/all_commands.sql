﻿CREATE OR REPLACE FUNCTION find_all_user(user_id integer)
RETURNS TABLE("noteId" integer, "title" varchar, "body" text, "updatedAt" timestamp, "tags" varchar[]) AS $$
DECLARE
BEGIN
  CREATE TEMP TABLE tags_by_note ON COMMIT DROP AS 
    SELECT n.id AS nid, array_agg(t.name) AS tags
    FROM notes n
    LEFT OUTER JOIN notes_tags nt ON n.id = nt.note_id
    LEFT OUTER JOIN tags t ON nt.tag_id = t.id
    WHERE n.user_id = 1
    GROUP BY n.id
    ORDER BY n.updated_at DESC;

  RETURN QUERY
    SELECT n.id AS "noteId",n.title,n.body,n.updated_at AS "updatedAt",tg.tags
    FROM notes n
    INNER JOIN tags_by_note tg ON n.id = tg.nid;
    
END;
$$ LANGUAGE plpgsql;
-- This is the query to call in the model
SELECT * FROM find_all_user(1);
