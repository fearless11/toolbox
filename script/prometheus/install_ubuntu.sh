#!/bin/bash
# date: 2021/10/15
# auth: vera
# desc: ubuntu install prometheus node_exporter grafana


install_node_exporter(){
  # https://prometheus.io/download/
  #curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.2.2/node_exporter-1.2.2.linux-amd64.tar.gz
  #sha256sum node_exporter-1.2.2.linux-amd64.tar.gz
  #tar xvf node_exporter-1.2.2.linux-amd64.tar.gz
  
  version=1.2.2
  
  sudo cp node_exporter-${version}.linux-amd64/node_exporter /usr/local/bin
  sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter


cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl start node_exporter
  sudo systemctl status node_exporter
}


install_process_exporter(){
 # https://github.com/ncabatoff/process-exporter
}


install_prometheus(){
  # https://prometheus.io/download/
  sudo useradd --no-create-home --shell /bin/false prometheus
  sudo useradd --no-create-home --shell /bin/false node_exporter
  
  sudo mkdir /etc/prometheus
  sudo mkdir /var/lib/prometheus
  
  sudo chown prometheus:prometheus /etc/prometheus
  sudo chown prometheus:prometheus /var/lib/prometheus
  
  #curl -LO https://github.com/prometheus/prometheus/releases/download/v2.30.3/prometheus-2.30.3.linux-amd64.tar.gz
  version=2.30.3
  
  sudo cp prometheus-${version}.linux-amd64/prometheus /usr/local/bin/
  sudo cp prometheus-${version}.linux-amd64/promtool /usr/local/bin/
  
  sudo cp -r prometheus-${version}.linux-amd64/consoles /etc/prometheus
  sudo cp -r prometheus-${version}.linux-amd64/console_libraries /etc/prometheus
  
  sudo chown -R prometheus:prometheus /etc/prometheus/consoles
  sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries

cat <<EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 60s 
  evaluation_interval: 60s 
  scrape_timeout: 30s 

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']
  - job_name: node_exporter 
    static_configs:
      - targets: ['localhost:9100']
EOF

  #sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

cat <<EOF > /etc/systemd/system/prometheus.service 
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
    --config.file /etc/prometheus/prometheus.yml \\
    --storage.tsdb.path /var/lib/prometheus/ \\
    --web.console.templates=/etc/prometheus/consoles --storage.tsdb.wal-compression --web.enable-lifecycle \\
    --web.console.libraries=/etc/prometheus/console_libraries --web.enable-admin-api \\
    --web.listen-address=0.0.0.0:9090 \\
    --storage.tsdb.min-block-duration=2h \\
    --storage.tsdb.max-block-duration=2h \\
    --storage.tsdb.retention=30d

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl start prometheus
  sudo systemctl status prometheus
  sudo systemctl enable prometheus

}

install_grafana(){
  # https://grafana.com/grafana/download/6.0.0?platform=linux&edition=oss
  #sudo apt-get install -y adduser libfontconfig1
  #wget https://dl.grafana.com/oss/release/grafana_6.0.0_amd64.deb

  sudo dpkg -i grafana_6.0.0_amd64.deb
  sudo systemctl start grafana-server
  sudo systemctl status grafana-server
  sudo systemctl enable grafana-server
  #sudo dpkg -l
  #sudo dpkg -r xxxx
}


install_node_exporter
install_prometheus
install_grafana
