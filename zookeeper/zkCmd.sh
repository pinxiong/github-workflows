#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ZK_2181_DIR=$DIR/zookeeper/2181
ZK_2182_DIR=$DIR/zookeeper/2182
LOG_DIR=$DIR/zookeeper/logs

ZK_SERVER_2181=$ZK_2181_DIR/apache-zookeeper-3.6.0-bin/bin/zkServer.sh
ZK_SERVER_2182=$ZK_2182_DIR/apache-zookeeper-3.6.0-bin/bin/zkServer.sh
ZK_CLIENT_2181=$ZK_2181_DIR/apache-zookeeper-3.6.0-bin/bin/zkCli.sh
ZK_CLIENT_2182=$ZK_2182_DIR/apache-zookeeper-3.6.0-bin/bin/zkCli.sh

ZOOKEEPER_BINARY_URL="https://archive.apache.org/dist/zookeeper/zookeeper-3.6.0/apache-zookeeper-3.6.0-bin.tar.gz"

case $1 in 
start)
    echo "Download zookeeper instances...."
    mkdir -p $ZK_2181_DIR $ZK_2182_DIR $LOG_DIR/2181 $LOG_DIR/2182
    wget -P $DIR/zookeeper -c $ZOOKEEPER_BINARY_URL
    echo "Setup zookeeper instances...."
    # setup zookeeper with 2182
    tar -zxf $DIR/zookeeper/apache-zookeeper-3.6.0-bin.tar.gz -C $ZK_2181_DIR
    cp $ZK_2181_DIR/apache-zookeeper-3.6.0-bin/conf/zoo_sample.cfg $ZK_2181_DIR/apache-zookeeper-3.6.0-bin/conf/zoo.cfg
    sed -i "s#^clientPort=.*#clientPort=2181#g" $ZK_2181_DIR/apache-zookeeper-3.6.0-bin/conf/zoo.cfg
    sed -i "s#^dataDir=.*#dataDir=$LOG_DIR/2181#g" $ZK_2181_DIR/apache-zookeeper-3.6.0-bin/conf/zoo.cfg
    echo "admin.serverPort=8081" >> $ZK_2181_DIR/apache-zookeeper-3.6.0-bin/conf/zoo.cfg
    # setup zookeeper with 2182
    tar -zxf $DIR/zookeeper/apache-zookeeper-3.6.0-bin.tar.gz -C $ZK_2182_DIR
    cp $ZK_2182_DIR/apache-zookeeper-3.6.0-bin/conf/zoo_sample.cfg $ZK_2182_DIR/apache-zookeeper-3.6.0-bin/conf/zoo.cfg
    sed -i "s#^clientPort=.*#clientPort=2182#g" $ZK_2182_DIR/apache-zookeeper-3.6.0-bin/conf/zoo.cfg
    sed -i "s#^dataDir=.*#dataDir=$LOG_DIR/2182#g" $ZK_2182_DIR/apache-zookeeper-3.6.0-bin/conf/zoo.cfg
    echo "admin.serverPort=8082" >> $ZK_2182_DIR/apache-zookeeper-3.6.0-bin/conf/zoo.cfg
    echo "Start zookeeper instances...."
    $ZK_SERVER_2181 start
    $ZK_SERVER_2182 start
    ;;
stop)
    echo "Stop zookeeper instances...."
    $ZK_SERVER_2181 stop
    $ZK_SERVER_2182 stop
    ;;
status)
    echo "Get status of all zookeeper instances...."
    $ZK_SERVER_2181 status
    $ZK_SERVER_2182 status
    ;;
reset)
    echo "Reset all zookeeper instances"
    $ZK_CLIENT_2181 -timeout 5000  -server 127.0.0.1:2181 deleteall /dubbo quit
    $ZK_CLIENT_2182 -timeout 5000  -server 127.0.0.1:2182 deleteall /dubbo quit
    ;;
*)
    echo "./zkCmd.sh start|stop|status|reset"
    exit 1
    ;;
esac