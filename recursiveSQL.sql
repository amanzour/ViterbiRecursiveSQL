-- PostgreSQL 14

-- initialization
drop table if exists PI;
create table PI(s_init int NOT NULL UNIQUE, w float);
insert into PI values(1, 0.5); 
insert into PI values(2, 0.5);

drop table if exists A;
create table A(s_source int, s_dest int, w float);
insert into A values(1, 1, 0.75);
insert into A values(1, 2, 0.25);
insert into A values(2, 1, 0.4);
insert into A values(2, 2, 0.6);

drop table if exists B;
create table B(s int, y int, prob float);
insert into B values(1, 1, 0.33);
insert into B values(1, 2, 0.54);
insert into B values(1, 3, 0.1);
insert into B values(2, 1, 0.5);
insert into B values(2, 2, 0.25);
insert into B values(2, 3, 0.25);

drop table if exists Y;
create table Y(j SERIAL, y int, j_next int GENERATED ALWAYS AS (j + 1) STORED);
insert into Y (y) values(3);
insert into Y (y) values(3);
insert into Y (y) values(3);
insert into Y (y) values(1);
insert into Y (y) values(3);
insert into Y (y) values(2);


-- optimization
with recursive viterbi (j, s, x, likelihood) as
(
select Y.j, PI.s_init, array[0] as x, PI.w*B.prob as likelihood from PI 
    inner join B on PI.s_init=B.s 
    inner join Y on B.y=Y.y and Y.j = 1 
union all
 -- keeping only the columns we would need (read this third)
select j, s_dest, x, likelihood from
 -- keeping only records with most highest likelihood (read this second)   
(select j, s_dest, x, likelihood, rank() over (partition by s_source order by likelihood desc) as ranking from 
 -- the actual recursive call (read this first)
 (select Y.j, A.s_source, A.s_dest, x || array[A.s_source] as x, viterbi.likelihood*A.w*B.prob as likelihood from A
    inner join viterbi on A.s_source = viterbi.s
    inner join B on A.s_dest=B.s 
    inner join Y on B.y=Y.y and viterbi.j + 1 = Y.j
    ) as t) as d where d.ranking = 1
)
-- selecting the most likely path and its corresponding final state
select j, s, x[2:cardinality(x)] || array[s] as states, likelihood from viterbi
where j in (select max(j) from viterbi)
order by likelihood desc limit 1;
