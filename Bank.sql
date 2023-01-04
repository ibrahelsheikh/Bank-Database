create database MyBank
go

use MyBank;

CREATE TABLE employee
(
    ssn         CHAR(9) primary key,
    name        VARCHAR(20) NOT NULL,
    phone_num   CHAR(11) UNIQUE,
    start_date  date        NOT NULL,
    manager_ssn CHAR(9),
    FOREIGN KEY (manager_ssn) REFERENCES employee (ssn)
);

create table customer
(
    ssn          char(9) primary key,
    name         varchar(20) not null,
    address      varchar(30),
    employee_ssn char(9) foreign key references employee (ssn)
)


create table dependent
(
    name         varchar(20),
    age          int,
    employee_ssn char(9) foreign key references employee (ssn),
    primary key (name, employee_ssn)
)

create table account
(
    number    int primary key identity (1,1),
    balance   float default 0,
    owner_ssn char(9),
    foreign key (owner_ssn) references customer (ssn) on delete cascade
)


create table saving_account
(
    number        int not null,
    interest_rate float default 0.05,
    foreign key (number) references account (number) on delete cascade
)

create table checking_account
(
    number           int not null,
    overdraft_amount float default 500,
    foreign key (number) references account (number) on delete cascade
)

create table branch
(
    name           varchar(10) primary key,
    city           varchar(10),
    available_cash float
)

create table loan
(
    number       int primary key identity (1,1),
    amount       float not null,
    customer_ssn char(9) foreign key references customer (ssn),
    branch_name  varchar(10) foreign key references branch (name),
    borrow_date  date
)

create table payment
(
    number  int primary key identity (1,1),
    loan_no int   not null foreign key references loan (number),
    amount  float not null,
    date    date
)

create table trans
(
    customer_ssn char(9) not null foreign key references customer (ssn),
    account_no   int     not null foreign key references account (number),
    date         date,
    type         char    not null,
    amount       float   not null
)


go
/* create function to make the account for existing customer*/
create procedure new_account @ssn char(9),
                             @type char
as
begin
    insert into account (owner_ssn) values (@ssn)

    declare @account_number int

    set @account_number = (select max(number) from account where owner_ssn = @ssn)
    if (@type = 's')
        insert into saving_account (number) values (@account_number)
    else
        insert into checking_account (number) values (@account_number)
end


/* Create procedure to add a new customer "Our rules says any customer must have an account" */
/*  1. Add the customer data
	2. Add the customer account
	3. Choose the type of the account */
go
create procedure add_new_customer @ssn char(9),
                                  @name varchar(20),
                                  @address varchar(30),
                                  @employee_ssn char(9),
                                  @account_type char
as
begin
    declare @account_number int
    insert into customer values (@ssn, @name, @address, @employee_ssn)

    execute new_account @ssn, @account_type
end
go

-- changing date format:
set dateformat dmy

GO
-- trigger to decrease the branch-cash when applying new loan from that branch

CREATE TRIGGER branch_cash
    on loan
    after insert
    as
begin
    update branch
    set available_cash = available_cash - loan.amount
    FROM loan
	WHERE branch.name = LOAN.branch_name
end


---------------------------------------------------------------
-- trigger to update balance on transaction

go

CREATE TRIGGER update_balance_on_transaction
    ON trans
    AFTER INSERT
    AS
BEGIN
    IF EXISTS(SELECT 1 FROM inserted WHERE [type] = 'd')
        BEGIN
            UPDATE a
            SET a.balance = a.balance + t.amount
            FROM account a,
                 trans t
            where a.number = t.account_no

        END
    ELSE
        IF EXISTS(SELECT 1 FROM inserted WHERE [type] = 'w')
            BEGIN
                UPDATE a
                SET a.balance = a.balance - t.amount
                FROM account a,
                     trans t
                where a.number = t.account_no

            END
END


-- trigger to decrease the amount of loan after payment
go
CREATE TRIGGER update_loan_amount
    on payment
    after insert
    as
BEGIN
    UPDATE loan
    SET amount = l.amount - p.amount
    from payment p,
         loan l
    WHERE l.number = p.loan_no;
END
go


/*********************************************************************************************************/
-- data insertion


/* Insert employees data */

