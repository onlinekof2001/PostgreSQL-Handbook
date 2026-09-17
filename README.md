# PostgreSQL学习思维导图

<details>
<summary><strong>一、宏观架构层（Instance / Cluster）</strong></summary>

<details>
<summary>1.1 数据库集簇</summary>

- 单个 PostgreSQL 服务器实例管理的数据库集合
- 共享全局配置、监听端口、进程和内存
- 默认数据库：`postgres`、`template0`、`template1`
- 数据库对象通过 OID 管理并存储于系统目录
- 官方文档：Chapter 2 Creating a Database
</details>

<details>
<summary>1.2 进程架构</summary>

- Postmaster：接受连接并 fork 后端进程
- Backend Process：执行查询并与客户端通信
- Background Writer：写入共享缓冲区脏页
- WAL Writer：写入 WAL 文件
- Checkpointer：执行检查点
- Autovacuum Launcher / Worker：清理死元组
- Stats Collector：收集统计信息
- WAL Archiver、WAL Receiver、WAL Sender：归档和流复制
- PostgreSQL 使用多进程模型，每个连接使用独立进程
- 官方文档：Chapter 31 Background Worker Processes
</details>

<details>
<summary>1.3 内存架构</summary>

- 共享内存：Shared Buffers、WAL Buffers、CLOG Buffers、Lock Space
- 本地内存：`work_mem`、`maintenance_work_mem`、`temp_buffers`
- 官方文档：Chapter 19.4 Resource Consumption
</details>
</details>

<details>
<summary><strong>二、逻辑存储结构</strong></summary>

<details><summary>2.1 数据库</summary>

- 数据库对象的容器和逻辑隔离边界
- 系统数据库：`postgres`、`template0`、`template1`
- 创建：`CREATE DATABASE`
- 存储位置：`PGDATA/base/数据库OID`
- 跨数据库访问：`dblink` 或 FDW
- 官方文档：Chapter 22 Managing Databases
</details>

<details><summary>2.2 表空间</summary>

- 逻辑存储单元，映射到操作系统目录
- 默认表空间：`pg_default`、`pg_global`
- 创建：`CREATE TABLESPACE ... LOCATION`
- 用途：SSD 和 HDD 分层、分散 I/O
- schema 是逻辑概念，不对应物理目录
- 官方文档：Chapter 22.6 Tablespaces
</details>

<details><summary>2.3 模式 Schema</summary>

- 数据库内的命名空间，默认模式为 `public`
- `search_path` 决定对象解析顺序
- 避免命名冲突，实现逻辑多租户
- 类似 Oracle 的 user 和 schema
- 官方文档：Chapter 5.8 Schemas
</details>

<details><summary>2.4 数据库对象</summary>

<details><summary>表</summary>

- 堆表、临时表、分区表、外部表
- 默认 8KB 页面，通过 `pg_class` 管理
</details>

<details><summary>索引</summary>

- B-tree：等值和范围查询
- Hash：等值查询
- GiST：地理数据和范围类型
- SP-GiST：空间分区
- GIN：全文搜索、数组、JSONB
- BRIN：大数据块范围索引
- 索引是独立数据结构，拥有独立物理存储
</details>

<details><summary>视图、物化视图和序列</summary>

- 普通视图：虚拟表
- 物化视图：存储查询结果并可刷新
- 序列：用于自增主键和唯一标识
- 序列函数：`nextval()`、`currval()`、`setval()`
- 序列是独立对象，可跨表共享
</details>

<details><summary>函数、存储过程和其他对象</summary>

- 函数：SQL、PL/pgSQL、PL/Python、PL/Perl、PL/Tcl
- PostgreSQL 11+ 存储过程支持事务控制
- 支持触发器函数和按参数类型重载
- 触发器：行级、语句级、BEFORE、AFTER、INSTEAD OF
- 规则：查询重写机制
- FDW：访问远程数据源
- Extension：`postgis`、`uuid-ossp` 等模块化功能
</details>

官方文档：Chapter 5、Chapter 9.16、Chapter 11、Chapter 36、Chapter 43
</details>

<details><summary>2.5 系统目录</summary>

- `pg_class`、`pg_attribute`、`pg_database`、`pg_namespace`
- `pg_tablespace`、`pg_type`、`pg_index`
- `pg_stat_*`：统计信息视图
- 系统目录是 PostgreSQL 的元数据库，OID 是核心标识
- 官方文档：Chapter 51 System Catalogs
</details>
</details>

<details>
<summary><strong>三、物理存储结构</strong></summary>

<details><summary>3.1 数据目录 PGDATA</summary>

