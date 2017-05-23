create or replace function aux_substring_with_dots_at_end(str text) returns text as $$
declare
    substr text := str;
begin
if char_length(str) > 40 then
    substr := substring(str for 40) || '...';
end if;
return substr;
end;
$$ language plpgsql;



create or replace function aux_get_user_name_by_id(the_user_id integer) returns text as $$
declare
    user_name text;
begin
select u.etc->>'name' into user_name
from users as u
where u.id = the_user_id;
return user_name;
end;
$$ language plpgsql;



create or replace function show_all(the_user_id integer) returns table(
        deck_name text,
        decks_list text[],
        card_id uuid,
        front text,
    -- back text,
        username text,
        due date,
        progress_data text
        ) as $$
select
    get_deck_name(deck_id) as deck_name,
    array(select get_deck_name(deck_id) from get_card_decks(the_user_id, c.id)),
    c.id,
    aux_substring_with_dots_at_end(c.front),
-- aux_substring_with_dots_at_end(c.back),
    aux_get_user_name_by_id(c.created_by),
    r.due_date,
    '(' ||
    'ef=' || (unpack_progress_data(r.packed_progress_data)).easiness_factor || ', ' ||
    'pri=' || (unpack_progress_data(r.packed_progress_data)).prev_interval   || ', ' ||
    'prr=' || (unpack_progress_data(r.packed_progress_data)).prev_response   || ', ' ||
    'nol=' || (unpack_progress_data(r.packed_progress_data)).num_of_lapses   || '' ||
-- (unpack_progress_data(r.packed_progress_data)).prev_response_was_made_in_mobile_app   || ',' ||
-- (unpack_progress_data(r.packed_progress_data)).more_than_one_removed_at    || ',' ||
-- (unpack_progress_data(r.packed_progress_data)).prev_seconds_spent_on_card
    ')'
from get_cards_orset(the_user_id) as r
    join cards as c on r.card_id = c.id
    join get_card_decks(the_user_id, c.id) on true
where true;
$$ language sql;
