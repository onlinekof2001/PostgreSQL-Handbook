# 二、逻辑存储结构

## 2.1 数据库（Database）

- **概念**：数据库对象的容器，逻辑上彼此隔离。
- 系统数据库：`postgres`（管理）、`template0`（纯净模板）、`template1`（默认模板）。
- 创建：`CREATE DATABASE`。
- 存储位置：`$PGDATA/base/数据库OID/`。
- **官方文档**：Chapter 22. Managing Databases
- **关联注解**：用户跨数据库访问需用 dblink/FDW，不能直接查询 [^43^][^54^][^56^]。

## 2.2 表空间（Tablespace）

- **概念**：数据库逻辑存储单元，映射到操作系统目录。
- 默认表空间：`pg_default`（`$PGDATA/base`）、`pg_global`（共享系统表）。
- 创建：`CREATE TABLESPACE ... LOCATION '...'`。
- 用途：数据分层存储（SSD/HDD 分离）、I/O 分散。
- **官方文档**：Chapter 22.6. Tablespaces
- **关联注解**：表空间是物理目录的抽象，schema 完全逻辑无实体目录 [^54^][^56^]。

## 2.3 模式（Schema/Namespace）

- **概念**：数据库内的命名空间，组织和管理数据库对象。
- 默认模式：`public`。
- 搜索路径：`search_path`（决定对象解析顺序）。
- 隔离性：避免命名冲突，实现多租户逻辑隔离。
- **官方文档**：Chapter 5.8. Schemas
- **关联注解**：PostgreSQL 的 schema 对应 Oracle 的 user/schema 概念 [^50^][^56^]。

## 2.4 数据库对象（Database Objects）

### 表（Table/Relation）

- 堆表（Heap Table）：默认存储方式。
- 临时表（Temporary Table）。
- 分区表（Partitioned Table）。
- 外部表（Foreign Table）。
- **官方文档**：Chapter 5. Data Definition → 5.11. Tables
- **关联注解**：表数据存储在 8KB 页面中，通过 OID 在 `pg_class` 中管理 [^43^][^54^]。

### 索引（Index）

- B-tree（默认）：等值、范围查询。
- Hash：等值查询。
- GiST：地理数据、范围类型。
- SP-GiST：空间分区。
- GIN：全文搜索、数组、JSONB。
- BRIN：大数据块范围索引。
- **官方文档**：Chapter 11. Indexes
- **关联注解**：索引是独立的数据结构，有单独的物理存储 [^51^]。

### 视图 / 物化视图

- 普通视图：虚拟表，不存储数据。
- 物化视图：物理存储查询结果，可刷新。
- **官方文档**：Chapter 5.9. Views / Chapter 5.10. Materialized Views
- **关联注解**：物化视图用于预计算复杂查询 [^52^]。

### 序列（Sequence）

- 用途：自增主键、唯一标识生成。
- 函数：`nextval()`、`currval()`、`setval()`。
- **官方文档**：Chapter 9.16. Sequence Manipulation Functions
- **关联注解**：序列是独立对象，非表属性，可跨表共享 [^43^]。

### 函数 / 存储过程

- SQL 函数、PL/pgSQL 函数。
- 其他语言：PL/Python、PL/Perl、PL/Tcl。
- 存储过程（PostgreSQL 11+）：支持事务控制。
- 触发器函数。
- **官方文档**：Chapter 36. Extending SQL / Chapter 43. PL/pgSQL
- **关联注解**：函数是数据库一等公民，支持重载（按参数类型区分） [^52^]。

### 其他对象

- 触发器（Trigger）：行级 / 语句级，BEFORE / AFTER / INSTEAD OF。
- 规则（Rule）：查询重写机制。
- 外部数据包装器（FDW）：访问远程数据源。
- 扩展（Extension）：模块化功能，如 postgis、uuid-ossp。
- **官方文档**：对应章节。

## 2.5 系统目录（System Catalog）

- `pg_class`：表、索引、序列等对象的元数据。
- `pg_attribute`：列信息。
- `pg_database`：数据库信息。
- `pg_namespace`：schema 信息。
- `pg_tablespace`：表空间信息。
- `pg_type`：数据类型。
- `pg_index`：索引详细信息。
- `pg_stat_*`：统计信息视图。
- **官方文档**：Chapter 51. System Catalogs
- **关联注解**：系统目录是 PostgreSQL 的元数据库，OID 是核心标识 [^43^][^54^]。
