USE MyBank;

-- ---------------------------------------------------
-- -- views customer data
-- Create view customer_data as
-- select customer_id, customer_name, customer_address, customer_phone, customer_email, customer_password, customer_status
-- from customer;
-- ------------------------------------------------------
-- CREATE VIEW LoanStatus AS
-- SELECT l.number AS 'Loan Number', l.amount AS 'Loan Amount', (l.amount - SUM(p.amount)) AS 'Remaining Balance',
--        DATEDIFF(month, l.borrow_date, GETDATE()) AS 'Months Passed', ( DATEDIFF(month, l.borrow_date, GETDATE())) AS 'Months Remaining'
-- FROM loan l
-- LEFT JOIN payment p ON l.number = p.loan_no
-- GROUP BY l.number, l.amount, l.borrow_date;
-- -------------------------------------
-- CREATE VIEW ManagerEmployees AS
-- SELECT e.manager_ssn AS 'Manager SSN', e.name AS 'Employee Name'
-- FROM employee e
-- WHERE e.manager_ssn IS NOT NULL;
--
--
--
--
-- ---------------------------------------------------
--
-- CREATE VIEW AccountHistory AS
-- SELECT top 10  a.number AS 'Account Number', t.amount AS 'Amount', t.date AS 'Date', t.type AS 'Transaction Type'
-- FROM trans t
-- INNER JOIN account a ON t.account_no = a.number
-- WHERE t.account_no = a.number
-- ORDER BY t.date  DESC;
--

--------------------------------------------------------------------------------------------
--Find all employees who work for a specific manager:
SELECT e1.ssn, e1.name
FROM employee e1
INNER JOIN employee e2 ON e1.manager_ssn = e2.ssn
WHERE e2.ssn = '780924598';

--Find the total balance for all accounts owned by a specific customer:
SELECT SUM(a.balance)
FROM account a
INNER JOIN customar c ON a.owner_ssn = c.ssn
WHERE c.ssn = '123456789';


--Find the total number of loans granted by a specific branch:

SELECT COUNT(*)
FROM loan
WHERE branch_name = 'Downtown';

--Find the average balance for all saving accounts:
SELECT COUNT(*)
FROM loan
WHERE branch_name = 'Downtown';

--Find the average balance for all saving accounts:
SELECT AVG(a.balance)
FROM saving_account sa
INNER JOIN account a ON sa.number = a.number;

--Find the names and phone numbers of all employees who have dependents:
SELECT e.name, e.phone_num
FROM employee e
INNER JOIN dependent d ON e.ssn = d.employee_ssn
GROUP BY e.name, e.phone_num;

--Find the total amount of payments made on each loan:
SELECT l.number, SUM(p.amount) AS total_payments
FROM loan l
INNER JOIN payment p ON l.number = p.loan_no
GROUP BY l.number;
--Find the total number of transactions made by each customer, along with the customer's name:
SELECT c.name, COUNT(t.customar_ssn) AS total_transactions
FROM trans t
INNER JOIN customar c ON t.customar_ssn = c.ssn
GROUP BY c.name;


