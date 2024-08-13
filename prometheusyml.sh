global:
  scrape_interval: 5s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'http_traffic_generator'
    static_configs:
      - targets: ['localhost:4000']

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
