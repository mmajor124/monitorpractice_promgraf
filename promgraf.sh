#!/bin/bash

# Update the system
sudo yum update -y

# Install wget
sudo yum install wget -y

# Install Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.37.0/prometheus-2.37.0.linux-amd64.tar.gz
tar xvfz prometheus-2.37.0.linux-amd64.tar.gz
sudo mv prometheus-2.37.0.linux-amd64 /opt/prometheus

# Create a Prometheus user
sudo useradd --no-create-home --shell /bin/false prometheus

# Set ownership for Prometheus directories
sudo chown -R prometheus:prometheus /opt/prometheus

# Create a Prometheus service file
cat << EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/opt/prometheus/prometheus \
    --config.file /opt/prometheus/prometheus.yml \
    --storage.tsdb.path /opt/prometheus/data

[Install]
WantedBy=multi-user.target
EOF

# Start and enable Prometheus service
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

# Install Grafana
sudo amazon-linux-extras install epel -y
sudo yum install grafana -y

# Start and enable Grafana service
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Print the public IP address
echo "Installation complete. Access Prometheus at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9090"
echo "Access Grafana at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):3000"
echo "Default Grafana login is admin/admin"
