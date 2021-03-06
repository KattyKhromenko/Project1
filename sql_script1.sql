#создание базы данных
create database exercise1;

#cоздание таблицы Orderlog для загрузки данных из файла Orderlog20151222
use exercise1;
create table Orderlog(
NO BIGINT PRIMARY KEY not null, 
SECCODE text, 
BUYSELL CHAR(1), 
TIME INT, 
ORDERNO BIGINT unsigned,
ACTION BIGINT unsigned,
PRICE FLOAT,
VOLUME BIGINT unsigned,
TRADENO TEXT,
TRADEPRICE TEXT);

SET autocommit =0;
SET unique_checks = 0;
SET foreign_key_checks = 0;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/OrderLog20151222.csv' 
INTO TABLE Orderlog
FIELDS TERMINATED BY ','
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(NO,SECCODE,BUYSELL,TIME,ORDERNO,ACTION,PRICE,VOLUME,TRADENO,TRADEPRICE);

COMMIT;

SET unique_checks = 1;
SET foreign_key_checks = 1;
 
#создание таблицы для загрузки классификатора
use exercise1;
create table list(
Instrument_id bigint, 
Instrument_type varchar(100),
TRADE_CODE varchar(30) not NULL);
LOAD DATA Infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ListingSecurityList.csv'
INTO TABLE list
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

#запрос, который позволяет выгрузить из Orderlog данные по привилегированным акциям 
SELECT NO,SECCODE,BUYSELL,TIME,ORDERNO,ACTION,PRICE,VOLUME,TRADENO,TRADEPRICE
FROM Orderlog JOIN list
ON SECCODE=TRADE_CODE
WHERE INSTRUMENT_TYPE='Акция привилегированная'

#запрос, который позволяет выгрузить из Orderlog данные по обыкновенным акциям 
SELECT SECCODE,BUYSELL,TIME,ORDERNO,ACTION,PRICE,VOLUME,TRADENO,TRADEPRICE
FROM Orderlog JOIN list
ON SECCODE=TRADE_CODE
WHERE INSTRUMENT_TYPE='Акция обыкновенная'

#запрос, который позволяет выгрузить из Orderlog данные по облигациям
SELECT SECCODE,BUYSELL,TIME,ORDERNO,ACTION,PRICE,VOLUME,TRADENO,TRADEPRICE
FROM Orderlog JOIN list
ON SECCODE=TRADE_CODE
WHERE INSTRUMENT_TYPE='Облигация биржевая' or 'Облигация федеральная' or 'Облигация муниципальная' or 'Еврооблигация'  
or 'Облигация инностранного эмитента' or 'Облигация Банка России' or 'Облигация федерального займа' or 
'Облигация корпоративная'

#Проверка на наличие отрицательных значений
use exercise1;
SELECT *,
CASE WHEN NO < 0 or SECCODE < 0 or BUYSELL <0 or TIME < 0 or ORDERNO < 0 or ACTION < 0 or PRICE < 0 or VOLUME < 0
THEN 'NEGATIVE VALUES'
else 'NO NEGATIVE VALUES'
END AS `NEGATIVE NUMBERS CHECK` 
from Orderlog;

#Проверка на наличие нулевого объема
use exercise1;
select *
from Orderlog
where VOLUME IS NULL;

#Проверка на наличие нулевой цены 
use exercise1;
select *
from Orderlog
where PRICE IS NULL;

#Проверка на нули и пропущенные значения
SELECT *,
CASE WHEN NO or SECCODE or BUYSELL or TIME or ORDERNO or ACTION or PRICE or VOLUME  or TRADENO or TRADEPRICE is NULL or
NO or SECCODE or BUYSELL or TIME or ORDERNO or ACTION or PRICE or VOLUME or TRADENO or TRADEPRICE =''
THEN 'Zero or empty values'
else 'NO zero or empty values'
END AS `ZERO AND EMPTY VALUES CHECK` 
from Orderlog;

#поиск тикера, по которому было совершено наибольшее количество рыночных сделок
SELECT SECCODE,
count(SECCODE) from Orderlog JOIN list
ON SECCODE=TRADE_CODE
where INSTRUMENT_TYPE='Акция обыкновенная' and PRICE is NULL
group by SECCODE
order by count(SECCODE) 
desc limit 1;


