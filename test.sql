-- select polls.id, count( distinct questions.id)
-- from polls
-- left join questions on questions.poll_id = polls.id
-- join answer_choices on answer_choices.question_id = questions.id
-- group by polls.id
-- ;

SELECT
  polls.*,
  count(distinct questions.id),
  count(distinct user_responses.id)
FROM
  polls
LEFT OUTER JOIN
  questions ON questions.poll_id = polls.id
LEFT OUTER JOIN
  answer_choices ON questions.id = answer_choices.question_id
left outer JOIN
  (
    SELECT
      responses.*
    FROM
      responses
    JOIN
      users ON users.id = responses.user_id
    WHERE
      users.id = 19
  ) AS user_responses
ON user_responses.answer_choice_id = answer_choices.id
group by
polls.id;
