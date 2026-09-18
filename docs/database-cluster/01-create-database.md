# 创建数据库

## 1. 概念

数据库是 PostgreSQL 集簇中的逻辑隔离单元。一个集簇可以包含多个数据库，但客户端建立连接时必须选择一个目标数据库；连接建立后，SQL 默认只能访问该数据库中的 schema 和对象。

使用 `initdb` 初始化集簇时，通常会创建 `postgres`、`template0` 和 `template1` 三个数据库。`postgres` 只是一个便于管理和连接的普通数据库，不是 PostgreSQL 内核必需的“原始库”。模板数据库的用途见[模板数据库](02-template-database.md)。

## 2. 语法

```sql
CREATE DATABASE name
    [ [ WITH ] OWNER [=] role_name ]
    [ TEMPLATE [=] template_name ]
    [ ENCODING [=] encoding ]
    [ LC_COLLATE [=] lc_collate ]
    [ LC_CTYPE [=] lc_ctype ]
    [ TABLESPACE [=] tablespace_name ]
    [ IS_TEMPLATE [=] is_template ]
    [ ALLOW_CONNECTIONS [=] allowconn ];
```

创建数据库需要超级用户、具有 `CREATEDB` 属性的角色，或满足版本要求的相应权限。数据库名必须在集簇中唯一，且 `CREATE DATABASE` 不能在事务块中执行。

## 3. 创建示例

```sql
-- 使用默认的 template1 创建，并指定所有者
CREATE DATABASE appdb OWNER app_owner;

-- 使用更干净的 template0 创建
CREATE DATABASE reportdb
    WITH OWNER = report_owner
         TEMPLATE = template0
         ENCODING = 'UTF8';
```

命令行工具对应的写法：

```bash
createdb appdb
createdb --owner=app_owner appdb
createdb --template=template0 reportdb
```

`TEMPLATE`、编码和 locale 必须与模板及操作系统支持情况相容；需要自定义编码或 locale 时，通常从 `template0` 创建。数据库创建完成后，再连接到新数据库执行 schema、扩展和业务对象初始化。

## 4. 验证

```sql
SELECT datname,
       pg_get_userbyid(datdba) AS owner,
       pg_encoding_to_char(encoding) AS encoding,
       datcollate,
       dattablespace
FROM pg_database
WHERE datname IN ('appdb', 'reportdb');
```

也可以连接并确认当前数据库：

```bash
psql --dbname=appdb -c 'SELECT current_database(), current_user;'
```
