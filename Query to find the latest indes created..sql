select STATS_DATE(so.object_id, index_id) StatsDate
, si.name IndexName
, schema_name(so.schema_id) + N'.' + so.Name TableName
, so.object_id, si.index_id
from sys.indexes si
inner join sys.tables so on so.object_id = si.object_id WHERE si.name LIKE ('%miss%')
order by 1 DESC


select 
DISTINCT
 schema_name(so.schema_id) + N'.' + so.Name TableName

from sys.indexes si
inner join sys.tables so on so.object_id = si.object_id WHERE si.name LIKE ('%miss%')
order by 1 desc