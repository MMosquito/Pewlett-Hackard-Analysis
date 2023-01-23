--  Data is from https://github.com/vrajmohan/pgsql-sample-data/tree/master/employee
-- Creating tables for PH-EmployeeDB
CREATE TABLE departments (
  dept_no VARCHAR(4) NOT NULL,
  dept_name VARCHAR(40) NOT NULL,
  PRIMARY KEY (dept_no),
  UNIQUE (dept_name)
);

CREATE TABLE employees (
  emp_no INT NOT NULL,
  birth_date DATE NOT NULL,
  first_name VARCHAR NOT NULL,
  last_name VARCHAR NOT NULL,
  gender VARCHAR NOT NULL,
  hire_date DATE NOT NULL,
  PRIMARY KEY (emp_no)
);

CREATE TABLE dept_manager (
	dept_no VARCHAR(4) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE dept_emp (
	emp_no INT NOT NULL,
	dept_no VARCHAR(4) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE titles (
	emp_no INT NOT NULL,
	title VARCHAR(50) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no, title, from_date)
);

CREATE TABLE salaries (
	emp_no INT NOT NULL,
	salary INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no, from_date)
);

--DELIVERABLE #1: The Number of Retiring Employees by Title
--Create Retirement Titles table
	SELECT employees.emp_no, 
	employees.first_name, 
  	employees.last_name,
	titles.title,
	titles.from_date,
	titles.to_date
	INTO retirement_titles
	FROM employees
	INNER JOIN titles
	ON employees.emp_no = titles.emp_no
	WHERE employees.birth_date BETWEEN '1952-01-01' AND '1955-12-31'
	ORDER BY employees.emp_no;
	
--Use distinct on to retrieve first occurance
	SELECT DISTINCT ON (emp_no) emp_no,
	first_name,
	last_name,
	title
	INTO unique_titles
	FROM retirement_titles
	WHERE to_date = '9999-01-01'
	ORDER BY emp_no, to_date DESC;
	
--Number employees ready to retire by most recent job title
	SELECT COUNT(unique_titles.emp_no),
	(unique_titles.title)
	INTO retiring_titles
	FROM unique_titles
	GROUP BY title
	ORDER BY COUNT(title) DESC;
	
	--DELIVERABLE #2: The Employees Eligible for the Mentorship Program
--Create quesry for Mentorship Eligibility 
	SELECT DISTINCT ON (employees.emp_no) employees.emp_no,
		employees.first_name,
		employees.Last_name,
		employees.birth_date,
		dept_emp.from_date,
		dept_emp.to_date,
		titles.title
	INTO mentorship_eligibility
	FROM employees
	LEFT OUTER JOIN dept_emp
	ON (employees.emp_no = dept_emp.emp_no)
	LEFT OUTER JOIN titles
	ON (employees.emp_no = titles.emp_no)
	WHERE (employees.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
	ORDER BY employees.emp_no ASC;