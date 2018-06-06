# CentOS 下的 Hadoop 安装脚本

## 参考

[Hadoop安装教程_伪分布式配置](http://dblab.xmu.edu.cn/blog/install-hadoop-in-centos)

[大佬](https://github.com/dccif/HadoopInstall)

## 使用方法

脚本完成的是Hadoop的伪分布式配置，集群请参考[Hadoop集群安装配置教程](http://dblab.xmu.edu.cn/blog/install-hadoop-cluster/)


前提条件：

- 登录用户具有sudo权限（root也可）
- 具有网络连接
- 安装了git
  - 如果服务器上没有git，可以把文件复制到服务器上。
  - 使用 `sudo yum install git` 安装git


## 运行方式

```bash
git clone https://github.com/enihsyou/HadoopDeployScripts.git
cd HadoopDeployScripts
chmod +x hadoop.sh
./hadoop.sh
```


## 说明

- hosts.txt文件里的hosts记录会被追加到/etc/hosts里；未修改hostname。
- jdk和hadoop文件在这个账户目录下，系统变量使用用户配置文件的设置，不会和系统配置冲突。
- 自定义hadoop配置文件在项目的 `/etc` 目录下
- 脚本使用了 `hostname -I` 获取本机IP地址
- 会为当前账户生成一个 *~/.ssh/id_rsa* 的RSA非对称密钥，注意冲突。
- 使用 `LANG=zh_CN.UTF-8` 设置为中文显示，有些Terminal可能不支持显示
- 在 `~/hadoop_files` 下放置HDFS文件，可通过修改xml文件自定义
- jdk和hadoop文件是直接从ftp上下载的

### 注意
- `/etc/hadoop/core-site.xml` 里面的路径需要修改为自己的用户目录
