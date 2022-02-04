1. 총내원일수, 최댓값 최솟값을 구하기 위해 visit_end_date - visit_start_date +1 조건을 수행한 사전 테이블 만든 이후 수행
/*
 * 총 내원일수의 최댓값과 최솟값 구하기
 */
SELECT SUM(visit_date), MAX(visit_date), MIN(visit_date) FROM  --총 내원일수의 최댓값과 최솟값
(SELECT (visit_end_date - visit_start_date +1) AS visit_date FROM visit_occurrence) A;


2. UPPER를 사용하여 대소문자 구분없이 데이터를 추출하고 추출한 데이터에서 heart 문자열이 있는 조건을 추가하여 추출
select distinct A.concept_name --중복비허용 
from concept A inner join condition_occurrence B 
ON A.concept_id = B.condition_concept_id where upper(A.concept_name) ~ '^A|^B|^C|^D|^E' and A.concept_name like '%heart%'; --A~E 및 heart포함

3. 복용 종요일과 복용 시작일의 차이를 구해 순서 정렬
SELECT *, (drug_exposure_end_date - drug_exposure_start_date) AS drug_exposure_date --종료일 -시작일을 복용일로 지정
FROM drug_exposure
WHERE person_id = '1891866'
ORDER BY drug_exposure_date DESC;  --order by로 복용일 내림차순 정렬

4. 사전에 만들어진 조건인 drug_list, drugs, prescription_count를 사용하여 짝지어진 처방건수의 drug_concept_id1, drug_concept_id2의 count를 구하고 테이블을 조인하여 요구하는 조건 추출 
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
, drug_pair_cnt1 as (select drug_concept_id1, drug_concept_id2, cnt as cnt1 from drug_pair A inner join prescription_count B on A.drug_concept_id1 = B.drug_concept_id) -- 1번째 조건의 cnt 값
, drug_pair_cnt2 as (select drug_concept_id1, drug_concept_id2, cnt as cnt2 from drug_pair A inner join prescription_count B on A.drug_concept_id2 = B.drug_concept_id) -- 2번째 조건의 cnt 값
select C.concept_name, cnt1
from drug_pair_cnt1 A inner join drug_pair_cnt2 B on (A.drug_concept_id1 = B.drug_concept_id1 and A.drug_concept_id2 = B.drug_concept_id2 and B.cnt2 > A.cnt1)
 inner join drug_list C on A.drug_concept_id1  = C.drug_concept_id
 order by cnt1

5. 제 2형 당뇨 진단받은 환자수 테이블을 구하고 18세이상, metformin 테이블을 순차적 구하고 각각의 테이블을 조인이후 진단이후(진단일이 없는 데이터 제외) 90일 이상 복용 조건 추출
with diabetes as (
select * from condition_occurrence where condition_concept_id in ('3191208','36684827','3194332','3193274','43531010','4130162',
'45766052', '45757474','4099651','4129519','4063043','4230254','4193704','4304377','201826','3194082','3192767') --제 2형 당뇨 진단 받은 환자 수 (personid로 count함)
),
birth as (
select *  from person where cast(to_char(now(), 'YYYY') as integer) -  year_of_birth >= 18       --18세 이상인 환자 수
),
metformin as (
select * from drug_exposure where drug_concept_id = '40163924'
)
select *
from diabetes A inner join birth B on A.person_id = B.person_id inner join metformin C on  A.person_id = C.person_id
where drug_exposure_end_date - drug_exposure_start_date >= 90 and condition_start_date is not null; 

6.각각의 패턴을 문자열로 만든후 나열하고 정규식을 사용하여 패턴을 단순화 시킨이후 group by를 사용하여 cnt 값 추출
-- 패턴 고정
select regexp_replace('aaaaabbbbccdaa',  '(.)\1*' ,'\1', 'g') 

7. sql을 사용하여 사전 추출 테이블을 생성하고 python 코드를 사용하여 조건에 맞는 테이블 추출
-- CONTINUING 데이터 제거 후 사전 추출 테이블 생성
CREATE TABLE clinical_note_regex AS select regexp_replace(note, 'CONTINUING.*', '', 'g') from clinical_note;

--이후는 python 코드
