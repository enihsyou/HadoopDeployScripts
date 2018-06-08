#!/usr/bin/env bash

if ! `command -v hdfs &> /dev/null` ; then
 echo 未找到 hdfs 指令 错误
 exit -1;
fi

input_directory=""
echo 选择测试数据量大小 或者手动指定输入文件
select size in "Small" "Medium" "Large" "Manuel"; do
    case $size in
        # https://www.cloudera.com/documentation/other/tutorial/CDH5/topics/ht_wordcount2.html
        Small ) input_directory=input/small/*.txt break;;

        # https://www.gutenberg.org/ebooks/
        Medium ) input_directory=input/medium/*.txt break;;

        # https://norvig.com/big.txt
        Large ) input_directory=input/large/*.txt break;;

        Manuel ) read -p "输入路径: " input_directory
        echo ${input_directory}
        break;;
    esac
done

echo 移动输入文件到hdfs
hadoop fs -rm -r -f /wordcount/input
hadoop fs -mkdir -p /wordcount/input
hadoop fs -put ${input_directory} /wordcount/input

echo 移除输出目录
hadoop fs -rm -r -f /wordcount/output

echo "执行操作
Official: 使用官方例子
Local   : 使用本地编译
No      : 不继续
"

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
                hadoop com.sun.tools.javac.Main src/main/java/*.java -d class
                jar cf wordcount.jar -C class .
                rm -rf class
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

## 删除HDFS上的input文件夹
#hadoop fs -rm -r -f /wordcount/input
## 重新创建input文件夹
#hadoop fs -mkdir -p /wordcount/input
## 把输入文件放到HDFS上
#hadoop fs -put DATA/* /wordcount/input
## 清空输出目录
#hadoop fs -rm -r -f /wordcount/output
## 编译wordcount Java文件
# mkdir class
#hadoop com.sun.tools.javac.Main *.java -d class
## 打包成jar包
#jar cf wordcount.jar *.class -C class .
## 运行
#hadoop jar wordcount.jar WordCount /wordcount/input /wordcount/output
#hadoop jar ${HADOOP_HOME}/share/hadoop/mapreduce1/hadoop-examples-2.6.0-mr1-cdh5.9.3.jar wordcount /wordcount/input /wordcount/output
## 查看结果
#hadoop fs -cat /wordcount/output/*
