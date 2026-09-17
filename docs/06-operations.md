# 六、运维管理

## 6.1 安装与部署

- 源码编译：灵活定制。
- 包管理器：yum、apt、brew。
- 容器化：Docker、Kubernetes。
- 初始化：initdb。

> 🚧 待补充

## 6.2 配置管理

- `postgresql.conf`：服务器参数。
- `pg_hba.conf`：客户端认证（信任、密码、LDAP、证书等）。
- `pg_ident.conf`：操作系统用户映射。
- 参数分类：内存、连接、WAL、查询规划、日志、复制。
- 配置生效：SIGHUP（pg_ctl reload）、需要重启、会话级 SET。

> 🚧 待补充

## 6.3 备份与恢复

- 物理备份：pg_basebackup、文件系统快照。
- 逻辑备份：pg_dump、pg_dumpall、pg_restore。
- PITR：基于 WAL 归档的时间点恢复。

> 🚧 待补充

## 6.4 高可用与复制

- 流复制（Streaming Replication）：同步 / 异步。
- 级联复制：备库再向下游复制。
- 故障转移：pg_ctl promote、patroni、repmgr。
- 负载均衡：pgpool-II、PgBouncer。

> 🚧 待补充

## 6.5 监控与诊断

- 系统视图：pg_stat_*、pg_locks、pg_activity。
- 日志分析：log_destination、log_min_duration_statement。
- 扩展工具：pg_stat_statements、auto_explain。
- 外部监控：Prometheus + Grafana、Zabbix。

> 🚧 待补充

## 6.6 安全管理

- 角色与权限：CREATE ROLE、GRANT、REVOKE。
- 行级安全（RLS）：CREATE POLICY。
- SSL 加密：ssl、ssl_cert_file、ssl_key_file。
- 审计：pgaudit 扩展。

> 🚧 待补充
