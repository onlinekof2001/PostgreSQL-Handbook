# 数据库集簇

本目录介绍 PostgreSQL 数据库集簇中数据库的创建、模板、配置、删除和表空间。这里的“集簇（cluster）”是一次 `initdb` 初始化得到的数据库集合，不是高可用集群；一个 PostgreSQL 服务实例通常管理一个数据目录和一个集簇。

## 目录结构

```text
database-cluster/
├── README.md                         # 本章总览与学习顺序
├── 01-create-database.md             # 创建数据库
├── 02-template-database.md           # 模板数据库
├── 03-database-configuration.md      # 数据库级配置
├── 04-destroying-database.md         # 删除数据库
└── 05-tablespaces.md                 # 表空间
```

## 学习路径

1. [01 创建数据库](01-create-database.md)：了解数据库与集簇的边界，以及 `CREATE DATABASE`。
2. [02 模板数据库](02-template-database.md)：理解 `template0`、`template1` 和数据库复制来源。
3. [03 数据库配置](03-database-configuration.md)：为单个数据库设置会话参数。
4. [04 删除数据库](04-destroying-database.md)：掌握连接清理、权限和 `DROP DATABASE`。
5. [05 表空间](05-tablespaces.md)：将数据库对象映射到指定的文件系统位置。

## 核心层次

```text
PostgreSQL 集簇（一个 PGDATA）
├── pg_global：集簇级共享系统目录
├── database：多个相互隔离的数据库
│   ├── schema：数据库内的命名空间
│   │   └── table / index / view / sequence / function ...
│   └── database-level settings
└── tablespace：数据库对象的物理存储位置
```

- 一个集簇可以包含多个数据库；客户端一次连接只连接到其中一个数据库。
- 角色、表空间和部分系统目录属于集簇级对象；表、视图、函数等通常属于某个数据库。
- 数据库之间默认不能直接引用对象；跨数据库访问应使用 `postgres_fdw`、`dblink` 等明确的外部访问方式。
- `CREATE DATABASE` 和 `DROP DATABASE` 作用于数据库本身，不能在事务块中执行。

## 常用检查

在任意可连接的数据库中，可以使用 `psql` 的 `\l` 或以下查询查看数据库：

```sql
SELECT datname,
       pg_get_userbyid(datdba) AS owner,
       pg_encoding_to_char(encoding) AS encoding,
       datcollate,
       dattablespace
FROM pg_database
ORDER BY datname;
```

命令行也可以执行：

```bash
psql -l
```

本章示例默认使用具有相应权限的管理角色，并以 `postgres` 数据库作为管理连接入口。实际操作前应确认 PostgreSQL 版本、数据库所有者、文件系统权限和备份策略。
