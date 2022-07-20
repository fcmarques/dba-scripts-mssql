<<<<<<< HEAD


SELECT name, (size*8)/1024, 
	(FILEPROPERTY(name,'SpaceUsed')*8)/1024
	FROM sys.database_files
	where type=0

	size/128-((CAST(FILEPROPERTY(name,'SpaceUsed')as int)/128)) as freespace,
		((CAST(FILEPROPERTY(name,'SpaceUsed')as int)/128))

		sp_spaceused [qa1.MSEG]

		select 232589952/1024/1024
=======


SELECT name, (size*8)/1024, 
	(FILEPROPERTY(name,'SpaceUsed')*8)/1024
	FROM sys.database_files
	where type=0

	size/128-((CAST(FILEPROPERTY(name,'SpaceUsed')as int)/128)) as freespace,
		((CAST(FILEPROPERTY(name,'SpaceUsed')as int)/128))

		sp_spaceused [qa1.MSEG]

		select 232589952/1024/1024
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
		1.331.422.991 