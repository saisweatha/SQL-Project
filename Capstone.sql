ALTER TABLE customerinfo
MODIFY COLUMN BankDOJ DATE;

-- 1st objective question
select round(avg(b.Balance),2) as Avgbalance,g.GeographyLocation from bank_churn b
join customerinfo c
on b.CustomerId=c.CustomerId
join geography g
on c.GeographyID=g.GeographyID
group by g.GeographyLocation
order by Avgbalance desc;

 -- 2nd objective question
 
 SELECT CustomerId,Surname,Age,GenderID,EstimatedSalary,GeographyID,BankDOJ
FROM customerinfo 
WHERE MONTH(BankDOJ) IN (10, 11, 12)
ORDER BY EstimatedSalary DESC
LIMIT 5;


 -- 3rd objective question
 SELECT round(avg(NumofProducts),2) as Avg_num_of_products from bank_churn
 where HasCrCard='1';
 

-- 5th objective question

SELECT ec.ExitCategory,
    round(AVG(bc.CreditScore),2) AS AvgCreditScore
FROM Exitcustomer ec
JOIN bank_churn bc 
ON ec.ExitID = bc.Exited
GROUP BY ec.ExitCategory;

-- 6th objective question
SELECT g.GenderCategory,
	round(AVG(c.EstimatedSalary),2) AS AvgEstimatedSalary,
    SUM(CASE WHEN b.IsActiveMember = 1 THEN 1 ELSE 0 END) AS ActiveAccounts
FROM customerinfo c
JOIN gender g 
    ON c.GenderID = g.GenderID
JOIN bank_churn b ON c.CustomerId = b.CustomerId
GROUP By g.GenderCategory;

-- 7th objective question

WITH CreditScoreSegments AS (
    SELECT 
        CASE 
            WHEN CreditScore >= 800 THEN 'Excellent'
            WHEN CreditScore >= 740 AND CreditScore < 800 THEN 'Very Good'
            WHEN CreditScore >= 670 AND CreditScore < 740 THEN 'Good'
            WHEN CreditScore >= 580 AND CreditScore < 670 THEN 'Fair'
            WHEN CreditScore >= 300 AND CreditScore < 580 THEN 'Poor'
            ELSE 'Unknown' 
        END AS CreditScoreSegment,
        CustomerId
    FROM bank_churn
)
SELECT 
    CreditScoreSegment,
    COUNT(CASE WHEN ExitCategory = 'Exit' THEN 1 END) AS ChurnedCustomers,
    COUNT(*) AS TotalCustomers,
    ROUND(COUNT(CASE WHEN ExitCategory = 'Exit' THEN 1 END) * 100.0 / COUNT(*), 2) AS ExitRate
FROM 
    CreditScoreSegments cs
JOIN bank_churn b ON cs.CustomerId = b.CustomerId
join exitcustomer ec
on b.Exited=ec.ExitID

GROUP BY 
    CreditScoreSegment
ORDER BY 
    ExitRate DESC;


-- 8th Objective question

SELECT g.GeographyLocation,
count(CASE WHEN b.IsActiveMember = 1 THEN 1 ELSE 0 END) AS ActiveAccounts from geography g
join customerinfo c
on g.GeographyID=c.GeographyID
join bank_churn b
on c.CustomerId=b.CustomerId
where b.Tenure>5 
group by g.GeographyLocation;

-- 9th Objective Question

SELECT cc.Category AS CreditCardCategory,count(CustomerId) as Total_customers,
COUNT(CASE WHEN ec.ExitCategory = 'Exit' THEN 1 END) AS ChurnedCustomers,
ROUND(COUNT(CASE WHEN ec.ExitCategory = 'Exit' THEN 1 END) / 10000, 2) AS ChurnRate
FROM Creditcard cc
JOIN bank_churn ci ON cc.CreditID = ci.HasCrCard
JOIN Exitcustomer ec ON ci.Exited = ec.ExitID
GROUP BY cc.Category;

