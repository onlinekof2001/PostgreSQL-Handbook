# 五、高级特性

## 5.1 分区表（Partitioning）

- 声明式分区（PostgreSQL 10+）：RANGE、LIST、HASH。
- 分区剪枝（Partition Pruning）：优化器自动排除无关分区。
- 分区维护：ATTACH/DETACH PARTITION、SPLIT、MERGE。

> 🚧 待补充

## 5.2 并行查询（Parallel Query）

- 并行顺序扫描、并行连接、并行聚合。
- 参数：`max_parallel_workers_per_gather`、`parallel_tuple_cost` 等。

> 🚧 待补充

## 5.3 逻辑复制（Logical Replication）

- 发布（Publication）：源端定义要复制的表。
- 订阅（Subscription）：目标端拉取数据。
- 复制槽（Replication Slot）：保证 WAL 不清理。
- 用途：版本升级、跨平台复制、部分表复制。

> 🚧 待补充

## 5.4 外部数据（FDW）

- `postgres_fdw`：访问其他 PostgreSQL 实例。
- `file_fdw`：访问文件。
- 其他：`oracle_fdw`、`mysql_fdw`、`mongo_fdw` 等。
- 下推（Pushdown）：谓词、连接下推优化。

> 🚧 待补充

## 5.5 扩展框架（Extension）

- `CREATE EXTENSION`：模块化安装功能。
- 常用扩展：postgis、pg_stat_statements、uuid-ossp、pg_trgm。
- 自定义扩展：C 语言编写共享库。

> 🚧 待补充
