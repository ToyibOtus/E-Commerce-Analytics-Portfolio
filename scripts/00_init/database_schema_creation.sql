/*
=====================================================================
Script    : database_schema_creation.sql
Location  : scripts/00_init/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-08
=====================================================================
Script Purpose:
	This script creates a new database [SalesDB]. It also creates 
	3 schemas in the newly generated database.

Schemas Created:
	bronze
	silver
	gold
=====================================================================
*/
-- Use master database
USE master;
GO

-- Drop database [SalesDB] if exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'SalesDB')
BEGIN
	ALTER DATABASE SalesDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE SalesDB;
END;
GO

-- Create database [SalesDB]
CREATE DATABASE SalesDB;
GO

-- Use newly generated  database [SalesDB]
USE SalesDB;
GO

-- Create schema [bronze]
CREATE SCHEMA bronze;
GO

-- Create schema [silver]
CREATE SCHEMA silver;
GO

-- Create schema [gold]
CREATE SCHEMA gold;
GO
