1.
/*
 * �� �����ϼ� ���ϱ�
 */
SELECT SUM (visit_date) FROM (SELECT (visit_end_date - visit_start_date +1 ) --'�湮������-�湮������+1'�� �� �����ϼ��� ����
 AS visit_date FROM visit_occurrence) A;



/*
 * �� �����ϼ��� �ִ񰪰� �ּڰ� ���ϱ�
 */
SELECT MAX(visit_date), MIN(visit_date) FROM  --�� �����ϼ��� �ִ񰪰� �ּڰ�
(SELECT (visit_end_date - visit_start_date +1) AS visit_date FROM visit_occurrence) A;


2.

select distinct A.concept_name --�ߺ������ 
from concept A inner join condition_occurrence B 
ON A.concept_id = B.condition_concept_id where upper(A.concept_name) ~ '^A|^B|^C|^D|^E' and A.concept_name like '%heart%'; --A~E �� heart����

3.
SELECT *, (drug_exposure_end_date - drug_exposure_start_date) AS drug_exposure_date --������ -�������� �����Ϸ� ����
FROM drug_exposure
WHERE person_id = '1891866'
ORDER BY drug_exposure_date DESC;  --order by�� ������ �������� ����













4.
with drug_list as ( 
select distinct drug_concept_id, concept_name, count(*) as cnt from drug_exposure de 
join concept 
on drug_concept_id = concept_id 
where concept_id in ( 
40213154,19078106,19009384,40224172,19127663,1511248,40169216,1539463, 19126352,1539411,1332419,40163924,19030765,19106768,19075601) group by drug_concept_id,concept_name 
order by count(*) desc 
) 
, drugs as (select drug_concept_id, concept_name from drug_list)
, prescription_count as (select drug_concept_id, cnt from drug_list)
, drug_pair_cnt1 as (select drug_concept_id1, drug_concept_id2, cnt as cnt1 from drug_pair A inner join prescription_count B on A.drug_concept_id1 = B.drug_concept_id)-- 1��° ������ cnt ��
, drug_pair_cnt2 as (select drug_concept_id1, drug_concept_id2, cnt as cnt2 from drug_pair A inner join prescription_count B on A.drug_concept_id2 = B.drug_concept_id)-- 2��° ������ cnt ��
select C.concept_name, cnt1
from drug_pair_cnt1 A inner join drug_pair_cnt2 B on (A.drug_concept_id1 = B.drug_concept_id1 and A.drug_concept_id2 = B.drug_concept_id2 and B.cnt2 > A.cnt1)
 inner join drug_list C on A.drug_concept_id1  = C.drug_concept_id
 order by cnt1