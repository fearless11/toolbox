#!/bin/bash
# date: 2021/08/13
# auth: vera
# desc: get deployment cpu/memory


# 计算指定命名空间的业务资源（打label实现）
calculate_project_k8s_source(){
    namespace="app-production"
    project="test"
    dir="/tmp/${project}/"
    mkdir -p $dir &> /dev/null
    cd $dir
    file_tmp="source.txt"

    kubectl -n $namespace describe deployment -l business=$project &> ${file_tmp}
    
    grep '^Name:' ${file_tmp} | awk '{print $2}' &> name.txt
    grep -A 2  Limits ${file_tmp} | grep cpu | awk '{print $2}' &> cpu.txt
    grep -A 2  Limits ${file_tmp} | grep memory | awk '{print $2}' &> memory.txt
    grep -w Replicas ${file_tmp}  | awk '{print $2}' &> pod.txt 

    echo "name cpu memory pod"
    paste -d ' ' name.txt cpu.txt memory.txt pod.txt

    echo -n "the total cpu "
    grep -A 2  Limits ${file_tmp} | grep cpu | awk '{print $2}' | tr '\n' '+' | sed 's/+$//g' | xargs -I{} echo "{}" | bc 
    echo -n "the total memory "
    grep -A 2  Limits ${file_tmp} | grep memory | awk '{if($2~/Mi/) {gsub("Mi"," ",$2);total=total+$2/1000}  else {gsub("Gi"," ",$2);total=total+$2}  }END{ print total"G"}'
}


calculate_project_k8s_source
