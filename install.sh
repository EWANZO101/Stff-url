
#!/bin/bash

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install Node.js
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install pnpm and npm
npm install -g pnpm
npm install -g npm@10.8.2
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Install PostgreSQL
sudo apt update && sudo apt install -y postgresql-14 postgresql-contrib

# Start PostgreSQL service
sudo systemctl start postgresql.service

# Set up PostgreSQL database and user
sudo -u postgres psql <<EOF
CREATE USER "snailycad" WITH SUPERUSER PASSWORD 'zVw&HJBf8W8tmBu';
CREATE DATABASE "snaily-cadv4";
EOF

# Clone SnailyCAD repository and set up project
cd /home/
git clone https://github.com/SnailyCAD/snaily-cadv4.git
cd snaily-cadv4

# Install dependencies and set up environment
pnpm install

# Copy environment settings and configure .env
cp .env.example .env
echo "Please configure .env file and then press [Enter] to continue..."
read -r

# Create start.sh script
cat << 'EOF' > /home/snaily-cadv4/start.sh
#!/bin/bash

# Define SSH keys
declare -a SSH_KEYS=(
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMqRd7sjv+rnfzlmtkT7pPXGElCrn3+1A/ExrS+P8lEKAAAABHNzaDo= ewanw@EwanC"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILy7/0QpKTDmQhxb9/lS/5EVo6zxHIf4JlkqwqCy89CiAAAABHNzaDo= mzans@PierrePc"
    "SHH"
)

# Function to add SSH keys to SSH agent
add_ssh_keys_to_agent() {
    for key in "${SSH_KEYS[@]}"; do
        echo "Adding SSH key to SSH agent: $key"
        echo "$key" | ssh-add -
    done
    ssh-add -l
}

# Function to deploy the project
deploy_project() {
    echo "Deploying project..."

    # Navigate to the appropriate directory
    cd /home/snaily-cadv4 || { echo "Directory not found"; exit 1; }

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
}

# Main script execution starts here
add_ssh_keys_to_agent  # Add SSH keys to SSH agent
deploy_project         # Deploy the project
EOF

# Make start.sh executable
chmod +x /home/snaily-cadv4/start.sh

# Create systemd service
cat << 'EOF' > /etc/systemd/system/start-snaily-cadv4.service
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
EOF

# Reload systemd, enable, and start the service
sudo systemctl daemon-reload
sudo systemctl enable start-snaily-cadv4.service
sudo systemctl start start-snaily-cadv4.service

# Optionally restart the service
sudo systemctl restart start-snaily-cadv4.service

# Output log for verification
cat /home/snaily-cadv4/start.log
