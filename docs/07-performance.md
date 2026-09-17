# 七、性能优化

## 7.1 SQL 优化

- EXPLAIN 分析：成本、实际时间、行数估计。
- 索引优化：B-tree、覆盖索引、部分索引、表达式索引。
- 查询重写：避免 SELECT *、减少子查询、使用 CTE 适度。
- 批量操作：COPY、INSERT ... ON CONFLICT、批量 UPDATE。
- 执行计划中的 Seq Scan 不一定慢，需结合实际数据量。

> 🚧 待补充

## 7.2 连接池

- PgBouncer：轻量级连接池。
- 模式：会话池、事务池、语句池。
- 配置：max_connections、default_pool_size。

> 🚧 待补充

## 7.3 参数调优

- 内存参数：shared_buffers、effective_cache_size、work_mem。
- WAL 参数：wal_buffers、checkpoint_completion_target。
- 并发参数：max_connections、max_worker_processes。

> 🚧 待补充
