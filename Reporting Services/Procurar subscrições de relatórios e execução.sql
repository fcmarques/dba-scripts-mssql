use [ReportServer$MAPS]
go
SELECT
      S.ScheduleID AS SQLAgent_Job_Name
      ,SUB.Description AS Sub_Desc
      ,SUB.DeliveryExtension AS Sub_Del_Extension
      ,C.Name AS ReportName
      ,C.Path AS ReportPath
FROM ReportSchedule RS (NOLOCK)
      INNER JOIN Schedule S (NOLOCK) ON (RS.ScheduleID = S.ScheduleID) 
      INNER JOIN Subscriptions SUB (NOLOCK) ON (RS.SubscriptionID = SUB.SubscriptionID) 
      INNER JOIN [Catalog] C (NOLOCK) ON (RS.ReportID = C.ItemID AND SUB.Report_OID = C.ItemID)
WHERE 
      SUB.Description like '%dba%' -- parte do email de subscrição
