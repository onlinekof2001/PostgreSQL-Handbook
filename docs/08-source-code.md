# 八、源码与内核（资深方向）

## 8.1 源码结构

- backend/：后端核心代码。
- storage/：存储管理（buffer、file、ipc、lmgr、page、smgr）。
- access/：访问方法（heap、index、transam）。
- executor/：执行器。
- optimizer/：优化器。
- parser/：解析器。
- catalog/：系统目录。
- utils/：工具函数。
- 源码阅读起点：src/backend/storage/buffer/README。

> 🚧 待补充

## 8.2 扩展开发

- C 语言扩展：共享库、PG_FUNCTION_INFO_V1。
- 自定义数据类型、操作符、索引方法。
- 钩子（Hook）机制：拦截和修改内核行为。

> 🚧 待补充

## 8.3 社区与生态

- 邮件列表：pgsql-hackers、pgsql-general。
- 年度会议：PGCon、PostgreSQL Conference China。
- 贡献代码：提交补丁、审核、文档。

> 🚧 待补充
