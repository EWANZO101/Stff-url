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

