- `base`：按数据库 OID 存放数据文件
- `global`：共享系统表
- `pg_wal`：WAL 日志；`pg_tblspc`：表空间符号链接
- `pg_stat`、`pg_stat_tmp`：统计信息临时文件
- `pg_clog`、`pg_xact`：事务状态
- `pg_multixact`、`pg_subtrans`：多事务和子事务
- `pg_notify`、`pg_serial`、`pg_snapshots`、`pg_replslot`
- `postgresql.conf`、`pg_hba.conf`、`pg_ident.conf`、`PG_VERSION`
- 官方文档：Chapter 66.1 Database File Layout
</details>

<details><summary>3.2 表文件结构</summary>

- Page / Block：默认 8KB
- Page Header：24 字节，包含 `pd_lsn`、`pd_checksum`
- Item ID Array：行指针数组；Tuple Data：行数据；Free Space：空闲空间
- 文件命名：表 OID，超过 1GB 后使用 OID.1、OID.2
- TOAST：超大字段存储；FSM：空闲空间映射；VM：可见性映射
- 官方文档：Chapter 66.6 Database Page Layout
</details>

<details><summary>3.3 WAL（Write-Ahead Logging）</summary>

- 先写日志再写数据，保证持久性和崩溃恢复
- WAL 记录包含 LSN，段文件默认 16MB，位于 `pg_wal`
- Checkpoint：确保此前数据页刷盘
- 归档模式支持 PITR，流复制基于 WAL 传输
- 官方文档：Chapter 29 Reliability and the WAL
</details>
</details>

<details>
<summary><strong>四、核心机制</strong></summary>

<details><summary>4.1 MVCC</summary>

- 多版本并发控制，读写互不阻塞
- `xmin`：插入事务 ID；`xmax`：删除事务 ID
- 事务快照判断数据版本可见性
- XID Wraparound：VACUUM 防止事务 ID 回卷
- 依据 xmin、xmax、clog 和快照判断可见性
- 官方文档：Chapter 13.2 Transaction Isolation
</details>

<details><summary>4.2 VACUUM</summary>

- 标准 VACUUM：清理死元组，空间供重用
- VACUUM FULL：重建表并释放磁盘，需要排他锁
- Autovacuum：自动后台清理
- Freeze：防止 XID 回卷；VM：加速 VACUUM
- 官方文档：Chapter 24.1 Routine Vacuuming
</details>

<details><summary>4.3 锁机制</summary>

- 表级锁：ACCESS SHARE、ROW SHARE、ROW EXCLUSIVE、SHARE UPDATE EXCLUSIVE、SHARE、SHARE ROW EXCLUSIVE、EXCLUSIVE、ACCESS EXCLUSIVE
- 行级锁：FOR UPDATE、FOR NO KEY UPDATE、FOR SHARE、FOR KEY SHARE
- 自动检测死锁并终止一个事务
- 通过 `pg_locks` 监控锁等待
- ACCESS EXCLUSIVE 会阻塞所有操作
- 官方文档：Chapter 13.3 Explicit Locking
</details>

<details><summary>4.4 查询处理流程</summary>

- Parser：SQL 转解析树
- Analyzer：解析树转查询树并补充类型信息
- Rewriter：规则系统和视图展开
- Planner / Optimizer：结合 `pg_statistic` 和成本参数生成执行计划
- 连接方法：Nested Loop、Hash Join、Merge Join
- Executor：执行计划
- `EXPLAIN` / `EXPLAIN ANALYZE`：查看执行计划
- 官方文档：Chapter 14、Chapter 50
</details>
</details>

<details>
<summary><strong>五、高级特性</strong></summary>

<details><summary>5.1 分区表</summary>

- 声明式分区（PostgreSQL 10+）：RANGE、LIST、HASH
- 分区剪枝：排除无关分区
- 维护：ATTACH、DETACH、SPLIT、MERGE
- 关键点：分区键选择和分区数量
- 官方文档：Chapter 5.11 Table Partitioning
</details>

<details><summary>5.2 并行查询</summary>

- 并行顺序扫描、并行连接、并行聚合
- 参数：`max_parallel_workers_per_gather`、`parallel_tuple_cost`
- 并非所有查询都适合并行
- 官方文档：Chapter 15 Parallel Query
</details>

<details><summary>5.3 逻辑复制</summary>

- Publication：源端发布表；Subscription：目标端拉取数据
- Replication Slot：保证 WAL 不被清理
- 用途：版本升级、跨平台复制、部分表复制
- 与物理复制互补
- 官方文档：Chapter 31 Logical Replication
</details>

<details><summary>5.4 外部数据 FDW</summary>

