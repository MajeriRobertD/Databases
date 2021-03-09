CREATE DATABASE lab1;
USE lab1;

CREATE TABLE dbo.actor(
	actor_name varchar(100) PRIMARY KEY,
	age INT,
);
	
CREATE TABLE dbo.series(
	sname varchar(100) PRIMARY KEY,
	fk_rating int  UNIQUE FOREIGN KEY REFERENCES rating(rid)
);

CREATE TABLE actor_series_relation(
	aid varchar(100) FOREIGN KEY(aid) REFERENCES actor(actor_name),
	sid varchar(100) FOREIGN KEY(sid) REFERENCES series(sname),
	UNIQUE (aid, sid)
);

create TABLE dbo.prize(
pname varchar(100) PRIMARY key ,
fk_actor_name varchar(100) FOREIGN key REFERENCES actor(actor_name)

);
create TABLE dbo.rating(
rid int IDENTITY(1,1) PRIMARY KEY,
rating_value int;
);
 
create TABLE dbo.genre(
gname varchar(100) PRIMARY KEY,
);
create TABLE series_genre_relation(
sid varchar(100) FOREIGN KEY(sid) REFERENCES series(sname),
gid varchar(100) FOREIGN KEY(gid) REFERENCES genre(gname)
)
--QUERIES AND STUFF |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
insert into actor  values('Ioan', 78);
insert into actor  values('Marian', 19);
insert into actor VALUES('Vasi', 90);
insert into actor VALUES('John', 28);
insert into actor values('Kennedy', 32);
insert into actor VALUES('Edward', 12);
insert into actor values('Robert', 16);
insert into actor values('Marcel',18);
insert into actor values('Maria', 18);

insert into rating VALUES(1);
insert into rating VALUES(2);
insert into rating VALUES(3);
insert into rating VALUES(4);
insert into rating VALUES(5);
insert into rating VALUES(6);
insert into rating VALUES(7);				
insert into rating VALUES(8);
insert into rating VALUES(9);
insert into rating VALUES(10);
--realised that the rating values should be unique, so we drop everything in order to modify it
DELETE FROM rating;
--resetting the identity count
DBCC CHECKIDENT ('rating', RESEED, 0);
--alter the table to make the rating_value unique 
alter table rating
ADD UNIQUE (rating);

insert into series(sname, fk_rating) VALUES('Vikings', 9);
insert into series(sname, fk_rating) VALUES('Sons of Anarchy', 10);
insert into series(sname, fk_rating) VALUES('Lost', 8);
insert into series(sname, fk_rating) VALUES('Silicon Valley', 7);
insert into series(sname, fk_rating) VALUES('Riverdale', 1);
insert into series(sname, fk_rating) VALUES('Originals', 2);
insert into series(sname, fk_rating) VALUES('Game of Thrones', 9);
insert into series(sname, fk_rating) VALUES('The Big Bang Theory', 8);
insert into series values ('serial slab', 3);

insert into actor_series_relation(aid, sid) VALUES('Ioan','Vikings');
insert into actor_series_relation(aid, sid) VALUES('Marian', 'Vikings');
insert into actor_series_relation(aid, sid) VALUES('Vasi', 'Lost');
insert into actor_series_relation(aid, sid) VALUES('Marian', 'Lost');
insert into actor_series_relation(aid, sid) VALUES('John', 'Sons of Anarchy');
insert into actor_series_relation(aid, sid) VALUES('Kennedy', 'Riverdale');
insert into actor_series_relation(aid, sid) VALUES('Robert', 'Vikings');
insert into actor_series_relation(aid, sid) VALUES('Edward', 'Silicon Valley');
insert into actor_series_relation(aid, sid) VALUES('Marcel', 'Silicon Valley');
insert into actor_series_relation(aid, sid) VALUES('Maria', 'Silicon Valley');
insert into actor_series_relation(aid, sid) VALUES('Maria', 'Originals');


insert into prize values('Best lead role', 'Vasi');
insert into prize values('Best secondary role', 'Marian');
insert into prize values('Best male actor', 'Marian');
insert into prize values('Oscar', 'Robert');
insert into prize values('Best comediant', 'Edward');

insert into genre VALUES('Comedy');
insert into genre VALUES('Horror');
insert into genre VALUES('Sci-fi');
insert into genre VALUES('Drama');
insert into genre VALUES('Romance');
insert into genre VALUES('Action');

insert into series_genre_relation VALUES('Vikings', 'Action');
insert into series_genre_relation VALUES('Vikings', 'Drama');
insert into series_genre_relation VALUES('Riverdale', 'Comedy');
insert into series_genre_relation VALUES('Riverdale', 'Romance');
insert into series_genre_relation VALUES('Lost', 'Action');
insert into series_genre_relation VALUES('Silicon Valley', 'Comedy');


alter table actor_series_relation
ADD CONSTRAINT [update_constraint]
FOREIGN KEY(aid) REFERENCES actor(actor_name)
ON DELETE CASCADE ON UPDATE CASCADE
GO
--Update
UPDATE actor 
SET actor_name = 'actor slab'
FROM actor_series_relation asr
where asr.sid ='Riverdale'

UPDATE actor
set age = age +1 
where actor_name LIKE 'M__%'

update actor_series_relation
set sid = 'serial slab'
where aid like 'k%'

--delete
delete from actor_series_relation
where sid = 'serial slab'

DELETE from actor
where age in (1,5,6,28)

alter table series
drop CONSTRAINT UQ__series__6C1354BC414C7DA9



--SHOW TABLES;
select * from actor_series_relation ;
select * from actor;

--return the names of the actors that played in Vikings and Lost
select aid
from actor_series_relation
where sid = 'Vikings'
UNION
select aid
from actor_series_relation asr
where sid = 'Lost'

