<<<<<<< HEAD
USE [dbdba]
GO

/****** Object:  StoredProcedure [dbo].[pr_checkjob]    Script Date: 18/12/2013 14:15:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[pr_checkjob]
as
set nocount on 
declare @previousdate datetime    
declare @year varchar(4)    
declare @month varchar(2)    
declare @monthpre varchar(2)    
declare @day varchar(2)    
declare @daypre varchar(2)    
declare @finaldate int    
   
-- lambança para converter em int    
set @previousdate = dateadd(dd, -5, getdate()) -- Ultimos 3 days     
set @year = datepart(yyyy, @previousdate)     
select @monthpre = convert(varchar(2), datepart(mm, @previousdate))    
select @month = right(convert(varchar, (@monthpre + 1000000000)),2)    
select @daypre = convert(varchar(2), datepart(dd, @previousdate))    
select @day = right(convert(varchar, (@daypre + 1000000000)),2)    
set @finaldate = cast(@year + @month + @day as int)    
   
declare @text varchar(30)      
set @text = 'Problem: '      
declare @texto varchar(8000)      
set @texto= ''      
   
select @texto = @texto + ' Job:' +  upper(j.Name)    
+ '  Status:' + case h.run_status    
when 0 then 'FALHA #'    
when 1 then 'Successful #'    
when 3 then 'Cancelled #'    
when 4 then 'In progress #'    
end    
from msdb..sysjobhistory h   
inner join msdb..sysjobs j on j.job_id = h.job_id   
where h.run_status not in (1,4)   
and h.run_date = (select max(hi.run_date) from msdb..sysjobhistory hi where h.job_id = hi.job_id)   
and h.run_date >= @finaldate   
group by j.name,h.run_date,h.run_status    
order by j.name   
     
  if len(@texto) > 0      
    begin      
        declare @soma int      
     
        select @soma = convert(int, len(@texto)+10)      
select @soma
     
    END  


GO

=======
USE [dbdba]
GO

/****** Object:  StoredProcedure [dbo].[pr_checkjob]    Script Date: 18/12/2013 14:15:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[pr_checkjob]
as
set nocount on 
declare @previousdate datetime    
declare @year varchar(4)    
declare @month varchar(2)    
declare @monthpre varchar(2)    
declare @day varchar(2)    
declare @daypre varchar(2)    
declare @finaldate int    
   
-- lambança para converter em int    
set @previousdate = dateadd(dd, -5, getdate()) -- Ultimos 3 days     
set @year = datepart(yyyy, @previousdate)     
select @monthpre = convert(varchar(2), datepart(mm, @previousdate))    
select @month = right(convert(varchar, (@monthpre + 1000000000)),2)    
select @daypre = convert(varchar(2), datepart(dd, @previousdate))    
select @day = right(convert(varchar, (@daypre + 1000000000)),2)    
set @finaldate = cast(@year + @month + @day as int)    
   
declare @text varchar(30)      
set @text = 'Problem: '      
declare @texto varchar(8000)      
set @texto= ''      
   
select @texto = @texto + ' Job:' +  upper(j.Name)    
+ '  Status:' + case h.run_status    
when 0 then 'FALHA #'    
when 1 then 'Successful #'    
when 3 then 'Cancelled #'    
when 4 then 'In progress #'    
end    
from msdb..sysjobhistory h   
inner join msdb..sysjobs j on j.job_id = h.job_id   
where h.run_status not in (1,4)   
and h.run_date = (select max(hi.run_date) from msdb..sysjobhistory hi where h.job_id = hi.job_id)   
and h.run_date >= @finaldate   
group by j.name,h.run_date,h.run_status    
order by j.name   
     
  if len(@texto) > 0      
    begin      
        declare @soma int      
     
        select @soma = convert(int, len(@texto)+10)      
select @soma
     
    END  


GO

>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
