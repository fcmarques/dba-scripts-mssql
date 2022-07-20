#list all subscriptions  
$rs2010 = New-WebServiceProxy -Uri "http://SQLDBGENCONT/ReportServer/ReportService2005.asmx" -Namespace SSRS.ReportingService2010 -UseDefaultCredential;  
$subscriptions = $rs2010.ListSubscriptions();  
$subscriptions | select subscriptionid, report, status, path