--return actors that played in vikings and whose name doesn't start with I
select asr.aid
from actor_series_relation asr
where asr.sid = 'Vikings'
EXCEPT
select asr2.aid
from actor_series_relation asr2
where asr2.aid like 'I%'


--return actors that played in Lost and are younger than 21
select asr.aid
from actor_series_relation asr
where asr.sid ='Lost'
INTERSECT
select a.actor_name
from actor a
where a.age<21

--get the actors and their awards that are younger than 18
select actor.actor_name, prize.pname
from actor
inner join prize on actor.actor_name = prize.fk_actor_name
where actor.age  < 18
order by actor.age

--get all actors in order to see who has awards
select actor.actor_name, prize.pname
from actor
left join prize on actor.actor_name = prize.fk_actor_name

--get all genres with the related series
select series_genre_relation.sid, genre.gname
from series_genre_relation
RIGHT join genre on series_genre_relation.gid = genre.gname

--select age, actor name, series and genre
select actor.age , actor.actor_name, actor_series_relation.sid, series_genre_relation.gid
from actor
full join actor_series_relation on actor.actor_name = actor_series_relation.aid
full join series_genre_relation on actor_series_relation.sid = series_genre_relation.sid

-- get all actors that played in any series with action genre
select DISTINCT aid
from actor_series_relation
where sid in (SELECT sid 
				from series_genre_relation 
				where gid = 'Action' )

--select all series in which act actors younger than 21
select DISTINCT sid
from actor_series_relation
where EXISTS (SELECT aid
				from actor
				where actor.actor_name = actor_series_relation.aid
				AND age < 21)
				

--get the actors that played in Vikings and their age
select A.aid,A.age
from (select  asr.aid , a.age
		from actor_series_relation asr  inner join actor a  on asr.aid = a.actor_name
		where asr.sid = 'Vikings' )A
		order by age


		
-- return the number of actors in each series with more than 1 actor
select count(aid), sid
from (actor_series_relation inner join  actor on actor.actor_name = actor_series_relation.aid)
GROUP by  sid
having count(aid) >1

--return the age average of all actors for each series
select asr.sid, AVG(a.age)
from actor_series_relation asr inner join actor a
on asr.aid = a.actor_name
GROUP BY sid

--return the series in which the average age of the actors is higher than 30 and lower than 50
select asr.sid, AVG(a.age) as Average
from actor_series_relation asr inner join actor a
on asr.aid = a.actor_name
GROUP BY sid
having AVG(a.age) > 30 and AVG(a.age) < 50
	

--return the series in which the age of the actors is higher than the average
select asr.sid, AVG(a.age) as Average
from actor_series_relation asr inner join actor a
on asr.aid = a.actor_name
GROUP BY sid, a.age
having a.age > ( select AVG(age) from actor)


	
		
-- top 3 rated series	
select top  3 sname, fk_rating
from series s
order by fk_rating desc;


create  PROCEDURE test as 
select * from actor
GO

exec test

CREATE PROCEDURE p1 AS
BEGIN
	ALTER TABLE actor
	ADD Manager varchar(100)
END

EXECUTE rp4

CREATE PROCEDURE rp1 as 
BEGIN
	Alter table actor
	DROP COLUMN Manager 
END


CREATE or alter  PROCEDURE p2 as 
BEGIN
	create table ChristmasSeries(Cid int not null, numberOfSeries int, daysAvailable int, fk_series varchar(100))
END


CREATE PROCEDURE rp2 as 
BEGIN
	drop table ChristmasSeries
END



CREATE PROCEDURE p3 as 
BEGIN
	alter table ChristmasSeries
	ADD CONSTRAINT pk_christmasSeries_cid PRIMARY KEY(Cid)
END

create or alter PROCEDURE rp3 as
begin 
	alter table ChristmasSeries
	drop CONSTRAINT pk_christmasSeries_cid
end

create PROCEDURE p4 as 
begin 
	alter table ChristmasSeries
	add constraint fk_christmasSeries_series FOREIGN KEY(fk_series) REFERENCES series(sname)
end

create PROCEDURE rp4 as 
BEGIN
	alter table ChristmasSeries
	drop CONSTRAINT fk_christmasSeries_series
END

create table Versions(Vid int PRIMARY KEY, nrVers int not null)

insert into Versions values(0,0)


--the main function
CREATE or ALTER PROCEDURE MAIN @versionToBring INT AS
BEGIN
	DECLARE @versionCurrent int= (select V.nrVers from Versions V)
	DECLARE @procedureToExecute varchar(50)
	IF @versionToBring >4 or @versionToBring <0
	BEGIN
		print('Invalid version number!')
		return
	END
	WHILE @versionToBring < @versionCurrent
	BEGIN
		SET @procedureToExecute= 'rp' + cast(@versionCurrent as varchar(2))
		EXECUTE @procedureToExecute
		SET @versionCurrent= @versionCurrent-1
	END
	WHILE @versionToBring > @	create table ChristmasSeries(Cid int not null, numberOfSeries int, daysAvailable int, add fk_series varchar(100)
versionCurrent
	BEGIN
		PRINT('EXECUTING')
		SET @versionCurrent= @versionCurrent+1
		SET @procedureToExecute= 'p' + cast(@versionCurrent as varchar(2))
		EXEC @procedureToExecute
	END
	DELETE  from Versions
	INSERT INTO Versions VALUES(0,@versionToBring)
END


exec main 11

print 'mesaj'


select * from series_genre_relation;
select * from genre;
select * from actor_series_relation asr;
select * from series
order by fk_rating DESC;

Select * from Versions;



