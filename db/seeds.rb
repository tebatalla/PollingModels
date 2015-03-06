# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.destroy_all
Poll.destroy_all
AnswerChoice.destroy_all
Question.destroy_all
Response.destroy_all

user = User.create(user_name: "blah")
user2 = User.create(user_name: "AlbertEinstein")
ned = User.create(user_name: "Ned")
andrew = User.create(user_name: 'Andrew')
poll = Poll.create(title: 'New Poll', author: user)
question = Question.create(text: "What is the meaning of life?", poll: poll)
question2 = Question.create(text: "What time is it?", poll: poll)
answer_choice = AnswerChoice.create(text: "There is none", question: question)
answer_choice2 = AnswerChoice.create(text: "Who cares, enjoy it", question: question)
answer_choice3 = AnswerChoice.create(text: "3:46 PM", question: question2)
response = Response.create(respondent: user2, answer_choice: answer_choice)
response2 = Response.create(respondent: ned, answer_choice: answer_choice)
response3 = Response.create(respondent: andrew, answer_choice: answer_choice2)
Response.create(respondent: andrew, answer_choice: answer_choice3)
