==========================================================================================================================
--How did total loans, defaulted loans and default rate change from 2024 to 2025?
==========================================================================================================================
select year(disbursement_date) as year,
count(loan_id) as total_loans,
sum(case when loan_status = 'Defaulted' then 1 else 0 end) as default_count,
round(cast(100.0*sum(case when loan_status = 'Defaulted' then 1 else 0 end)/count(loan_id) as float),2) as default_rate,
sum(case when loan_status = 'Written off' then 1 else 0 end) as written_off_count,
round(cast(100.0*sum(case when loan_status = 'Written off' then 1 else 0 end)/count(loan_id) as float),2) as written_off_rate
from loans
group by year(disbursement_date)

--Default rate has decreased from 4.33 to 3.75 from 2024 to 2025 and written off loans rate has also decreased from 1.3 to 1.13 from 2024 to 2025.

==========================================================================================================================
-- How did loans in various status changed from 2024 to 2025?
==========================================================================================================================
with cte_loan as
(
select loan_status, year, count(loan_id) as loan_count
from loans
group by loan_status, year
)
select loan_status, year, loan_count, 
lag(loan_count) over (partition by loan_status order by year) as PY_loan_count,
round(cast(100.00*(loan_count - lag(loan_count) over (partition by loan_status order by year))/lag(loan_count) over (partition by loan_status order by year) as float),2) as yoy_change
from cte_loan;

-- active loans(873.7 %), default loans(189.7 %), restructured loans(818.29%) and written off loans(190.91%) has shown a lot of increase in 2025


==========================================================================================================================
--Checking the delinquency over the year
==========================================================================================================================
with cte_delinq as 
(
select year(collection_date) as year, count(distinct loan_id) as delinquent_loans
from collections
where days_past_due >=30
group by year(collection_date)
)
, cte_total as
(
select l.year, count(distinct l.loan_id) as total_loans , d.delinquent_loans
from loans as l
join cte_delinq as d
on d.year = l.year
group by l.year, d.delinquent_loans
)
select year, total_loans, delinquent_loans , round(cast(100.0 * delinquent_loans/total_loans as float), 2) as delinquent_rate
from cte_total

--Delinquency rate has increased from 2.66 in 2024 to 5.97 in 2025

===============================================================================================================================
-- Which loan types have the highest default rates and contribute the largest number of defaults?
===============================================================================================================================

select loan_type, count(loan_id) as total_loans,
sum(case when loan_status = 'Defaulted' then 1 else 0 end) as default_loans,
round(cast(100.00*sum(case when loan_status = 'Defaulted' then 1 else 0 end)/ count(loan_id) as float) ,2) as default_rate
from loans
group by loan_type
order by default_rate desc;

--Consumer loand type has default rate of 3.92 followed by personal(3.91) then education(3.74) asn last emergency(3.65).

===============================================================================================================================
-- How do default rates differ across underwriting policy versions?
===============================================================================================================================

select underwriting_policy_version, count(loan_id) as total_loans,
sum(case when loan_status = 'Defaulted' then 1 else 0 end) as default_loans,
round(cast(100.00*sum(case when loan_status = 'Defaulted' then 1 else 0 end)/ count(loan_id) as float) ,2) as default_rate
from loans
group by underwriting_policy_version
order by default_rate desc;

--Default rate for policy v1 (4.36) is higher than policy v2(3.6)

===============================================================================================================================
-- Which acquisition channels contribute the most defaults and have the highest delinquency rates?
===============================================================================================================================

select acquisition_channel, count(loan_id) as total_loans,
sum(case when loan_status = 'Defaulted' then 1 else 0 end) as default_loans,
round(cast (100.00* sum(case when loan_status = 'Defaulted' then 1 else 0 end)/count(loan_id) as float), 2) as default_rate
from loans
group by acquisition_channel
order by default_rate desc;

with cte_delinq as
(select l.acquisition_channel, count(distinct l.loan_id) as deliq_loans
from collections as cl 
left join loans as l 
on l.loan_id = cl.loan_id
where cl.days_past_due>=30
group by l.acquisition_channel
)
select l.acquisition_channel, count(distinct l.loan_id) as total_loans, d.deliq_loans,
round(cast(100.00*d.deliq_loans/count(distinct l.loan_id) as float),2) as deliq_rate 
from loans as l
left join cte_delinq as d
on l.acquisition_channel = d.acquisition_channel
group by l.acquisition_channel, d.deliq_loans
order by deliq_rate desc;

--Social Media has highest default rate (7.23) and least for organic and referral.
--Social Media is showing highest delinquency rate, follwoed by affiliate (6.4) and paid search(6.2) and least is for organic(0.97)

===============================================================================================================================
-- How does default rate vary credit risk behaviour?
===============================================================================================================================

select  r.risk_band,round(cast(avg(r.credit_score) as float),2) as avg_credit_score, 
round(cast(avg(r.debt_to_income) as float),2) as avg_dti, 
round(cast(avg(r.loan_to_income) as float),2) as avg_lti, 
round(cast(avg(r.previous_late_payments) as float),2) as avg_prev_late_payments, 
round(cast(avg(r.probability_of_default) as float),2) as avg_prob_of_default, count(r.loan_id) as total_loans, 
sum(case when l.loan_status = 'Defaulted' then 1 else 0 end) as default_loans,
round(cast(100.00*sum(case when l.loan_status = 'Defaulted' then 1 else 0 end)/count(r.loan_id) as float),2) as default_rate
from credit_risk as r
join loans as l
on l.loan_id = r.loan_id
group by r.risk_band
order by default_rate desc;

