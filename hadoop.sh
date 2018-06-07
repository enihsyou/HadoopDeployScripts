#!/usr/bin/env bash

export LANG=zh_CN.UTF-8

#unset HOME
# 错误判断
if [[ $HOME != ~ ]]; then
    echo '$HOME环境变量设置有问题 退出脚本'
    exit -1
fi

echo 一些操作需要ROOT权限

echo 关闭防火墙 or 添加过滤规则
select yn in "Stop" "Rule"; do
    case $yn in
        Stop )
sudo systemctl stop firewalld
            break;;
        Rule )
echo 添加防火墙规则
echo 开启 8088 端口 用于查看 ResourceManager
sudo firewall-cmd --permanent --zone=public --add-port=8088/tcp

echo 开启 50000 50100 端口 用于查看 DataNode 和 NameNode 的状态
sudo firewall-cmd --permanent --zone=public --add-port=50000-50100/tcp

echo 开启 19888 端口 用于查看 MapReduce JobHistory Server
sudo firewall-cmd --permanent --zone=public --add-port=19888/tcp

echo 开启 8000 - 10000 端口
sudo firewall-cmd --permanent --zone=public --add-port=8000-10000/tcp

echo 重载防火墙配置
sudo firewall-cmd --reload
        break;;
    esac
done



readonly SCRIPT_HOME=$PWD
readonly JDK_FOLDER_NAME=jdk # JDK文件的存放目录名
readonly HADOOP_FOLDER_NAME=hadoop # hadoop文件的存放目录名
readonly HADOOP_FILES_FOLDER_NAME=hadoop_files # hadoop运行时的文件存放目录名
readonly HOST_IP=`hostname -I | xargs` # 本机IP
readonly HOSTS_FILENAME=hosts.txt

# hadoop 文件的根目录
HADOOP_HOME=~/${HADOOP_FOLDER_NAME}/hadoop-2.6.0-cdh5.9.3
# hadoop 运行时文件根目录
HADOOP_FILES=~/${HADOOP_FILES_FOLDER_NAME}

cd $HOME

echo 从哪个源下载? FTP or Local
echo "Local is for debug"
download_url=""
additional_url_parm=""
select yn in "FTP" "Local"; do
    case $yn in
        FTP )
         download_url=ftp://202.120.222.71/Download_%D7%F7%D2%B5%CF%C2%D4%D8%C7%F8/hadoop/
         additional_url_parm="-u stu-lirui:stu-lirui"
         break;;
        Local )
         download_url=http://192.168.0.100:8088/Y%3A/hadoop
        break;;
    esac
done

echo 从FTP上下载OracleJDK
curl -O -C - ${download_url}/jdk-8u171-linux-x64.tar.gz ${additional_url_parm}
mkdir -p ${JDK_FOLDER_NAME}

echo 解压OracleJDK
if [ ! -d ${JDK_FOLDER_NAME}/jdk1.8.0_171 ]; then
    tar xf jdk-8u171-linux-x64.tar.gz -C ${JDK_FOLDER_NAME}
fi

echo 从FTP上下载Hadoop
curl -O -C - ${download_url}/hadoop-2.6.0-cdh5.9.3.tar.gz ${additional_url_parm}
mkdir -p ${HADOOP_FOLDER_NAME}

echo 解压Hadoop
if [ ! -d ${HADOOP_FOLDER_NAME}/hadoop-2.6.0-cdh5.9.3 ]; then
    tar xf hadoop-2.6.0-cdh5.9.3.tar.gz -C ${HADOOP_FOLDER_NAME}
fi

echo
echo 配置系统变量
if ! `command -v java &> /dev/null`; then
echo "
export JAVA_HOME=\$HOME/$JDK_FOLDER_NAME/jdk1.8.0_171
export JRE_HOME=\$JAVA_HOME/jre
export CLASSPATH=.:\$JAVA_HOME/lib:\$JRE_HOME/lib:\$CLASSPATH
export HADOOP_HOME=\$HOME/$HADOOP_FOLDER_NAME/hadoop-2.6.0-cdh5.9.3
export HADOOP_CLASSPATH=\$JAVA_HOME/lib/tools.jar
export HADOOP_INSTALL=\$HADOOP_HOME
export HADOOP_MAPRED_HOME=\$HADOOP_HOME
export HADOOP_COMMON_HOME=\$HADOOP_HOME
export HADOOP_HDFS_HOME=\$HADOOP_HOME
export YARN_HOME=\$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native
export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$PATH
" >> ~/.bashrc
fi
source $HOME/.bashrc

if ! `command -v hdfs &> /dev/null` ; then
 echo 未找到指令 错误
 exit -1;
fi

echo
echo 追加Hosts
cat ${SCRIPT_HOME}/${HOSTS_FILENAME}
sudo -- sh -c "cat ${SCRIPT_HOME}/${HOSTS_FILENAME} >> /etc/hosts"

echo
echo 生成SSH密钥
ssh-keygen

echo
echo 添加密钥到hosts列表中的实例
while read line; do
  string_array=(${line})
  _host_ip=${string_array[0]}
  _hostname=${string_array[1]}

  echo 添加到: ${_hostname} - ${_host_ip}
  ssh-copy-id ${_hostname}

  if [ ${_host_ip} == ${HOST_IP} ]; then
    echo 设置hostname: ${_hostname}
    sudo hostname ${_hostname}
  fi
done < ${SCRIPT_HOME}/${HOSTS_FILENAME}
echo 如果有其他实例 请手动添加

echo
echo 生成目标路径 ${HADOOP_FILES} 及子目录
mkdir -p ${HADOOP_FILES}/hdfs/name
mkdir -p ${HADOOP_FILES}/hdfs/data

echo 复制hadoop配置文件
cp -rv ${SCRIPT_HOME}/etc ${HADOOP_HOME}/


echo
echo =====================
echo    启动Hadoop集群
echo =====================

select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No )
        echo "
设置系统中文请设置系统变量 LANG=zh_CN.UTF-8
如果有问题找不到命令 执行: source ~/.bashrc
关闭请使用 stop_hadoop.sh
"
        exit;;
    esac
done

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

echo "WebUI:
NameNode                    http://${HOST_IP}:50070
ResourceManager             http://${HOST_IP}:8088
MapReduce JobHistory Server http://${HOST_IP}:19888

设置系统中文请设置系统变量 LANG=zh_CN.UTF-8
如果有问题找不到命令 执行: source $HOME/.bashrc
关闭请使用 stop_hadoop.sh
"
