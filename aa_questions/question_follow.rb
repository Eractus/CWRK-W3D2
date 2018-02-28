require 'sqlite3'
require 'singleton'
require 'byebug'
require_relative 'user'
require_relative 'question'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class QuestionFollow
  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_follows
      JOIN users
        ON question_follows.user_id = users.id
      WHERE
        question_follows.question_id = ?
      SQL
    return nil if followers.empty?
    followers.map { |hash| User.new(hash) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        question_follows
      JOIN questions
        ON question_follows.question_id = questions.id
      WHERE
        question_follows.user_id = ?
    SQL
    return nil if questions.empty?
    questions.map { |hash| Question.new(hash) }
  end
end
