# 表空间

## 1. 概念

表空间是 PostgreSQL 对文件系统位置的逻辑映射。数据库、表、索引和物化视图等对象可以放在指定表空间，从而将不同对象分布到不同磁盘或文件系统。

集簇初始化时通常包含：

- `pg_default`：默认表空间，对应 `PGDATA/base`。
- `pg_global`：存放集簇级共享系统目录，不能作为普通对象的迁移目标。

表空间位置必须是 PostgreSQL 服务进程可访问的目录。目录应由操作系统层面的 PostgreSQL 用户拥有，并且不能随意在数据库运行期间移动或删除。

## 2. 创建与查看

```sql
CREATE TABLESPACE fast_ssd
    OWNER app_owner
    LOCATION '/data/postgresql/fast_ssd';
```

创建前应在操作系统上准备一个空目录，并设置正确的所有者和权限。表空间路径不能位于数据库目录内部，也不能与其他表空间复用。

```sql
SELECT spcname,
       pg_get_userbyid(spcowner) AS owner,
       pg_tablespace_location(oid) AS location
FROM pg_tablespace
ORDER BY spcname;
```

## 3. 使用表空间

为数据库指定默认表空间：

```sql
ALTER DATABASE appdb SET TABLESPACE fast_ssd;
```

单独为表或索引指定表空间：

```sql
CREATE TABLE app.orders (
    order_id bigint PRIMARY KEY,
    created_at timestamptz NOT NULL
) TABLESPACE fast_ssd;

CREATE INDEX orders_created_at_idx
    ON app.orders (created_at)
    TABLESPACE fast_ssd;
```

移动已经存在的对象：

```sql
ALTER TABLE app.orders SET TABLESPACE fast_ssd;
ALTER INDEX app.orders_created_at_idx SET TABLESPACE fast_ssd;
```

移动表通常会重写表文件并产生较多 I/O，生产环境应安排维护窗口并预留足够磁盘空间。

## 4. 权限、备份与删除

创建表空间需要超级用户或相应的表空间管理权限，且对象创建者还需要对目标表空间有 `CREATE` 权限：

```sql
GRANT CREATE ON TABLESPACE fast_ssd TO app_owner;
```

表空间不是备份策略的替代品。使用 `pg_basebackup`、文件系统快照或其他备份工具时，必须同时纳入所有表空间目录，并保证恢复主机上的挂载路径一致或使用正确的重定位配置。

删除前必须先迁移其中的对象：

```sql
ALTER TABLE app.orders SET TABLESPACE pg_default;
DROP TABLESPACE fast_ssd;
```

不能删除仍包含对象的表空间，也不应尝试手工删除其目录。数据库级默认表空间变更只影响后续创建或迁移的对象，不会自动移动已有对象。
