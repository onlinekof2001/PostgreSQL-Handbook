# PostgreSQL 知识体系

```text
PostgreSQL 知识体系
├── 一、宏观架构层（Instance/Cluster）
│   ├── 1.1 数据库集簇（Database Cluster）
│   │   ├── 概念：单个 PostgreSQL 服务器实例管理的数据库集合
│   │   ├── 共享资源：全局配置文件、监听端口、进程、内存结构
│   │   ├── 默认数据库：postgres、template0、template1
│   │   ├── 官方文档：Chapter 2. Creating a Database
│   │   └── 关联注解：所有数据库对象通过 OID（无符号四字节整数）管理，存储于系统目录表 [^43^][^54^]
│   ├── 1.2 进程架构（多进程模型）
│   │   ├── Postmaster：主进程，接受客户端连接，fork 后端进程
│   │   ├── Backend Process：执行查询，直接与客户端通信
│   │   ├── Background Writer：将共享缓冲区的脏页写入磁盘
│   │   ├── WAL Writer：将 WAL 缓冲区写入 WAL 文件
│   │   ├── Checkpointer：执行检查点，确保数据一致性
│   │   ├── Autovacuum Launcher/Worker：自动清理死元组
│   │   ├── Stats Collector：收集统计信息
│   │   ├── WAL Archiver：归档 WAL 文件（归档模式）
│   │   ├── WAL Receiver/Sender：流复制进程
│   │   ├── 官方文档：Chapter 31. Background Worker Processes
│   │   └── 关联注解：PostgreSQL 基于多进程而非多线程模型，每个连接独立进程 [^47^][^50^]
│   └── 1.3 内存架构
│       ├── 共享内存（Shared Memory）
│       │   ├── Shared Buffers：数据页缓存（默认 128MB）
│       │   ├── WAL Buffers：WAL 记录缓存
│       │   ├── CLOG Buffers：事务提交状态缓存
│       │   └── Lock Space：锁表
│       ├── 本地内存（Local Memory）
│       │   ├── work_mem：排序/哈希操作内存
│       │   ├── maintenance_work_mem：VACUUM/CREATE INDEX 内存
│       │   └── temp_buffers：临时表缓存
│       ├── 官方文档：Chapter 19. Server Configuration → 19.4. Resource Consumption
│       └── 关联注解：合理的内存配置是性能调优的核心 [^50^]
├── 二、逻辑存储结构
│   ├── 2.1 数据库（Database）
│   │   ├── 概念：数据库对象的容器，逻辑上彼此隔离
│   │   ├── 系统数据库：postgres（管理）、template0（纯净模板）、template1（默认模板）
│   │   ├── 创建：CREATE DATABASE
│   │   ├── 存储位置：$PGDATA/base/数据库OID/
│   │   ├── 官方文档：Chapter 22. Managing Databases
│   │   └── 关联注解：用户跨数据库访问需用 dblink/FDW，不能直接查询 [^43^][^54^][^56^]
│   ├── 2.2 表空间（Tablespace）
│   │   ├── 概念：数据库逻辑存储单元，映射到操作系统目录
│   │   ├── 默认表空间：pg_default（$PGDATA/base）、pg_global（共享系统表）
│   │   ├── 创建：CREATE TABLESPACE ... LOCATION '...'
│   │   ├── 用途：数据分层存储（SSD/HDD分离）、I/O分散
│   │   ├── 官方文档：Chapter 22.6. Tablespaces
│   │   └── 关联注解：表空间是物理目录的抽象，schema 完全逻辑无实体目录 [^54^][^56^]
│   ├── 2.3 模式（Schema/Namespace）
│   │   ├── 概念：数据库内的命名空间，组织和管理数据库对象
│   │   ├── 默认模式：public
│   │   ├── 搜索路径：search_path（决定对象解析顺序）
│   │   ├── 隔离性：避免命名冲突，实现多租户逻辑隔离
│   │   ├── 官方文档：Chapter 5.8. Schemas
│   │   └── 关联注解：PostgreSQL 的 schema 对应 Oracle 的 user/schema 概念 [^50^][^56^]
│   ├── 2.4 数据库对象（Database Objects）
│   │   ├── 表（Table/Relation）
│   │   │   ├── 堆表（Heap Table）：默认存储方式
│   │   │   ├── 临时表（Temporary Table）
│   │   │   ├── 分区表（Partitioned Table）
│   │   │   ├── 外部表（Foreign Table）
│   │   │   ├── 官方文档：Chapter 5. Data Definition → 5.11. Tables
│   │   │   └── 关联注解：表数据存储在 8KB 页面中，通过 OID 在 pg_class 中管理 [^43^][^54^]
│   │   ├── 索引（Index）
│   │   │   ├── B-tree（默认）：等值、范围查询
│   │   │   ├── Hash：等值查询
│   │   │   ├── GiST：地理数据、范围类型
│   │   │   ├── SP-GiST：空间分区
│   │   │   ├── GIN：全文搜索、数组、JSONB
│   │   │   ├── BRIN：大数据块范围索引
│   │   │   ├── 官方文档：Chapter 11. Indexes
│   │   │   └── 关联注解：索引是独立的数据结构，有单独的物理存储 [^51^]
│   │   ├── 视图（View）/物化视图（Materialized View）
│   │   │   ├── 普通视图：虚拟表，不存储数据
│   │   │   ├── 物化视图：物理存储查询结果，可刷新
│   │   │   ├── 官方文档：Chapter 5.9. Views / Chapter 5.10. Materialized Views
│   │   │   └── 关联注解：物化视图用于预计算复杂查询 [^52^]
│   │   ├── 序列（Sequence）
│   │   │   ├── 用途：自增主键、唯一标识生成
│   │   │   ├── 函数：nextval()、currval()、setval()
│   │   │   ├── 官方文档：Chapter 9.16. Sequence Manipulation Functions
│   │   │   └── 关联注解：序列是独立对象，非表属性，可跨表共享 [^43^]
│   │   ├── 函数（Function）/存储过程（Procedure）
│   │   │   ├── SQL 函数、PL/pgSQL 函数
│   │   │   ├── 其他语言：PL/Python、PL/Perl、PL/Tcl
│   │   │   ├── 存储过程（PostgreSQL 11+）：支持事务控制
│   │   │   ├── 触发器函数
│   │   │   ├── 官方文档：Chapter 36. Extending SQL / Chapter 43. PL/pgSQL
│   │   │   └── 关联注解：函数是数据库一等公民，支持重载（按参数类型区分） [^52^]
│   │   └── 其他对象：触发器、规则、FDW、扩展（postgis、uuid-ossp）
│   └── 2.5 系统目录（System Catalog）
│       ├── pg_class、pg_attribute、pg_database、pg_namespace
│       ├── pg_tablespace、pg_type、pg_index、pg_stat_*
│       ├── 官方文档：Chapter 51. System Catalogs
│       └── 关联注解：系统目录是 PostgreSQL 的元数据库，OID 是核心标识 [^43^][^54^]
├── 三、物理存储结构
│   ├── 3.1 数据目录布局（$PGDATA）
│   │   ├── base/、global/、pg_wal/、pg_tblspc/
│   │   ├── pg_stat/、pg_stat_tmp/、pg_clog/、pg_xact/
│   │   ├── pg_multixact/、pg_subtrans/、pg_notify/、pg_serial/
│   │   ├── pg_snapshots/、pg_replslot/
│   │   ├── postgresql.conf、pg_hba.conf、pg_ident.conf、PG_VERSION
│   │   ├── 官方文档：Chapter 66. Database Physical Storage → 66.1. Database File Layout
│   │   └── 关联注解：理解目录结构是故障排查和备份恢复的基础 [^54^][^56^]
│   ├── 3.2 表文件结构
│   │   ├── 页（Page/Block）：固定 8KB（默认）
│   │   │   ├── Page Header：24 字节，包含 pd_lsn、pd_checksum 等
│   │   │   ├── Item ID Array：行指针数组
│   │   │   ├── Tuple Data：实际行数据（从页尾向前增长）
│   │   │   └── Free Space：中间空闲空间
│   │   ├── 文件命名：表 OID（不超过 1GB 时），超出后 OID.1、OID.2...
│   │   ├── TOAST、FSM、VM
│   │   ├── 官方文档：Chapter 66.6. Database Page Layout
│   │   └── 关联注解：页面结构是理解索引、MVCC、VACUUM 的基础 [^50^][^54^]
│   └── 3.3 WAL（Write-Ahead Logging）
│       ├── 概念：先写日志再写数据，保证持久性和崩溃恢复
│       ├── WAL 记录包含 LSN，WAL 段文件默认 16MB
│       ├── 检查点、归档模式、PITR、流复制
│       ├── 官方文档：Chapter 29. Reliability and the Write-Ahead Log
│       └── 关联注解：WAL 是 PostgreSQL 高可用和灾难恢复的核心机制 [^46^][^51^]
├── 四、核心机制
│   ├── 4.1 MVCC：多版本并发控制、xmin、xmax、事务快照、XID 回卷
│   ├── 4.2 VACUUM：标准 VACUUM、VACUUM FULL、Autovacuum、Freeze、VM
│   ├── 4.3 锁机制：表级锁、行级锁、死锁检测、pg_locks、ACCESS EXCLUSIVE
│   └── 4.4 查询处理流程：Parser → Analyzer → Rewriter → Planner/Optimizer → Executor
├── 五、高级特性
│   ├── 5.1 分区表：RANGE、LIST、HASH、分区剪枝、ATTACH/DETACH
│   ├── 5.2 并行查询：并行扫描、连接、聚合及相关参数
│   ├── 5.3 逻辑复制：Publication、Subscription、Replication Slot
│   ├── 5.4 外部数据（FDW）：postgres_fdw、file_fdw、下推
│   └── 5.5 扩展框架：CREATE EXTENSION、postgis、pg_stat_statements、pg_trgm
├── 六、运维管理
│   ├── 6.1 安装与部署：源码编译、包管理器、Docker、Kubernetes、initdb
│   ├── 6.2 配置管理：postgresql.conf、pg_hba.conf、pg_ident.conf
│   ├── 6.3 备份与恢复：pg_basebackup、pg_dump、pg_restore、PITR、3-2-1
│   ├── 6.4 高可用与复制：流复制、级联复制、Patroni、repmgr、PgBouncer
│   ├── 6.5 监控与诊断：pg_stat_*、pg_locks、pg_stat_statements、Prometheus
│   └── 6.6 安全管理：角色权限、RLS、SSL、pgaudit、最小权限
├── 七、性能优化
│   ├── 7.1 SQL 优化：EXPLAIN、索引、查询重写、批量操作
│   ├── 7.2 连接池：PgBouncer、会话池、事务池、语句池
│   └── 7.3 参数调优：内存、WAL、并发参数与工作负载
└── 八、源码与内核（资深方向）
    ├── 8.1 源码结构：backend、storage、access、executor、optimizer、parser、catalog、utils
    ├── 8.2 扩展开发：C 扩展、自定义类型、操作符、索引方法、Hook
    └── 8.3 社区与生态：邮件列表、PGCon、代码贡献、文档贡献
```
