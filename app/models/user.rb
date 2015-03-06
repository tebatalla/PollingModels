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
    Poll.find_by_sql([<<-SQL, self.id])
      SELECT
        polls.*
      FROM
        polls
      LEFT OUTER JOIN
        questions ON questions.poll_id = polls.id
      LEFT OUTER JOIN
        answer_choices ON questions.id = answer_choices.question_id
      LEFT OUTER JOIN
        (
          SELECT
            responses.*
          FROM
            responses
          JOIN
            users ON users.id = responses.user_id
          WHERE
            users.id = ?
        ) AS user_responses
      ON user_responses.answer_choice_id = answer_choices.id
      GROUP BY
        polls.id
      HAVING
        COUNT(DISTINCT questions.id) = COUNT(DISTINCT user_responses.id)
    SQL

    # sub = Response.joins('JOIN users ON users.id = responses.user_id')
    #   .where('users.id = ?', self.id).select('responses.*')

    # Poll.joins('LEFT OUTER JOIN questions ON questions.poll_id = polls.id')
    #   .joins('LEFT OUTER JOIN answer_choices ON questions.id = answer_choices.question_id')
    #   .joins('JOIN (SELECT responses.* FROM responses JOIN users ON users.id = responses.user_id
    #          WHERE users.id = ?) AS user_responses ON answer_choices.id = user_responses.answer_choice_id', self.id)
    # .group('polls.id')
    # .having('COUNT(DISTINCT questions.id) = COUNT(DISTINCT user_responses.id)')


  end

  def uncompleted_polls

    Poll.find_by_sql([<<-SQL, self.id])
      SELECT
        polls.*
      FROM
        polls
      LEFT OUTER JOIN
        questions ON questions.poll_id = polls.id
      LEFT OUTER JOIN
        answer_choices ON questions.id = answer_choices.question_id
      LEFT OUTER JOIN
        (
          SELECT
            responses.*
          FROM
            responses
          JOIN
            users ON users.id = responses.user_id
          WHERE
            users.id = ?
        ) AS user_responses
      ON user_responses.answer_choice_id = answer_choices.id
      GROUP BY
        polls.id
      HAVING
        COUNT(DISTINCT questions.id) != COUNT(DISTINCT user_responses.id) AND
        COUNT(DISTINCT user_responses.id) != 0
    SQL
    # data = Poll.joins('LEFT OUTER JOIN questions ON questions.poll_id = polls.id')
    #   .joins('LEFT OUTER JOIN answer_choices' +
    #   ' ON questions.id = answer_choices.question_id')
    #   .joins('JOIN responses ON answer_choices.id = responses.answer_choice_id')
    #   .where('responses.user_id = ?', self.id)
    #   .group('polls.id')
    #   .having('COALESCE(COUNT(questions.id), 0) != COALESCE(COUNT(responses.id), 0)')
  end
end
