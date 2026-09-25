/*
**Question: What are the top-paying data analyst jobs, and what skills are required?** 
- Identify the top 10 highest-paying Data Analyst jobs and the specific skills required for these roles.
- Filters for roles with specified salaries that are remote
- Why?
    It provides a detailed look at which high-paying jobs demand certain skills,
    helping job seekers understand which skills to develop that align with top salaries
*/

-- Top 10 highest-paying Data Analyst jobs with skills required
WITH top_ten_jobs AS (
    SELECT
        j.job_id,
        j.job_title,
        c.name AS company_name,
        j.salary_year_avg
    FROM job_postings_fact AS j
    LEFT JOIN company_dim AS c
        ON j.company_id = c.company_id
    WHERE
        j.job_title_short = 'Data Analyst'
        AND j.salary_year_avg IS NOT NULL
        AND j.job_location = 'Anywhere'
    ORDER BY
        j.salary_year_avg DESC
    LIMIT 10
)
SELECT
    t.*,
    s.skills AS skill_name
FROM top_ten_jobs AS t
INNER JOIN skills_job_dim AS sj
    ON t.job_id = sj.job_id
INNER JOIN skills_dim AS s
    ON sj.skill_id = s.skill_id;


-- Additional analysis:
-- Most frequent skills among the top 10 highest-paying Data Analyst jobs

WITH top_ten_jobs AS (
    SELECT
        j.job_id,
        j.job_title,
        c.name AS company_name,
        j.salary_year_avg
    FROM job_postings_fact AS j
    LEFT JOIN company_dim AS c
        ON j.company_id = c.company_id
    WHERE
        j.job_title_short = 'Data Analyst'
        AND j.salary_year_avg IS NOT NULL
        AND j.job_location = 'Anywhere'
    ORDER BY
        j.salary_year_avg DESC
    LIMIT 10
),
top_paying_skills AS (
    SELECT
        t.job_id,
        s.skills AS skill_name
    FROM top_ten_jobs AS t
    INNER JOIN skills_job_dim AS sj
        ON t.job_id = sj.job_id
    INNER JOIN skills_dim AS s
        ON sj.skill_id = s.skill_id
),
skill_frequency AS (
    SELECT
        skill_name,
        COUNT(*) AS frequency
    FROM top_paying_skills
    GROUP BY
        skill_name
)
SELECT
    skill_name,
    frequency
FROM (
    SELECT
        skill_name,
        frequency,
        MAX(frequency) OVER () AS max_frequency
    FROM skill_frequency
)
WHERE frequency >= FLOOR(max_frequency / 2) - 1
ORDER BY frequency DESC;