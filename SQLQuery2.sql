create database hr_data
use hr_data

select * from hr_data


select termdate from hr_data order by termdate desc

update hr_data set termdate = FORMAT(CONVERT(datetime,left(termdate,19),120),'yyyy-mm-dd')

select distinct termdate from hr_data

alter table hr_data add new_termdate date;

update hr_data set new_termdate = case when termdate is not null and isdate(termdate)=1 then cast(termdate as datetime) else null end ;

select new_termdate from hr_data order by new_termdate desc


alter table hr_data add age  nvarchar(50)

update hr_data set age = DATEDIFF(year,birthdate,getdate())

select age from hr_data


--What's the age distribution in the company?

select min(age) as youngest, max(age) as oldest from hr_data

--What's the gender breakdown in the company?

select age_group,count(*) as count from
(select case when age >=21 and age <=30 then '21 to 30' 
            when age >=31 and age <=40 then '31 to 40'
			when age >=41 and age <=50 then '41 to 50'
			else '50+' end as age_group from hr_data where termdate is null) as sub
group by age_group
order by age_group

-- age group distribution by gender

select gender,age_group,count(*) as count from
(select case when age >=21 and age <=30 then '21 to 30' 
            when age >=31 and age <=40 then '31 to 40'
			when age >=41 and age <=50 then '41 to 50'
			else '50+' end as age_group , gender from hr_data where termdate is null) as sub
group by age_group,gender
order by age_group,gender

--- gender  breakdown

select gender,count(gender) as count from hr_data where new_termdate is null group by gender order by gender

--How does gender vary across departments and job titles?

select department,gender,count(gender) as count from hr_data where new_termdate is null group by gender,department order by gender,department

-- by job title
select department,jobtitle,gender,count(gender) as count from hr_data where new_termdate is null group by gender,department,jobtitle order by gender,department,jobtitle

--What's the race distribution in the company?

select race,count(race) as count from hr_data where new_termdate is null group by race order by race

--What's the average length of employment in the company?

select avg(datediff(year,hire_date,new_termdate)) as tenure from hr_data where new_termdate is not null and new_termdate <= getdate()


--Which department has the highest turnover rate?

select depart,total,terminated,round((cast(terminated as float )/total),2)*100 as turnover from
(select department as depart,count(*) as total , sum(case when new_termdate is not null and new_termdate<= getdate() then 1 else 0 end)
as terminated from hr_data group by department) as subque


--What is the tenure distribution for each department

select department,avg(datediff(year,hire_date,new_termdate)) as tenure from hr_data where new_termdate is not null and new_termdate <= getdate()
group by department order by department desc

--How many employees work remotely for each department?
select department,count(1) as location from hr_data where location like '%Remote%' group by department order by department desc

select location,count(*) as count from hr_data where new_termdate is null group by location

--What's the distribution of employees across different states?

select location_state,count(1) as count from hr_data where new_termdate is null group by location_state order by count desc

--How are job titles distributed in the company?


select jobtitle,count(*) as count from hr_data where new_termdate is null group by jobtitle order by count desc


--How have employee hire counts varied over time?
select hire_year,hires,terminated,(hires-terminated) as net_change,round(cast((hires-terminated) as float)/hires,2)*100 as percent_change from
(select year(hire_date) as hire_year , count(1) as hires , sum(case when new_termdate is not null and new_termdate <= getdate() then 1 else 0 end ) as terminated
from hr_data
group by year(hire_date) ) as subqu order by percent_change
