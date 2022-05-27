#!/bin/bash
# date: 2022-05-25
# auth: fearless11
# desc: install go

version=1.18.2
package=go${version}.linux-amd64.tar.gz
url=https://gomirrors.org/dl/go/${package}
soft=/tmp/${package}

install() {
    wget $url -O ${soft}
    mkdir -p /usr/local/go${version} >/dev/null
    tar xf ${soft} -C /usr/local/go${version}
    unlink /usr/local/go
    ln -s /usr/local/go${version}/go /usr/local/go
    mkdir -p /opt/go/src
    cp /etc/profile /home

    cat <<EOF >>/etc/profile
export GOROOT=/usr/local/go
export GOPATH=/opt/go
export GOPROXY=https://proxy.golang.com.cn,direct
export GOPRIVATE="*.code.oa.com,*.woa.com"
export GO111MODULE=on
export PATH=\$GOROOT/bin:\$GOPATH/bin:\$PATH
EOF

    source /etc/profile
    # go env
}

update() {
    wget $url -O ${soft}
    mkdir -p /usr/local/go${version} >/dev/null
    tar xf ${soft} -C /usr/local/go${version}
    unlink /usr/local/go
    ln -s /usr/local/go${version}/go /usr/local/go
}

case $1 in
install)
    install
    ;;
update)
    update
    ;;
esac
