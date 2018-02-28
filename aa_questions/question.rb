require 'sqlite3'
require 'singleton'
require 'byebug'
require_relative 'reply'
require_relative 'question_follow'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Question
  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL

    return nil if question.empty?

    Question.new(question.first)
  end

  def self.find_by_author_id(user_id)
    question_by_auth = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL

    return nil if question_by_auth.empty?

    question_by_auth.map { |hash| Question.new(hash) }
  end

  attr_accessor :title, :body
  attr_reader :id, :user_id

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def author
    author = QuestionsDatabase.instance.execute(<<-SQL, self.user_id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    return nil if author.empty?
    User.new(author.first)
  end

  def replies
    # q_replies = QuestionsDatabase.instance.execute(<<-SQL, self.id)
    #   SELECT
    #     *
    #   FROM
    #     replies
    #   WHERE
    #     question_id = ?
    # SQL
    #
    # return nil if q_replies.empty?
    #
    # q_replies.map { |hash| Reply.new(hash) }
    Reply.find_by_question_id(self.id)
  end

  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end
end
