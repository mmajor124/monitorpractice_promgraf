#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update the system
echo "Updating the system..."
sudo apt update
sudo apt upgrade -y

# Install Node.js and npm
echo "Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Git
echo "Installing Git..."
sudo apt install git -y

# Create directory for the application
echo "Creating application directory..."
mkdir -p ~/http-traffic-generator
cd ~/http-traffic-generator

# Create app.js file
echo "Creating app.js..."
cat << EOF > app.js
const express = require('express');
const promClient = require('prom-client');

const app = express();
const port = 4000;

// Create a Registry to register the metrics
const register = new promClient.Registry();

// Create a counter for total requests
const totalRequests = new promClient.Counter({
  name: 'total_requests',
  help: 'Total number of requests',
  labelNames: ['endpoint']
});

// Create a histogram for response times
const responseTime = new promClient.Histogram({
  name: 'response_time',
  help: 'Response time in milliseconds',
  labelNames: ['endpoint'],
  buckets: [10, 30, 50, 100, 200, 500, 1000]
});

// Register the metrics
register.registerMetric(totalRequests);
register.registerMetric(responseTime);

// Middleware to measure response time
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    responseTime.labels(req.path).observe(duration);
    totalRequests.labels(req.path).inc();
  });
  next();
});

// Root endpoint
app.get('/', (req, res) => {
  res.send('Welcome to the HTTP Traffic Generator!');
});

// Simulate a fast endpoint
app.get('/fast', (req, res) => {
  res.send('This is a fast response');
});

// Simulate a slow endpoint
app.get('/slow', (req, res) => {
  setTimeout(() => {
    res.send('This is a slow response');
  }, 500);
});

// Endpoint for Prometheus metrics
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Start the server
app.listen(port, () => {
  console.log(\`HTTP Traffic Generator listening at http://localhost:\${port}\`);
});
EOF

# Initialize Node.js project and install dependencies
echo "Initializing Node.js project and installing dependencies..."
npm init -y
npm install express prom-client

# Install PM2 globally
echo "Installing PM2..."
sudo npm install -g pm2

# Start the application with PM2
echo "Starting the application with PM2..."
pm2 start app.js --name "http-traffic-generator"

# Set PM2 to start on boot
echo "Setting PM2 to start on boot..."
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u $USER --hp $HOME
pm2 save

# Install and configure Nginx
echo "Installing and configuring Nginx..."
sudo apt install nginx -y

# Create Nginx configuration
sudo tee /etc/nginx/sites-available/http-traffic-generator > /dev/null << EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Enable the Nginx configuration
sudo ln -s /etc/nginx/sites-available/http-traffic-generator /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

echo "Installation complete! Your HTTP Traffic Generator should now be running."
echo "You can access it at http://your-instance-public-dns/"
echo "Remember to update your EC2 security group to allow inbound traffic on ports 22, 80, and 4000."
