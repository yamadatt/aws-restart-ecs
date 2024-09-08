- [1. このリポジトリは](#1-このリポジトリは)
- [2. 構成](#2-構成)
- [3. 使用したコマンド](#3-使用したコマンド)
  - [3.1. タスク定義ファイルを作成](#31-タスク定義ファイルを作成)
  - [3.2. タスク一覧表示](#32-タスク一覧表示)
  - [3.3. タスク定義の登録](#33-タスク定義の登録)
  - [3.4. ECSへのデプロイ](#34-ecsへのデプロイ)
  - [3.5. コンテナアタッチ](#35-コンテナアタッチ)
  - [3.6. コンテナを落とす](#36-コンテナを落とす)
- [4. 結果](#4-結果)


## 1. このリポジトリは

ECSタスクのコンテナにリスタート設定を入れて素振りするためのもの。

## 2. 構成

nginxコンテナとlog_routerコンテナが同一タスクで動いている。

## 3. 使用したコマンド


### 3.1. タスク定義ファイルを作成

ファイル出力に最後尾の```registeredAt```と```registeredBy```を削除すること。

```bash
aws ecs describe-task-definition --task-definition stag-yamada-nginx-def |   jq '.taskDefinition | del (.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities)' > task-def.json 
```
### 3.2. タスク一覧表示

```bash
aws ecs list-tasks --cluster stag-yamada-ecs --service-name stag-yamada-nginx-service
```

### 3.3. タスク定義の登録

```bash
aws ecs register-task-definition --cli-input-json file://task-def.json
```

### 3.4. ECSへのデプロイ

```bash
aws ecs update-service --cluster stag-yamada-ecs --service stag-yamada-nginx-service --task-definition stag-yamada-nginx-def
```
### 3.5. コンテナアタッチ

コンテナにアタッチするためのコマンド。

```bash
aws ecs execute-command \
  --cluster stag-yamada-ecs \
  --task arn:aws:ecs:ap-northeast-1:449671225256:task/stag-yamada-ecs/57f00fb643c74df282b5187c938473d7 \
  --container log_router \
  --interactive \
  --command "/bin/sh"
```

### 3.6. コンテナを落とす

コンテナにアタッチするだけで、コマンドだけいれる。

コンテナを落とすコマンド。

```bash
aws ecs execute-command \
--cluster stag-yamada-ecs \
--task arn:aws:ecs:ap-northeast-1:449671225256:task/stag-yamada-ecs/a710f676562a4f5a8868003cb2ca5d1a \
--container log_router \
--interactive \
--command "kill -SIGTERM 1"
```

## 4. 結果

CloudWatchのログから。

以下でSIGTERMを検知。

```log
| 1725796866059 | [2024/09/08 12:01:06] [engine] caught signal (SIGTERM)                                                                      |
| 1725796866059 | [2024/09/08 12:01:06] [ info] [input] pausing forward.0                                                                     |
| 1725796866059 | [2024/09/08 12:01:06] [ warn] [engine] service will shutdown in max 5 seconds  
```

その後、以下でプロセスがスタートしている。（リスタートを確認できた）

```log
| 1725796878414 | [2024/09/08 12:01:18] [ info] [sp] stream processor started     
```

全部のログは以下。

```log
-----------------------------------------------------------------------------------------------------------------------------------------------
|   timestamp   |                                                           message                                                           |
|---------------|-----------------------------------------------------------------------------------------------------------------------------|
| 1725796605494 | AWS for Fluent Bit Container Image Version 2.32.2.20240820                                                                  |
| 1725796605915 | Fluent Bit v1.9.10                                                                                                          |
| 1725796605915 | * Copyright (C) 2015-2022 The Fluent Bit Authors                                                                            |
| 1725796605915 | * Fluent Bit is a CNCF sub-project under the umbrella of Fluentd                                                            |
| 1725796605915 | * https://fluentbit.io                                                                                                      |
| 1725796605994 | [2024/09/08 11:56:45] [ info] [fluent bit] version=1.9.10, commit=1cebbf0106, pid=1                                         |
| 1725796605995 | [2024/09/08 11:56:45] [ info] [storage] version=1.4.0, type=memory-only, sync=normal, checksum=disabled, max_chunks_up=128  |
| 1725796605995 | [2024/09/08 11:56:45] [ info] [cmetrics] version=0.3.7                                                                      |
| 1725796605995 | [2024/09/08 11:56:45] [ info] [input:forward:forward.0] listening on 0.0.0.0:24224                                          |
| 1725796605996 | time="2024-09-08T11:56:45Z" level=info msg="[cloudwatch 0] plugin parameter log_group_name = 'fluent-bit-cloudwatch'"       |
| 1725796605996 | time="2024-09-08T11:56:45Z" level=info msg="[cloudwatch 0] plugin parameter default_log_group_name = 'fluentbit-default'"   |
| 1725796605996 | time="2024-09-08T11:56:45Z" level=info msg="[cloudwatch 0] plugin parameter log_stream_prefix = 'from-fluent-bit-'"         |
| 1725796605996 | time="2024-09-08T11:56:45Z" level=info msg="[cloudwatch 0] plugin parameter log_stream_name = ''"                           |
| 1725796605996 | time="2024-09-08T11:56:45Z" level=info msg="[cloudwatch 0] plugin parameter default_log_stream_name = '/fluentbit-default'" |
| 1725796605996 | time="2024-09-08T11:56:45Z" level=info msg="[cloudwatch 0] plugin parameter region = 'us-east-1'"                           |
| 1725796605996 | time="2024-09-08T11:56:45Z" level=info msg="[cloudwatch 0] plugin parameter log_key = ''"                                   |
| 1725796605996 | time="2024-09-08T11:56:45Z" level=info msg="[cloudwatch 0] plugin parameter role_arn = ''"                                  |
| 1725796605996 | time="2024-09-08T11:56:45Z" level=info msg="[cloudwatch 0] plugin parameter auto_create_group = 'true'"                     |
| 1725796605996 | time="2024-09-08T11:56:45Z" level=info msg="[cloudwatch 0] plugin parameter auto_create_stream = 'true'"                    |
| 1725796605996 | time="2024-09-08T11:56:45Z" level=info msg="[cloudwatch 0] plugin parameter new_log_group_tags = ''"                        |
| 1725796605996 | time="2024-09-08T11:56:45Z" level=info msg="[cloudwatch 0] plugin parameter log_retention_days = '0'"                       |
| 1725796605996 | time="2024-09-08T11:56:45Z" level=info msg="[cloudwatch 0] plugin parameter endpoint = ''"                                  |
| 1725796605996 | time="2024-09-08T11:56:45Z" level=info msg="[cloudwatch 0] plugin parameter sts_endpoint = ''"                              |
| 1725796605996 | time="2024-09-08T11:56:45Z" level=info msg="[cloudwatch 0] plugin parameter external_id = ''"                               |
| 1725796605996 | time="2024-09-08T11:56:45Z" level=info msg="[cloudwatch 0] plugin parameter credentials_endpoint = "                        |
| 1725796605996 | time="2024-09-08T11:56:45Z" level=info msg="[cloudwatch 0] plugin parameter log_format = ''"                                |
| 1725796605997 | [2024/09/08 11:56:45] [ info] [sp] stream processor started                                                                 |
| 1725796866059 | [2024/09/08 12:01:06] [engine] caught signal (SIGTERM)                                                                      |
| 1725796866059 | [2024/09/08 12:01:06] [ info] [input] pausing forward.0                                                                     |
| 1725796866059 | [2024/09/08 12:01:06] [ warn] [engine] service will shutdown in max 5 seconds                                               |
| 1725796866974 | [2024/09/08 12:01:06] [ info] [engine] service has stopped (0 pending tasks)                                                |
| 1725796878304 | AWS for Fluent Bit Container Image Version 2.32.2.20240820                                                                  |
| 1725796878411 | Fluent Bit v1.9.10                                                                                                          |
| 1725796878411 | * Copyright (C) 2015-2022 The Fluent Bit Authors                                                                            |
| 1725796878411 | * Fluent Bit is a CNCF sub-project under the umbrella of Fluentd                                                            |
| 1725796878411 | * https://fluentbit.io                                                                                                      |
| 1725796878413 | [2024/09/08 12:01:18] [ info] [fluent bit] version=1.9.10, commit=1cebbf0106, pid=1                                         |
| 1725796878414 | [2024/09/08 12:01:18] [ info] [storage] version=1.4.0, type=memory-only, sync=normal, checksum=disabled, max_chunks_up=128  |
| 1725796878414 | [2024/09/08 12:01:18] [ info] [cmetrics] version=0.3.7                                                                      |
| 1725796878414 | [2024/09/08 12:01:18] [ info] [input:forward:forward.0] listening on 0.0.0.0:24224                                          |
| 1725796878414 | time="2024-09-08T12:01:18Z" level=info msg="[cloudwatch 0] plugin parameter log_group_name = 'fluent-bit-cloudwatch'"       |
| 1725796878414 | time="2024-09-08T12:01:18Z" level=info msg="[cloudwatch 0] plugin parameter default_log_group_name = 'fluentbit-default'"   |
| 1725796878414 | time="2024-09-08T12:01:18Z" level=info msg="[cloudwatch 0] plugin parameter log_stream_prefix = 'from-fluent-bit-'"         |
| 1725796878414 | time="2024-09-08T12:01:18Z" level=info msg="[cloudwatch 0] plugin parameter log_stream_name = ''"                           |
| 1725796878414 | time="2024-09-08T12:01:18Z" level=info msg="[cloudwatch 0] plugin parameter default_log_stream_name = '/fluentbit-default'" |
| 1725796878414 | time="2024-09-08T12:01:18Z" level=info msg="[cloudwatch 0] plugin parameter region = 'us-east-1'"                           |
| 1725796878414 | time="2024-09-08T12:01:18Z" level=info msg="[cloudwatch 0] plugin parameter log_key = ''"                                   |
| 1725796878414 | time="2024-09-08T12:01:18Z" level=info msg="[cloudwatch 0] plugin parameter role_arn = ''"                                  |
| 1725796878414 | time="2024-09-08T12:01:18Z" level=info msg="[cloudwatch 0] plugin parameter auto_create_group = 'true'"                     |
| 1725796878414 | time="2024-09-08T12:01:18Z" level=info msg="[cloudwatch 0] plugin parameter auto_create_stream = 'true'"                    |
| 1725796878414 | time="2024-09-08T12:01:18Z" level=info msg="[cloudwatch 0] plugin parameter new_log_group_tags = ''"                        |
| 1725796878414 | time="2024-09-08T12:01:18Z" level=info msg="[cloudwatch 0] plugin parameter log_retention_days = '0'"                       |
| 1725796878414 | time="2024-09-08T12:01:18Z" level=info msg="[cloudwatch 0] plugin parameter endpoint = ''"                                  |
| 1725796878414 | time="2024-09-08T12:01:18Z" level=info msg="[cloudwatch 0] plugin parameter sts_endpoint = ''"                              |
| 1725796878414 | time="2024-09-08T12:01:18Z" level=info msg="[cloudwatch 0] plugin parameter external_id = ''"                               |
| 1725796878414 | time="2024-09-08T12:01:18Z" level=info msg="[cloudwatch 0] plugin parameter credentials_endpoint = "                        |
| 1725796878414 | time="2024-09-08T12:01:18Z" level=info msg="[cloudwatch 0] plugin parameter log_format = ''"                                |
| 1725796878414 | [2024/09/08 12:01:18] [ info] [sp] stream processor started                                                                 |
-----------------------------------------------------------------------------------------------------------------------------------------------
```