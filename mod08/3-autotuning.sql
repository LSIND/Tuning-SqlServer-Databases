-- Системные предстовления для Autotuning

SELECT * FROM sys.dm_db_tuning_recommendations;

SELECT name, reason, score,
    JSON_VALUE(details, '$.implementationDetails.script') AS script,
    details.* 
FROM sys.dm_db_tuning_recommendations
CROSS APPLY OPENJSON(details, '$.planForceDetails')
    WITH (    [query_id] int '$.queryId',
            regressed_plan_id int '$.regressedPlanId',
            last_good_plan_id int '$.recommendedPlanId') AS details
WHERE JSON_VALUE(state, '$.currentValue') = 'Active';




SELECT reason, score,
script = JSON_VALUE(details, '$.implementationDetails.script')
FROM sys.dm_db_tuning_recommendations;