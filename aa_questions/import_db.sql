

DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(20) NOT NULL,
  lname VARCHAR(20) NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(50) NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  top_reply_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (top_reply_id) REFERENCES replies(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  users(fname, lname)
VALUES
  ('Herbert', "Sloth"),
  ('Danny', 'Bighead');

INSERT INTO
  questions(title, body, user_id)
VALUES
  ('Recursion', 'Why does it exist?', (SELECT id FROM users WHERE fname = 'Herbert')),
  ('Bighead', 'Why is my head so big?', (SELECT id FROM users WHERE fname = 'Danny'));

INSERT INTO
  replies(body, top_reply_id, question_id, user_id)
VALUES
  ('blah', 1, 1, 1);

INSERT INTO
  question_follows(user_id, question_id)
VALUES
  (2, 2);
