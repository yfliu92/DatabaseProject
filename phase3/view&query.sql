-- 2.2.1 Available rooms
-- This view returns all available rooms in the hotel

CREATE VIEW AVAILABLE_ROOMS
  AS
    SELECT *
    FROM ROOM R
    WHERE R.OCCUPIED = 0;

-- 2.2.2 Popular event manager
-- This view shows the popular event managers who have helped organize more than 10 events in one month.

CREATE VIEW POPULAR_EVENT_MANAGER
  AS
    SELECT *
    FROM EMPLOYEE E
    WHERE E.EMPLOYEE_ID IN
          (
            SELECT EV.MGR_ID
            FROM EVENT EV
            WHERE months_between(sysdate, EV.DATE_TIME) <= 1
            GROUP BY EV.MGR_ID
            HAVING COUNT(*) >= 10
          );

-- 2.2.3 Frequent customers
-- This view shows the individual customers who checked in at least 10 times this year.

CREATE VIEW FREQUENT_CUSTOMERS AS
  SELECT *
  FROM INDIVIDUAL_CLIENT I
  WHERE I.ID IN
        (
          SELECT H.IC_ID
          FROM HELP_CHECK_IN H
          WHERE months_between(sysdate, H.CHECK_IN_DATE_TIME) <= 12
          GROUP BY H.IC_ID
          HAVING COUNT(*) >= 10
        );

-- 2.2.4 Popular rooms
-- This view shows the rooms that were checked in at least 30 times this year.

CREATE VIEW POPULAR_ROOMS AS
  SELECT *
  FROM ROOM R
  WHERE R.Room# IN (
    SELECT H.Room#
    FROM HELP_CHECK_IN H
    WHERE EXTRACT(YEAR FROM H.CHECK_IN_DATE_TIME) = EXTRACT(YEAR FROM SYSDATE)
    GROUP BY H.Room#
    HAVING COUNT(*) >= 30);

-- 2.3 Creation of SQL Queries

-- 2.3.1. Retrieve the number of employees who work at the lounge/bar.

SELECT COUNT(*)
FROM DINING_STAFF D
WHERE D.Dining_type = 'bar';

-- 2.3.2. Retrieve the average salary of the receptionists.

SELECT AVG(Salary_rate)
FROM RECEPTIONIST R, EMPLOYEE E
WHERE R.ID = E.Employee_id;

-- 2.3.3. Retrieve the information of individual customers who have been billed more than $1,000 in total this year.
SELECT *
FROM INDIVIDUAL_CLIENT IC
WHERE IC.ID IN (
  SELECT I.Individual_id
  FROM INDIVIDUAL_BILL I
  WHERE EXTRACT(YEAR FROM I.ISSUE_DATE) = EXTRACT(YEAR FROM SYSDATE)
  GROUP BY I.Individual_id
  HAVING SUM(I.Amount) >= 1000);

-- 2.3.4. For each individual, retrieve his/her bill amount in ascending order of each check-in date.
SELECT
  IND.CHECK_IN_DATE,
  I.ID,
  IND.AMOUNT
FROM INDIVIDUAL_BILL IND, INDIVIDUAL_CLIENT I
WHERE I.ID = IND.INDIVIDUAL_ID
ORDER BY IND.CHECK_IN_DATE;

-- 2.3.5. Retrieve the information of the frequent customers who have stayed for at least 15 nights this year.
SELECT *
FROM FREQUENT_CUSTOMERS FC
WHERE FC.ID IN (
  SELECT res.ID
  FROM (
         SELECT
           SUM(H.LENGHT_OF_STAY),
           H.IC_ID AS ID
         FROM FREQUENT_CUSTOMERS F, HELP_CHECK_IN H
         WHERE F.ID = H.IC_ID AND EXTRACT(YEAR FROM SYSDATE) = EXTRACT(YEAR FROM H.CHECK_IN_DATE_TIME)
         GROUP BY H.IC_ID
         HAVING SUM(H.LENGHT_OF_STAY) >= 15
       ) res);

-- 2.3.6. Retrieve the average age of individual customers who were helped by a receptionist who only speaks Spanish.

SELECT SUM(trunc((months_between(sysdate, DOB))) / 12) / COUNT(*)
FROM INDIVIDUAL_CLIENT IND
WHERE IND.ID IN
      (SELECT DISTINCT I.ID
       FROM HELP_CHECK_IN H, RECEPTIONIST_LANGUAGE RL, INDIVIDUAL_CLIENT I
       WHERE H.RECEPTIONIST_ID = RL.ID AND RL.Language = 'Spanish' AND H.IC_ID = I.ID);

-- 2.3.7. Retrieve the information of the organization that organized at least two events and got bills of over $2000 in total.

SELECT *
FROM ORGANIZATION_CLIENT OC
WHERE
  OC.ID IN (
    SELECT HO.O_CLIENT_ID
    FROM HOLD HO
    GROUP BY HO.O_CLIENT_ID
    HAVING COUNT(HO.O_CLIENT_ID) >= 2
  )
  AND
  OC.ID IN (
    SELECT HOL.O_CLIENT_ID
    FROM EVENT_BILL EB, HOLD HOL
    WHERE HOL.EVENT_ID = EB.EVENT_ID
    GROUP BY HOL.O_CLIENT_ID
    HAVING SUM(EB.AMOUNT) >= 1000
  );

-- 2.3.8. Retrieve the highest amount of bill of the events helped by the most popular event manager.

-- 2.3.9. Retrieve information of the event that each of its organizers pays the highest amount for the event (suppose organizers of the same event pay the bill evenly).

-- 2.3.10. Retrieve the date and time the most popular room was last checked in.




