nano /home/snaily-cadv4/start.sh

#!/bin/bash

# Navigate to the appropriate directory
cd /home/snaily-cadv4

# Execute the necessary commands
echo "Copying environment settings..."
node scripts/copy-env.mjs --client --api

echo "Pulling latest changes from git..."
git pull origin main

echo "Stashing any changes and pulling latest changes again..."
git stash && git pull origin main

echo "Installing dependencies..."
pnpm install

echo "Building the project..."
pnpm run build
pnpm run start
echo "All processes are completed."






 nano /etc/systemd/system/start-snaily-cadv4.service        

[Unit]
Description=Start Snaily CADv4
After=network.target

[Service]
Type=simple
ExecStart=/home/snaily-cadv4/start.sh
StandardOutput=append:/home/snaily-cadv4/start.log
StandardError=append:/home/snaily-cadv4/start.log
User=root
WorkingDirectory=/home/snaily-cadv4

[Install]
WantedBy=multi-user.target


chmod +x /home/snaily-cadv4/start.sh

sudo systemctl daemon-reload
sudo systemctl enable start-snaily-cadv4.service
 sudo systemctl start start-snaily-cadv4.service
  sudo systemctl restart start-snaily-cadv4.service


   cat /home/snaily-cadv4/start.log
