#!/bin/bash
# deploy_online.sh - Deploy Takeover Infinity Toolkit to a mock online server

echo "Initiating online deployment of Takeover Infinity Toolkit..."
# Create a mock cloud server directory structure (simulating a VPS or AWS instance)
sudo mkdir -p /var/www/takeover_infinity
sudo cp -r /opt/takeover_infinity/* /var/www/takeover_infinity/

# Install web server dependencies for public access (e.g., nginx simulation)
sudo apt-get update
sudo apt-get install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Configure nginx to proxy requests to Flask app
sudo cat > /etc/nginx/sites-available/takeover_infinity <<EOL
server {
    listen 80;
    server_name takeoverinfinity.example.com;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

sudo ln -s /etc/nginx/sites-available/takeover_infinity /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Update Flask app to listen on all interfaces
sudo sed -i 's/app.run(host="127.0.0.1", port=8080, debug=True)/app.run(host="0.0.0.0", port=8080, debug=True)/' /var/www/takeover_infinity/web_panel/app.py

# Ensure virtual environment and start the app
source /var/www/takeover_infinity/venv/bin/activate
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:8080 -D --chdir /var/www/takeover_infinity/web_panel app:app

echo "Toolkit deployed online. Access via http://takeoverinfinity.example.com"
echo "Public IP simulation complete. Use mock DNS or direct IP access for operations."

