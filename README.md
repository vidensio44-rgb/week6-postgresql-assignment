# Week 6 PostgreSQL Backup, Recovery and Replication Assignment

**Author:** Vidensio Oyoo
**Database:** PostgreSQL 18.6
**Platform:** Windows
**Date:** October 7, 2026

## Objective

The objective of this assignment was to practice PostgreSQL logical backup, WAL archiving, Point-in-Time Recovery (PITR), and streaming replication.

---

## 1. Logical Backup

A custom-format logical backup of the `bootcamp` database was created using `pg_dump`.

```bash
pg_dump -U postgres -h 127.0.0.1 -Fc -f ~/backups/bootcamp.dump bootcamp
```

The backup was inspected using:

```bash
pg_restore --list ~/backups/bootcamp.dump
```

The backup contained the `students` table, its sequence, data, and primary key.

---

## 2. Backup Restore Test

A separate database called `bootcamp_check` was created to test the backup.

```bash
createdb -U postgres -h 127.0.0.1 bootcamp_check
pg_restore -U postgres -h 127.0.0.1 -d bootcamp_check ~/backups/bootcamp.dump
```

The restored database contained all five original student records.

The students were:

* Alice
* Brian
* Carol
* David
* Esther

---

## 3. WAL Archiving

PostgreSQL WAL archiving was configured with:

```conf
wal_level = replica
archive_mode = on
```

A Windows-compatible archive command was configured to copy WAL files to the backup directory.

The WAL archive was successfully populated with PostgreSQL WAL files.

This demonstrated that PostgreSQL was generating and archiving WAL files for recovery purposes.

---

## 4. Physical Base Backup

A physical base backup was created using `pg_basebackup`.

```bash
pg_basebackup -U postgres -h 127.0.0.1 -D ~/backups/base -Ft -z -Xs -P
```

The base backup successfully produced:

* `backup_manifest`
* `base.tar.gz`
* `pg_wal.tar.gz`

---

## ## 5. Point-in-Time Recovery (PITR)

A disaster scenario was simulated by deleting all records from the `students` table.

Before deletion, the database contained five students.

The recovery point was recorded before the deletion.

The records were then deleted:

```sql
DELETE FROM students;
```

The database was recovered using the physical base backup and archived WAL files.

The recovered database was started on port `5433` to keep it separate from the main PostgreSQL server.

### PITR Recovery Configuration

The following recovery settings were used for the PITR instance:

```conf
port = 5433

restore_command = 'cmd.exe /c C:/Users/UBUNTU/pitr_recovery/restore_wal.bat %f %p'

recovery_target_time = '2026-10-07 15:54:43.648772+03'

recovery_target_action = 'pause'
```

A `recovery.signal` file was also created in the PITR recovery directory to enable recovery mode.

The `restore_command` retrieved archived WAL files from the WAL archive using the Windows recovery script. The `recovery_target_time` specified the point immediately before the simulated deletion, while `recovery_target_action = 'pause'` instructed PostgreSQL to pause when the recovery target was reached.

The recovery was successful.

Verification:

```sql
SELECT count(*) FROM students;
```

Result:

```text
5
```

All five original student records were successfully recovered.

---


## 6. Streaming Replication

A replication user was created and configured with the PostgreSQL replication privilege.

A standby server was created using:

```bash
pg_basebackup -U replicator -h 127.0.0.1 -D ~/standby -R -P
```

The standby PostgreSQL instance was configured to use port `5434`.

The standby server was started successfully.

Its recovery status was verified with:

```sql
SELECT pg_is_in_recovery();
```

Result:

```text
t
```

This confirmed that the server was operating as a standby/recovery server.

---

## 7. Replication Health

Replication health was checked on the primary server using:

```sql
SELECT application_name,
       client_addr,
       state,
       sync_state,
       pg_wal_lsn_diff(sent_lsn, replay_lsn) AS lag_bytes
FROM pg_stat_replication;
```

The result showed:

* **State:** streaming
* **Sync mode:** async
* **Replication lag:** 0 bytes

This confirmed that streaming replication was working successfully.

---

## 8. Evidence

Screenshots showing the completed work are included in the `screenshots` folder.

The evidence includes:

1. Logical backup
2. Restored database
3. WAL archive
4. Point-in-Time Recovery
5. Standby server
6. Replication health

---

## Conclusion

This assignment demonstrated the practical use of PostgreSQL backup and disaster recovery features.

The completed lab successfully demonstrated:

* Logical database backup
* Backup restoration
* WAL archiving
* Physical base backup
* Point-in-Time Recovery
* Streaming replication
* Replication health monitoring

The exercise provided practical experience in protecting PostgreSQL databases against data loss and maintaining a standby database for high availability.
