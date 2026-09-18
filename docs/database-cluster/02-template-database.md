# 模板数据库

## 1. 工作方式

`CREATE DATABASE` 默认复制 `template1`。复制的是模板数据库中的数据库对象和数据，而不是创建一个持续同步的副本；创建完成后，源数据库和新数据库彼此独立。

- `template1`：默认建库模板，可按组织需要预置 schema、扩展或公共对象。
- `template0`：初始化时的干净模板，通常不允许普通连接，适合需要独立指定编码或 locale 的场景。
- `postgres`：普通的管理和连接入口，不是模板数据库。

修改模板前要评估影响：之后从该模板创建的每个数据库都会继承改动，但已经存在的数据库不会自动变化。

## 2. 查看模板属性

```sql
SELECT datname,
       datistemplate,
       datallowconn,
       pg_get_userbyid(datdba) AS owner,
       pg_encoding_to_char(encoding) AS encoding,
       datcollate
FROM pg_database
WHERE datistemplate
ORDER BY datname;
```

`datistemplate` 表示该数据库可作为模板，`datallowconn` 控制是否允许连接。`template0` 通常是 `datallowconn = false`，但管理员可以在确有需要时临时调整。

## 3. 使用模板创建数据库

```sql
CREATE DATABASE appdb TEMPLATE template1 OWNER app_owner;
CREATE DATABASE clean_db TEMPLATE template0 OWNER app_owner;
```

命令行写法：

```bash
createdb --template=template0 --owner=app_owner clean_db
```

从模板复制时，模板数据库不能有其他会话连接，否则建库可能失败。模板中的数据库级设置、扩展对象和数据也会被复制；角色本身属于集簇级对象，不会因为复制模板而被创建。

## 4. 常见做法与限制

如果需要让所有新业务库都带有公共扩展，可以在维护窗口中连接 `template1` 后执行相应安装操作；不要把业务数据、临时表或环境专属配置放入 `template1`。

需要不同编码或 locale 时使用 `template0`，并确认操作系统已提供目标 locale。模板数据库的所有者和连接权限也应纳入变更与审计范围。
