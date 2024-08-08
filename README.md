# Prometheus, Grafana, and Node.js Updater Setup on Amazon EC2

This README provides step-by-step instructions for setting up Prometheus, Grafana, and a Node.js application for updating Prometheus configurations on an Amazon EC2 instance.

## Prerequisites

- An Amazon EC2 instance running Amazon Linux 2
- SSH access to your EC2 instance
- Sufficient permissions to modify EC2 security groups

## Step 1: Configure EC2 Security Group

Before installing the applications, you need to configure your EC2 security group to allow inbound traffic on the necessary ports:

1. Open the Amazon EC2 console
2. Select your instance and click on the "Security" tab
3. Click on the security group link
4. In the "Inbound rules" tab, click "Edit inbound rules"
5. Add the following rules:
   - Type: Custom TCP, Port Range: 9090, Source: Your IP (for Prometheus)
   - Type: Custom TCP, Port Range: 3000, Source: Your IP (for Grafana and Node.js app)
   - Type: SSH, Port Range: 22, Source: Your IP (if not already added)
6. Click "Save rules"

## Step 2: Install Prometheus and Grafana

1. SSH into your EC2 instance
2. Create a new file named `install_prometheus_grafana.sh`:
   ```
   nano install_prometheus_grafana.sh
   ```
3. Copy and paste the contents of the Prometheus and Grafana installation script into this file
4. Save and exit the file (in nano, press CTRL+X, then Y, then Enter)
5. Make the script executable:
   ```
   chmod +x install_prometheus_grafana.sh
   ```
6. Run the script:
   ```
   sudo ./install_prometheus_grafana.sh
   ```
7. Wait for the installation to complete. The script will print the URLs for accessing Prometheus and Grafana.

## Step 3: Install Node.js Prometheus Updater

1. Create a new file named `install_prometheus_updater.sh`:
   ```
   nano install_prometheus_updater.sh
   ```
2. Copy and paste the contents of the Node.js application installation script into this file
3. Save and exit the file
4. Make the script executable:
   ```
   chmod +x install_prometheus_updater.sh
   ```
5. Run the script:
   ```
   sudo ./install_prometheus_updater.sh
   ```
6. Wait for the installation to complete. The script will print information about how to use the application.

## Accessing the Applications

- Prometheus: http://[Your-EC2-Public-IP]:9090
- Grafana: http://[Your-EC2-Public-IP]:3000 (default login is admin/admin)
- Node.js Updater: http://[Your-EC2-Public-IP]:3000/add-target (POST requests only)

## Troubleshooting

- If you can't access the applications, ensure that your EC2 instance's security group is correctly configured and that the services are running:
  ```
  sudo systemctl status prometheus
  sudo systemctl status grafana-server
  sudo systemctl status prometheus-updater
  ```
- Check the application logs for any error messages:
  ```
  sudo journalctl -u prometheus
  sudo journalctl -u grafana-server
  sudo journalctl -u prometheus-updater
  ```