insert into employee
values (780924598, 'mohamed ahmed', '01111111111', '10-10-2001', null),
       (193702892, 'Johnny nabil', '01000000000', '02-12-2000', 780924598),
       (11111111, 'Adel said', '01113111111', '12-12-2005', 193702892),
       (222222222, 'ibrahim mohamed', '01040500000', '02-12-2003', 780924598),
       (333333333, 'ahmed Hosni', '01040000000', '03-01-2006', 780924598)

insert into dependent
values ('loay', 11, 780924598),
       ('salma', 12, 780924598),
       ('michel', 5, 193702892),
       ('rahma', 2, 222222222),
	   ('esraa', 5, 222222222),
	   ('ahmed', 10, 222222222),
	   ('mohamed', 16, 333333333)


	   
execute add_new_customer 123456789, 'mohamed samy', '16 helw st', 11111111, 'c';
execute add_new_customer 678432109, 'ahmed kamal', '23 el nady st', 222222222, 's';
execute add_new_customer 567865558, 'nada kamel', '43 galaa st', 193702892, 'c';
execute add_new_customer 674993893, 'mostafa alaa', '25 hassan st', 333333333, 's';

update account set balance = 2000 where number = 1
update account set balance = 4000.5 where number = 2
update account set balance = 1000.25 where number = 3
update account set balance = 2000.05 where number = 4

insert into TRANS  VALUES ('123456789', 1, '1/1/2023', 'd', 200),
                          ('123456789', 1, '1/1/2023', 'w', 2000),
                          ('123456789', 1, '2/1/2023', 'w', 500),
	                      ('123456789', 1, '3/1/2023', 'd', 250),
						  ('678432109', 2, '4/12/2021', 'd', 5000),
						  ('678432109', 2, '26/12/2020', 'w', 3000),
						  ('678432109', 2, '26/12/2020', 'w', 3000),
						  ('567865558', 3, '2/3/2019', 'd', 650),
						  ('674993893', 4, '22/9/2018', 'w', 850)



		
insert into branch
values ('hekma', 'tanta', 500000),
        ('stanly', 'alex', 1000000),
		('nozha', 'cairo', 25000000)

insert into loan (amount, customer_ssn, branch_name, borrow_date)
values (10000, '123456789', 'hekma', '25/1/2011'),
       (50000, '678432109', 'hekma', '25/1/2022'),
	   (500000, '567865558', 'nozha', '25/2/2022')
	   

insert into payment (loan_no, amount, date)
values (1, 500, '25/1/2012'),
       (2, 2500,'29/7/2022'),
	   (3, 25000,'30/9/2022')



-------------------------------------------------------------------------------------

-----------------------VIEWS---------------------------------------------------------


-- views customer data

CREATE VIEW customer_data 
AS
SELECT c.name, c.address, c.employee_ssn, c.ssn, acc.number, acc.balance
FROM customer c
         INNER JOIN account acc ON c.ssn = acc.owner_ssn;

-- call the view

--   SELECT * FROM customer_data;

----------------------------------------------------------------------------------------

-------------------------------QUIRIES--------------------------------------------------

--Find the total number of loans granted by a specific branch:

/*
SELECT COUNT(*)
FROM loan
WHERE branch_name = 'NOZHA';
*/

--Find the average balance for all saving accounts:

/*
SELECT count(a.balance)
FROM saving_account sa
         INNER JOIN account a ON sa.number = a.number;

		 */

--Find the average balance for all saving accounts:

/*
SELECT AVG(a.balance)
FROM saving_account sa
         INNER JOIN account a ON sa.number = a.number;
		 */

--Find the names and phone numbers of all employees who have dependents:


/*
SELECT e.name, e.phone_num
FROM employee e
         INNER JOIN dependent d ON e.ssn = d.employee_ssn
GROUP BY e.name, e.phone_num;
*/

--Find the total amount of payments made on each loan:

/*
SELECT l.number, SUM(p.amount) AS total_payments
FROM loan l
         INNER JOIN payment p ON l.number = p.loan_no
GROUP BY l.number;

*/

--Find the total number of transactions made by each customer, along with the customer's name:

/*

SELECT c.name, COUNT(t.customer_ssn) AS total_transactions
FROM trans t
         INNER JOIN customer c ON t.customer_ssn = c.ssn
GROUP BY c.name;  

*/

