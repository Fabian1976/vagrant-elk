#!/bin/bash
cerebro_version='0.8.4'
kafka_version='2.0.0'
zookeeper_version='3.4.12'

#Cerebro
mkdir -p ./software/cerebro
wget https://github.com/lmenezes/cerebro/releases/download/v${cerebro_version}/cerebro-${cerebro_version}.tgz -O software/cerebro/cerebro-${cerebro_version}.tgz

#Kafka
wget -r -np -nH -nd -R index.html* -X kafka/$kafka_version/javadoc http://archive.apache.org/dist/kafka/$kafka_version/ -P ./software/kafka/$kafka_version/

#Zookeeper
mkdir -p software/zookeeper/zookeeper-${zookeeper_version}
pushd software/zookeeper/zookeeper-${zookeeper_version}
wget http://archive.apache.org/dist/zookeeper/zookeeper-${zookeeper_version}/zookeeper-${zookeeper_version}.tar.gz
popd