- `postgres_fdw`、`file_fdw`、`oracle_fdw`、`mysql_fdw`、`mongo_fdw`
- Pushdown：谓词和连接下推
- 分布式查询和数据联邦
- 官方文档：Chapter 32 Foreign Data Wrappers
</details>

<details><summary>5.5 扩展框架</summary>

- `CREATE EXTENSION`：安装模块
- 常用扩展：`postgis`、`pg_stat_statements`、`uuid-ossp`、`pg_trgm`
- C 语言编写自定义扩展
- 官方文档：Chapter 37 Extensions
</details>
</details>

<details>
<summary><strong>六、运维管理</strong></summary>

<details><summary>6.1 安装与部署</summary>

- 源码编译、yum、apt、brew
- Docker、Kubernetes
- 初始化：`initdb`
- 官方文档：Chapter 17、Chapter 18
</details>

<details><summary>6.2 配置管理</summary>

- `postgresql.conf`：服务器参数
- `pg_hba.conf`：客户端认证；`pg_ident.conf`：用户映射
- 参数：内存、连接、WAL、规划、日志、复制
- 生效方式：SIGHUP、重启、会话级 SET
- 官方文档：Chapter 19 Server Configuration
</details>

<details><summary>6.3 备份与恢复</summary>

- 物理备份：`pg_basebackup`、文件系统快照
- 逻辑备份：`pg_dump`、`pg_dumpall`、`pg_restore`
- PITR：基于 WAL 归档的时间点恢复
- 3-2-1 备份原则和恢复演练
- 官方文档：Chapter 25 Backup and Restore
</details>

<details><summary>6.4 高可用与复制</summary>

- 流复制：同步和异步；级联复制
- 故障转移：`pg_ctl promote`、Patroni、repmgr
- 负载均衡：pgpool-II、PgBouncer
- 根据 RTO 和 RPO 选择架构
- 官方文档：Chapter 26 High Availability
</details>

<details><summary>6.5 监控与诊断</summary>

- `pg_stat_*`、`pg_locks`、`pg_activity`
- 日志：`log_destination`、`log_min_duration_statement`
- 扩展工具：`pg_stat_statements`、`auto_explain`
- Prometheus、Grafana、Zabbix
- 官方文档：Chapter 28 Monitoring Database Activity
</details>

<details><summary>6.6 安全管理</summary>

- 角色与权限：CREATE ROLE、GRANT、REVOKE
- 行级安全：CREATE POLICY
- SSL：`ssl`、`ssl_cert_file`、`ssl_key_file`
- 审计：pgaudit
- 最小权限原则
- 官方文档：Chapter 20、Chapter 21
</details>
</details>

<details>
<summary><strong>七、性能优化</strong></summary>

<details><summary>7.1 SQL 优化</summary>

- EXPLAIN：成本、实际时间和行数估计
- B-tree、覆盖索引、部分索引、表达式索引
- 避免 SELECT *，适度使用 CTE
- COPY、INSERT ON CONFLICT、批量 UPDATE
- Seq Scan 不一定慢，要结合数据量判断
- 官方文档：Chapter 14 Performance Tips
</details>

<details><summary>7.2 连接池</summary>

- PgBouncer：轻量级连接池
- 会话池、事务池、语句池
- `max_connections`、`default_pool_size`
- 应对高并发短连接
</details>

<details><summary>7.3 参数调优</summary>

- 内存：`shared_buffers`、`effective_cache_size`、`work_mem`
- WAL：`wal_buffers`、`checkpoint_completion_target`
- 并发：`max_connections`、`max_worker_processes`
- 基于工作负载和硬件配置调优
- 官方文档：Chapter 19 Server Configuration
</details>
</details>

<details>
<summary><strong>八、源码与内核（资深方向）</strong></summary>

<details><summary>8.1 源码结构</summary>

- backend：后端核心代码
- storage：buffer、file、ipc、lmgr、page、smgr
- access：heap、index、transam
- executor、optimizer、parser、catalog、utils
- 阅读起点：`src/backend/storage/buffer/README`
</details>

<details><summary>8.2 扩展开发</summary>

- C 语言扩展：共享库、`PG_FUNCTION_INFO_V1`
- 自定义数据类型、操作符和索引方法
- Hook：拦截和修改内核行为
- 官方文档：Chapter 36、Chapter 55
</details>

<details><summary>8.3 社区与生态</summary>

- 邮件列表：pgsql-hackers、pgsql-general
- PGCon、PostgreSQL Conference China
- 提交补丁、代码审核、文档贡献
- 参与社区，深入理解 PostgreSQL
</details>
</details>
