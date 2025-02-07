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
sudo sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/" $PG_CONF_FILE

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
