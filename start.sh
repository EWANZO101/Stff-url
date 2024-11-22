#!/bin/bash

# Update system
sudo apt update && apt upgrade -y

# Install Node.js
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install nodejs -y
npm install -g pnpm
npm install -g npm@10.8.2
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Install PostgreSQL
sudo apt update && sudo apt install postgresql-14 postgresql-contrib -y
sudo systemctl start postgresql.service

# Set up PostgreSQL database and user
sudo -u postgres -i <<EOF
psql -d postgres <<SQL
CREATE USER "snailycad";
ALTER USER "snailycad" WITH SUPERUSER;
ALTER USER "snailycad" PASSWORD 'zVw&HJBf8W8tmBu';
CREATE DATABASE "snaily-cadv4";
SQL
exit
EOF

# Change to home directory
cd /home/

# Clone SnailyCAD repository
git clone https://github.com/SnailyCAD/snaily-cadv4.git
cd snaily-cadv4

# Install dependencies
pnpm install

# Wait until installation is complete
# (You can add a check here if needed, like a `sleep` command or a wait for the node modules)

# Copy environment settings and update .env
cp .env.example .env
nano .env  # Edit your environment file, then press Ctrl+X, Y, Enter to save and exit

# Create start script
nano /home/snaily-cadv4/start.sh <<'EOF'
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

# Make start script executable
chmod +x /home/snaily-cadv4/start.sh

# Create systemd service for auto-starting SnailyCAD
sudo nano /etc/systemd/system/start-snaily-cadv4.service <<'EOF'
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
sudo systemctl restart start-snaily-cadv4.service

# Show logs from the start script
cat /home/snaily-cadv4/start.log


# Separate backup script for PostgreSQL
BACKUP_SCRIPT="/home/snaily-cadv4/backup_postgresql.sh"

cat > "$BACKUP_SCRIPT" <<'EOF'
#!/bin/bash

# PostgreSQL credentials and backup directory
PGUSER="snailycad"
PGPASSWORD="zVw&HJBf8W8tmBu"
BACKUP_DIR="/path/to/backup"  # Replace with your desired backup directory
DATE=$(date +\%F_\%H-\%M)
BACKUP_FILE="$BACKUP_DIR/snaily-cadv4_backup_$DATE.sql.gz"

# Run pg_dump to backup the database and compress the backup using gzip
pg_dump -h localhost -U "$PGUSER" -d snaily-cadv4 | gzip > "$BACKUP_FILE"

# Check if backup was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully at $(date) and saved to $BACKUP_FILE"
else
    echo "Backup failed at $(date)"
fi
EOF

# Make backup script executable
chmod +x "$BACKUP_SCRIPT"

# Add cron job to run the backup script every hour
(crontab -l 2>/dev/null; echo "0 * * * * $BACKUP_SCRIPT") | crontab -

echo "PostgreSQL backup script created and scheduled to run every hour."
