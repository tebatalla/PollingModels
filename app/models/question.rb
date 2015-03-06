# == Schema Information
#
# Table name: questions
#
#  id         :integer          not null, primary key
#  text       :text
#  poll_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Question < ActiveRecord::Base
  validates :text, presence: true
  validates :poll_id, presence: true
  belongs_to(
    :poll,
    foreign_key: :poll_id,
    primary_key: :id,
    class_name: 'Poll'
  )

  has_many(
    :answer_choices,
    class_name: 'AnswerChoice',
    foreign_key: :question_id,
    primary_key: :id
  )

  has_many :responses, through: :answer_choices, source: :responses

  # N+1 queries
  # def results
  #   results = {}
  #   self.answer_choices.each do |choice|
  #     results[choice.text] = choice.responses.count
  #   end
  #   results
  # end

  # def results
  #   results = {}
  #   self.answer_choices.includes(:responses).each do |choice|
  #     results[choice.text] = choice.responses.length
  #   end
  #   results
  # end

  # using SQL query
  # def results
  #   data = AnswerChoice.find_by_sql([<<-SQL, self.id])
  #     SELECT
  #       answer_choices.*,
  #       COALESCE(COUNT(responses.*), 0) AS response_count
  #     FROM
  #       answer_choices
  #     LEFT OUTER JOIN
  #       responses ON responses.answer_choice_id = answer_choices.id
  #     WHERE
  #       answer_choices.question_id = ?
  #     GROUP BY
  #       answer_choices.id
  #   SQL
  #   results = {}
  #   data.each do |choice|
  #     results[choice.text] = choice.response_count
  #   end
  #   results
  # end

  def results
    data = self.answer_choices
      .joins('LEFT OUTER JOIN responses
      ON responses.answer_choice_id = answer_choices.id')
      .select('answer_choices.*,
      COALESCE(COUNT(responses.*), 0) AS response_count')
      .group('answer_choices.id')
      .where(question_id: self.id)
    p data
    results = {}
    data.each do |choice|
      results[choice.text] = choice.response_count
    end
    results
  end


end
