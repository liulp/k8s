#!/bin/bash
# 定义日志
workdir=`pwd`
log_file=${workdir}/sync_images_$(date +"%Y-%m-%d").log

logger()
{
    log=$1
    cur_time='['$(date +"%Y-%m-%d %H:%M:%S")']'
    echo ${cur_time} ${log} | tee -a ${log_file}
}

list="images.txt"
#images="images.tar.gz"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -i|--images)
        images="$2"
        shift # past argument
        shift # past value
        ;;
        -l|--image-list)
        list="$2"
        shift # past argument
        shift # past value
        ;;
        -h|--help)
        help="true"
        shift
    ;;
    esac
done

usage () {
    echo "USAGE: $0 [--image-list images.txt] [--images images.tar.gz]"
    echo "  [-l|--images-list path] text file with list of images. 1 per line."
    echo "  [-l|--images path] tar.gz generated by docker save."
    echo "  [-h|--help] Usage message"
}

if [[ $help ]]; then
    usage
    exit 0
fi

#set -e -x

#mkdir -p images-$(date +"%Y-%m-%d")
#cd images-$(date +"%Y-%m-%d")
mkdir -p images-harbor

for i in $(cat ${list}); 
do
    docker pull ${i}

    if [ $? -ne 0 ]; then
        logger "${i} pull failed."
    else
        logger "${i} pull successfully."
    fi

    #docker save ${i} | gzip >images-$(date +"%Y-%m-%d")/$(echo $i |sed "s#/#-#g; s#:#-#g").tgz
    docker save ${i} | gzip >images-harbor/$(echo $i |sed "s#/#-#g; s#:#-#g").tgz

    if [ $? -ne 0 ]; then
        logger "${i} save failed."
    else
        logger "${i} save successfully."
    fi
done
