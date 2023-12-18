DROP TABLE IF EXISTS
  Confers, Prereq, Requires, Offers, Courses, Degree, Has, Departments, Faculties
  CASCADE;

CREATE TABLE Faculties (
  code  VARCHAR(4) PRIMARY KEY,
  name  VARCHAR(50) NOT NULL
);

CREATE TABLE Departments (
  name    VARCHAR(50) PRIMARY KEY,
  address VARCHAR(50)
);

CREATE TABLE Has (
  code  VARCHAR(4) REFERENCES Faculties,
  name  VARCHAR(50) REFERENCES Departments,
  PRIMARY KEY (code, name)
);

CREATE TABLE Degree (
  title VARCHAR(15) PRIMARY KEY,
  name  VARCHAR(50) NOT NULL,
  kind  VARCHAR(10) NOT NULL
);

CREATE TABLE Courses (
  code  VARCHAR(5) PRIMARY KEY,
  name  VARCHAR(50) NOT NULL,
  mc    INT NOT NULL CHECK (mc > 0)
);

CREATE TABLE Offers (
  code  VARCHAR(5) REFERENCES Courses,
  name  VARCHAR(50) REFERENCES Departments,
  sem   INT NOT NULL,
  PRIMARY KEY (code, name, sem)
);

CREATE TABLE Prereq (
  pre   VARCHAR(5) REFERENCES Courses,
  post  VARCHAR(5) REFERENCES Courses,
  PRIMARY KEY (pre, post)
);

CREATE TABLE Requires (
  title VARCHAR(15) REFERENCES Degree,
  code  VARCHAR(5) REFERENCES Courses,
  PRIMARY KEY (title, code)
);

CREATE TABLE Confers (
  title VARCHAR(15) REFERENCES Degree,
  code  VARCHAR(4) REFERENCES Faculties,
  PRIMARY KEY (title, code)
);

