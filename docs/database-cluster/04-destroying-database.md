# 删除数据库

## 1. 删除前检查

`DROP DATABASE` 会删除数据库中的所有 schema、对象和数据文件，操作不可逆。执行前应确认备份、业务审批、数据库名称和目标集簇，避免把删除动作误执行到生产环境。

删除者必须是数据库所有者或超级用户，并且当前连接不能位于待删除的数据库中。应先连接到同一集簇中的 `postgres` 或其他管理数据库。

```sql
SELECT datname,
       pg_get_userbyid(datdba) AS owner,
       datallowconn
FROM pg_database
WHERE datname = 'appdb';
```

## 2. 删除语法

```sql
DROP DATABASE appdb;
```

PostgreSQL 13 及更高版本支持在删除时强制终止现有连接：

```sql
DROP DATABASE appdb WITH (FORCE);
```

`WITH (FORCE)` 仍可能因为准备事务、逻辑复制槽或其他无法终止的资源而失败。对于较早版本，应先确认并处理连接，再执行删除。

命令行工具：

```bash
dropdb appdb
dropdb --force appdb       # PostgreSQL 13+
```

## 3. 手动清理连接

在不支持 `WITH (FORCE)` 的版本中，可以从管理数据库查看并终止目标数据库连接：

```sql
SELECT pid, usename, client_addr, state, query
FROM pg_stat_activity
WHERE datname = 'appdb';

SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'appdb'
  AND pid <> pg_backend_pid();
```

确认应用连接池已停止后再执行 `DROP DATABASE`。不要直接删除 `PGDATA/base/<database_oid>` 下的目录；数据库目录必须由 PostgreSQL 通过 SQL 命令维护。
