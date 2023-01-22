--Creating tables for PH-EmployeeDB

CREATE TABLE departments (
     dept_no VARCHAR NOT NULL,
     dept_name VARCHAR(40) NOT NULL,
     PRIMARY KEY (dept_no),
     UNIQUE (dept_name)
);

CREATE TABLE employees (
	 emp_no VARCHAR NOT NULL,
     birth_date DATE NOT NULL,
     first_name VARCHAR NOT NULL,
     last_name VARCHAR NOT NULL,
     gender VARCHAR NOT NULL,
     hire_date DATE NOT NULL,
     PRIMARY KEY (emp_no)
);

CREATE TABLE dept_manager (
dept_no VARCHAR NOT NULL,
    emp_no VARCHAR NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
    PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE salaries (
  emp_no VARCHAR NOT NULL,
  salary INT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  PRIMARY KEY (emp_no)
);

CREATE TABLE titles (
	emp_no VARCHAR NOT NULL,
	title VARCHAR NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	PRIMARY KEY (emp_no),
	UNIQUE (title)
);

CREATE TABLE dept_emp (
	emp_no VARCHAR NOT NULL,
	dept_no VARCHAR NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	PRIMARY KEY (dept_no)
);

-- List employees begin to retire
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

--List birthdates from 1952
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01'AND '1952-12-31';

--List birthdates from 1953
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1953-01-01'AND '1953-12-31';

--List birthdates from 1954
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1954-01-01'AND '1954-12-31';

--List birthdates from 1955
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1955-01-01'AND '1955-12-31';

--Number of employees retiring
SELECT COUNT (first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
	
--List retirement-eligible employees	
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
	
SELECT * FROM retirement_info;	
	
DROP TABLE retirement_info;

-- Create new table for retiring employees
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Check the table
SELECT * FROM retirement_info;

-- Joining departments and dept_manager tables
SELECT retirement_info.emp_no,
    retirement_info.first_name,
retirement_info.last_name,
    dept_emp.to_date
FROM retirement_info
LEFT JOIN dept_emp
ON retirement_info.emp_no = dept_emp.emp_no;

--Update joining departments and dept_manager tables to use nicknames
SELECT ri.emp_no,
    ri.first_name,
ri.last_name,
    de.to_date
FROM retirement_info
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no;

SELECT d.dept_name,
     dm.emp_no,
     dm.from_date,
     dm.to_date
FROM departments as d
INNER JOIN dept_manager as dm
ON d.dept_no = dm.dept_no;

--Only current employees eligible for retirement
SELECT ri.emp_no,
    ri.first_name,
    ri.last_name,
de.to_date
INTO current_emp
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');

-- Employee count by department number
SELECT COUNT(ce.emp_no), de.dept_no
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;

--Create table employee count by department number
	SELECT COUNT(ce.emp_no), de.dept_no
	INTO employee_count
	FROM current_emp as ce
	LEFT JOIN dept_emp as de
	ON ce.emp_no = de.emp_no
	GROUP BY de.dept_no
	ORDER BY de.dept_no;

SELECT * FROM employee_count;

SELECT * FROM salaries
ORDER BY to_date DESC;

--Create temporary emp_info table
SELECT emp_no, first_name, last_name, gender
INTO emp_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

--List 1: Employee Information 
SELECT e.emp_no, e.first_name, e.last_name,
    e.gender, s.salary, de.to_date
INTO emp_info
FROM employees as e
INNER JOIN salaries as s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
     AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (de.to_date = '9999-01-01');

--List 2: Management Information 
SELECT  dm.dept_no,
        d.dept_name,
        dm.emp_no,
        ce.last_name,
        ce.first_name,
        dm.from_date,
        dm.to_date
INTO manager_info
FROM dept_manager AS dm
    INNER JOIN departments AS d
        ON (dm.dept_no = d.dept_no)
    INNER JOIN current_emp AS ce
        ON (dm.emp_no = ce.emp_no);
		
--List 3: Department Retirees
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
INTO dept_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no);

--Sales Team eligible retirees
SELECT retirement_info.*,
dept_info.dept_name
INTO sales_team
FROM retirement_info 
FULL JOIN dept_info
ON retirement_info.emp_no = dept_info.emp_no
WHERE dept_info.dept_name = ('Sales');

SELECT * FROM sales_team

SELECT * FROM dept_info

--Sales & Development Teams eligible retirees
SELECT retirement_info.*,
dept_info.dept_name
INTO sandd_teams
FROM retirement_info 
FULL JOIN dept_info
ON retirement_info.emp_no = dept_info.emp_no
WHERE dept_info.dept_name IN ('Sales', 'Development'); 





