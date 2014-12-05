/*
select n.title, t.name
from notes n
inner join notes_tags nt on nt.note_id = n.id
inner join tags t on nt.tag_id = t.id;
*/

select n.title, t.name, u.username
from users u
inner join notes n on u.id = n.user_id
inner join notes_tags nt on nt.note_id = n.id
inner join tags t on nt.tag_id = t.id;