# Update package lists and upgrade installed packages
sudo apt update && sudo apt upgrade -y

# Set up the latest Node.js repository (ensure you're on version 18.x)
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -

# Install the latest Node.js version (18.x)
sudo apt install nodejs -y

# Update pnpm to the latest version globally
npm install -g pnpm

# Install the latest npm version
npm install -g npm

# Install pnpm using the official script (in case you need it installed via script)
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Update package lists and install or update PostgreSQL to the latest available version (PostgreSQL 14)
sudo apt update && sudo apt install postgresql-14 postgresql-contrib -y

# Start PostgreSQL service
sudo systemctl start postgresql.service

# Switch to the PostgreSQL user
sudo -u postgres -i

# Enter PostgreSQL shell
psql -d postgres

# Create a new PostgreSQL user
CREATE USER "snailycad";
ALTER USER "snailycad" WITH SUPERUSER;
ALTER USER "snailycad" PASSWORD 'zVw&HJBf8W8tmBu';

# Create a new PostgreSQL database
CREATE DATABASE "snaily-cadv4";

# Exit PostgreSQL shell
\quit

# Exit PostgreSQL user session
exit

# Switch to root user
sudo -s

##################################################

# Clone the SnailyCAD repository
cd /home/
git clone https://github.com/SnailyCAD/snaily-cadv4.git

# Navigate to the cloned directory
cd snaily-cadv4

# Install dependencies
pnpm install

### Wait until it's done ###

# Copy the environment example file
cp .env.example .env

# Edit the environment file
nano .env

### When done: Ctrl + X, Y, Enter, Ctrl + C ###

## Create the startup script ##

####################################
nano /home/snaily-cadv4/start.sh

#####################

# Copy the following script into start.sh

#!/bin/bash

# Define PostgreSQL user and database
USER="snailycad"
DATABASE="snaily-cadv4"

# Detect PostgreSQL version dynamically
PG_VERSION=$(psql --version | awk '{print $3}' | cut -d '.' -f1)
PG_HBA_FILE="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
PG_CONF_FILE="/etc/postgresql/$PG_VERSION/main/postgresql.conf"

# Get the VM's IP address dynamically
VM_IP=$(hostname -I | awk '{print $1}')

# Check if PostgreSQL configuration files exist
if [[ ! -f $PG_HBA_FILE ]] || [[ ! -f $PG_CONF_FILE ]]; then
    echo "Error: PostgreSQL version $PG_VERSION not found or configuration files are missing."
    exit 1
fi

# Add the entry to pg_hba.conf
echo "host    $DATABASE   $USER   $VM_IP/32   trust" | sudo tee -a $PG_HBA_FILE

# Update listen_addresses in postgresql.conf
sudo sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'" $PG_CONF_FILE

# Reload PostgreSQL to apply changes
sudo systemctl reload postgresql

echo "Configuration updated: pg_hba.conf and postgresql.conf modified. PostgreSQL reloaded."

# Function to deploy the project
deploy_project() {
    echo "Starting project deployment..."

    # Navigate to the project directory
    PROJECT_DIR="/home/snaily-cadv4"
    if ! cd "$PROJECT_DIR"; then
        echo "Error: Directory $PROJECT_DIR not found or inaccessible."
        exit 1
    fi

    # Copy environment settings
    echo "Copying environment settings..."
    if ! node scripts/copy-env.mjs --client --api; then
        echo "Error: Failed to copy environment settings."
        exit 1
    fi

    # Pull the latest changes from Git
    echo "Pulling latest changes from git..."
    if ! git pull origin main; then
        echo "Error: Failed to pull changes from git."
        exit 1
    fi

    # Stash any local changes and pull again
    echo "Stashing any changes and pulling latest changes again..."
    git stash || echo "Warning: No changes to stash."
    if ! git pull origin main; then
        echo "Error: Failed to pull changes from git after stashing."
        exit 1
    fi

    # Install dependencies
    echo "Installing dependencies with pnpm..."
    if ! pnpm install; then
        echo "Error: Failed to install dependencies."
        exit 1
    fi

    # Build the project
    echo "Building the project..."
    if ! pnpm run build; then
        echo "Error: Failed to build the project."
        exit 1
    fi

    # Start the project
    echo "Starting the project..."
    if ! pnpm run start; then
        echo "Error: Failed to start the project."
        exit 1
    fi

    echo "Deployment completed successfully."
}

# Call the function
deploy_project

####################  END  #############

###
nano /etc/systemd/system/start-snaily-cadv4.service

#####

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

###
chmod +x /home/snaily-cadv4/start.sh

####

#####
sudo systemctl daemon-reload
sudo systemctl enable start-snaily-cadv4.service
sudo systemctl start start-snaily-cadv4.service
sudo systemctl restart start-snaily-cadv4.service
#####

cat /home/snaily-cadv4/start.log

################################
nano update_start.sh
# Update start.sh script
chmod +x update_start.sh

#!/bin/bash

# Define the GitHub raw URL for update.sh
GITHUB_URL="https://raw.githubusercontent.com/EWANZO101/Stff-url/main/update.sh"

# Find the location of start.sh on the system
START_SCRIPT_PATH=$(find / -type f -name "start.sh" 2>/dev/null | head -n 1)

# If start.sh is found, update it
if [ -n "$START_SCRIPT_PATH" ]; then
    echo "start.sh found at $START_SCRIPT_PATH, updating..."
    curl -o "$START_SCRIPT_PATH" "$GITHUB_URL"
    echo "start.sh has been updated."
else
    echo "start.sh not found, adding to system..."
    DEFAULT_PATH="/usr/local/bin/start.sh"
    curl -o "$DEFAULT_PATH" "$GITHUB_URL"
    chmod +x "$DEFAULT_PATH"
    echo "start.sh has been added to the system at $DEFAULT_PATH."
fi
