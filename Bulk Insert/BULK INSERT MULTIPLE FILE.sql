<<<<<<< HEAD
--BULK INSERT MULTIPLE FILE 
    --a table to loop thru filenames drop table ALLFILENAMES
    CREATE TABLE ALLFILENAMES(WHICHPATH VARCHAR(255),WHICHFILE varchar(255))
    --the source table: yours already exists, but needed for this example.
    CREATE TABLE BULKACT(RAWDATA VARCHAR (8000))
    --some variables
    declare @filename varchar(255),
            @path     varchar(255),
      @sql      varchar(8000),
            @cmd      varchar(1000)
    --get the list of files to process:
    --#########################################
    SET @path = 'C:\DB\'
    SET @cmd = 'dir ' + @path + '*.txt /b'
    INSERT INTO  ALLFILENAMES(WHICHFILE)
    EXEC Master..xp_cmdShell @cmd
    UPDATE ALLFILENAMES SET WHICHPATH = @path where WHICHPATH is null

    SET @path = 'C:\DB2\'
    SET @cmd = 'dir ' + @path + '*.txt /b'
    INSERT INTO  ALLFILENAMES(WHICHFILE)
    EXEC Master..xp_cmdShell @cmd
    UPDATE ALLFILENAMES SET WHICHPATH = @path where WHICHPATH is null

    SET @path = 'C:\DB3\'
    SET @cmd = 'dir ' + @path + '*.txt /b'
    INSERT INTO  ALLFILENAMES(WHICHFILE)
    EXEC Master..xp_cmdShell @cmd
    UPDATE ALLFILENAMES SET WHICHPATH = @path where WHICHPATH is null

    SET @path = 'C:\DB4\'
    SET @cmd = 'dir ' + @path + '*.txt /b'
    INSERT INTO  ALLFILENAMES(WHICHFILE)
    EXEC Master..xp_cmdShell @cmd
    UPDATE ALLFILENAMES SET WHICHPATH = @path where WHICHPATH is null
    --#########################################
    --cursor loop
    declare c1 cursor for SELECT WHICHPATH,WHICHFILE FROM ALLFILENAMES where WHICHFILE like '%.txt%'
    open c1
    fetch next from c1 into @path,@filename
    While @@fetch_status <> -1
      begin
    --bulk insert won't take a variable name, so make a sql and execute it instead:
       set @sql = 'BULK INSERT BULKACT FROM ''' + @path + @filename + ''' '
           + '     WITH ( 
                   DATAFILETYPE = ''char'', 
                   FIELDTERMINATOR = '','', 
                   ROWTERMINATOR = ''\n'', 
                   FIRSTROW = 2 
                ) '
    print @sql
    exec (@sql)

      fetch next from c1 into @path,@filename
      end
    close c1
=======
--BULK INSERT MULTIPLE FILE 
    --a table to loop thru filenames drop table ALLFILENAMES
    CREATE TABLE ALLFILENAMES(WHICHPATH VARCHAR(255),WHICHFILE varchar(255))
    --the source table: yours already exists, but needed for this example.
    CREATE TABLE BULKACT(RAWDATA VARCHAR (8000))
    --some variables
    declare @filename varchar(255),
            @path     varchar(255),
      @sql      varchar(8000),
            @cmd      varchar(1000)
    --get the list of files to process:
    --#########################################
    SET @path = 'C:\DB\'
    SET @cmd = 'dir ' + @path + '*.txt /b'
    INSERT INTO  ALLFILENAMES(WHICHFILE)
    EXEC Master..xp_cmdShell @cmd
    UPDATE ALLFILENAMES SET WHICHPATH = @path where WHICHPATH is null

    SET @path = 'C:\DB2\'
    SET @cmd = 'dir ' + @path + '*.txt /b'
    INSERT INTO  ALLFILENAMES(WHICHFILE)
    EXEC Master..xp_cmdShell @cmd
    UPDATE ALLFILENAMES SET WHICHPATH = @path where WHICHPATH is null

    SET @path = 'C:\DB3\'
    SET @cmd = 'dir ' + @path + '*.txt /b'
    INSERT INTO  ALLFILENAMES(WHICHFILE)
    EXEC Master..xp_cmdShell @cmd
    UPDATE ALLFILENAMES SET WHICHPATH = @path where WHICHPATH is null

    SET @path = 'C:\DB4\'
    SET @cmd = 'dir ' + @path + '*.txt /b'
    INSERT INTO  ALLFILENAMES(WHICHFILE)
    EXEC Master..xp_cmdShell @cmd
    UPDATE ALLFILENAMES SET WHICHPATH = @path where WHICHPATH is null
    --#########################################
    --cursor loop
    declare c1 cursor for SELECT WHICHPATH,WHICHFILE FROM ALLFILENAMES where WHICHFILE like '%.txt%'
    open c1
    fetch next from c1 into @path,@filename
    While @@fetch_status <> -1
      begin
    --bulk insert won't take a variable name, so make a sql and execute it instead:
       set @sql = 'BULK INSERT BULKACT FROM ''' + @path + @filename + ''' '
           + '     WITH ( 
                   DATAFILETYPE = ''char'', 
                   FIELDTERMINATOR = '','', 
                   ROWTERMINATOR = ''\n'', 
                   FIRSTROW = 2 
                ) '
    print @sql
    exec (@sql)

      fetch next from c1 into @path,@filename
      end
    close c1
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
    deallocate c1