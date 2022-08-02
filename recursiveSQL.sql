# PostgreSQL 14
drop table if exists B;
create table B(s int, y int, prob float);
insert into B values(1, 1, 0.33);
insert into B values(1, 2, 0.54);
insert into B values(1, 3, 0.1);
insert into B values(2, 1, 0.5);
insert into B values(2, 2, 0.25);
insert into B values(2, 3, 0.25);
select * from B;

drop table if exists Obs;
create table Obs(j SERIAL PRIMARY KEY, y int);
insert into Obs (y) values(3);
insert into Obs (y) values(3);
insert into Obs (y) values(3);
insert into Obs (y) values(1);
insert into Obs (y) values(3);
insert into Obs (y) values(2);
select * from Obs;

drop table if exists A;
create table A(j_source int, s_source int, s_dest int, j_dest int, w float);
insert into A values(0, 1, 1, 1, 0.5); 
insert into A values(0, 2, 2, 1, 0.5);
insert into A values(1, 1, 1, 2, 0.75);
insert into A values(1, 1, 2, 2, 0.25);
insert into A values(1, 2, 1, 2, 0.4);
insert into A values(1, 2, 2, 2, 0.6);
insert into A values(2, 1, 1, 3, 0.75);
insert into A values(2, 1, 2, 3, 0.25);
insert into A values(2, 2, 1, 3, 0.4);
insert into A values(2, 2, 2, 3, 0.6);
insert into A values(3, 1, 1, 4, 0.75);
insert into A values(3, 1, 2, 4, 0.25);
insert into A values(3, 2, 1, 4, 0.4);
insert into A values(3, 2, 2, 4, 0.6);
insert into A values(4, 1, 1, 5, 0.75);
insert into A values(4, 1, 2, 5, 0.25);
insert into A values(4, 2, 1, 5, 0.4);
insert into A values(4, 2, 2, 5, 0.6);
insert into A values(5, 1, 1, 6, 0.75);
insert into A values(5, 1, 2, 6, 0.25);
insert into A values(5, 2, 1, 6, 0.4);
insert into A values(5, 2, 2, 6, 0.6);
select * from A;


with recursive viterbi (j_source, s_dest, j_dest, x, likelihood) as
(
select A.j_source, A.s_dest, A.j_dest, array[0] as x, A.w*B.prob as likelihood from A 
    inner join Obs on A.j_source = 0 and A.j_dest=Obs.j 
    inner join B on A.s_dest=B.s and Obs.y=B.y
union all
select j_source, s_dest, j_dest, x, likelihood from
(select j_source, s_dest, j_dest, x, likelihood, rank() over (partition by s_source order by likelihood desc) as ranking from (select A.j_source, A.s_source, A.s_dest, A.j_dest, x || array[A.s_source] as x, viterbi.likelihood*A.w*B.prob as likelihood from A
    inner join Obs on A.j_dest=Obs.j 
    inner join B on A.s_dest=B.s and Obs.y=B.y
    inner join viterbi on A.j_source = viterbi.j_dest and A.s_source = viterbi.s_dest) as t) as d where d.ranking = 1
)
select j_source, s_dest, j_dest, x || array[viterbi.s_dest], likelihood from viterbi
where j_dest in (select max(j_dest) from viterbi)
order by likelihood desc limit 1;
