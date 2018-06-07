#!/usr/bin/env bash

if ! `command -v hdfs &> /dev/null` ; then
 echo 未找到 hdfs 指令 错误
 exit -1;
fi

input_directory=""
echo 选择测试数据量大小
select yn in "Small" "Medium" "Large"; do
    case $yn in
        # https://www.cloudera.com/documentation/other/tutorial/CDH5/topics/ht_wordcount2.html
        Small ) input_directory=wordcount_input/small/*.txt break;;

        # https://www.gutenberg.org/ebooks/
        Medium ) input_directory=wordcount_input/medium/*.txt break;;

        # https://norvig.com/big.txt
        Large ) input_directory=wordcount_input/large/*.txt break;;
    esac
done
echo 移动输入文件到hdfs
hdfs dfs -mkdir -p /wordcount/input
hdfs dfs -put ${input_directory} /wordcount/input

echo 移除输出目录
hadoop fs -rm -r -f /wordcount/output

echo 执行操作
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done
hadoop jar ${HADOOP_HOME}/share/hadoop/mapreduce1/hadoop-examples-2.6.0-mr1-cdh5.9.3.jar wordcount /wordcount/input /wordcount/output

echo 查看结果
hadoop fs -cat /wordcount/output/*
