--creating dataabse and table

drop table if exists project_hr ;

CREATE TABLE project_hr (
    id text PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    birthdate DATE,
    gender TEXT,
    race TEXT,
    department TEXT,
    jobtitle TEXT,
    location TEXT,
    hire_date DATE,
    termdate DATE,
    location_city TEXT,
    location_state TEXT
);

-- importing csv file 

select * from project_hr;

COPY project_hr (id, first_name, last_name, birthdate, gender, race, department,
                 jobtitle, location, hire_date, termdate, location_city, location_state)
FROM 'C:\Program Files\PostgreSQL\17\Human Resources.csv'
DELIMITER ',' 
CSV 
HEADER;

-- data cleanding and preprocessing

ALTER TABLE project_hr
RENAME COLUMN id TO emp_id;

ALTER TABLE project_hr
ALTER COLUMN emp_id TYPE VARCHAR(20);

-- creating age coloum

ALTER TABLE project_hr
ADD COLUMN age INT;

UPDATE project_hr
SET age = DATE_PART('year', AGE(CURRENT_DATE, birthdate));

select min (age), max (age) from project_hr;

-- (1)gender count brakedown 

select gender , count (*) as gender_count
from project_hr
where termdate is null
group by gender ;

-- (2)race count brakedown 

select race , count (*) as race_count
from project_hr 
where termdate is null
group by race ;

-- (3) age distribution on empleyees

SELECT age_group, count
FROM (
    SELECT 
        CASE
            WHEN age BETWEEN 18 AND 24 THEN '18-24'
            WHEN age BETWEEN 25 AND 34 THEN '25-34'
            WHEN age BETWEEN 35 AND 44 THEN '35-44'
            WHEN age BETWEEN 45 AND 54 THEN '45-54'
            WHEN age BETWEEN 55 AND 64 THEN '55-64'
            ELSE '65+'
        END AS age_group,
        COUNT(*) AS count
    FROM project_hr
    WHERE termdate IS NULL
    GROUP BY age_group
) AS grouped
ORDER BY age_group;

--(4) counting HQ vs remote employee

select location , count(*) as count
from project_hr 
where termdate is null 
group by location ;

--(5) average length of empleyeee who has been terminatied

SELECT ROUND(AVG(EXTRACT(YEAR FROM termdate) - EXTRACT(YEAR FROM hire_date)), 0) AS length_of_emp
FROM project_hr
WHERE termdate IS NOT NULL AND termdate <= CURRENT_DATE;

-- (6) gender distribution accroding to gender and job titles

select department,jobtitle ,gender,count(*) as count 
from project_hr
group by department,jobtitle,gender
order by department,jobtitle,gender;

-- (7) what is the distribution of job titles

select jobtitle , count (*) as count 
from project_hr 
where termdate is null 
group by jobtitle;

--(8) ternover rate department wise

SELECT department,
       COUNT(*) AS total_count,
       COUNT(CASE
                WHEN termdate IS NOT NULL AND termdate <= CURRENT_DATE THEN 1 
            END) AS terminated_count,
       ROUND(
           (COUNT(CASE
                     WHEN termdate IS NOT NULL AND termdate <= CURRENT_DATE THEN 1 
                  END)::decimal / COUNT(*) * 100), 
           2
       ) AS termination_rate
FROM project_hr
GROUP BY department
ORDER BY termination_rate DESC;

-- (9) Distribution of empleyee across location_state and location_city 

select location_state , count (*)
from project_hr 
where termdate is null
group by location_state;

select location_city , count (*)
from project_hr 
where termdate is null
group by location_city;

-- (10)  employee count changed over time based on hire and termination date.

SELECT year,
       hires,
       terminations,
       hires - terminations AS net_change,
       ROUND((terminations::decimal / NULLIF(hires, 0)) * 100, 2) AS change_percent
FROM (
    SELECT EXTRACT(YEAR FROM hire_date)::int AS year,
           COUNT(*) AS hires,
           COUNT(CASE 
                     WHEN termdate IS NOT NULL AND termdate <= CURRENT_DATE THEN 1 
                 END) AS terminations
    FROM project_hr
    GROUP BY EXTRACT(YEAR FROM hire_date)
) AS subquery
ORDER BY year;

--(11) average tenure of employee in each department

SELECT department, 
       ROUND(AVG((termdate - hire_date) / 365.0), 0) AS avg_tenure
FROM project_hr
WHERE termdate IS NOT NULL AND termdate <= CURRENT_DATE
GROUP BY department;


--(12) gender wise termination rate 

SELECT 
    gender,
    COUNT(*) AS total_hires,
    COUNT(termdate) AS total_terminations,
    ROUND(COUNT(termdate) * 100.0 / COUNT(*), 2) AS termination_rate
FROM 
    project_hr
GROUP BY 
    gender;

--(13) race wise termination rate

SELECT 
    race,
    COUNT(*) AS total_hires,
    COUNT(termdate) AS total_terminations,
    ROUND(COUNT(termdate) * 100.0 / COUNT(*), 2) AS termination_rate
FROM 
    project_hr
GROUP BY 
    race;

--(14) department wise termination rate 

SELECT 
    department,
    COUNT(*) AS total_hires,
    COUNT(termdate) AS total_terminations,
    ROUND(COUNT(termdate) * 100.0 / COUNT(*), 2) AS termination_rate
FROM 
    project_hr
GROUP BY 
    department;

--(15) age wise termination rate 

SELECT 
    age,
    COUNT(*) AS total_hires,
    COUNT(termdate) AS total_terminations,
    ROUND(COUNT(termdate) * 100.0 / COUNT(*), 2) AS termination_rate
FROM 
    project_hr
GROUP BY 
    age;




