/* Clean Up */
DROP VIEW IF EXISTS student,
  q1, q2, q3, q4, q5, q6, q7, q8, q9, q10;


/*
  Student View
    Please replace:
      - 'A0000000X' with your Matric number
      - 'e0000000'  with your NUSNET id
*/
CREATE OR REPLACE VIEW student(student_id, nusnet_id) AS
 SELECT 'A0245643A', 'e0902049'
;



/*
  Q1
  Your task for this question is, for each degree, find the number of required courses to graduate with the degree.  Limit it to only courses that requires at most 3 courses.
*/
CREATE OR REPLACE VIEW q1 (code,count) AS
SELECT DISTINCT D.title, COUNT(R.code)
FROM Degree D LEFT JOIN Requires R
ON D.title = R.title
GROUP BY D.title
HAVING COUNT(R.code) <= 3
;



/*
  Q2
  Your task for this question is to find all course codes that is offered in semester 2 (i.e., the sem is equal to 2) by the Mathematics department or offered in semester 1 by the Computer Science department.
*/
CREATE OR REPLACE VIEW q2 (code) AS
SELECT DISTINCT code
FROM Offers
WHERE (name = 'Mathematics' AND sem = 2)
OR (name = 'Computer Science' AND sem = 1)
;



/*
  Q3
  Find all undergraduate degree title and name that is conferred by the School of Computing.  A degree is an undergraduate degree when the value of kind is 'Undergrad'.
*/
CREATE OR REPLACE VIEW q3 (title,name) AS
SELECT DISTINCT title, name
FROM Degree NATURAL JOIN Confers
WHERE code = 'SOC'
AND kind = 'Undergrad'
;



/*
  Q4
  Find all department names that is not part of any faculties.  Note that you only need the department names, you do not need to find the courses they offer.
*/
CREATE OR REPLACE VIEW q4 (name) AS
SELECT DISTINCT D.name
FROM Departments D LEFT JOIN Has H
ON D.name = H.name
WHERE H.name IS NULL
;



/*
  Q5
  Find all courses (i.e., the code, name, and mc) for courses with 'Database' in its name.  It can be in the beginning, the end, or the middle.  You are only interested in cases where the name contains exactly the phrase 'Database' with the initial character D in uppercase.
*/
CREATE OR REPLACE VIEW q5 (code, name, mc) AS
SELECT DISTINCT code, name, mc
FROM Courses
WHERE name LIKE '%Database%'
;



/*
  Q6
  Find all pair of degree name (not title) and faculty names that is conferred by more than 1 faculties.
*/
CREATE OR REPLACE VIEW q6 (degree,faculty) AS
SELECT DISTINCT D.name, F.name
FROM Degree D NATURAL JOIN Confers S 
JOIN Faculties F ON S.code = F.code
WHERE S.title IN (
SELECT title
FROM Confers
GROUP BY title
HAVING COUNT(code) > 1)
;



/*
  Q7
  For each department, find the sum of all MC but only for distinct courses offered by the department in at least one semester.  So, if a department offers the course in two different semesters then you should not count it twice.  If a department is not even offering the course but it is listed as a valid course, you should not even count that course.
  
  Include departments that do not offer any courses.  For these departments, the total MC should be listed as 0.
*/
CREATE OR REPLACE VIEW q7 (name, total) AS
WITH CourseWithDepartment (code, name) AS (
SELECT DISTINCT code, name
FROM Offers
)
SELECT DISTINCT CD.name, SUM(C.mc)
FROM CourseWithDepartment CD JOIN Courses C
ON CD.code = C.code
GROUP BY CD.name
UNION
SELECT DISTINCT name, 0
FROM Departments
WHERE name NOT IN (
SELECT name
FROM Offers)
;



/*
  Q8
  For each faculty code (e.g, SOC), find the number of distinct course codes that is offered only by that faculty.  This quickly excludes courses offered by departments that is in more than one faculties such as Computer Science.

  However, this includes courses that may be offered by two different departments as long as the two departments are in the same faculty.  For instance, the course PC333 Statistical Physics is offered by both Physics department and Statistics department.  But because both are in SCI, it should be part of the 14 other courses offered exclusively by SCI.
*/
CREATE OR REPLACE VIEW q8 (faculty, count) AS
WITH CourseWithFaculty (fcode, ccode) AS (
SELECT DISTINCT H.code, O.code
FROM Has H JOIN Offers O
ON H.name = O.name
)
SELECT DISTINCT CF1.fcode, COUNT(CF1.ccode)
FROM CourseWithFaculty CF1
WHERE CF1.ccode NOT IN (
SELECT CF2.ccode
FROM CourseWithFaculty CF2
WHERE CF1.fcode <> CF2.fcode)
GROUP BY CF1.fcode
;



/*
  Q9
  Find all courses code and name that is offered (can be in any semester as long as it is offered) by all known departments that offers at least one course.  In other words, ignore departments that do not offer any courses.
*/
CREATE OR REPLACE VIEW q9 (code, name) AS
WITH CourseWithDepartment (code, count) AS (
SELECT DISTINCT code, COUNT(DISTINCT name)
FROM Offers
GROUP BY code
)
SELECT DISTINCT code, name
FROM Courses NATURAL JOIN CourseWithDepartment
WHERE count = (
SELECT COUNT(DISTINCT name)
FROM Offers
)
;



/*
  Q10
  As a graduation requirement, students need to take all the required courses for the degree.  Of course, to take the course, they also need to have taken the prerequisite (i.e., prereq).  Find all course code that a student need to take to graduate with a BComp.  Note, it is BComp and not BComp (Sec).
*/
CREATE OR REPLACE VIEW q10 (code) AS
WITH RECURSIVE Premod (pre) AS (
SELECT DISTINCT code
FROM Requires
WHERE title = 'BComp'
UNION
SELECT DISTINCT R.pre
FROM Premod P, Prereq R
WHERE P.pre = R.post
)
SELECT DISTINCT pre
FROM Premod
;

