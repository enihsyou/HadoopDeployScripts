# CentOS 7 下的 Hadoop 一键脚本

## 使用方法

脚本完成的是Hadoop的分布式集群配置
包含wordcount例子 (在wordcount文件夹下面)

单机版配置方法请看下面的注意事项

前提条件：

- 登录用户具有sudo权限（root也可）
- 具有网络连接
- 安装了git
  - 如果服务器上没有git，可以把文件复制到服务器上。
  - 使用 `sudo yum install git` 安装git


## 运行方式

运行脚本安装
```bash
git clone https://github.com/enihsyou/HadoopDeployScripts.git
cd HadoopDeployScripts
chmod +x hadoop.sh
./hadoop.sh
```

运行wordcount测试
```bash
cd wordcount
chmod +x wordcount.sh
./wordcount.sh
```

wordcount 统计性别的输入文件路径: `input/data/*.txt`
注意使用Local编译。

## 说明

- hosts.txt文件里的hosts记录会被追加到 `/etc/hosts` 里；未修改hostname。
- jdk和hadoop文件在这个账户目录下，系统变量使用用户配置文件的设置，不会和系统配置冲突。
- 自定义hadoop配置文件在项目的 `etc` 目录下
- 脚本使用了 `hostname -I` 获取本机IP地址
- 会为当前账户生成一个 *~/.ssh/id_rsa* 的RSA非对称密钥，注意冲突。
- 使用 `LANG=zh_CN.UTF-8` 设置为中文显示，有些Terminal可能不支持显示
- 脚本会在 `~/hadoop_files` 下放置HDFS文件，可通过修改xml文件自定义
- jdk和hadoop文件是直接从ftp上下载的，Local选项仅用作Debug


- wordcount测试文件在 `wordcount/input` 下面，可自行替换
### 注意
- `etc/hadoop/core-site.xml` 里面的路径 *hadoop.tmp.dir* 可能需要修改为自己的用户目录
- 如果想体验单机版

  1. 把 `hosts.txt` 中的ip映射修改为只留下master，注意设置本机ip。
  2. 把 `etc/masters` 里的其他清空，只留下本机（填写 `localhost` 或者 `master`）
  3. 把 `etc/slaves` 里清空（因为不需要其他机器）
  4. 把 `etc/hdfs-site.xml` 里的 *dfs.namenode.secondary.http-address* 记录删除掉，因为没有第二台机器放置namenode。




## 参考

[Hadoop安装教程_伪分布式配置](http://dblab.xmu.edu.cn/blog/install-hadoop-in-centos)

[大佬](https://github.com/dccif/HadoopInstall)

[Hadoop集群安装配置教程](http://dblab.xmu.edu.cn/blog/install-hadoop-cluster/)

[MapReduce Official tutorial](https://hadoop.apache.org/docs/stable/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html)
