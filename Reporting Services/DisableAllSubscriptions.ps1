#DISABLE all subscriptions  
$rs2010 = New-WebServiceProxy -Uri "http://SQLDBGENCONT/ReportServer/ReportService2005.asmx" -Namespace SSRS.ReportingService2010 -UseDefaultCredential;  
$subscriptions = $rs2010.ListSubscriptions("/") ;  
ForEach ($subscription in $subscriptions)  
{  
    $rs2010.DisableSubscription($subscription.SubscriptionID);  
    $subscription | select subscriptionid, report, path  
}  