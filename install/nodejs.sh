#!/bin/bash


# https://nodejs.org/download/release/

version=v12.22.0

linux_install(){
    curl -sS -o /tmp/node-${version}-linux-x64.tar.xz https://nodejs.org/download/release/${version}/node-${version}-linux-x64.tar.xz
    cd /tmp && xz -d node-${version}-linux-x64.tar.xz
    tar xf /tmp/node-${version}-linux-x64.tar -C /opt/
    echo "export PATH=\$PATH:/opt/node-${version}-linux-x64/bin/" >> /etc/profile
    source /etc/profile
}

linux_clean() {
    rm -rf /tmp/node-${version}-linux-x64.tar.xz /tmp/node-${version}-linux-x64.tar /opt/node-${version}-linux-x64
}

linux_check() {
    echo "check version"
    echo "node:" $(node -v)
    echo "npm:" $(npm -v)
    echo "npx:" $(npx -v)
}

case $1 in
install)
    linux_install;;
clean)
    linux_clean;;
check)
    linux_check;;
esac


