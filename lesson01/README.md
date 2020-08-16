# TiDB课后作业



> 课前学习资料：
> [1. How we build TiDB](https://pingcap.com/blog-cn/how-do-we-build-tidb/)  
> [2. 三篇文章了解 TiDB 技术内幕 - 说存储](https://pingcap.com/blog-cn/tidb-internal-1/)  
> [3. 三篇文章了解 TiDB 技术内幕 - 说计算](https://pingcap.com/blog-cn/tidb-internal-2/)  
> [4. 三篇文章了解 TiDB 技术内幕 - 谈调度](https://pingcap.com/blog-cn/tidb-internal-3/)  
> 视频：[https://www.bilibili.com/video/BV17K411T7Kd](https://www.bilibili.com/video/BV17K411T7Kd)  
> 课程作业：  
> 本地下载 TiDB，TiKV，PD 源代码，改写源码并编译部署以下环境：  
> - 1 TiDB
> - 1 PD
> - 3 TiKV
> 改写后：使得 TiDB 启动事务时，能打印出一个 “hello transaction” 的 日志


<br />TIDB架构:<br />![image.png](https://cdn.nlark.com/yuque/0/2020/png/87032/1597543776239-8f06dda5-4b30-4936-82d1-a913f44f391e.png#align=left&display=inline&height=591&margin=%5Bobject%20Object%5D&name=image.png&originHeight=1182&originWidth=2200&size=207352&status=done&style=none&width=1100)<br />根据架构图的依赖关系，我们依次部署 pd, tikv, tidb。
<a name="NYjb9"></a>
## PD(Placement Driver)
PD通过嵌入etcd支持分布和容错，它用于管理和调度TiKV集群。每个 TiKV 节点会定期向 PD 汇报节点的整体信息。<br />Golang: 1.13<br />Code: [https://github.com/pingcap/pd](https://github.com/pingcap/pd)<br />编译代码：
```bash
[root@test tikv]# pd
CGO_ENABLED=1 go build  -gcflags '' -ldflags '-X "github.com/pingcap/pd/v4/server/versioninfo.PDReleaseVersion=v4.0.0-rc.2-140-g865fbd82" -X "github.com/pingcap/pd/v4/server/versioninfo.PDBuildTS=2020-08-16 05:07:50" -X "github.com/pingcap/pd/v4/server/versioninfo.PDGitHash=865fbd82a028aecfb875a20b932fee3ba4b8c73c" -X "github.com/pingcap/pd/v4/server/versioninfo.PDGitBranch=master" -X "github.com/pingcap/pd/v4/server/versioninfo.PDEdition=Community" -X "github.com/pingcap-incubator/tidb-dashboard/pkg/utils/version.InternalVersion=2020.08.07.1" -X "github.com/pingcap-incubator/tidb-dashboard/pkg/utils/version.Standalone=No" -X "github.com/pingcap-incubator/tidb-dashboard/pkg/utils/version.PDVersion=v4.0.0-rc.2-140-g865fbd82" -X "github.com/pingcap-incubator/tidb-dashboard/pkg/utils/version.BuildTime=2020-08-16 05:07:51" -X "github.com/pingcap-incubator/tidb-dashboard/pkg/utils/version.BuildGitHash=01f0abe88e93"' -tags " swagger_server" -o bin/pd-server cmd/pd-server/main.go
CGO_ENABLED=0 go build -gcflags '' -ldflags '-X "github.com/pingcap/pd/v4/server/versioninfo.PDReleaseVersion=v4.0.0-rc.2-140-g865fbd82" -X "github.com/pingcap/pd/v4/server/versioninfo.PDBuildTS=2020-08-16 05:10:01" -X "github.com/pingcap/pd/v4/server/versioninfo.PDGitHash=865fbd82a028aecfb875a20b932fee3ba4b8c73c" -X "github.com/pingcap/pd/v4/server/versioninfo.PDGitBranch=master" -X "github.com/pingcap/pd/v4/server/versioninfo.PDEdition=Community" -X "github.com/pingcap-incubator/tidb-dashboard/pkg/utils/version.InternalVersion=2020.08.07.1" -X "github.com/pingcap-incubator/tidb-dashboard/pkg/utils/version.Standalone=No" -X "github.com/pingcap-incubator/tidb-dashboard/pkg/utils/version.PDVersion=v4.0.0-rc.2-140-g865fbd82" -X "github.com/pingcap-incubator/tidb-dashboard/pkg/utils/version.BuildTime=2020-08-16 05:10:02" -X "github.com/pingcap-incubator/tidb-dashboard/pkg/utils/version.BuildGitHash=01f0abe88e93"' -o bin/pd-ctl tools/pd-ctl/main.go
CGO_ENABLED=0 go build -gcflags '' -ldflags '-X "github.com/pingcap/pd/v4/server/versioninfo.PDReleaseVersion=v4.0.0-rc.2-140-g865fbd82" -X "github.com/pingcap/pd/v4/server/versioninfo.PDBuildTS=2020-08-16 05:10:26" -X "github.com/pingcap/pd/v4/server/versioninfo.PDGitHash=865fbd82a028aecfb875a20b932fee3ba4b8c73c" -X "github.com/pingcap/pd/v4/server/versioninfo.PDGitBranch=master" -X "github.com/pingcap/pd/v4/server/versioninfo.PDEdition=Community" -X "github.com/pingcap-incubator/tidb-dashboard/pkg/utils/version.InternalVersion=2020.08.07.1" -X "github.com/pingcap-incubator/tidb-dashboard/pkg/utils/version.Standalone=No" -X "github.com/pingcap-incubator/tidb-dashboard/pkg/utils/version.PDVersion=v4.0.0-rc.2-140-g865fbd82" -X "github.com/pingcap-incubator/tidb-dashboard/pkg/utils/version.BuildTime=2020-08-16 05:10:26" -X "github.com/pingcap-incubator/tidb-dashboard/pkg/utils/version.BuildGitHash=01f0abe88e93"' -o bin/pd-recover tools/pd-recover/main.go
```
编译出三个可执行文件
```bash
./bin/pd-server
./bin/pd-ctl
./bin/pd-recover
```


运行：<br />参考 [https://github.com/pingcap/pd](https://github.com/pingcap/pd)
```bash
export HostIP="10.0.2.94"
pd-server --name="pd" \
    --data-dir="pd" \
    --client-urls="http://${HostIP}:12379" \
    --peer-urls="http://${HostIP}:12380" \
    --log-file=pd.log
```
运行后能通过api看到pd的节点信息， 我们这里只有一个节点<br />[http://10.0.2.94:12379/pd/api/v1/members](http://10.0.2.94:12379/pd/api/v1/members)
```json
{
	"header": {
		"cluster_id": 6861460113396132000
	},
	"members": [{
		"name": "pd",
		"member_id": 13805696380853990000,
		"peer_urls": [
			"http://10.0.2.94:12380"
		],
		"client_urls": [
			"http://10.0.2.94:12379"
		],
		"deploy_path": "/root/git/pd/bin",
		"binary_version": "v4.0.0-rc.2-140-g865fbd82",
		"git_hash": "865fbd82a028aecfb875a20b932fee3ba4b8c73c"
	}],
	"leader": {
		"name": "pd",
		"member_id": 13805696380853990000,
		"peer_urls": [
			"http://10.0.2.94:12380"
		],
		"client_urls": [
			"http://10.0.2.94:12379"
		]
	},
	"etcd_leader": {
		"name": "pd",
		"member_id": 13805696380853990000,
		"peer_urls": [
			"http://10.0.2.94:12380"
		],
		"client_urls": [
			"http://10.0.2.94:12379"
		],
		"deploy_path": "/root/git/pd/bin",
		"binary_version": "v4.0.0-rc.2-140-g865fbd82",
		"git_hash": "865fbd82a028aecfb875a20b932fee3ba4b8c73c"
	}
}
```
<a name="YgscB"></a>
## TiKV
<a name="t5F7R"></a>
### 编译
编译环境：rust, cmake3.1, gcc, g++。rust参考：[https://www.rust-lang.org/zh-CN/learn/get-started](https://www.rust-lang.org/zh-CN/learn/get-started)。<br />Code：[https://github.com/tikv/tikv](https://github.com/tikv/tikv)<br />编译代码：
```bash
[root@test tikv]# make
cargo build --release --no-default-features --features " jemalloc portable sse protobuf-codec"
    Updating git repository `https://github.com/tikv/fail-rs.git`
    Updating git repository `https://github.com/tikv/rust-prometheus.git`
    Updating git repository `https://github.com/pingcap/rust-protobuf`
    Updating git submodule `https://github.com/google/protobuf`
    Updating git submodule `https://github.com/google/benchmark.git`
    Updating git repository `https://github.com/pingcap/raft-rs`
    Updating crates.io index
    Updating git repository `https://github.com/pingcap/kvproto.git`
    Updating git repository `https://github.com/breeswish/slog-global.git`
    Updating git repository `https://github.com/pingcap/tipb.git`
    Updating git repository `https://github.com/pingcap-incubator/minitrace-rust.git`
    Updating git repository `https://github.com/tikv/yatp.git`
    Updating git repository `https://github.com/tikv/procinfo-rs`
    Updating git repository `https://github.com/tikv/rust-rocksdb.git`
    Updating git submodule `https://github.com/tikv/rocksdb.git`
    Updating git submodule `https://github.com/tikv/titan.git`
    Updating git repository `https://github.com/busyjay/lz4-rs.git`
    Updating git submodule `https://github.com/lz4/lz4.git`
    Updating git repository `https://github.com/busyjay/rust-snappy.git`
    Updating git submodule `https://github.com/google/snappy.git`
  Downloaded futures-channel v0.3.4
  Downloaded hex v0.3.2
  ...
  Downloaded 328 crates (56.5 MB) in 13.48s (largest was `protobuf-build` at 9.8 MB)
  ...
   Compiling tipb v0.0.1 (https://github.com/pingcap/tipb.git#dcfcea0b)
   Compiling num v0.2.1
   Compiling chrono-tz v0.5.1
   Compiling cdc v0.0.1 (/root/git/tikv/components/cdc)
   Compiling cmd v0.0.1 (/root/git/tikv/cmd)
    Finished release [optimized] target(s) in 31m 16s
```
这个过程比较耗时，我看了下编译输出，需要下载编译328个依赖。<br />编译出两个可执行文件
```bash
./target/release/tikv-server
./target/release/tikv-ctl
```

<br />运行：<br />参考[https://tikv.org/docs/4.0/tasks/deploy/binary/](https://tikv.org/docs/4.0/tasks/deploy/binary/)<br />启动三个tikv节点
```bash
# Set correct HostIP here.
export HostIP="10.0.2.94"

tikv-server --pd-endpoints="${HostIP}:12379" \
    --addr="${HostIP}:20160" \
    --data-dir=tikv1 \
    --log-file=tikv1.log

tikv-server --pd-endpoints="${HostIP}:12379" \
    --addr="${HostIP}:20161" \
    --data-dir=tikv2 \
    --log-file=tikv2.log

tikv-server --pd-endpoints="${HostIP}:12379" \
    --addr="${HostIP}:20162" \
    --data-dir=tikv3 \
    --log-file=tikv3.log
```

<br />启动完毕后可以从PD获取tikv节点的状态<br />`pd-ctl store -u http://10.0.2.94:12379`
```bash
{
	"count": 3,
	"stores": [{
			"store": {
				"id": 1,
				"address": "10.0.2.94:20160",
				"version": "4.1.0-alpha",
				"status_address": "127.0.0.1:20180",
				"git_hash": "ae7a6ecee6e3367da016df0293a9ffe9cc2b5705",
				"start_timestamp": 1597558458,
				"deploy_path": "/root/git/tikv/target/release",
				"last_heartbeat": 1597559258639045957,
				"state_name": "Up"
			},
			"status": {
				"capacity": "199.9GiB",
				"available": "15.73GiB",
				"used_size": "31.5MiB",
				"leader_count": 1,
				"leader_weight": 1,
				"leader_score": 1,
				"leader_size": 1,
				"region_count": 1,
				"region_weight": 1,
				"region_score": 1073725712.34375,
				"region_size": 1,
				"start_ts": "2020-08-16T14:14:18+08:00",
				"last_heartbeat_ts": "2020-08-16T14:27:38.639045957+08:00",
				"uptime": "13m20.639045957s"
			}
		},
		{
			"store": {
				"id": 4,
				"address": "10.0.2.94:20161",
				"version": "4.1.0-alpha",
				"status_address": "127.0.0.1:20180",
				"git_hash": "ae7a6ecee6e3367da016df0293a9ffe9cc2b5705",
				"start_timestamp": 1597558500,
				"deploy_path": "/root/git/tikv/target/release",
				"last_heartbeat": 1597559260486680776,
				"state_name": "Up"
			},
			"status": {
				"capacity": "199.9GiB",
				"available": "15.73GiB",
				"used_size": "31.5MiB",
				"leader_count": 0,
				"leader_weight": 1,
				"leader_score": 0,
				"leader_size": 0,
				"region_count": 0,
				"region_weight": 1,
				"region_score": 1073725712.34375,
				"region_size": 0,
				"start_ts": "2020-08-16T14:15:00+08:00",
				"last_heartbeat_ts": "2020-08-16T14:27:40.486680776+08:00",
				"uptime": "12m40.486680776s"
			}
		},
		{
			"store": {
				"id": 5,
				"address": "10.0.2.94:20162",
				"version": "4.1.0-alpha",
				"status_address": "127.0.0.1:20180",
				"git_hash": "ae7a6ecee6e3367da016df0293a9ffe9cc2b5705",
				"start_timestamp": 1597558513,
				"deploy_path": "/root/git/tikv/target/release",
				"last_heartbeat": 1597559253686446464,
				"state_name": "Up"
			},
			"status": {
				"capacity": "199.9GiB",
				"available": "15.73GiB",
				"used_size": "31.5MiB",
				"leader_count": 0,
				"leader_weight": 1,
				"leader_score": 0,
				"leader_size": 0,
				"region_count": 0,
				"region_weight": 1,
				"region_score": 1073725712.34375,
				"region_size": 0,
				"start_ts": "2020-08-16T14:15:13+08:00",
				"last_heartbeat_ts": "2020-08-16T14:27:33.686446464+08:00",
				"uptime": "12m20.686446464s"
			}
		}
	]
}
```
启动state_name为Up表示节点部署成功。
<a name="OFSfG"></a>
## TiDB
tidb基于pd和tikv提供分布式关系数据库功能，100% 兼容 MySQL 5.7 协议。<br />Golang: 1.13<br />Code: [https://github.com/pingcap/tidb](https://github.com/pingcap/tidb)
```bash
[root@test tidb]# make
CGO_ENABLED=1 GO111MODULE=on go build  -tags codes  -ldflags '-X "github.com/pingcap/parser/mysql.TiDBReleaseVersion=v4.0.0-beta.2-960-g5184a0d70" -X "github.com/pingcap/tidb/util/versioninfo.TiDBBuildTS=2020-08-16 01:41:43" -X "github.com/pingcap/tidb/util/versioninfo.TiDBGitHash=5184a0d7060906e2022d18f11532f119f5df3f39" -X "github.com/pingcap/tidb/util/versioninfo.TiDBGitBranch=master" -X "github.com/pingcap/tidb/util/versioninfo.TiDBEdition=Community" ' -o bin/tidb-server tidb-server/main.go
Build TiDB Server successfully!
```

<br />编译出一个可执行文件
```shell
./bin/tidb-server
```

<br />部署：<br />在官方文档里没有找到纯二进制部署的文档，我是参考了ansible部署的文档<br />参考[https://docs.pingcap.com/zh/tidb/stable/online-deployment-using-ansible](https://docs.pingcap.com/zh/tidb/stable/online-deployment-using-ansible)
```bash
tidb-server -path 10.0.2.94:12379 -store tikv
```
tidb-server默认是使用mocktikv，把数据存储在/tmp/tidb下。我们这里要配置成使用tikv去存储数据，同时通过-path去指定pd地址。<br />
<br />tidb启动:<br />可以用适配mysql5.7协议的mysql客户端工具去访问了。默认用户root，没有密码
```bash
[root@test git]# mycli -h 10.0.2.94 -P 4000 -u root
mysql root@10.0.2.94:(none)> show databases
+--------------------+
| Database           |
+--------------------+
| INFORMATION_SCHEMA |
| METRICS_SCHEMA     |
| PERFORMANCE_SCHEMA |
| mysql              |
| test               |
+--------------------+
5 rows in set
Time: 0.011s
```
<a name="FJ0EH"></a>
## 让TIDB在开启事物时打印日志
tidb的事物效果还是依赖于tikv的事物能力。这里主要修改了tikv相关的代码，tidb调用tikv开启事物。<br />修改的代码：
```bash
diff --git a/session/session.go b/session/session.go
index 622688f59..5f2b59d10 100644
--- a/session/session.go
+++ b/session/session.go
@@ -2165,6 +2165,7 @@ func (s *session) PrepareTxnCtx(ctx context.Context) {
        if s.txn.validOrPending() {
                return
        }
+       logutil.Logger(ctx).Info("hello transaction")
 
        is := domain.GetDomain(s).InfoSchema()
        s.sessionVars.TxnCtx = &variable.TransactionContext{
@@ -2201,6 +2202,7 @@ func (s *session) RefreshTxnCtx(ctx context.Context) error {
                return err
        }
 
+       logutil.Logger(ctx).Info("hello transaction")
        return s.NewTxn(ctx)
 }
```

<br />
<br />

