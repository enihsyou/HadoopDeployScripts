#!/usr/bin/env bash

if ! `command -v hdfs &> /dev/null` ; then
 echo 未找到 hdfs 指令 错误
 exit -1;
fi

input_directory=""
echo 选择测试数据量大小
select size in "Small" "Medium" "Large"; do
    case $size in
        # https://www.cloudera.com/documentation/other/tutorial/CDH5/topics/ht_wordcount2.html
        Small ) input_directory=input/small break;;

        # https://www.gutenberg.org/ebooks/
        Medium ) input_directory=input/medium break;;

        # https://norvig.com/big.txt
        Large ) input_directory=input/large break;;
    esac
done

echo 移动输入文件到hdfs
hadoop fs -rm -r -f /wordcount/input
hadoop fs -mkdir -p /wordcount/input
hadoop fs -put ${input_directory}/*.txt /wordcount/input

echo 移除输出目录
hadoop fs -rm -r -f /wordcount/output

echo "执行操作
Official: 使用官方例子
Local   : 使用本地编译
No      : 不继续"

run_path=""
select yn in "Official" "Local" "No"; do
    case $yn in
        Official ) 
            run_path="${HADOOP_HOME}/share/hadoop/mapreduce1/hadoop-examples-2.6.0-mr1-cdh5.9.3.jar wordcount"
            break;;
        Local )
            if [ ! -f wordcount.jar ]; then
                echo 没有找到本地jar
                #echo 使用 Gradle 进行编译
                echo 使用 Javac 进行编译

                mkdir class
                hadoop com.sun.tools.javac.Main src/main/java/WordCount.java -d class
                jar cf wordcount.jar -C class .
            fi
            run_path="wordcount.jar WordCount"
            break;;
        No ) exit;;
    esac
done

readonly HOST_IP=`hostname -I | xargs` # 本机IP
echo "
NameNode                    http://${HOST_IP}:50070
ResourceManager             http://${HOST_IP}:8088
MapReduce JobHistory Server http://${HOST_IP}:19888
"

hadoop jar ${run_path} /wordcount/input /wordcount/output


echo 查看结果?
select yn in "Yes" "No"; do
    case $yn in
        Yes )
hadoop fs -cat /wordcount/output/*
        break;;
        No )  break;;
    esac
done
