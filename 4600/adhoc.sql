-- Reset the "allow updates" setting to the recommended 0
sp_configure 'allow updates',0;
reconfigure with override
go