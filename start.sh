# Update package lists and upgrade installed packages
sudo apt update && sudo apt upgrade -y

# Set up the latest Node.js repository (Node.js 22.x)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -

# Install Node.js 22.x
sudo apt install -y nodejs

# Update npm to the latest version
sudo npm install -g npm@latest

# Install pnpm globally (using npm)
sudo npm install -g pnpm@latest

# Alternatively, install pnpm using the official script (recommended)
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Update package lists and install or update PostgreSQL to the latest available version (PostgreSQL 16)
sudo apt update && sudo apt install -y postgresql-16 postgresql-contrib


install_postgresql16.sh
```````````````````````````````````


#!/bin/bash
# install_postgresql16.sh
# Script to install PostgreSQL 16 on Ubuntu 22.04+ (Jammy or newer)

set -e

echo "🔄 Updating package lists..."
sudo apt update -y

echo "📦 Installing prerequisites..."
sudo apt install -y wget gnupg lsb-release

echo "➕ Adding PostgreSQL APT repository..."
RELEASE=$(lsb_release -cs)
echo "deb http://apt.postgresql.org/pub/repos/apt ${RELEASE}-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list > /dev/null

echo "🔑 Importing PostgreSQL signing key..."
wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

echo "🔄 Updating package lists (PostgreSQL repo added)..."
sudo apt update -y

echo "🚀 Installing PostgreSQL 16 and contrib package..."
sudo apt install -y postgresql-16 postgresql-contrib

echo "✅ PostgreSQL 16 installation complete!"

# Enable and start PostgreSQL service
echo "🧩 Enabling and starting PostgreSQL service..."
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Display PostgreSQL version
echo "🔎 Checking PostgreSQL version..."
psql --version

# Optional: Show status
sudo systemctl status postgresql --no-pager

echo "🎉 PostgreSQL 16 is installed and running successfully!"



``````````````````````````````````````````````````
chmod +x install_postgresql16.sh
./install_postgresql16.sh


sudo systemctl start postgresql.service


sudo -u postgres -i

psql -d postgres

CREATE USER "snailycad";


ALTER USER "snailycad" WITH SUPERUSER;


ALTER USER "snailycad" PASSWORD 'zVw&HJBf8W8tmBu';


CREATE DATABASE "snaily-cadv4";


exit 

exit

sudo -s 


##################################################

cd /home/


git clone https://github.com/SnailyCAD/snaily-cadv4.git


cd snaily-cadv4



pnpm install


### wait untill its done ##



cp .env.example .env



nano .env

when done ### ctrl X yes  enter ctrl C

## Then make the code ## 

####################################
nano /home/snaily-cadv4/start.sh



#####################

copy code below then right click in the

#####



#!/bin/bash
set -e
set -o pipefail

# Colors for better readability
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color

# Function to print status messages
log() {
    echo -e "${GREEN}[*]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error_exit() {
    echo -e "${RED}[x]${NC} $1" >&2
    exit 1
}

# Function to deploy the project
deploy_project() {
    log "Starting project deployment..."

    PROJECT_DIR="/home/snaily-cadv4"

    if [[ ! -d "$PROJECT_DIR" ]]; then
        error_exit "Directory $PROJECT_DIR not found or inaccessible."
    fi

    cd "$PROJECT_DIR" || error_exit "Failed to change directory to $PROJECT_DIR."

    # Ensure git and pnpm are available
    command -v git >/dev/null 2>&1 || error_exit "git not found. Please install git."
    command -v pnpm >/dev/null 2>&1 || error_exit "pnpm not found. Please install pnpm."
    command -v node >/dev/null 2>&1 || error_exit "node not found. Please install Node.js."

    # Copy environment settings
    log "Copying environment settings..."
    if ! node scripts/copy-env.mjs --client --api; then
        error_exit "Failed to copy environment settings."
    fi

    # Git operations
    log "Stashing any local changes..."
    git stash save "pre-deploy-$(date +%F-%T)" >/dev/null 2>&1 || warn "No changes to stash."

    log "Fetching latest changes from origin/main..."
    git fetch origin main || error_exit "Failed to fetch from git."

    log "Pulling latest changes..."
    git reset --hard origin/main || error_exit "Failed to reset to latest commit."

    # Install dependencies
    log "Installing dependencies with pnpm..."
    pnpm install || error_exit "Failed to install dependencies."

    # Build the project
    log "Building the project..."
    pnpm run build || error_exit "Failed to build the project."

    # Start the project
    log "Starting the project..."
    pnpm run start || error_exit "Failed to start the project."

    log "✅ Deployment completed successfully."
}

# Execute deployment
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

tail -f /home/snaily-cadv4/start.log

################################

update_start.sh

chmod +x update_start.sh


#!/bin/bash

# Define the GitHub raw URL for update.sh
GITHUB_URL="https://raw.githubusercontent.com/EWANZO101/Stff-url/main/update.sh"

# Find the location of start.sh on the system
START_SCRIPT_PATH=$(find / -type f -name "start.sh" 2>/dev/null | head -n 1)

# If start.sh is found, update it
if [ -n "$START_SCRIPT_PATH" ]; then
    echo "start.sh found at $START_SCRIPT_PATH, updating..."
    # Download and update the start.sh file from the GitHub URL
    curl -o "$START_SCRIPT_PATH" "$GITHUB_URL"
    echo "start.sh has been updated."
else
    echo "start.sh not found, adding to system..."
    # Add the script to a default location, for example, /usr/local/bin/
    DEFAULT_PATH="/usr/local/bin/start.sh"
    curl -o "$DEFAULT_PATH" "$GITHUB_URL"
    chmod +x "$DEFAULT_PATH"
    echo "start.sh has been added to the system at $DEFAULT_PATH."
fi

























