# 1.1 数据库集簇（Database Cluster）

> 本文根据 [LearningPath.md](../LearningPath.md) 中“一、宏观架构层 → 1.1 数据库集簇”建立。当前先保留学习框架，并为每个叶子节点提供 PostgreSQL 官方文档参考。

## 目录

- [1. 数据库集簇概览](#1-数据库集簇概览)
- [2. 概念：服务器实例管理的数据库集合](#2-概念服务器实例管理的数据库集合)
- [3. 共享资源](#3-共享资源)
- [4. 默认数据库](#4-默认数据库)
- [5. 创建数据库](#5-创建数据库)
- [6. OID 与系统目录](#6-oid-与系统目录)
- [7. 学习任务](#7-学习任务)
- [8. 官方文档参考](#8-官方文档参考)

## 1. 数据库集簇概览

### 1.1 学习目标

- 理解 PostgreSQL 中“数据库集簇”的边界。
- 区分服务器实例、数据库、schema 和数据库对象。
- 了解默认数据库的用途和模板关系。
- 能够根据 OID 在系统目录中定位数据库对象。

### 1.2 核心术语

| 术语 | 当前框架中的含义 | 官方参考 |
| --- | --- | --- |
| Database Cluster | 单个 PostgreSQL 服务器实例管理的数据库集合 | [Managing Databases](https://www.postgresql.org/docs/current/managing-databases.html) |
| Database | 数据库集簇中的逻辑数据库 | [Managing Databases](https://www.postgresql.org/docs/current/managing-databases.html) |
| Database Object | 数据库中的表、索引、序列等对象 | [System Catalogs](https://www.postgresql.org/docs/current/catalogs.html) |
| OID | PostgreSQL 用于标识部分系统对象的对象标识符 | [Object Identifier Types](https://www.postgresql.org/docs/current/datatype-oid.html) |

> 🚧 待补充：补充服务器实例、数据库集簇、数据库和 schema 的关系图。

## 2. 概念：服务器实例管理的数据库集合

**原始叶子节点**：单个 PostgreSQL 服务器实例管理的数据库集合。

### 2.1 待整理内容

- 一个 PostgreSQL server instance 初始化并管理一个 database cluster。
- 一个 database cluster 可以包含多个相互隔离的 database。
- 集簇级资源与单个数据库内对象需要区分说明。
- 同一集簇中的数据库不能直接跨库查询，跨库访问需要使用 dblink 或 FDW。

### 2.2 官方文档入口

- [Chapter 22. Managing Databases](https://www.postgresql.org/docs/current/managing-databases.html)
- [CREATE DATABASE](https://www.postgresql.org/docs/current/sql-createdatabase.html)
- [PostgreSQL Glossary：database cluster](https://www.postgresql.org/docs/current/glossary.html)

> 🚧 待补充：补充“集簇 / 数据库 / schema / 表”的层级示例。

## 3. 共享资源

**原始叶子节点**：全局配置文件、监听端口、进程、内存结构。

### 3.1 待整理内容

- 全局配置文件：`postgresql.conf`、`pg_hba.conf`、`pg_ident.conf`。
- 监听端口：服务器实例对外提供连接的网络入口。
- 进程：PostgreSQL 的主进程、后端进程和后台进程。
- 内存结构：共享内存和每个进程或会话使用的本地内存。

### 3.2 官方文档入口

- [Server Configuration](https://www.postgresql.org/docs/current/runtime-config.html)
- [Connections and Authentication](https://www.postgresql.org/docs/current/runtime-config-connection.html)
- [Server Setup and Operation](https://www.postgresql.org/docs/current/runtime.html)
- [Server Start-up Processes](https://www.postgresql.org/docs/current/server-start.html)
- [Resource Consumption](https://www.postgresql.org/docs/current/runtime-config-resource.html)

> 🚧 待补充：补充配置文件、监听端口、进程和内存结构之间的关系。

## 4. 默认数据库

**原始叶子节点**：`postgres`、`template0`、`template1`。

### 4.1 待整理内容

- `postgres`：通常作为默认连接目标或管理用途数据库。
- `template0`：纯净模板，通常作为创建数据库时的基础模板。
- `template1`：默认模板，创建新数据库时通常从该模板复制。
- 创建数据库时可以通过 `TEMPLATE` 指定模板数据库。

### 4.2 官方文档入口

- [Managing Databases](https://www.postgresql.org/docs/current/managing-databases.html)
- [Template Databases](https://www.postgresql.org/docs/current/manage-ag-templatedbs.html)
- [CREATE DATABASE：TEMPLATE clause](https://www.postgresql.org/docs/current/sql-createdatabase.html)
- [The `pg_database` system catalog](https://www.postgresql.org/docs/current/catalog-pg-database.html)

> 🚧 待补充：补充三个默认数据库的用途对比表和常用运维注意事项。

## 5. 创建数据库

**原始叶子节点**：官方文档：Chapter 2. Creating a Database。

### 5.1 待整理内容

- 使用 SQL 命令创建数据库。
- 使用命令行工具 `createdb` 创建数据库。
- 创建数据库时可以指定所有者、编码、模板和表空间。
- 创建数据库需要相应的权限。

### 5.2 官方文档入口

- [Chapter 2. Creating a Database](https://www.postgresql.org/docs/current/manage-ag-createdb.html)
- [CREATE DATABASE](https://www.postgresql.org/docs/current/sql-createdatabase.html)
- [createdb](https://www.postgresql.org/docs/current/app-createdb.html)

### 5.3 示例框架

```sql
-- TODO：根据实际学习环境补充可执行示例
CREATE DATABASE database_name;
```

> 🚧 待补充：补充创建数据库的完整参数、权限要求和验证步骤。

## 6. OID 与系统目录

**原始叶子节点**：所有数据库对象通过 OID（无符号四字节整数）管理，存储于系统目录表 [^43^][^54^]。

### 6.1 待整理内容

- OID 是 PostgreSQL 内部用于标识对象的标识符类型。
- 系统目录保存数据库对象的元数据。
- `pg_database` 保存数据库级信息。
- `pg_class` 保存表、索引、序列等 relation 的元数据。
- `pg_namespace` 保存 schema 信息。
- 不应把 OID 当作业务主键或长期稳定的业务标识。

### 6.2 官方文档入口

- [System Catalogs](https://www.postgresql.org/docs/current/catalogs.html)
- [Object Identifier Types](https://www.postgresql.org/docs/current/datatype-oid.html)
- [The `pg_database` system catalog](https://www.postgresql.org/docs/current/catalog-pg-database.html)
- [The `pg_class` system catalog](https://www.postgresql.org/docs/current/catalog-pg-class.html)
- [The `pg_namespace` system catalog](https://www.postgresql.org/docs/current/catalog-pg-namespace.html)

### 6.3 查询示例框架

```sql
-- TODO：补充当前数据库和对象元数据查询示例
SELECT oid, datname
FROM pg_catalog.pg_database;
```

> 🚧 待补充：补充 OID 生命周期、系统目录查询方法及 OID 与 relfilenode 的区别。

## 7. 学习任务

- [ ] 解释 database cluster 与 database 的区别。
- [ ] 列出集簇级共享资源，并指出对应配置或进程。
- [ ] 对比 `postgres`、`template0`、`template1`。
- [ ] 使用 `CREATE DATABASE` 创建测试数据库。
- [ ] 查询 `pg_database`，观察数据库 OID。
- [ ] 查询 `pg_class`，观察表、索引和序列的对象元数据。

## 8. 官方文档参考

1. [Chapter 2. Creating a Database](https://www.postgresql.org/docs/current/manage-ag-createdb.html)
2. [Managing Databases](https://www.postgresql.org/docs/current/managing-databases.html)
3. [Template Databases](https://www.postgresql.org/docs/current/manage-ag-templatedbs.html)
4. [CREATE DATABASE](https://www.postgresql.org/docs/current/sql-createdatabase.html)
5. [System Catalogs](https://www.postgresql.org/docs/current/catalogs.html)
6. [Object Identifier Types](https://www.postgresql.org/docs/current/datatype-oid.html)
7. [The `pg_database` system catalog](https://www.postgresql.org/docs/current/catalog-pg-database.html)
8. [The `pg_class` system catalog](https://www.postgresql.org/docs/current/catalog-pg-class.html)
9. [The `pg_namespace` system catalog](https://www.postgresql.org/docs/current/catalog-pg-namespace.html)

[^43^]: 原 LearningPath.md 中的关联注解编号，当前仅作为来源标记保留。
[^54^]: 原 LearningPath.md 中的关联注解编号，当前仅作为来源标记保留。
