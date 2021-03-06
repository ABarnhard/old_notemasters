﻿/*
WITH denormalized AS (
	select n.id,n.title,n.body,n.created_at,n.user_id,nt.note_id,nt.tag_id,t.id,t.name
	from notes n
	inner join notes_tags nt on nt.note_id = n.id
	inner join tags t on nt.tag_id = t.id
	WHERE n.user_id = 2
),
tag_names_by_notes AS (
	SELECT d.note_id, array_agg(d.name) AS tag_names
	FROM denormalized d
	GROUP BY d.note_id
)
select *
from denormalized d
inner join tag_names_by_notes tn on tn.note_id = n.id
inner join tags t on nt.tag_id = t.id;
*/

select n.id,n.title,n.body,n.created_at,t.name
from notes n
inner join notes_tags nt on nt.note_id = n.id
inner join tags t on nt.tag_id = t.id
WHERE n.user_id = 2;
	
/*
-- Note Ids
WITH notes_ids AS (
  SELECT id
  FROM notes
  WHERE notes.user_id = 1
),
-- Tag Ids grouped by note id
tag_names_by_notes AS (
  SELECT tags.name, array_agg(tags.name) AS tag_names
  FROM tags
  GROUP BY tags.name
  HAVING "tags"."name" IN (
    SELECT "notes_ids"."id"
    FROM "notes_ids"
  )
),
-- Tag records
tags_attributes_filter AS (
  SELECT "tags"."id", "tags"."name", "tags"."note_id"
  FROM "tags"
  WHERE "tags"."note_id" IN (
    SELECT "notes_ids"."id"
    FROM "notes_ids"
  )
),
-- Tag records as a JSON array
tags_as_json_array AS (
  SELECT array_to_json(array_agg(row_to_json(tags_attributes_filter)))
AS tags, 1 AS match
  FROM "tags_attributes_filter"
),
-- Note records
notes_attributes_filter AS (
  SELECT "notes"."id", "notes"."content", "notes"."name",
coalesce("tag_ids_by_notes"."tag_ids", '{}'::int[]) AS tag_ids
  FROM "notes"
  LEFT OUTER JOIN "tag_ids_by_notes"
  ON "notes"."id" = "tag_ids_by_notes"."note_id"
  WHERE "notes"."id" < 40
),
-- Note records as a JSON array
notes_as_json_array AS (
  SELECT array_to_json(array_agg(row_to_json(notes_attributes_filter)))
AS notes, 1 AS match
  FROM "notes_attributes_filter"
),
-- Notes and tags together as one JSON object
jsons AS (
  SELECT "tags_as_json_array"."tags", "notes_as_json_array"."notes"
  FROM "tags_as_json_array"
  INNER JOIN "notes_as_json_array"
  ON "tags_as_json_array"."match" = "notes_as_json_array"."match"
)
SELECT row_to_json(jsons) FROM "jsons";
*/