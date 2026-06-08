/* 
***************************
Create Database and Schemas
***************************

Purpose: 
  Creates a new database named 'Datawarehouse' after checking if it already exists. 
  If the database exists, it is dropped and recreated. 
  Sets up three schemas within the database: 'bronze', 'silver', and 'gold'.


WARNING:
************************************************************************************************************************************
This script will drop DataWarehouse database if it is initualized, if running after initualization, ensure backups of existing data. 
************************************************************************************************************************************
  */

USE master; 
GO
-- Drop and recreate DataWarehouse database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
  ALTER DATABASE dataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE; --Only allows one connection while executing, disconnects other connections, rolls back uncommitted transactions
  DROP DATABASE DataWArehouse; 
END; 

--Create DataWarehouse database
GO
CREATE DATABASE DataWarehouse; 

--Point to new Database
USE DataWarehouse; 

GO
  
--Create Schemas 
CREATE SCHEMA bronze; 
GO
  
CREATE SCHEMA silver; 
GO
  
CREATE SCHEMA gold; 
