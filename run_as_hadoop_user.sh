#!/usr/bin/env bash
if [ "$(whoami)" != "hadoop" ]; then
        echo "Script must be run as user: hadoop"
        exit -1
fi

export LANG=zh_CN.UTF-8
readonly JDK_FOLDER_NAME=jdk # JDK根路径
readonly HADOOP_FOLDER_NAME=hadoop
readonly HADOOP_FILES_FOLDER_NAME=hadoop_files
readonly HOST_IP=`hostname -I | xargs`

cd ~

echo 从FTP上下载OracleJDK
curl -O -C - ftp://202.120.222.71/Download_%D7%F7%D2%B5%CF%C2%D4%D8%C7%F8/hadoop/jdk-8u171-linux-x64.tar.gz -u stu-lirui:stu-lirui
#curl -O -C - http://192.168.0.100:8088/Y%3A/hadoop/jdk-8u171-linux-x64.tar.gz
mkdir ${JDK_FOLDER_NAME}

echo
echo 解压OracleJDK
tar xf jdk-8u171-linux-x64.tar.gz -C ${JDK_FOLDER_NAME}

echo
echo 从FTP上下载Hadoop
curl -O -C - ftp://202.120.222.71/Download_%D7%F7%D2%B5%CF%C2%D4%D8%C7%F8/hadoop/hadoop-2.6.0-cdh5.9.3.tar.gz -u stu-lirui:stu-lirui
#curl -O -C - http://192.168.0.100:8088/Y%3A/hadoop/hadoop-2.6.0-cdh5.9.3.tar.gz
mkdir ${HADOOP_FOLDER_NAME}

echo
echo 解压Hadoop
tar xf hadoop-2.6.0-cdh5.9.3.tar.gz -C ${HADOOP_FOLDER_NAME}

echo
echo 配置系统变量
echo "export JAVA_HOME=\$HOME/$JDK_FOLDER_NAME/jdk1.8.0_171" >> ~/.bashrc
echo "export JRE_HOME=\$JAVA_HOME/jre" >> ~/.bashrc
echo "export CLASSPATH=.:\$CLASSPATH:\$JAVA_HOME/lib:\$JRE_HOME/lib" >> ~/.bashrc
echo "export HADOOP_HOME=\$HOME/$HADOOP_FOLDER_NAME/hadoop-2.6.0-cdh5.9.3" >> ~/.bashrc
echo "export HADOOP_INSTALL=\$HADOOP_HOME" >> ~/.bashrc
echo "export HADOOP_MAPRED_HOME=\$HADOOP_HOME" >> ~/.bashrc
echo "export HADOOP_COMMON_HOME=\$HADOOP_HOME" >> ~/.bashrc
echo "export HADOOP_HDFS_HOME=\$HADOOP_HOME" >> ~/.bashrc
echo "export YARN_HOME=\$HADOOP_HOME" >> ~/.bashrc
echo "export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native" >> ~/.bashrc
echo "export PATH=\$PATH:\$JAVA_HOME/bin:\$JRE_HOME/bin:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" >> ~/.bashrc

source $HOME/.bashrc

echo
echo 生成SSH密钥
ssh-keygen -f ~/.ssh/hadoop
cat ~/.ssh/hadoop.pub >> ~/.ssh/authorized_keys
chmod 644 ~/.ssh/authorized_keys

echo 启动ssh-agent
ssh-agent
eval $(ssh-agent -s)

echo 添加密钥
ssh-add ~/.ssh/hadoop

HADOOP_FILES=$HOME/${HADOOP_FILES_FOLDER_NAME}
echo 生成目标路径 ${HADOOP_FILES}
mkdir -p ${HADOOP_FILES}
mkdir -p ${HADOOP_FILES}/dfs/name
mkdir -p ${HADOOP_FILES}/dfs/data

HADOOP_HOME=$HOME/${HADOOP_FOLDER_NAME}/hadoop-2.6.0-cdh5.9.3
cp git_tmp/*.xml ${HADOOP_HOME}/etc/hadoop

echo
echo 执行 NameNode 的格式化
hdfs namenode -format

echo
echo 开启 NaneNode 和 DataNode 守护进程
echo 注意确认添加SSH key
start-dfs.sh

echo
echo 启动YARN
start-yarn.sh

echo
echo 开启历史服务器, 在Web中查看任务运行情况
mr-jobhistory-daemon.sh start historyserver

echo
echo 运行jps验证
jps

echo
echo 可以访问 Web 界面 http://${HOST_IP}:50070 查看 NameNode 和 Datanode 信息
echo 可以通过 Web 界面 http://${HOST_IP}:8088/cluster 查看任务的运行情况
echo 设置系统中文请设置系统变量 LANG=zh_CN.UTF-8
echo hadoop文件在hadoop用户下 使用 sudo -iu hadoop
