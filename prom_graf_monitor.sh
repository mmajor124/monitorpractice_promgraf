#!/bin/bash

# Update the package lists
sudo apt-get update -y

# Install necessary dependencies
sudo apt-get install -y wget tar

# Install Prometheus
PROMETHEUS_VERSION="2.42.0"
wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
tar -xvf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
sudo mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus /usr/local/bin/
sudo mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool /usr/local/bin/
sudo mkdir -p /etc/prometheus
sudo mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus.yml /etc/prometheus/
sudo mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/consoles /etc/prometheus/
sudo mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/console_libraries /etc/prometheus/

# Create Prometheus systemd service
sudo bash -c 'cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/prometheus --config.file /etc/prometheus/prometheus.yml --storage.tsdb.path /var/lib/prometheus/
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd, start and enable Prometheus
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

# Install Grafana
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt-get update -y
sudo apt-get install -y grafana

# Start and enable Grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Clean up
rm -rf prometheus-${PROMETHEUS_VERSION}.linux-amd64*
echo "Prometheus and Grafana installation completed!"
