#!/bin/bash

# Step 1: Create the Web App
echo "Setting up Node.js web application..."

# Create project directory and navigate into it
mkdir prometheus-demo
cd prometheus-demo

# Initialize npm project
npm init -y

# Install dependencies
npm install express prom-client

# Create app.js file
cat <<EOF > app.js
const express = require('express');
const client = require('prom-client');

const app = express();
const register = new client.Registry();

// Create a counter metric
const counter = new client.Counter({
    name: 'node_request_operations_total',
    help: 'The total number of processed requests'
});

// Register the counter
register.registerMetric(counter);
register.setDefaultLabels({
    app: 'example-node-app'
});

// Collect default metrics
client.collectDefaultMetrics({ register });

// Define a route handler
app.get('/', (req, res) => {
    counter.inc();
    res.send('Hello World!');
});

// Expose metrics endpoint
app.get('/metrics', async (req, res) => {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
});

// Start the server
const port = 3000;
app.listen(port, () => {
    console.log(\`Server is running on http://localhost:\${port}\`);
});
EOF

# Step 2: Run the Web App
echo "Starting Node.js web application..."
node app.js &

# Step 3: Install and Configure Prometheus
echo "Setting up Prometheus..."

# Download Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.41.0/prometheus-2.41.0.linux-amd64.tar.gz
tar xvfz prometheus-2.41.0.linux-amd64.tar.gz
cd prometheus-2.41.0.linux-amd64

# Create Prometheus configuration file
cat <<EOF > prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node-app'
    static_configs:
      - targets: ['localhost:3000']
EOF

# Run Prometheus
echo "Starting Prometheus..."
./prometheus --config.file=prometheus.yml &

echo "Setup complete. Node.js app is running on http://localhost:3000 and Prometheus is running on http://localhost:9090"
