# 四、核心机制

## 4.1 MVCC（Multi-Version Concurrency Control）

- 概念：多版本并发控制，读写不阻塞。
- 实现：每行有 xmin（插入事务 ID）、xmax（删除事务 ID）。
- 事务快照：确定事务可见的数据版本。
- 事务 ID 回卷（XID Wraparound）：VACUUM 防止事务 ID 耗尽。
- 可见性规则：通过 xmax、xmin、clog、快照判断。

> 🚧 待补充

## 4.2 VACUUM 机制

- 标准 VACUUM：清理死元组，释放空间给重用，不释放磁盘。
- VACUUM FULL：完全重建表，释放磁盘空间，需要排他锁。
- Autovacuum：自动后台清理进程。
- 冻结（Freeze）：防止 XID 回卷。
- 可见性映射（VM）：加速 VACUUM。

> 🚧 待补充

## 4.3 锁机制

- 表级锁：ACCESS SHARE、ROW SHARE、ROW EXCLUSIVE、SHARE UPDATE EXCLUSIVE、SHARE、SHARE ROW EXCLUSIVE、EXCLUSIVE、ACCESS EXCLUSIVE。
- 行级锁：FOR UPDATE、FOR NO KEY UPDATE、FOR SHARE、FOR KEY SHARE。
- 死锁检测：自动检测并终止一个事务。
- 锁等待：`pg_locks` 视图监控。
- ACCESS EXCLUSIVE 锁会阻塞所有操作，是 DDL 变更的痛点。

> 🚧 待补充

## 4.4 查询处理流程

- 解析器（Parser）：SQL → 解析树。
- 分析器（Analyzer）：解析树 → 查询树（增加类型、列信息）。
- 重写器（Rewriter）：规则系统、视图展开。
- 规划器 / 优化器（Planner/Optimizer）：生成执行计划。
  - 统计信息：`pg_statistic` 系统表。
  - 成本估算：`seq_page_cost`、`random_page_cost`、`cpu_tuple_cost` 等。
  - 连接方法：Nested Loop、Hash Join、Merge Join。
  - 路径选择：遗传算法（复杂查询）。
- 执行器（Executor）：按执行计划运行。
- EXPLAIN / EXPLAIN ANALYZE：查看执行计划。

> 🚧 待补充
