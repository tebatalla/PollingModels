# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  user_name  :string           not null
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
  validates :user_name, uniqueness: true, presence: true

  has_many(
    :authored_polls,
    class_name: 'Poll',
    foreign_key: :author_id,
    primary_key: :id
    )

  has_many(
    :responses,
    class_name: 'Response',
    foreign_key: :user_id,
    primary_key: :id
  )

  def completed_polls
    # data = Poll.find_by_sql([<<-SQL, self.id])
    #   SELECT
    #     polls.*,
    #     COALESCE(COUNT(questions.id), 0) AS question_count
    #   FROM
    #     polls
    #   LEFT OUTER JOIN
    #     questions ON questions.poll_id = polls.id
    #   LEFT OUTER JOIN
    #     answer_choices ON questions.id = answer_choices.question_id
    #   JOIN
    #     (
    #       SELECT
    #         responses.*
    #       FROM
    #         responses
    #       JOIN
    #         users ON users.id = responses.user_id
    #     ) AS user_responses
    #   ON user_responses.answer_choice_id = answer_choices.id
    #   WHERE
    #     user_responses.user_id = ?
    #   GROUP BY
    #     polls.id
    #   HAVING
    #     COUNT(questions.id) = COUNT(user_responses.id)
    # SQL
    # p data

    data = Poll.joins('LEFT OUTER JOIN questions ON questions.poll_id = polls.id')
      .joins('LEFT OUTER JOIN answer_choices' +
      ' ON questions.id = answer_choices.question_id')
      .joins('JOIN responses ON answer_choices.id = responses.answer_choice_id')
      .where('responses.user_id = ?', self.id)
      .group('polls.id')
      .having('COUNT(questions.id) = COUNT(responses.id)')


  end
end