-- 10th Objective Question
select b.NumOfProducts, 
COUNT(CASE WHEN ec.ExitCategory = 'Exit' THEN 1 END) AS ExitedCustomers
from bank_churn b
join exitcustomer ec
on b.Exited=ec.ExitID
group by b.NumOfProducts
order by ExitedCustomers desc;

-- 11th Objective Question

SELECT 
    EXTRACT(YEAR FROM BankDOJ) AS JoinYear,
    EXTRACT(MONTH FROM BankDOJ) AS JoinMonth,
    COUNT(*) AS JoinCount
FROM 
    customerinfo
GROUP BY 
    JoinYear,JoinMonth
ORDER BY 
    joinCount desc;
    
    -- 13 th objective question
    SELECT Exited,
    COUNT(*) AS count_retained,
    SUM(CASE WHEN Balance = 0 THEN 1 ELSE 0 END) AS count_zero_balance,
    SUM(CASE WHEN Balance <> 0 THEN 1 ELSE 0 END) AS count_nonzero_balance
FROM bank_churn
GROUP BY Exited;


-- 15th objective question
SELECT 
    c.GeographyID,
    ge.GeographyLocation,
    g.GenderCategory,
    round(AVG(c.EstimatedSalary),2) AS AvgIncome,
    RANK() OVER (PARTITION BY c.GeographyID ORDER BY AVG(c.EstimatedSalary) DESC) AS GenderRank
FROM 
    customerinfo c
JOIN 
    gender g ON c.GenderID = g.GenderID
join geography ge
on c.GeographyID=ge.GeographyID
GROUP BY 
    c.GeographyID, ge.GeographyLocation,g.GenderCategory
ORDER BY 
    c.GeographyID, GenderRank;
    
 -- 16th Objective Question
 
 SELECT CASE 
        WHEN Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN Age BETWEEN 31 AND 50 THEN '31-50'
        ELSE '50+'
    END AS AgeBracket,
    round(AVG(Tenure),2) AS AvgTenure
FROM customerinfo ci
JOIN bank_churn bc ON ci.CustomerId = bc.CustomerId
JOIN exitcustomer ec ON bc.Exited = ec.ExitID
GROUP BY AgeBracket;

-- 18 th Ojective Question

SELECT
    Exited,
    COUNT(*) AS count_retained,
    SUM(CASE WHEN Balance = 0 THEN 1 ELSE 0 END) AS count_zero_balance,
    SUM(CASE WHEN Balance <> 0 THEN 1 ELSE 0 END) AS count_nonzero_balance
FROM
    bank_churn
GROUP BY
    Exited;

-- 19th Objective question

SELECT CreditScoreBucket,
       COUNT(CASE WHEN ec.ExitCategory = 'Exit' THEN 1 END) AS ChurnedCustomers,
       RANK() OVER (ORDER BY COUNT(CASE WHEN ec.ExitCategory = 'Exit' THEN 1 END) DESC) AS Ranks
FROM (
    SELECT CASE 
             WHEN CreditScore BETWEEN 800 AND 850 THEN 'Excellent'
        WHEN CreditScore BETWEEN 740 AND 799 THEN 'Very Good'
        WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good'
        WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair'
        WHEN CreditScore BETWEEN 300 AND 579 THEN 'Poor'
         END AS CreditScoreBucket,
         CustomerId,Exited
    FROM bank_churn
) AS ScoreBuckets
LEFT JOIN exitcustomer ec ON ScoreBuckets.Exited = ec.ExitID
GROUP BY CreditScoreBucket
ORDER BY Ranks;

-- 20th Objective Question
SELECT CASE 
        WHEN Age between 17 AND 30 THEN '18-30'
        WHEN Age BETWEEN 30 AND 51 THEN '31-50'
        ELSE '50+'
    END AS AgeBracket,
    sum(bc.HasCrCard) AS CountCredit,
    Avg(bc.HasCrCard) AS AvgCredit
