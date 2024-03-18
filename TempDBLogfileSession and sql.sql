SELECT t1.session_id,
       t1.request_id,
       task_alloc_GB = CAST((t1.task_alloc_pages * 8. / 1024. / 1024.) 
         AS NUMERIC(10, 1)),
       task_dealloc_GB = CAST((t1.task_dealloc_pages * 
          8. / 1024. / 1024.) 
         AS NUMERIC(10, 1)),
       host = CASE
                  WHEN t1.session_id <= 50 THEN
                      'SYS'
                  ELSE
                      s1.host_name
              END,
       s1.login_name,
       s1.status,
       s1.last_request_start_time,
       s1.last_request_end_time,
       s1.row_count,
       s1.transaction_isolation_level,
       query_text = COALESCE(
                    (
                  SELECT SUBSTRING(
                    text,
                    t2.statement_start_offset / 2 + 1,
                    (CASE
                     WHEN statement_end_offset = -1 THEN
                        LEN(CONVERT(NVARCHAR(MAX), text)) * 2
                     ELSE
                        statement_end_offset
                     END - t2.statement_start_offset
                                            ) / 2
                                        )
                        FROM sys.dm_exec_sql_text(t2.sql_handle)
                    ),
                    'Not currently executing'
                            ),
       query_plan =
       (
           SELECT query_plan FROM sys.dm_exec_query_plan(t2.plan_handle)
       )
FROM
(
    SELECT session_id,
           request_id,
           task_alloc_pages = SUM(internal_objects_alloc_page_count 
               + user_objects_alloc_page_count),
           task_dealloc_pages = SUM(internal_objects_dealloc_page_count 
                + user_objects_dealloc_page_count)
    FROM sys.dm_db_task_space_usage
    GROUP BY session_id,
             request_id
) AS t1
    LEFT JOIN sys.dm_exec_requests AS t2
        ON t1.session_id = t2.session_id
           AND t1.request_id = t2.request_id
    LEFT JOIN sys.dm_exec_sessions AS s1
        ON t1.session_id = s1.session_id
-- ignore system unless you suspect there's a problem there
WHERE t1.session_id > 50 
 -- ignore this request itself 
AND t1.session_id <> @@SPID
ORDER BY t1.task_alloc_pages DESC; 


--select vad.fiscalYear, td.TaxDistrictId, td.Label as TaxDistrictName, v.ParcelClassFactorId, sum(par.Amount) as totalAmount 
--into #rawData   from RM_Payment pt with (nolock)    inner join RM_PaymentToParcel p2p with (nolock) on pt.paymentID = p2p.paymentID 
--inner join RM_PaymentToAdderRemitter par with (nolock) on p2p.PaymentToParcelId = par.PaymentToParcelId   
--inner join RM_AdderRemitterCollection arc with (nolock) on par.adderRemitterCollectionID = arc.adderRemitterCollectionID  
--left outer join RM_Parent prt with (nolock) on prt.parentID = arc.billTypeParentID   
--inner join LK_BillType bt with (nolock) on arc.billTypeID = bt.billtypeID   
--inner join LK_BillCharge bc with (nolock) on arc.billChargeID = bc.billChargeID   
--inner join RM_Parcel prc with (nolock) on p2p.parcelID = prc.parcelID  
--inner join vw_AmountDuePeriod vad with (nolock) on vad.amountDuePeriodID = arc.amountDuePeriodID and vad.parcelTypeID = prc.parcelTypeID   
--inner join LK_TaxDistrict td with (nolock) on prc.taxDistrictID = td.taxDistrictID   
--cross apply     (      select top 1 pct.ParcelClassFactorId      from RM_ValueControl vc with (nolock)   
--inner join LK_ParcelClassType pct with (nolock) on vc.FormattedParcelClassTypeId = pct.ParcelClassTypeId  
--where vc.ParcelId = prc.ParcelId       and vc.EffectiveYear = vad.fiscalYear       and vc.statusTypeID <> 71   
--order by vc.valueControlID desc     ) as v   where pt.dexID is not null    and bt.Name = 'BASE'    
--and p2p.effectiveDate >= cast(@startDate as date)    and p2p.effectiveDate < dateAdd(day, 1, cast(@endDate as date))  
--and prc.ParcelTypeId = @ParcelType   group by vad.fiscalYear, td.TaxDistrictId, td.Label, v.ParcelClassFactorId    