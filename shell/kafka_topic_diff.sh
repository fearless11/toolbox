#!/bin/bash
# date: 2022/03/07
# auth: vera
# desc: diff test1 and test2 kafka topic/partition

get_topic(){
# test1
addr1=127.0.0.1:9092
kafka-topics.sh --bootstrap-server ${addr1} --list | xargs -I{} kafka-topics.sh --bootstrap-server ${addr1} --describe --topic {}| grep '^Topic' | awk '{print $1,$2,$3,$4,$5,$6}' > kafka.test1

# test2
addr2=127.0.0.2:9092
kafka-topics.sh --bootstrap-server ${addr2} --list | xargs -I{} kafka-topics.sh --bootstrap-server ${addr2} --describe --topic {}| grep '^Topic' | awk '{print $1,$2,$3,$4,$5,$6}' > kafka.test2
}


diff_topic(){
while read i; 
do 
    echo $i | grep '__' &> /dev/null && continue
    topic=$(echo $i | awk '{print $2}'); 
    test1_count=$(grep -w $topic kafka.prod| awk '{print $4,$6}')
    test2_count=$(grep -w $topic kafka.chk| awk '{print $4,$6}')
    echo $topic $test1_count $test2_count
done < kafka.chk 
}

get_topic
diff_topic
