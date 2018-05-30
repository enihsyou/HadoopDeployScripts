#!/usr/bin/env bash

export LANG=zh_CN.UTF-8

echo 一些操作需要ROOT权限

echo 添加 hadoop 用户
sudo adduser hadoop

echo 添加防火墙规则
echo 开启 8088 端口
sudo firewall-cmd --permanent --zone=public --add-port=50070/tcp
echo 开启 50070 端口
sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
echo 重载防火墙配置
sudo firewall-cmd --reload

echo 复制临时文件
GIT_TMP=/home/hadoop/git_tmp

sudo mkdir ${GIT_TMP}

sudo cp run_as_hadoop_user.sh ${GIT_TMP}
sudo cp *.xml ${GIT_TMP}
sudo chmod -R 777 ${GIT_TMP}

# 切换到hadoop用户下继续操作
sudo -iu hadoop << 'EOF'
    git_tmp/run_as_hadoop_user.sh
EOF

sudo rm -rf ${GIT_TMP}
echo 清理临时文件 ... OK
