-- DATA TRANSFORMATION / DATA WRANGLING, DATA MANIPULATION & DATA MODELING OF OUR
-- HUMAN RESOURCE TABLE IN MY SQL AND DATA VISUALIZATION
-- IN POWER BI (PROJECT)

CREATE DATABASE project;
USE project;
SELECT * FROM hr;

-- change the primary key column name from ï»¿id 
-- to employee_id

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id
VARCHAR(20) NOT NULL; 
DESCRIBE hr;
SELECT emp_id FROM hr;
SELECT * FROM hr;

-- change the birthdate datatype from text to date
-- change the birthdate format and make them uniform

SET SQL_SAFE_UPDATES = 0;
UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
    END;
DESCRIBE hr;
SELECT birthdate FROM hr;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;
DESCRIBE hr;

-- change the hiredate datatype from text to date
-- change the hiredate format and make them uniform

SELECT * FROM hr;
SELECT hire_date FROM hr;
UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
    END;
SELECT hire_date FROM hr;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;
DESCRIBE hr;

-- creating an age group column because our stakeholders
-- require the ages of the employees in the organization

ALTER TABLE hr
ADD COLUMN age INT;
SELECT age FROM hr;

-- After creating the age column we used time difference
-- date function to get the ages of our employees 

UPDATE hr
SET age = TIMESTAMPDIFF(YEAR, birthdate, CURDATE());
SELECT age FROM hr;
SELECT * FROM hr;

-- we want to know the oldest and youngest employee ages

SELECT 
   MIN(age) AS youngest,
   MAX(age) AS oldest
FROM hr;

-- we observed that we had a negative value as the mininum employee age
-- due to employees filling wrong birth dates
-- we are going to write a query to ignore any negative value and also state it in
-- our reports to stakeholders about the findings so as to ensure data integrity.

SELECT termdate FROM hr;
-- we want to change the blank values in our termination
-- date column from blank to zeros for easy analysis

 SELECT termdate FROM hr;
 UPDATE hr
 SET termdate = '0000-00-00'
 WHERE termdate = '';

-- we want to change the data type of our termination date column
-- from text to date

SET GLOBAL SQL_MODE = '';
ALTER TABLE hr
MODIFY COLUMN termdate DATE;
DESCRIBE hr;

-- QUESTION 1: what is the gender breakdown of employees 
-- in the organisation?
SELECT * FROM hr;
SELECT
   gender,
   COUNT(emp_id) AS total_employees
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY gender;

-- QUESTION 2: what is the race/ethnicity breakdown of employees
-- in the company?
SELECT * FROM hr;
SELECT
   race,
   COUNT(emp_id) AS total_employees
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY total_employees DESC;

-- QUESTION 3: what is the age distribution of employees in the company?
SELECT * FROM hr;
SELECT
   MIN(age),
   MAX(age)
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00';

SELECT
   CASE
   WHEN age >= 20 AND age <= 30 THEN '20-30'
   WHEN age >= 31 AND age <= 40 THEN '31-40'
   WHEN age >= 41 AND age <= 50 THEN '41-50'
   ELSE '57+'
END AS age_group, gender, COUNT(emp_id) AS total_employees
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY age_group, gender
ORDER BY age_group; 

-- QUESTION 4: how many employees work at headquarters versus remote?
SELECT * FROM hr;
SELECT 
   location,
   COUNT(emp_id) AS total_employees
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location;

-- QUESTION 5: what is the average length of employment for employees 
-- who have been terminated?
SELECT termdate FROM hr;
SELECT
   ROUND(AVG(DATEDIFF(termdate, hire_date)/365),1) AS average_employment_span
FROM hr
WHERE age >= 18 AND termdate != '0000-00-00';

-- QUESTION 6: how does the gender distribution 
-- vary across departments and job titles?
SELECT * FROM hr;
SELECT
   gender,
   jobtitle,
   COUNT(emp_id) AS total_employees
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY gender, jobtitle
ORDER BY total_employees DESC;

-- QUESTION 7: what is the distribution of job titles 
-- across the company?
SET GLOBAL SQL_MODE = '';
SELECT * FROM hr;
SELECT 
    jobtitle,
    COUNT(emp_id) AS total_employees
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY total_employees DESC;

-- QUESTION 8: which department has the highest turnover rate?
SELECT * FROM hr;
SELECT
   department,
   total_employees,
   terminated_employment,
   ROUND(terminated_employment/total_employees ,3) AS termination_rate
FROM (
     SELECT
         department,
         COUNT(emp_id) AS total_employees,
         SUM(CASE
         WHEN termdate != '0000-00-00' AND termdate <= CURDATE()
         THEN 1 ELSE 0
         END) AS terminated_employment
       FROM hr
       WHERE age >= 18
       GROUP BY department
       ORDER BY terminated_employment DESC ) AS termination_table;

-- QUESTION 9: what is the distribution of employees across
-- locations by state
SELECT * FROM hr;
SELECT 
    location_state,
    COUNT(emp_id) AS total_employment
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location_state
ORDER BY total_employment DESC;

-- QUESTION 10: how has the company's employee count
-- changed overtime based on hire and term dates?
SELECT * FROM hr;
SELECT
    year,
    hires,
    termination,
    (hires-termination) AS employee_count
FROM (
    SELECT 
        YEAR(hire_date) AS year,
        COUNT(emp_id) AS hires,
        SUM(CASE
        WHEN termdate != '0000-00-00' AND termdate <= CURDATE()
        THEN 1 ELSE 0
        END) AS termination
    FROM hr
    WHERE age >= 18
    GROUP BY YEAR(hire_date) 
    ORDER BY YEAR(hire_date)) AS termination_count_table;

-- QUESTION 11: what is the tenure distribution for each department?
SELECT * FROM hr;
SELECT
    department,
    ROUND(AVG(DATEDIFF(termdate, hire_date) /365),1) AS tenure_distribution
FROM hr
WHERE age >= 18 AND termdate != '0000-00-00' AND termdate <= CURDATE()
GROUP BY department
ORDER BY tenure_distribution DESC;


   
  