# 一、宏观架构层（Instance/Cluster）

## 1.1 [数据库集簇（Database Cluster）](01-database-cluster.md)

- **概念**：单个 PostgreSQL 服务器实例管理的数据库集合。
- **共享资源**：全局配置文件、监听端口、进程、内存结构。
- **默认数据库**：`postgres`、`template0`、`template1`。
- **官方文档**：Chapter 2. Creating a Database
- **关联注解**：所有数据库对象通过 OID（无符号四字节整数）管理，存储于系统目录表 [^43^][^54^]。

## 1.2 进程架构（多进程模型）

- Postmaster：主进程，接受客户端连接，fork 后端进程。
- Backend Process：执行查询，直接与客户端通信。
- Background Writer：将共享缓冲区的脏页写入磁盘。
- WAL Writer：将 WAL 缓冲区写入 WAL 文件。
- Checkpointer：执行检查点，确保数据一致性。
- Autovacuum Launcher/Worker：自动清理死元组。
- Stats Collector：收集统计信息。
- WAL Archiver：归档 WAL 文件（归档模式）。
- WAL Receiver/Sender：流复制进程。
- **官方文档**：Chapter 31. Background Worker Processes
- **关联注解**：PostgreSQL 基于多进程而非多线程模型，每个连接独立进程 [^47^][^50^]。

## 1.3 内存架构

### 共享内存（Shared Memory）

- Shared Buffers：数据页缓存（默认 128MB）。
- WAL Buffers：WAL 记录缓存。
- CLOG Buffers：事务提交状态缓存。
- Lock Space：锁表。

### 本地内存（Local Memory）

- `work_mem`：排序 / 哈希操作内存。
- `maintenance_work_mem`：VACUUM / CREATE INDEX 内存。
- `temp_buffers`：临时表缓存。

- **官方文档**：Chapter 19. Server Configuration → 19.4. Resource Consumption
- **关联注解**：合理的内存配置是性能调优的核心 [^50^]。