FROM customerinfo ci
JOIN bank_churn bc ON ci.CustomerId = bc.CustomerId
GROUP BY AgeBracket;


-- 21st Objective Question

SELECT GeographyLocation,Num_Churned_Customers,Avg_Balance,
    RANK() OVER (ORDER BY Num_Churned_Customers DESC, Avg_Balance DESC) AS Location_Rank
FROM(SELECT
        geo.GeographyLocation,
        COUNT(*) AS Num_Churned_Customers,
        ROUND(AVG(bc.Balance),2) AS Avg_Balance
    FROM bank_churn bc
    JOIN CustomerInfo ci ON bc.CustomerId = ci.CustomerId
    JOIN Geography geo ON ci.GeographyID = geo.GeographyID
    WHERE bc.Exited = 1
    GROUP BY geo.GeographyLocation) AS LocationStats;

-- 22nd Objective Question
 
 SELECT CONCAT(ci.CustomerID, '_', ci.Surname) AS CustomerID_Surname
FROM CustomerInfo ci
JOIN bank_churn ot ON ci.CustomerID = ot.CustomerID;



-- 23 rd Objective Question
SELECT *,
    (SELECT ExitCategory FROM exitcustomer WHERE ExitID = bc.Exited) AS ExitCategory
FROM bank_churn bc;

-- 25th Objective Question

SELECT
    ci.CustomerId,
    ci.Surname,
    MAX(ac.ActiveCategory) AS ActiveCategory
FROM 
    customerinfo ci
JOIN bank_churn b ON ci.CustomerId = b.CustomerId
JOIN activecustomer ac ON b.IsActiveMember = ac.ActiveID
WHERE 
    ci.Surname LIKE '%on'
GROUP BY
    ci.CustomerId,
    ci.Surname;



-- Subjective question
    
 -- 9 th Subjective Question   
    SELECT g.GenderCategory,
    CASE
        WHEN c.Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN c.Age BETWEEN 31 AND 50 THEN '31-50'
        ELSE '50 or above'
    END AS AgeBin,
    COUNT(*) AS CustomerCount,
    AVG(bc.balance) AS AverageBalance
FROM customerinfo c
JOIN bank_churn bc ON c.CustomerId = bc.CustomerId
JOIN activecustomer ac ON bc.IsActiveMember = ac.ActiveID
JOIN Gender g ON c.GenderId = g.GenderId
JOIN creditcard cc ON bc.HasCrCard = cc.CreditID
JOIN exitcustomer ec ON bc.Exited = ec.ExitID
GROUP BY g.GenderCategory,
    CASE
        WHEN c.Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN c.Age BETWEEN 31 AND 50 THEN '31-50'
        ELSE '50 or above'
    END;
SELECT 
    -- Demographic Segmentation
    CASE
        WHEN ci.Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN ci.Age BETWEEN 31 AND 50 THEN '31-50'
        WHEN ci.Age > 50 THEN '50+'
        ELSE 'Unknown'
    END AS Age_Group,
    g.GeographyLocation,
    gi.GenderCategory AS Gender,
    
    -- Account Details Segmentation
    CASE
        WHEN bc.Balance < 10000 THEN 'Low Balance'
        WHEN bc.Balance >= 10000 AND bc.Balance < 50000 THEN 'Medium Balance'
        WHEN bc.Balance >= 50000 THEN 'High Balance'
        ELSE 'Unknown'
    END AS Balance_Category,
    cc.Category AS Credit_Card_Status
    
FROM customerinfo ci
JOIN bank_churn bc ON ci.CustomerId = bc.CustomerId
JOIN geography g ON ci.GeographyID = g.GeographyID
JOIN gender gi ON ci.GenderID = gi.GenderID
JOIN creditcard cc ON bc.HasCrCard = cc.CreditID;


 
