INSERT INTO offervouchers (voucherid, acceptedat, expiresat)
WITH dayzero AS (
  SELECT MAX(balanceon) AS dayzero
    FROM accountbalances
),
availablevouchers AS (
  SELECT voucherid
    FROM offervouchers
    GROUP BY voucherid
    HAVING MAX(issuedat) IS NOT NULL
      AND MAX(acceptedat) IS NULL
      AND MAX(expiresat) IS NULL
),
acceptedvouchers AS (
 SELECT voucherid, (random() < .4) AS accepted
   FROM availablevouchers
)
SELECT voucherid, CASE WHEN accepted THEN dayzero ELSE NULL END, CASE WHEN NOT accepted THEN dayzero ELSE NULL END
  FROM dayzero, acceptedvouchers

;
INSERT INTO offervouchers
WITH salaryday AS (
  SELECT MAX(balanceon) + INTERVAL '1 day' AS salaryday
    FROM accountbalances
),
salarycomparison AS (
  SELECT accountid, amount AS currentsalary, LAG(amount) OVER(PARTITION BY accountid ORDER BY transactedon) AS previoussalary
    FROM transactions, salaryday
    WHERE amount > 0
      AND transactedon > salaryday - INTERVAL '1 month' - INTERVAL '1 day'
),
firstoffers AS (
  SELECT COUNT(*) AS offercount
    FROM offervouchers
)
SELECT random()*1000000, 1, accountid - MIN(accountid) OVER() + 32767*(offercount = 0)::int
  FROM salarycomparison, firstoffers
  WHERE currentsalary - previoussalary > previoussalary * .05
    AND currentsalary - previoussalary > 250;
INSERT INTO transactions
WITH dayzero AS (
  SELECT MAX(balanceon) AS dayzero
    FROM accountbalances
),
daterange AS (
SELECT dayzero, dayzero + INTERVAL '1 month',
    EXTRACT('day' FROM (dayzero + INTERVAL '1 Month') - dayzero)::int AS daycount
  FROM dayzero
),
transacted AS (
  SELECT accountid, SUM(amount) AS transactedsincebalance
    FROM dayzero INNER JOIN transactions
      ON transactedon > dayzero
    GROUP BY accountid
),
opening AS (
  SELECT accountid, creditlimit + balance AS openingavailable
    FROM accountbalances, dayzero
    WHERE balanceon = dayzero
),
transactionamounts AS (
  --Transactions for the month may be between .7 and 1.2 times income in the period
  SELECT opening.accountid, (transactedsincebalance)*(.9 + random()*.35) AS transactionamount
    FROM transacted INNER JOIN opening ON opening.accountid = transacted.accountid
),
transactiondistributions AS (
  SELECT accountid, transactionamount, dayzero + generate_series(1, daterange.daycount) * INTERVAL '1 day' AS transactionday, random() AS portion
    FROM transactionamounts, daterange
    WHERE transactionamount > 0
),
transactions AS (
  SELECT accountid, transactionday, portion/SUM(portion) OVER(PARTITION BY accountid)*transactionamount AS transactionvalue,
      (random()*750)::int AS vendorID
    FROM transactiondistributions
)
SELECT accountid, transactionday, 0 - transactionvalue, label
  FROM transactions INNER JOIN vendors ON vendors.vendorid = transactions.vendorid
  WHERE transactionvalue >= 1;
INSERT INTO accountbalances
WITH dayzero AS (
  SELECT MAX(balanceon) AS dayzero
    FROM accountbalances
),
daterange AS (
SELECT MAX(transactedon) AS balanceday
  FROM transactions
),
transacted AS (
  SELECT accountid, balanceday, SUM(amount) AS transactiontotal
    FROM daterange, dayzero INNER JOIN transactions
      ON transactedon > dayzero
    GROUP BY accountid, balanceday
),
opening AS (
  SELECT accountid, balance, creditlimit
    FROM accountbalances, dayzero
    WHERE balanceon = dayzero
)
--TODO: Change a few (1%?) of credit limits - some up a few % and some halved
SELECT opening.accountid, balanceday, balance + transactiontotal AS newbalance, creditlimit
  FROM opening INNER JOIN transacted ON opening.accountid = transacted.accountid;
INSERT INTO transactions
WITH salaryday AS (
  SELECT MAX(balanceon) + INTERVAL '1 day' AS salaryday
    FROM accountbalances
),
precedent AS (
  SELECT accountid, amount, description
    FROM transactions, salaryday
    WHERE transactedon = salaryday - INTERVAL '1 month'
      AND amount > 0
)
SELECT accountid, salaryday,
    CASE WHEN random() < 0.02 THEN amount * (1 + random()*.2) ELSE amount END AS amount, description
  FROM precedent,salaryday
;
