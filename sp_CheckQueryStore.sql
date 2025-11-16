CREATE OR ALTER PROCEDURE [dbo].[sp_CheckQueryStore]
(
	@CheckConfiguration BIT = 0,
	@Databases NVARCHAR(MAX) = 'ALL',
	@ConfigTable NVARCHAR(4000) = NULL,
	@LoggingTable NVARCHAR(4000) = NULL,
	@DefaultAlerting BIT = 1,
	@EnableReadWriteState BIT = 1,
	@UnforceFailedPlans BIT = 1,
	@UnforceFailedPlansThreshold INT = 5,
	@MonitorPlanRegression BIT = 0;
)
AS
BEGIN
/*
sp_CheckQueryStore By DataPaws
Documentation: https://datapawsconsulting.com/sp_CheckQueryStore
Version: 11/16/25 18:48
GitHub: https://github.com/DataPaws/sp_CheckQueryStore

Requirements:
	sp_ineachdb - From Brent Ozar's First Responder Kit - https://raw.githubusercontent.com/BrentOzarULTD/SQL-Server-First-Responder-Kit/main/sp_ineachdb.sql

Description:
	This procedure monitors various aspects of the SQL Server 2016+ feature Query Store and can generate alerts, 
	attempt to automatically resolve issues, and provide recommendations on Query Store related settings.
	
Parameters:
	@CheckConfiguration		0 = Disabled, 1 = Checks query store related settings and outputs recommended changes to ensure optimal configuration
	@Databases				Specify the list of databases to target, default is all query store enabled databases - Example: @Databases = 'Database1, Database2, Database3'
	@DefaultAlerting		0 = Disabled, 1 = Uses built-in SQL Alerts on Severity 16 that write to the error log to notify for failures
	@EnableReadWriteState	0 = Disabled, 1 = Attempts to automatically switch the operation mode back to READ_WRITE when in a failed state
	@ConfigTable			Specify a table to enable custom thresholds for query store alerting - Table can be specified in one, two, or three-part format
	@LoggingTable			Specify a table to enable logging of actions and query store failures - Table can be specified in one, two, or three-part format
	@UnforceFailedPlans		0 = Disabled, 1 = Automatically unforces failed plans
	@MonitorPlanRegression	0 = Disabled, 1 = Alert on plan regression based on set filters - Requires SQL Server 2017+ Enterprise/Developer Edition
	
Standard Query Store Settings:
	Operation Mode (Actual): Read write
	Operation Mode (Requested): Read write

	Data Flush Interval (Minites): 15
	Statistics Collection Interval: 1 Hour

	Max Plans Per Query: 200
	Max Size (MB): 1024 - 2048 (Starting point)
	Query Store Capture Mode: Auto
	Size Based Cleanup Mode: Auto
	Stale Query Thresold (Days): 30 - 90 Days

	Trace Flag 7745
	Trace Flag 7752 (Is the default behavior in SQL 2019+)

Credit:
	Brent Ozar    - https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit
	Erin Stellato - https://www.sqlskills.com/blogs/erin/query-store-trace-flags/
	Kendra Little - https://github.com/LitKnd/FreeSQLServerScripts/blob/main/queryStore/dba_QueryStoreUnforceFailed.sql
	
*/
