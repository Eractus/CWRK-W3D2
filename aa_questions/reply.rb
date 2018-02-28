require 'sqlite3'
require 'singleton'
require 'byebug'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Reply
  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

    return nil if reply.empty?

    Reply.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    user = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL

    return nil if user.empty?

    user.map { |hash| Reply.new(hash) }
  end

  def self.find_by_question_id(question_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL

    return nil if reply.empty?

    reply.map { |hash| Reply.new(hash) }
  end


  attr_accessor :body
  attr_reader :id, :top_reply_id, :question_id, :user_id

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @top_reply_id = options['top_reply_id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def author
    reply = QuestionsDatabase.instance.execute(<<-SQL, self.user_id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    return nil if reply.empty?

    User.new(reply.first)
  end

  def question
    question = QuestionsDatabase.instance.execute(<<-SQL, self.question_id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL

    Question.new(question.first)
  end

  def parent_reply
    par_reply = QuestionsDatabase.instance.execute(<<-SQL, self.top_reply_id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

      Reply.new(par_reply.first)

  end

  def child_replies
    c_reply = QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT
        *
      FROM
        replies
      WHERE
        top_reply_id = ?
    SQL

    return nil if c_reply.empty?

    c_reply.map { |hash| Reply.new(hash) }

  end
end
