create database case_study2;
USE case_study2;
select length(id)
from case_study2.dailyactivity_merged;

select id
from case_study2.dailyactivity_merged
where length(id) <> 10;

-- check for inconsistencies in all tables

SELECT t1.Id, t1.ActivityDate, t1.Calories AS table1_column, t2.Calories AS table2_column
FROM case_study2.dailyactivity_merged t1
JOIN case_study2.dailycalories_merged t2 ON t1.id = t2.id AND t1.ActivityDate = t2.ActivityDay
WHERE t1.Calories <> t2.Calories;

-- drop the tables

drop table dailycalories_merged;
drop table dailyactivity_merged;

-- After cleaning

select * from sleep;
SET SQL_SAFE_UPDATES = 0;
SELECT COUNT(*) AS total_rows
FROM activity;


ALTER TABLE weight_diff RENAME COLUMN ï»¿id TO id;
select* from weight;

-- count uniq number of rows in each table

SELECT COUNT(DISTINCT activity.id) AS activity_id, COUNT(DISTINCT sleep.id) AS sleep_id, COUNT(DISTINCT weight.id) AS weight_id
FROM activity 
left JOIN sleep ON activity.id = sleep.id
left join weight ON activity.id = weight.id;

-- how many matching rows in each table
SELECT COUNT(DISTINCT activity.id) AS activity_id, COUNT(DISTINCT sleep.id) AS sleep_id
FROM activity 
jOIN sleep ON activity.id = sleep.id;
-- op:24:24

SELECT COUNT(DISTINCT activity.id) AS activity_id, COUNT(DISTINCT weight.id) AS weight_id
FROM activity 
join weight ON activity.id = weight.id; 
-- op:8:8

SELECT COUNT(DISTINCT sleep.id) AS sleep_id, COUNT(DISTINCT weight.id) AS weight_id
FROM sleep 
jOIN weight ON sleep.id = weight.id;
-- op: 6:6

SELECT COUNT(DISTINCT activity.id) AS activity_id, COUNT(DISTINCT sleep.id) AS sleep_id, COUNT(DISTINCT weight.id) AS weight_id
FROM activity 
jOIN sleep ON activity.id = sleep.id
join weight ON activity.id = weight.id;
-- op:6:6:6, There are only 6 rows comman in all tables

 Alter table sleep add avg_hr float;
 update sleep set avg_hr= TotalMinutesAsleep/60;
 select avg_hr from sleep;

create table avg_activity as
SELECT DISTINCT id,
 COUNT(id) as num,
 avg(TotalSteps) as avg_steps,
 avg(TotalDistance) as avg_total_distance, 
 avg(VeryActiveMinutes) as avg_very_min,
 avg(FairlyActiveMinutes) as avg_fair_min,
 avg(LightlyActiveMinutes) as avg_light_min,
 avg(SedentaryMinutes) as avg_sedentary_min,
 avg(totalactive_min) as avg_tactive_min,
 avg(Calories) as avg_calories_burned
from activity
group by id
order by id;

create table avg_sleep as
SELECT *,
(avg_min_asleep/60) AS avg_hour_asleep     
from (      
   select distinct id,      
    count(id) as nums,      
    sum(time_bed) as total_min_not_asleep,     
    avg(time_bed) as avg_min_not_asleep  ,   
    sum(TotalMinutesAsleep) as total_min_asleep,      
    avg(TotalMinutesAsleep) as avg_min_asleep     
 from sleep    
 group by id      
 order by id ) as subquery;

select * from avg_activity_sleep;

 Alter table avg_activity_sleep add avg_hr float;
 update avg_activity_sleep set avg_hr= avg_min_asleep/60;
 select avg_hr from avg_activity_sleep;

create table avg_weight as
select 
 distinct id,
 COUNT(id) as nums,
 avg(weight) as avg_weight_lbs,
 avg(BMI) as avg_BMI
from weight
GROUP BY id
ORDER BY id;

select min(avg_weight_lbs) from avg_weight;

select count( distinct id) from weight;
select count(distinct date) from weight;

select date, count(id) from weight
group by date;


/*CREATE TABLE weight_start_end AS
SELECT
    id,
    MIN(date_time) AS start_date,
    MAX(date_time) AS end_date
FROM weight
GROUP BY id;

-- create table start_weight
SELECT weight.id, start_date, weight_pounds
FROM fitbit.weight_w_days
JOIN fitbit.weight_start_end_dates ON weight_w_days.Id = weight_start_end_dates.Id
WHERE Date = start_date;
-- Saved table as: “weight_start_date”*/


select id, count(id) from weight group by id;

create table common_ids as 
SELECT DISTINCT avg_weight.id          
FROM avg_sleep         
JOIN avg_weight ON avg_weight.id = avg_sleep.id           
WHERE avg_sleep.id =avg_weight.id;

ALTER TABLE weight_diff
CHANGE COLUMN `weight diffper` weight_diffper float;

create table avg_activity_sleep_weight as
SELECT t1.id,t2.num as nactivity_log, t2.nums as nsleep_log, t3.nums as nweight_log,  t2.avg_steps,t2.avg_total_distance,t2.avg_very_min,t2.avg_fair_min,t2.avg_light_min,
t2.avg_sedentary_min,t2.avg_tactive_min,t2.avg_calories_burned,t2.avg_min_not_asleep,t2.avg_min_asleep,avg_hour_asleep,
t3.avg_weight_lbs, t4.weight_diffper
FROM common_ids AS t1
JOIN avg_activity_sleep AS t2 ON t1.id = t2.id
Join avg_weight as t3 on t1.id=t3.id
join weight_diff as t4 on t1.id=t4.id;

ALTER TABLE activity
MODIFY COLUMN day DATE;

select weight_diffper from avg_activity_sleep_weight;

alter table weight_diff add column weightp float;
update weight_diff set weightp= (end_weight-start_weight)/start_weight;
update weight_diff set weightp=weightp*100;

update avg_activity_sleep_weight set weight_diffper=round(weight_diffper,2);