--Default rate is highest for very high risk band(7.91) then followed by high risk band(5.91) then medium (4.4) and last low risk band (3.35).

===============================================================================================================================
-- How do default rates vary by employment status, gender and customer segment?
===============================================================================================================================
-- by employment status
select c.employment_status, count(l.loan_id) as total_loans,
sum(case when l.loan_status = 'Defaulted' then 1 else 0 end) as default_loans,
round(cast(100.00*sum(case when l.loan_status = 'Defaulted' then 1 else 0 end)/count(l.loan_id) as float),2) as default_rate
from loans as l
left join customers as c
on l.customer_id = c.customer_id
group by c.employment_status
order by default_rate desc;

-- by gender
select c.gender, count(l.loan_id) as total_loans,
sum(case when l.loan_status = 'Defaulted' then 1 else 0 end) as default_loans,
round(cast(100.00*sum(case when l.loan_status = 'Defaulted' then 1 else 0 end)/count(l.loan_id) as float),2) as default_rate
from loans as l
left join customers as c
on c.customer_id = l.customer_id
group by c.gender
order by default_rate desc;

-- by customer_segment
select c.customer_segment, count(l.loan_id) as total_loans,
sum(case when l.loan_status = 'Defaulted' then 1 else 0 end) as default_loans,
round(cast(100.00*sum(case when l.loan_status = 'Defaulted' then 1 else 0 end)/count(l.loan_id) as float),2) as default_rate
from loans as l
left join customers as c
on c.customer_id = l.customer_id
group by c.customer_segment
order by default_rate desc;

--Default rate is highest for unemployed(4.67), then followed by self-employed(3.92) then salaried (3.88) and last contract (3.59)
--Default rate for female (3.95) and male (3.85)
--Default rate is highest for upper middle income customer segment (3.98), followed by low income(3.92), then middle income(3.87) and last high income(3.13)

===============================================================================================================================
-- Which loan, risk-band and customer segments have the highest delinquency rates?
===============================================================================================================================

===========================================================================================================================
-- delinquency rate by loan type
===========================================================================================================================

with cte_deliq as
(
select l.loan_type, count(distinct l.loan_id) as delin_loans
from loans as l
left join collections as cl
on l.loan_id = cl.loan_id
where cl.days_past_due >= 30
group by l.loan_type
)
select l.loan_type, count(distinct l.loan_id) as total_loans, d.delin_loans as delinquent_loans,
round(cast(100.00* d.delin_loans/count(distinct l.loan_id) as float),2) as delinq_rate
from loans as l
join cte_deliq as d on d.loan_type = l.loan_type
group by l.loan_type, d.delin_loans
order by delinq_rate desc;

--Personal loan type has highest delinquency rate(4.8) followed by consumer loan type(4.72) and then emergency (4.5) and last education (4.46)

===========================================================================================================================
-- delinquency rate by risk band
===========================================================================================================================
with cte_delinq as
(
select risk_band, count(distinct loan_id) as delinq_loans
from collections
where days_past_due>=30
group by risk_band
)
, cte_loans as
(
select r.risk_band, count(distinct l.loan_id) as total_loans
from  loans as l
left join credit_risk as r on l.loan_id = r.loan_id
group by r.risk_band
)
select l.risk_band, l.total_loans, d.delinq_loans,
round(cast(100.00*d.delinq_loans/ l.total_loans as float),2) as delinq_rate
from cte_loans as l
left join cte_delinq as d on d.risk_band = l.risk_band
order by delinq_rate desc;

-- Delinquency rate is highest for very high risk band (9.8) followed by high risk band(7.43) and then medium(5.41) and last low risk band(4.06)

===========================================================================================================================
-- delinquency rate by customer segment
===========================================================================================================================
 with cte_delinq as
 (select c.customer_segment, count(distinct cl.loan_id) as delinq_loans
 from collections as cl
 left join customers as c on cl.customer_id = c.customer_id
 group by c.customer_segment)
 , cte_loans as 
 (select c.customer_segment, count(distinct l.loan_id) as total_loans
 from loans as l
 left join customers as c on c.customer_id = l.customer_id
 group by c.customer_segment)
 select d.customer_segment, l.total_loans, d.delinq_loans,
 round(cast(100.00* d.delinq_loans/l.total_loans as float),2) as delinq_rate
 from cte_delinq as d
 join cte_loans as l on l.customer_segment = d.customer_segment
 order by delinq_rate desc;

 -- delinquency rate is highest for Low income segment (5.15) followed by upper middle income (5.06) and then middle income(4.91) and last high income(4.16)

===============================================================================================================================
-- How much is recovered, how much does recovery cost, and which collection stages or recovery outcomes show the strongest results?
===============================================================================================================================


select collection_stage, round(sum(amount_recovered),2) as total_amt_recovered, 
round(sum(recovery_cost),2) as total_recovery_cost
from collections
group by collection_stage
order by total_recovery_cost desc;

select recovery_status, round(sum(amount_recovered),2) as total_amt_recovered, 
round(sum(recovery_cost),2) as total_recovery_cost
from collections
group by recovery_status
order by total_recovery_cost desc;

--recovery stage has highest amount recovered (8046355.01) with others as zero and total recovery cost is also highest in recovery stage(58681.48)
--contacted (recovery_status) has largest total recovery cost (156504.66) and recovered (recovery status) has shown largest amount recovered with others as zero


