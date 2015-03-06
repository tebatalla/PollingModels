# == Schema Information
#
# Table name: responses
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  answer_choice_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class Response < ActiveRecord::Base
  validates :user_id, presence: true
  validates :answer_choice_id, presence: true
  validate :respondent_has_not_already_answered_question
  validate :author_cant_respond_to_own_poll

  belongs_to(
    :answer_choice,
    class_name: 'AnswerChoice',
    foreign_key: :answer_choice_id,
    primary_key: :id
  )

  belongs_to(
    :respondent,
    class_name: 'User',
    foreign_key: :user_id,
    primary_key: :id
  )

  has_one :question, through: :answer_choice, source: :question

  has_one :poll, through: :answer_choice, source: :poll

  def sibling_responses
    question.responses.where('responses.id != :id OR :id IS NULL', id: self.id)
  end

  private

  def respondent_has_not_already_answered_question
    if self.sibling_responses.exists?(user_id: self.user_id)
      errors[:responded] << "This user has already responded to this question."
    end
  end

  def author_cant_respond_to_own_poll
    if poll.author.id == respondent.id
      errors[:creator] << "Cannot respond to poll authored by self."
    end
  end
end
