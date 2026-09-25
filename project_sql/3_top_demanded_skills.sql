/*
**Question: What are the most in-demand skills for data analysts?**

- Identify the top 5 in-demand skills for a data analyst.
- Focus on all job postings.
- Why? Retrieves the top 5 skills with the highest demand in the job market,
    providing insights into the most valuable skills for job seekers.
*/


SELECT
    s.skill_id,
    skills,
    COUNT(*) AS skill_count
FROM job_postings_fact AS j
INNER JOIN skills_job_dim AS sj ON j.job_id = sj.job_id
INNER JOIN skills_dim AS s ON sj.skill_id = s.skill_id
WHERE j.job_title_short = 'Data Analyst'
    AND j.job_work_from_home IS TRUE
GROUP BY s.skill_id, s.skills
ORDER BY skill_count DESC
LIMIT 5;
