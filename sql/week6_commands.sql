-- Week 6 PostgreSQL Backup, Recovery and Replication
-- Author: Vidensio Oyoo
-- PostgreSQL 18.6

-- ==========================================
-- 1. Verify PostgreSQL Version
-- ==========================================

SELECT version();

-- ==========================================
-- 2. Verify Students Database
-- ==========================================

SELECT *
FROM students
ORDER BY id;

-- ==========================================
-- 3. Check WAL Configuration
-- ==========================================

SHOW wal_level;

SHOW archive_mode;

SHOW archive_command;

-- ==========================================
-- 4. PITR Disaster Simulation
-- ==========================================

-- Record the recovery point before making changes
SELECT now();

-- Simulate accidental deletion
DELETE FROM students;

-- Verify the table after deletion
SELECT count(*)
FROM students;

-- ==========================================
-- 5. Verify PITR Recovery
-- ==========================================

SELECT count(*)
FROM students;

SELECT *
FROM students
ORDER BY id;

-- ==========================================
-- 6. Verify Standby Server
-- ==========================================

SELECT pg_is_in_recovery();

-- ==========================================
-- 7. Check Replication Health
-- ==========================================

SELECT application_name,
client_addr,
state,
sync_state,
pg_wal_lsn_diff(sent_lsn, replay_lsn) AS lag_bytes
FROM pg_stat_replication;

-- ==========================================
-- End of Week 6 Assignment
-- ==========================================
