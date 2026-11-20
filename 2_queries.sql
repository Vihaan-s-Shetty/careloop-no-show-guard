-- Task 2.1 — Build and load the database
CREATE DATABASE  noshowguard;
USE noshowguard;
CREATE TABLE clinics (
  clinic_id VARCHAR(5) PRIMARY KEY, clinic_name VARCHAR(40) NOT NULL, city VARCHAR(20) NOT NULL,
  tier VARCHAR(10), latitude DECIMAL(8,4), longitude DECIMAL(8,4), temp_c DECIMAL(5,1));
CREATE TABLE appointments (
  appointment_id VARCHAR(8) PRIMARY KEY, patient_id VARCHAR(8) NOT NULL, clinic_id VARCHAR(5) NOT NULL,
  booked_on DATE, appt_date DATE, age INT, gender VARCHAR(1), distance_km DECIMAL(5,1), fee_inr INT,
  booking_channel VARCHAR(10), visit_type VARCHAR(12), reminder_sent VARCHAR(3), prior_no_shows INT,
  status VARCHAR(10), lead_days INT, no_show INT,
  FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id));
  
  -- CHECKING VALUES
SELECT COUNT(*) FROM clinics ;
SELECT COUNT(*) FROM appointments;

-- checking after uploading the file
SELECT COUNT(*) FROM clinics;
SELECT COUNT(*) FROM appointments;
SELECT SUM(no_show) FROM appointments;

-- Task 2.2 — No-show rate by clinic
-- joining all from appointments and clinic
SELECT appointments.*,clinics.*
FROM appointments JOIN clinics
ON appointments.clinic_id=clinics.clinic_id;

-- selecting required columns only  from appointment and clinc
SELECT a.appointment_id,a.clinic_id,a.no_show,c.clinic_name,c.city
FROM appointments a JOIN clinics c
ON a.clinic_id=c.clinic_id;
 
 -- using groupby  and having clause
 SELECT
    c.clinic_name,
    c.city,
    COUNT(*) AS appointments,
    SUM(a.no_show)AS no_shows,
    ROUND(100.0*SUM(a.no_show)/COUNT(*),1) as no_show_pct
    FROM appointments a JOIN clinics c
    ON a.clinic_id = c.clinic_id
    GROUP BY
        c.clinic_id,
        c.clinic_name,
		c.city
	HAVING appointments >=95
	ORDER BY no_show_pct  DESC ;
	
    -- Task 2.3 — Does booking far ahead matter? 
   SELECT COUNT(*) AS appointments,
          SUM(appointments.no_show)AS no_shows,
          ROUND(100.0 * SUM(no_show) / COUNT(*), 1) AS no_show_pct,
   CASE
   WHEN lead_days <=7 THEN '1-7'
   WHEN lead_days <=14 THEN '8-14'
   WHEN lead_days <=30 THEN '15-30'
   ELSE  '31+'
   END AS lead_band
   FROM appointments
   GROUP BY lead_band
   ORDER BY MIN(lead_days);
   
   
   -- Task 2.4 — Month-by-month trend
  
WITH monthly AS 
(
  SELECT  SUBSTR(appt_date,1,7) AS month,
		 COUNT(*) AS appointments,
		 ROUND(100.0 * SUM(no_show) / COUNT(*), 1) AS no_show_pct
		 FROM appointments
		 GROUP BY SUBSTR(appt_date, 1, 7)
         )
SELECT
    month,
    appointments,
    no_show_pct,
    no_show_pct - LAG(no_show_pct)
	OVER (ORDER BY month) AS changed_percentage
FROM monthly
ORDER BY month;
    
    -- Task 2.5 — Rank clinics inside each city 
    
    WITH clinic_rates AS (
      SELECT clinics.clinic_name,clinics.city, ROUND(100.0* SUM(no_show)/ COUNT(*),1) AS no_show_pct
      FROM appointments JOIN clinics
      ON appointments.clinic_id=clinics.clinic_id
      GROUP BY clinic_name,city
      )
      SELECT clinic_name,
      city,
      no_show_pct,
      RANK () OVER(PARTITION BY city ORDER BY no_show_pct DESC) AS rank_in_city,
      CASE
    WHEN no_show_pct > (
        SELECT 100.0 * SUM(no_show) / COUNT(*)
        FROM appointments
    ) THEN 'above'
    WHEN no_show_pct < (
        SELECT 100.0 * SUM(no_show) / COUNT(*)
        FROM appointments
    ) THEN 'below'
      ELSE 'equal'
      END AS vs_overall
      FROM clinic_rates
      ORDER BY city, rank_in_city;
       
      
      
    
    
    
    
    
    
    
    
    
 