/*
**Question: What are the most optimal skills to learn
(aka it’s in high demand and a high-paying skill) for a data analyst?** 

- Identify skills in high demand and associated with high average salaries for Data Analyst roles
- Concentrates on remote positions with specified salaries
- Why? Targets skills that offer job security (high demand)
    and financial benefits (high salaries),
    offering strategic insights for career development in data analysis
*/

-- 1st answer:
-- Using Query 3 & 4 in the solution
WITH top_demanded_skills AS (
    SELECT
        s.skill_id,
        s.skills,
        COUNT(*) AS demand
    FROM skills_dim AS s
    INNER JOIN skills_job_dim AS sj ON s.skill_id = sj.skill_id
    INNER JOIN job_postings_fact AS j ON sj.job_id = j.job_id
    WHERE j.job_title_short = 'Data Analyst'
        AND j.salary_year_avg IS NOT NULL
        AND j.job_work_from_home IS TRUE
    GROUP BY s.skills, s.skill_id
),
top_paying_skills AS (
    SELECT
        sj.skill_id,
        ROUND(AVG(j.salary_year_avg) ,2) AS avg_salary
    FROM skills_job_dim AS sj
    INNER JOIN job_postings_fact AS j ON sj.job_id = j.job_id
    WHERE j.job_title_short = 'Data Analyst'
        AND j.salary_year_avg IS NOT NULL
        AND j.job_work_from_home IS TRUE
    GROUP BY sj.skill_id
)
SELECT
    td.skill_id,
    td.skills,
    td.demand,
    tp.avg_salary
FROM top_demanded_skills AS td
INNER JOIN top_paying_skills AS tp ON td.skill_id = tp.skill_id
WHERE td.demand >= 50
ORDER BY tp.avg_salary DESC
;


-- 2nd answer:
-- In one query, without CTE-s
SELECT
  skills_job_dim.skill_id,
  skills_dim.skills, 
  COUNT(skills_job_dim.job_id) as demand_count,
  ROUND(AVG(job_postings_fact.salary_year_avg),0) AS avg_salary
FROM
  job_postings_fact
  INNER JOIN
    skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
  INNER JOIN
    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
  job_postings_fact.job_title_short = 'Data Analyst'
	AND job_postings_fact.salary_year_avg IS NOT NULL
  AND job_postings_fact.job_work_from_home = True
GROUP BY
  skills_job_dim.skill_id,
  skills_dim.skills
HAVING
	COUNT(skills_job_dim.job_id) > 10
ORDER BY
	avg_salary DESC,
	demand_count DESC
LIMIT 25;