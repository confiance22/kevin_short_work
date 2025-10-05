-- =============================================
-- Oracle PDB Management Lab - MANZI Eric Kevin
-- Student ID: 27387
-- =============================================

-- TASK 1: CREATE PRIMARY PDB
-- =============================================

-- Connect as sysdba
CONNECT / AS SYSDBA

-- Create the first PDB
CREATE PLUGGABLE DATABASE er_pdb_27387
ADMIN USER eric_plsqlauca_27387 IDENTIFIED BY password
ROLES=(DBA)
FILE_NAME_CONVERT=('D:\ORCL\ORADATA\ORCL\PDBSEED\', 
                   'D:\ORCL\ORADATA\ORCL\ER_PDB_27387\');

-- Open the PDB
ALTER PLUGGABLE DATABASE er_pdb_27387 OPEN;

-- Save the state so it opens automatically on restart
ALTER PLUGGABLE DATABASE er_pdb_27387 SAVE STATE;

-- Switch to the new PDB
ALTER SESSION SET CONTAINER = er_pdb_27387;

-- Create tablespace
CREATE TABLESPACE ts_eric_27387 
DATAFILE 'D:\ORCL\ORADATA\ORCL\ER_PDB_27387\ts_eric_27387.dbf' 
SIZE 100M AUTOEXTEND ON;

-- Unlock and configure the admin user (created during PDB creation)
ALTER USER eric_plsqlauca_27387 IDENTIFIED BY password ACCOUNT UNLOCK;

-- Grant necessary privileges
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, 
CREATE PROCEDURE, CREATE SEQUENCE, SELECT ANY DICTIONARY 
TO eric_plsqlauca_27387;

-- TASK 2: CREATE AND DELETE SECOND PDB
-- =============================================

-- Connect as sysdba
CONNECT / AS SYSDBA

-- Create the second PDB (to be deleted)
CREATE PLUGGABLE DATABASE er_to_delete_pdb_27387
ADMIN USER temp_admin IDENTIFIED BY temp123
FILE_NAME_CONVERT=('D:\ORCL\ORADATA\ORCL\PDBSEED\', 
                   'D:\ORCL\ORADATA\ORCL\ER_TO_DELETE_PDB_27387\');

-- Open the PDB
ALTER PLUGGABLE DATABASE er_to_delete_pdb_27387 OPEN;

-- Verify both PDBs were created
SELECT name, open_mode FROM v$pdbs WHERE name LIKE '%27387%';

-- Now delete the PDB
ALTER PLUGGABLE DATABASE er_to_delete_pdb_27387 CLOSE;

DROP PLUGGABLE DATABASE er_to_delete_pdb_27387 
INCLUDING DATAFILES;

-- Verify deletion
SELECT name, open_mode FROM v$pdbs WHERE name LIKE '%27387%';

-- TASK 3: ORACLE ENTERPRISE MANAGER CONFIGURATION
-- =============================================

-- Connect as sysdba
CONNECT / AS SYSDBA

-- Check current OEM port
SELECT dbms_xdb_config.gethttpsport FROM dual;

-- Unset the current port and set new port (5501)
EXEC DBMS_XDB_CONFIG.SETHTTPSPORT(0);
EXEC DBMS_XDB_CONFIG.SETHTTPSPORT(5501);

-- Verify new port
SELECT dbms_xdb_config.gethttpsport FROM dual;

-- VERIFICATION QUERIES
-- =============================================

-- Verify all PDBs
SELECT name, open_mode FROM v$pdbs;

-- Verify user exists in the PDB
ALTER SESSION SET CONTAINER = er_pdb_27387;
SELECT username, account_status, default_tablespace 
FROM dba_users 
WHERE username = 'ERIC_PLSQLAUCA_27387';

-- Verify tablespace
SELECT tablespace_name, file_name 
FROM dba_data_files 
WHERE tablespace_name = 'TS_ERIC_27387';

-- Verify user privileges
SELECT * FROM session_privs;

-- Check XDB service status
SELECT comp_name, status, version FROM dba_registry 
WHERE comp_name LIKE '%XDB%';

-- =============================================
-- END OF QUERIES
-- =============================================
