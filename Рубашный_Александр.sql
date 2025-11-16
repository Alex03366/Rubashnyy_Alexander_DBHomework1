create table temp_transactions (
    transaction_id integer,
    product_id integer,
    customer_id integer,
    transaction_date text,
    online_order text,
    order_status text,
    brand text,
    product_line text,
    product_class text,
    product_size text,
    list_price text,
    standard_cost text
);

create table temp_customers (
    customer_id integer,
    first_name text,
    last_name text,
    gender text,
    dob text,
    job_title text,
    job_industry_category text,
    wealth_segment text,
    deceased_indicator text,
    owns_car text,
    address text,
    postcode text,
    state text,
    country text,
    property_valuation integer
);

create table brands (
    brand_id serial primary key,
    brand_name varchar(100) not null unique
);

create table product_lines (
    product_line_id serial primary key,
    line_name varchar(50) not null unique
);

create table product_classes (
    product_class_id serial primary key,
    class_name varchar(50) not null unique
);

create table product_sizes (
    product_size_id serial primary key,
    size_name varchar(50) not null unique
);

create table customers (
    customer_id integer primary key,
    first_name varchar(100),
    last_name varchar(100),
    gender varchar(10),
    date_of_birth date,
    job_title varchar(100),
    job_industry_category varchar(50),
    wealth_segment varchar(50),
    deceased_indicator varchar(1),
    owns_car varchar(3),
    address text,
    postcode varchar(10),
    state varchar(50),
    country varchar(50),
    property_valuation integer
);

create table products (
    product_id integer primary key,
    brand_id integer not null,
    product_line_id integer not null,
    product_class_id integer not null,
    product_size_id integer not null,
    standard_cost decimal(10,2) not null,
    foreign key (brand_id) references brands(brand_id),
    foreign key (product_line_id) references product_lines(product_line_id),
    foreign key (product_class_id) references product_classes(product_class_id),
    foreign key (product_size_id) references product_sizes(product_size_id)
);

create table transactions (
    transaction_id integer primary key,
    product_id integer not null,
    customer_id integer not null,
    transaction_date date not null,
    online_order boolean not null,
    order_status varchar(50) not null,
    list_price decimal(10,2) not null,
    foreign key (product_id) references products(product_id),
    foreign key (customer_id) references customers(customer_id)
);

insert into brands (brand_name)
select distinct brand from temp_transactions;

insert into product_lines (line_name) 
select distinct product_line from temp_transactions;

insert into product_classes (class_name) 
select distinct product_class from temp_transactions;

insert into product_sizes (size_name) 
select distinct product_size from temp_transactions;

insert into customers (customer_id, first_name, last_name, gender, date_of_birth, job_title, job_industry_category, wealth_segment, deceased_indicator, owns_car, address, postcode, state, country, property_valuation)
select 
    customer_id,
    first_name,
    last_name,
    gender,
    to_date(dob, 'YYYY-MM-DD'),
    job_title,
    job_industry_category,
    wealth_segment,
    deceased_indicator,
    owns_car,
    address,
    postcode,
    state,
    country,
    property_valuation
from temp_customers;

insert into products (product_id, brand_id, product_line_id, product_class_id, product_size_id, standard_cost)
select distinct on (t.product_id)
    t.product_id,
    b.brand_id,
    pl.product_line_id,
    pc.product_class_id,
    ps.product_size_id,
    case 
        when t.standard_cost = '' or t.standard_cost is null then 0
        else cast(replace(t.standard_cost, ',', '.') as decimal(10,2))
    end as standard_cost
from temp_transactions t
join brands b on t.brand = b.brand_name
join product_lines pl on t.product_line = pl.line_name
join product_classes pc on t.product_class = pc.class_name
join product_sizes ps on t.product_size = ps.size_name
where t.product_id is not null and t.product_id != 0;

insert into transactions (transaction_id, product_id, customer_id, transaction_date, online_order, order_status, list_price)
select 
    transaction_id,
    product_id,
    customer_id,
    to_date(transaction_date, 'MM/DD/YYYY'),
    case when online_order = 'True' then true else false end,
    order_status,
    cast(replace(list_price, ',', '.') as decimal(10,2))
from temp_transactions
where product_id is not null and product_id != 0;

drop table if exists temp_transactions;
drop table if exists temp_customers;

select 
    t.transaction_id,
    c.customer_id,
    c.first_name,
    c.last_name,
    b.brand_name,
    p.product_id,
    t.transaction_date,
    t.list_price
from transactions t
join customers c on t.customer_id = c.customer_id
join products p on t.product_id = p.product_id
join brands b on p.brand_id = b.brand_id
limit 10;
