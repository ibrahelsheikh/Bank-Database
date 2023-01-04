
create database MyBank
go

use MyBank;

CREATE TABLE employee (
	ssn	CHAR(9) primary key,
	name VARCHAR(20)  NOT NULL,
	phone_num INT,
	start_date date NOT NULL,
	manager_ssn CHAR(9)
	)

/*  modifing unique value constraint */
alter table employee add unique (phone_num)

/* add manager id as foreign key */
ALTER TABLE employee
ADD FOREIGN KEY (manager_ssn) REFERENCES employee(ssn);

create table customer(
	ssn char(9) primary key,
	name varchar(20) not null,
	address varchar(30),
	employee_ssn char(9) foreign key references employee(ssn)
	)


create table dependent(
	name varchar(20) ,
	age int,
	employee_ssn char(9) foreign key references employee(ssn),
	primary key(name,employee_ssn)
	)

create table account(
	number int primary key identity(1,1),
	balance float default 0,
	owner_ssn char(9),
	foreign key(owner_ssn) references customer(ssn) on delete cascade
	)


create table saving_account(
	number int  not null,
	interest_rate float default 0.05,
	foreign key(number) references account(number) on delete cascade
	)

create table checking_account(
	number int not null,
	overdraft_amount float default 500,
	foreign key(number) references account(number) on delete cascade
	)

create table branch(
	name varchar(10) primary key,
	city varchar(10),
	available_cash float
	)

create table loan(
	number int primary key identity(1,1),
	amount float not null,
	customar_ssn char(9) foreign key references customer(ssn),
	branch_name varchar(10) foreign key references branch(name),
	borrow_date date
	)

create table payment(
	number int primary key identity(1,1),
	loan_no int not null foreign key references loan(number),
	amount float not null,
	date date
	)

create table trans(
	customar_ssn char(9) not null foreign key references customer(ssn),
	account_no int not null foreign key references account(number),
	date date,
	type char not null,
	amount float not null
	)

	

/* Insert employees data */
insert into employee
values (780924598, 'Saad Eldaly', 01111111111, '2001-02-13', null),
	(193702892, 'Johnny depp', 01000000000, '2002-02-12', 780924598),
	(11111111, 'Adel Shakal', 01113111111, '2010-12-13', 193702892),
	(222222222, 'Johnny depp', 01040500000, '2002-02-12', 780924598),
	(333333333, 'Soaad Hosny', 01040000000, '2015-03-01', 780924598)

go
/* create function to make the account for existing customar*/
create procedure new_account
@ssn char(9),
@type char
as
begin
	insert into account (owner_ssn) values (@ssn)

	declare @account_number int

	set @account_number = (select max(number) from  account where owner_ssn = @ssn)
	if (@type = 's')
	insert into saving_account (number) values (@account_number)
	else
	insert into checking_account (number) values (@account_number)
end



/* Create procedure to add a new customar "Our rules says any customar must have an account" */
/*  1. Add the customar data
	2. Add the customar account
	3. Choose the type of the account */
go
    create procedure add_new_customar
@ssn char(9),
@name varchar(20),
@address varchar(30),
@employee_ssn char(9),
@account_type char
as
begin
	declare @account_number int
	insert into customer values(@ssn, @name, @address, @employee_ssn)

	execute new_account @ssn, @account_type
end
go

execute add_new_customar 910758468, 'Thomas Shelby', 'England', 333333333, 'c';
execute add_new_customar 444444444, 'Mohamed Abohend', 'Gharbia', 780924598, 's';
execute add_new_customar 555555555, 'Mohamed Elshorbagy', 'Menofia', 193702892, 'c';
execute add_new_customar 666666666, 'Ebrahim', 'Alexandria', 193702892, 's';
execute add_new_customar 999999999, 'Mohamed Elsha7at', 'Marsa Matro7', 222222222, 'c';
execute add_new_customar 123456789, 'Mohamed Konsowa', 'El3lmeen', 333333333, 's';
execute new_account 910758468, 's'

--delete customar


-- changing dateformat:
set dateformat dmy



-- trigger to decrease the branch-cash when applying new loan from that branch
go
create trigger branch_cash
on loan after insert
as
begin
update branch
set available_cash = available_cash - loan.amount
FROM loan
end
go
insert into customer values('123456789','mohamed','16 helw st','11111111')
insert into branch values('tanta','tanta',5000)
update branch set available_cash = 50000 where name = 'tanta'
insert into loan (amount,customar_ssn,branch_name,borrow_date)values(2000,'123456789','tanta','25/1/2011')

--select * from loan
--select * from branch
--select * from customar
--select * from employee

 ---------------------------------------------------------------







-- trigger to update balance on transaction


go
CREATE TRIGGER update_balance_on_transaction
ON trans
AFTER INSERT
AS
BEGIN
  IF EXISTS (SELECT 1 FROM inserted WHERE [type] = 'd')
  BEGIN
    UPDATE a
    SET a.balance = a.balance + t.amount
    FROM account a , trans t
	where a.number = t.account_no
   -- INNER JOIN inserted i ON a.number = i.account_no
  END
  ELSE IF EXISTS (SELECT 1 FROM inserted WHERE [type] = 'w')
  BEGIN
    UPDATE a
    SET a.balance = a.balance - t.amount
    FROM account a , trans t
	where a.number = t.account_no
   -- INNER JOIN inserted i ON a.number = i.account_no
  END
END


go
update account
set balance = 5000
where owner_ssn =  '444444444'

insert into trans values('444444444',2,'25/1/2011','w',500)

--select * from account
--select * from trans

-- trigger to decrease the amount of loan after payment
go
CREATE TRIGGER update_loan_amount
on payment
after insert
as
BEGIN
   UPDATE loan
   SET amount = l.amount - p.amount
   from payment p, loan l
   WHERE l.number = p.loan_no;
END
go
insert into payment (loan_no, amount,date)values(1,500,'27/1/2011')
--select * from loan





go
-- views customer data
CREATE VIEW customer_data AS
SELECT c.name, c.address, c.employee_ssn, c.ssn, acc.number, acc.balance
FROM customer c
INNER JOIN account acc ON c.ssn = acc.owner_ssn;

-- call the view
SELECT * FROM customer_data;
















--Find the total number of loans granted by a specific branch:

SELECT COUNT(*)
FROM loan
WHERE branch_name = 'Downtown';

--Find the average balance for all saving accounts:
SELECT count(a.balance)
FROM saving_account sa
INNER JOIN account a ON sa.number = a.number;

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
INNER JOIN customer c ON t.customar_ssn = c.ssn
GROUP BY c.name;







