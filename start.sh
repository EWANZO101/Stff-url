sudo apt update && apt upgrade

curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -

sudo apt install nodejs

npm install -g pnpm
npm install -g npm@10.8.2

curl -fsSL https://get.pnpm.io/install.sh | sh -


sudo apt update && sudo apt install postgresql-14 postgresql-contrib


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

# Define SSH keys
declare -a SSH_KEYS=(
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMqRd7sjv+rnfzlmtkT7pPXGElCrn3+1A/ExrS+P8lEKAAAABHNzaDo= ewanw@EwanC"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILy7/0QpKTDmQhxb9/lS/5EVo6zxHIf4JlkqwqCy89CiAAAABHNzaDo= mzans@PierrePc"
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
