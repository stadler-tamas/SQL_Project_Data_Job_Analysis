-- **Question: What are the top-paying data analyst jobs?**

/*
- Identify the top 10 highest-paying Data Analyst roles that are available remotely.
- Focuses on job postings with specified salaries.
- Why? Aims to highlight the top-paying opportunities for Data Analysts, offering insights into employment options and location flexibility.
*/

-- THESE 2 CONDITIONS ARE THE BASICALLY THE SAME, BUT I WILL KEEP BOTH FOR REFERENCE
-- Both are used to filter for remote jobs,
-- but the first one uses a boolean column while the second one checks for a specific location string.
--      job_work_from_home = TRUE
--      job_location = 'Anywhere'


SELECT
    j.job_id,
    j.job_title,
    c.name AS company_name,
    j.job_location,
    j.job_schedule_type,
    j.salary_year_avg,
    j.job_posted_date
FROM job_postings_fact AS j
LEFT JOIN company_dim AS c
    ON j.company_id = c.company_id
WHERE
    j.job_title_short = 'Data Analyst'
    AND j.salary_year_avg IS NOT NULL
    AND j.job_location = 'Anywhere'
ORDER BY
    j.salary_year_avg DESC
LIMIT 10;

