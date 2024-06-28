CREATE TABLE Departments
(
Name varchar(20) NOT NULL,
ID char(5) PRIMARY KEY,
Budget numeric(12,2),
Category varchar(15) Check (Category in ('Engineering' , 'Science'))
);

CREATE TABLE Teachers
(
FirstName varchar(20) NOT NULL,
LastName varchar(30) NOT NULL,
ID char(7),
BirthYear int,
DepartmentID char(5),
Salary numeric(7,2) Default 10000.00,
PRIMARY KEY (ID),
FOREIGN KEY (DepartmentID) REFERENCES Departments(ID),
);

CREATE TABLE Students
(
FirstName varchar(20) NOT NULL,
LastName varchar(30) NOT NULL,
StudentNumber char(7) PRIMARY KEY,
BirthYear int,
DepartmentID char(5),
AdvisorID char(7),
FOREIGN KEY (DepartmentID) REFERENCES Departments(ID),
FOREIGN KEY (AdvisorID) REFERENCES Teachers(ID)
);

ALTER TABLE Students
ADD passed int

CREATE TABLE Courses
(
ID char(5) PRIMARY KEY,
Title char(30) NOT NULL,
Credits int NOT NULL,
DepartmentID char(5),
FOREIGN KEY (DepartmentID) REFERENCES Departments(ID),
);

CREATE TABLE Available_Courses
(
CourseID char(5) NOT NULL,
Semester varchar(6) Check (Semester in ('spring' , 'fall')),
year int,
ID char(5) PRIMARY KEY,
TeacherID char(7),
FOREIGN KEY (TeacherID) REFERENCES Teachers(ID),
FOREIGN KEY (CourseID) REFERENCES Courses(ID)
);

CREATE TABLE Taken_Courses
(
StudentID char(7) NOT NULL,
CourseID char(5) NOT NULL,
Semester varchar(6) Check (Semester in ('spring' , 'fall')),
year int,
Grade int,
PRIMARY KEY(StudentID , CourseID, Semester, year),
FOREIGN KEY (StudentID) REFERENCES Students(StudentNumber),
FOREIGN KEY (CourseID) REFERENCES Courses(ID),
);

CREATE TABLE Prerequisites
(
CourseID char(5) NOT NULL,
PrereqID char(5) NOT NULL,
PRIMARY KEY(CourseID , PrereqID),
FOREIGN KEY (CourseID) REFERENCES Courses(ID),
FOREIGN KEY (PrereqID) REFERENCES Courses(ID),
);

INSERT INTO Departments(Name , ID, Budget , Category) VALUES ('cE' , 1 , 200 , 'Engineering')
INSERT INTO Departments(Name , ID, Budget , Category) VALUES ('cE1' , 2 , 300 , 'Science')
INSERT INTO Departments(Name , ID, Budget , Category) VALUES ('cE2' , 3 , 600 , 'Science')

INSERT INTO Teachers(FirstName , LastName, ID , BirthYear , DepartmentID , Salary) VALUES ('sara' ,'soltani' , 1 , 1300 , 1 , 200)
INSERT INTO Teachers(FirstName , LastName, ID , BirthYear , DepartmentID , Salary) VALUES ('sara1' ,'soltani1' , 2 , 1301 , 2 , 300)
INSERT INTO Teachers(FirstName , LastName, ID , BirthYear , DepartmentID , Salary) VALUES ('sara2' ,'soltani2' , 3 , 1302 , 3 , 400)

INSERT INTO Students(FirstName , LastName, StudentNumber , BirthYear , DepartmentID , AdvisorID) VALUES ('sara3' ,'soltani3' , 1 , 1302 , 1 , 1)
INSERT INTO Students(FirstName , LastName, StudentNumber , BirthYear , DepartmentID , AdvisorID) VALUES ('sara4' ,'soltani4' , 2 , 1302 , 2 , 2)
INSERT INTO Students(FirstName , LastName, StudentNumber , BirthYear , DepartmentID , AdvisorID) VALUES ('sara5' ,'soltani5' , 3 , 1302 , 3 , 3)

INSERT INTO Courses(ID , Title, Credits , DepartmentID) VALUES (1 , 'DB' ,3 , 1)
INSERT INTO Courses(ID , Title, Credits , DepartmentID) VALUES (2 , 'DS' ,3 , 2)
INSERT INTO Courses(ID , Title, Credits , DepartmentID) VALUES (3 , 'AL' , 4 , 3)

INSERT INTO Available_Courses(CourseID , Semester, year , ID , TeacherID) VALUES (1 , 'spring' , 1302 , 1 , 1)
INSERT INTO Available_Courses(CourseID , Semester, year , ID , TeacherID) VALUES (2 , 'fall' , 1302 , 2 , 2)
INSERT INTO Available_Courses(CourseID , Semester, year , ID , TeacherID) VALUES (3 , 'spring' , 1302 , 3 , 3)

ALTER TABLE Taken_Courses
ADD CONSTRAINT CHK_taken CHECK (Grade>=0 AND Grade<=20);

INSERT INTO Taken_Courses(StudentID , CourseID , Semester, year , Grade) VALUES (1 , 1 , 'spring' , 1302 , 19)
INSERT INTO Taken_Courses(StudentID , CourseID , Semester, year , Grade) VALUES (2 , 2 , 'fall' , 1302 , 20)
INSERT INTO Taken_Courses(StudentID , CourseID , Semester, year , Grade) VALUES (3 , 3 , 'spring' , 1303 , 17)

INSERT INTO Prerequisites(CourseID , PrereqID) VALUES (1 , 2)
INSERT INTO Prerequisites(CourseID , PrereqID) VALUES (1 , 3)
INSERT INTO Prerequisites(CourseID , PrereqID) VALUES (2 , 3)

SELECT Departments.* FROM Departments , Students
	WHERE Students.StudentNumber=1 AND Departments.ID=Students.DepartmentID

UPDATE Taken_Courses
SET Grade = Grade + 1
WHERE Taken_Courses.Grade < 20

SELECT * FROM Students
	WHERE Students.StudentNumber NOT IN (SELECT StudentID FROM Taken_Courses WHERE Taken_Courses.CourseID=1)


SELECT * FROM Students LEFT JOIN Taken_Courses ON
(Students.StudentNumber=Taken_Courses.StudentID)
WHERE Taken_Courses.CourseID<>1