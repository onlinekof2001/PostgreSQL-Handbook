# 三、物理存储结构

## 3.1 数据目录布局（$PGDATA）

- `base/`：数据库数据文件（按数据库 OID 分目录）。
- `global/`：共享系统表（`pg_database` 等）。
- `pg_wal/`：WAL 日志文件（预写日志）。
- `pg_tblspc/`：表空间符号链接。
- `pg_stat/`：统计信息临时文件。
- `pg_stat_tmp/`：统计信息临时文件。
- `pg_clog/`：事务提交状态（CLOG）。
- `pg_xact/`：PostgreSQL 10+ 事务状态。
- `pg_multixact/`：多事务状态。
- `pg_subtrans/`：子事务状态。
- `pg_notify/`：LISTEN/NOTIFY 数据。
- `pg_serial/`：可串行化事务信息。
- `pg_snapshots/`：导出快照。
- `pg_replslot/`：复制槽数据。
- `postgresql.conf`：主配置文件。
- `pg_hba.conf`：客户端认证配置。
- `pg_ident.conf`：用户映射配置。
- `PG_VERSION`：版本标识。
- **官方文档**：Chapter 66. Database Physical Storage → 66.1. Database File Layout
- **关联注解**：理解目录结构是故障排查和备份恢复的基础 [^54^][^56^]。

## 3.2 表文件结构

- 页（Page/Block）：固定 8KB（默认）。
- Page Header：24 字节，包含 `pd_lsn`、`pd_checksum` 等。
- Item ID Array：行指针数组。
- Tuple Data：实际行数据（从页尾向前增长）。
- Free Space：中间空闲空间。
- 文件命名：表 OID（不超过 1GB 时），超出后 OID.1、OID.2...
- TOAST：超大字段存储（The Oversized-Attribute Storage Technique）。
- FSM：空闲空间映射（Free Space Map）。
- VM：可见性映射（Visibility Map，VACUUM 优化）。
- **官方文档**：Chapter 66. Database Physical Storage → 66.6. Database Page Layout
- **关联注解**：页面结构是理解索引、MVCC、VACUUM 的基础 [^50^][^54^]。

## 3.3 WAL（Write-Ahead Logging）

- **概念**：先写日志再写数据，保证持久性和崩溃恢复。
- WAL 记录：包含 LSN（Log Sequence Number）。
- WAL 段文件：默认 16MB，位于 `pg_wal/`。
- 检查点（Checkpoint）：确保 WAL 之前的所有数据页已刷盘。
- 归档模式：WAL 归档用于 PITR（Point-in-Time Recovery）。
- 复制：流复制基于 WAL 日志传输。
- **官方文档**：Chapter 29. Reliability and the Write-Ahead Log
- **关联注解**：WAL 是 PostgreSQL 高可用和灾难恢复的核心机制 [^46^][^51^]。
