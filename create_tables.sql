CREATE TABLE questions(
    question_id INT PRIMARY KEY,
    question_content TEXT NOT NULL
);

CREATE TABLE users(
    username VARCHAR(50) PRIMARY KEY
);

CREATE TABLE interviews(
    username VARCHAR(50),
    interview_id INT,
    PRIMARY KEY (username, interview_id)
);

CREATE SEQUENCE interview_id_seq
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE FUNCTION generate_interview_id()
RETURNS TRIGGER AS $$
BEGIN
    NEW.interview_id := nextval('interview_id_seq');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_interview
BEFORE INSERT ON interviews
FOR EACH ROW
EXECUTE FUNCTION generate_interview_id();

CREATE TABLE user_response(
    interview_id INT,
    question_id INT,
    PRIMARY KEY (interview_id, question_id),
    text_response TEXT NOT NULL,
    audio_response TEXT,
    video_response_url TEXT
);

CREATE TABLE analysis_results(
    interview_id INT,
    question_id INT,
    PRIMARY KEY (interview_id, question_id),
    analysis_type VARCHAR(50),
    emotion VARCHAR(50),
    percent REAL,
    CHECK (analysis_type IN ('sentiment', 'speech_emotion', 'facial'))
);

INSERT INTO questions (question_id, question_content) VALUES
    (1, 'What is object-oriented programming (OOP)?'),
    (2, 'What are the pillars of OOP?'),
    (3, 'What is inheritance in OOP?'),
    (4, 'What is polymorphism in OOP?'),
    (5, 'What is encapsulation in OOP?'),
    (6, 'What is a class and object in OOP?'),
    (7, 'What is the difference between method overloading and method overriding?'),
    (8, 'What is a design pattern?'),
    (9, 'What are the different types of design patterns?'),
    (10, 'What is MVC architecture?'),
    (11, 'Explain the difference between process and thread.'),
    (12, 'What is concurrency?'),
    (13, 'What is synchronization?'),
    (14, 'What is deadlock?'),
    (15, 'Explain the concept of multithreading.'),
    (16, 'What is RESTful API?'),
    (17, 'What is the difference between PUT and POST HTTP methods?'),
    (18, 'What is a relational database?'),
    (19, 'What is SQL?'),
    (20, 'What is a primary key?'),
    (21, 'What is a foreign key?'),
    (22, 'What is a JOIN in SQL?'),
    (23, 'What is normalization in databases?'),
    (24, 'What is denormalization in databases?'),
    (25, 'What is an index in databases?'),
    (26, 'What is the difference between SQL and NoSQL databases?'),
    (27, 'What is Git?'),
    (28, 'What is version control?'),
    (29, 'What are the benefits of using Git?'),
    (30, 'What is a merge conflict?'),
    (31, 'Explain the difference between Git rebase and merge.'),
    (32, 'What is Agile methodology?'),
    (33, 'What is Scrum?'),
    (34, 'What are user stories in Agile?'),
    (35, 'What is the difference between waterfall and Agile methodologies?'),
    (36, 'What is a code review?'),
    (37, 'Why is code review important?'),
    (38, 'What is continuous integration (CI)?'),
    (39, 'What is continuous delivery (CD)?'),
    (40, 'Explain the concept of unit testing.'),
    (41, 'What is Test-Driven Development (TDD)?'),
    (42, 'What is a RESTful API endpoint?'),
    (43, 'What is a microservice architecture?'),
    (44, 'What is containerization?'),
    (45, 'What is Docker?'),
    (46, 'What is Kubernetes?'),
    (47, 'What is cloud computing?'),
    (48, 'What is Infrastructure as Code (IaC)?'),
    (49, 'What is serverless computing?'),
    (50, 'What are the principles of the SOLID design principles?');
