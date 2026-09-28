# Introducton

I was diving into the data job market, focusing on the data analyst roles. This project explores the
* top-paying jobs,
* in-demand skills,
* skills with both high salary and high demand

in the world of data analytics.
You will find the SQL queries here: [project_sql folder](/project_sql/)


# Background

As I was aiming to navigate the data analyst job market, and have a better understanding of the skills required in this field, I used the dataset provided by Luke Barousse to search for the optimal jobs for a junior data analyst and honing my skills in SQL along the way.

The five questions this project was concentrating on are:
1. What are the top-paying jobs for data analysts?
2. What skill are required for these top-paying jobs?
3. What skills are the most demanded for data analysts?
4. Which skills are relevant at the jobs with higher salaries?
5. What are the most optimal skills to learn?

# Tools I Used

The tools I used to perform the analysis were:
- **SQL** (Structured Query Language): for interacting with the database and to answer the five questions through SQL queries,
- **PostreSQL**: the database managment system I was working with,
- **Visual Studio Code**: the open source code editor to execute the SQL queries on the database.

# The Analysis

Five queries were made for answering the five questions I was aimig to address.

In each of them I not only tried to concentrate on giving an answer, but also to use the skills I learned in a meaningful but also an effective way.

## 1. Top Paying Data Analyst Jobs

In order to determine the top 10 Data Analyst jobs, I filtered the fact table by the job title (Data Analyst), the average yearly salary and by the job location focusing only on remote jobs available.

```sql
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
```

## 2. Skills for Top Paying Jobs

Using the information I received in the first query, I joined the job information we gathered with the skill table to determine and show the skills that are required for each of the top paying jobs.

```sql
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
```

Additionally I made an extra query to calculate the frequency of the skills among these top 10 jobs to showcase only the most demanded skills in these cases.

```sql
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
```

## 3. In-Demand Skills for Data Analysts in General

For a broader perspective I made a very similar analysis to the previous one, but focusing on all the remote Data Analyst jobs instead of only the top-paying ten alternatives.

```sql
SELECT
  skills_dim.skills,
  COUNT(skills_job_dim.job_id) AS demand_count
FROM
  job_postings_fact
  INNER JOIN
    skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
  INNER JOIN
    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
  job_postings_fact.job_title_short = 'Data Analyst'
GROUP BY
  skills_dim.skills
ORDER BY
  demand_count DESC
LIMIT 5;
```

## 4. Skills Based on Salary

For each skill in our database I determined the avarage salary of the jobs associated with those skills. Showing the top 25 list of the most valuable skills gives us a useful information about the real value of them in the job market.

```sql
SELECT
    s.skills,
    ROUND(AVG(j.salary_year_avg),2) AS avg_salary
FROM skills_dim AS s
INNER JOIN skills_job_dim AS sj ON s.skill_id = sj.skill_id
INNER JOIN job_postings_fact AS j ON sj.job_id = j.job_id
WHERE
    j.salary_year_avg IS NOT NULL
    AND j.job_title_short = 'Data Analyst'
GROUP BY s.skills
ORDER BY avg_salary DESC
LIMIT 25;
```

## 5. Most Optimal Skills to Learn

The most optimal skills to learn have to
* be in **high demand**
* and have **high salary** assoiciated to them.

Therefore I combined the frequency of the demanded skills and the avarage salary values for them into one query to have a result set, that can help to decide which skills are ideal focusing on developing in the future.
I filtered out the skills with low demand and ordered the results by the avarege salary values to show the more valuable ones.
(In the source file I also made a second version of the query without CTE-s to optimize a bit while also being less strict in filtering out the least demanded skills.)

```sql
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
```

# What I Learned

With the implementation the project I managed honing my skills in SQL techniques and skills like:
* **Complex Query Construction**:
Building advanced SQL queries joining multiple tables and using Common Table Expressions (CTE-s).
* **Data Aggregation**: Grouping data with GROUP BY, calculating result with window functions, using aggregate functions like COUNT(), AVG() and MAX() to summarize data effectively.
* **Analytical Thinking**: Developing the ability of translating real world problems into questions and answering them building SQL queries to get some insights.  

# Insights

The general insights I learned from the queries I made are:

1. **Top Paying Data Analyst Jobs**: Looking at the Data Analyst jobs that also offer remote work opportunity, the yearly salaries are spreading in a wide range, from $184,000 to $650,000.
2. **Skills for Top Paying Jobs**: Among the best paid jobs the most required skill is still SQL (proving to be an invaluable skill to have in Data Analysis), followed by Python and Tableau.
3. **In-Demand Skills for Data Analysts in General**: In broader spectrum, when we look at all the jobs without concentrating on the best salaries, the top 5 most demanded skills are:
SQL (being the most demanded by a far margin), Excel, Python, Tableau and Power BI.
4. **Skills Based on Salary**: To reach the highest average salaries one must have very specialized skills (such as SVN and Solidity).  
5. **Most Optimal Skills to Learn**: SQL is still the most demanded skill in Data Analysis, also having high salaries associeted to it. Python and R programming is also very valuable both in demand and in wages.

# Conclusions

This project was not only good for honing my skills in SQL but also provided me valuable insights to the data job market, and helped me to determine which skills are the most required to have as a Junior Data Analyst. It also helped to determine the knowledge I can already build on and to pinpoint the goals yet to achieve in short and middle term. 

