/*
**Question: What are the top skills based on salary?** 

- Look at the average salary associated with each skill for Data Analyst positions.
- Focuses on roles with specified salaries, regardless of location.
- Why? It reveals how different skills impact salary levels for Data Analysts
 and helps identify the most financially rewarding skills to acquire or improve.
*/

SELECT
    s.skills,
    ROUND(AVG(j.salary_year_avg),2) AS avg_salary
FROM skills_dim AS s
INNER JOIN skills_job_dim AS sj ON s.skill_id = sj.skill_id
INNER JOIN job_postings_fact AS j ON sj.job_id = j.job_id
WHERE
    j.salary_year_avg IS NOT NULL
    AND j.job_title_short = 'Data Analyst'
    AND j.job_work_from_home IS TRUE
GROUP BY s.skills
ORDER BY avg_salary DESC
LIMIT 25;
