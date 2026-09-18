# 数据库级配置

## 1. 作用范围

PostgreSQL 的许多运行参数可以按数据库设置。数据库级设置会写入系统目录，对该数据库后续建立的会话生效；已经建立的会话不会被强制修改。参数仍可能被更高优先级的会话级 `SET` 或连接配置覆盖。

## 2. 设置、重置和查看

```sql
ALTER DATABASE appdb SET work_mem = '16MB';
ALTER DATABASE appdb SET statement_timeout = '5min';
ALTER DATABASE appdb RESET statement_timeout;
```

查看某个数据库保存的设置：

```sql
SELECT datname, unnest(datconfig) AS setting
FROM pg_database
WHERE datname = 'appdb';
```

连接到目标数据库后，可以确认当前会话最终使用的值：

```sql
SELECT current_database(), current_setting('work_mem');
```

## 3. 与其他配置层级的区别

| 配置方式 | 作用范围 | 典型用途 |
| --- | --- | --- |
| `ALTER SYSTEM` | 整个实例 | 统一的实例级配置，写入 `postgresql.auto.conf` |
| `ALTER DATABASE` | 某个数据库的新会话 | 数据库级默认值 |
| `ALTER ROLE` | 某个角色的新会话 | 用户级默认值 |
| `ALTER ROLE ... IN DATABASE` | 某角色连接某数据库时 | 精确到角色和数据库的组合 |
| `SET` | 当前会话 | 临时调整当前连接 |

配置优先级和参数是否支持运行时修改取决于 PostgreSQL 版本及参数的 `context`。使用 `ALTER DATABASE` 前可检查：

```sql
SELECT name, setting, context, pending_restart
FROM pg_settings
WHERE name IN ('work_mem', 'statement_timeout', 'shared_buffers');
```

`shared_buffers` 等实例级参数不能通过数据库级配置替代；需要重启的参数也不会因为执行 `ALTER DATABASE` 而自动生效。

## 4. 权限与维护建议

通常只有数据库所有者或超级用户可以修改数据库级默认配置。建议在变更记录中同时保留参数、旧值、新值、作用范围和回滚语句，并用新建连接验证实际效果。
