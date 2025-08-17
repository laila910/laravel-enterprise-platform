#!/bin/bash

# Azure Infrastructure Setup Script for Laravel Docker Project
# This script creates all necessary Azure resources for hosting the Laravel application

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Configuration variables (modify these as needed)
RESOURCE_GROUP_NAME="laravel-docker-rg"
LOCATION="East US"
WEB_APP_NAME="laravel-docker-webapp"
ACR_NAME="laraveldockeracr"
DATABASE_NAME="laravel-mysql"
REDIS_NAME="laravel-redis"
APP_SERVICE_PLAN="laravel-asp"

# Database configuration
DB_ADMIN_USER="laraveladmin"
DB_ADMIN_PASSWORD="" # Will be prompted

# Function to check if Azure CLI is installed and logged in
check_azure_cli() {
    print_step "Checking Azure CLI..."
    
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install it first."
        print_error "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    fi
    
    # Check if logged in
    if ! az account show &> /dev/null; then
        print_error "You are not logged in to Azure CLI."
        print_error "Please run: az login"
        exit 1
    fi
    
    print_status "Azure CLI check passed!"
}

# Function to prompt for configuration
prompt_configuration() {
    print_step "Configuration setup..."
    
    read -p "Resource Group Name [$RESOURCE_GROUP_NAME]: " input
    RESOURCE_GROUP_NAME=${input:-$RESOURCE_GROUP_NAME}
    
    read -p "Location [$LOCATION]: " input
    LOCATION=${input:-$LOCATION}
    
    read -p "Web App Name [$WEB_APP_NAME]: " input
    WEB_APP_NAME=${input:-$WEB_APP_NAME}
    
    read -p "Container Registry Name [$ACR_NAME]: " input
    ACR_NAME=${input:-$ACR_NAME}
    
    read -p "Database Server Name [$DATABASE_NAME]: " input
    DATABASE_NAME=${input:-$DATABASE_NAME}
    
    read -p "Redis Cache Name [$REDIS_NAME]: " input
    REDIS_NAME=${input:-$REDIS_NAME}
    
    # Prompt for database password
    while [[ -z "$DB_ADMIN_PASSWORD" ]]; do
        read -s -p "Database Admin Password (min 8 characters): " DB_ADMIN_PASSWORD
        echo
        if [[ ${#DB_ADMIN_PASSWORD} -lt 8 ]]; then
            print_error "Password must be at least 8 characters long."
            DB_ADMIN_PASSWORD=""
        fi
    done
    
    print_status "Configuration completed!"
}

# Function to create resource group
create_resource_group() {
    print_step "Creating resource group: $RESOURCE_GROUP_NAME"
    
    if az group show --name "$RESOURCE_GROUP_NAME" &> /dev/null; then
        print_status "Resource group already exists."
    else
        az group create \
            --name "$RESOURCE_GROUP_NAME" \
            --location "$LOCATION"
        print_status "Resource group created successfully!"
    fi
}

# Function to create Azure Container Registry
create_container_registry() {
    print_step "Creating Azure Container Registry: $ACR_NAME"
    
    if az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP_NAME" &> /dev/null; then
        print_status "Container Registry already exists."
    else
        az acr create \
            --resource-group "$RESOURCE_GROUP_NAME" \
            --name "$ACR_NAME" \
            --sku Basic \
            --admin-enabled true
        print_status "Container Registry created successfully!"
    fi
    
    # Get registry credentials
    print_step "Getting registry credentials..."
    ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query loginServer --output tsv)
    ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query username --output tsv)
    ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query passwords[0].value --output tsv)
    
    print_status "Registry credentials obtained!"
}

# Function to create Azure Database for MySQL
create_mysql_database() {
    print_step "Creating Azure Database for MySQL: $DATABASE_NAME"
    
    if az mysql flexible-server show --name "$DATABASE_NAME" --resource-group "$RESOURCE_GROUP_NAME" &> /dev/null; then
        print_status "MySQL server already exists."
    else
        az mysql flexible-server create \
            --resource-group "$RESOURCE_GROUP_NAME" \
            --name "$DATABASE_NAME" \
            --location "$LOCATION" \
            --admin-user "$DB_ADMIN_USER" \
            --admin-password "$DB_ADMIN_PASSWORD" \
            --sku-name Standard_B1ms \
            --tier Burstable \
            --storage-size 20 \
            --version "8.0.21"
        print_status "MySQL server created successfully!"
    fi
    
    # Create database
    print_step "Creating Laravel database..."
    az mysql flexible-server db create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --server-name "$DATABASE_NAME" \
        --database-name "laravel" || print_warning "Database may already exist"
    
    # Configure firewall to allow Azure services
    print_step "Configuring MySQL firewall..."
    az mysql flexible-server firewall-rule create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$DATABASE_NAME" \
        --rule-name "AllowAllAzureIps" \
        --start-ip-address 0.0.0.0 \
        --end-ip-address 0.0.0.0 || print_warning "Firewall rule may already exist"
    
    print_status "MySQL database setup completed!"
}

# Function to create Azure Cache for Redis
create_redis_cache() {
    print_step "Creating Azure Cache for Redis: $REDIS_NAME"
    
    if az redis show --name "$REDIS_NAME" --resource-group "$RESOURCE_GROUP_NAME" &> /dev/null; then
        print_status "Redis cache already exists."
    else
        az redis create \
            --resource-group "$RESOURCE_GROUP_NAME" \
            --name "$REDIS_NAME" \
            --location "$LOCATION" \
            --sku Basic \
            --vm-size c0 \
            --enable-non-ssl-port false \
            --minimum-tls-version 1.2
        print_status "Redis cache created successfully!"
    fi
    
    # Get Redis connection details
    print_step "Getting Redis connection details..."
    REDIS_HOST=$(az redis show --name "$REDIS_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query hostName --output tsv)
    REDIS_PASSWORD=$(az redis list-keys --name "$REDIS_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query primaryKey --output tsv)
    
    print_status "Redis cache setup completed!"
}

# Function to create App Service Plan
create_app_service_plan() {
    print_step "Creating App Service Plan: $APP_SERVICE_PLAN"
    
    if az appservice plan show --name "$APP_SERVICE_PLAN" --resource-group "$RESOURCE_GROUP_NAME" &> /dev/null; then
        print_status "App Service Plan already exists."
    else
        az appservice plan create \
            --resource-group "$RESOURCE_GROUP_NAME" \
            --name "$APP_SERVICE_PLAN" \
            --location "$LOCATION" \
            --sku P1V3 \
            --is-linux true
        print_status "App Service Plan created successfully!"
    fi
}

# Function to create Web App
create_web_app() {
    print_step "Creating Web App: $WEB_APP_NAME"
    
    if az webapp show --name "$WEB_APP_NAME" --resource-group "$RESOURCE_GROUP_NAME" &> /dev/null; then
        print_status "Web App already exists."
    else
        az webapp create \
            --resource-group "$RESOURCE_GROUP_NAME" \
            --plan "$APP_SERVICE_PLAN" \
            --name "$WEB_APP_NAME" \
            --deployment-container-image-name "nginx:latest"
        print_status "Web App created successfully!"
    fi
    
    # Configure container settings
    print_step "Configuring Web App container settings..."
    az webapp config container set \
        --name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --docker-registry-server-url "https://$ACR_LOGIN_SERVER" \
        --docker-registry-server-user "$ACR_USERNAME" \
        --docker-registry-server-password "$ACR_PASSWORD"
    
    # Configure app settings
    print_step "Configuring Web App settings..."
    az webapp config appsettings set \
        --name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --settings \
            APP_ENV="production" \
            APP_DEBUG="false" \
            APP_URL="https://$WEB_APP_NAME.azurewebsites.net" \
            DB_CONNECTION="mysql" \
            DB_HOST="$DATABASE_NAME.mysql.database.azure.com" \
            DB_PORT="3306" \
            DB_DATABASE="laravel" \
            DB_USERNAME="$DB_ADMIN_USER" \
            DB_PASSWORD="$DB_ADMIN_PASSWORD" \
            REDIS_HOST="$REDIS_HOST" \
            REDIS_PORT="6380" \
            REDIS_PASSWORD="$REDIS_PASSWORD" \
            CACHE_DRIVER="redis" \
            SESSION_DRIVER="redis" \
            QUEUE_CONNECTION="redis" \
            WEBSITES_ENABLE_APP_SERVICE_STORAGE="false"
    
    print_status "Web App configuration completed!"
}

# Function to output connection details
output_details() {
    print_step "Deployment Summary"
    echo ""
    echo -e "${BLUE}🎉 Azure infrastructure setup completed!${NC}"
    echo ""
    echo -e "${BLUE}Resource Details:${NC}"
    echo "• Resource Group: $RESOURCE_GROUP_NAME"
    echo "• Web App URL: https://$WEB_APP_NAME.azurewebsites.net"
    echo "• Container Registry: $ACR_LOGIN_SERVER"
    echo "• Database Host: $DATABASE_NAME.mysql.database.azure.com"
    echo "• Redis Host: $REDIS_HOST"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo "1. Build and push your Docker images to the Container Registry"
    echo "2. Update your Azure DevOps pipeline with the resource names"
    echo "3. Configure your environment variables in Azure DevOps"
    echo "4. Run your CI/CD pipeline to deploy the application"
    echo ""
    echo -e "${BLUE}Container Registry Credentials:${NC}"
    echo "• Login Server: $ACR_LOGIN_SERVER"
    echo "• Username: $ACR_USERNAME"
    echo "• Password: [HIDDEN - check Azure portal or run: az acr credential show --name $ACR_NAME]"
    echo ""
    echo -e "${YELLOW}Important:${NC} Save these details for your pipeline configuration!"
}

# Main execution
main() {
    echo -e "${BLUE}🚀 Laravel Docker Azure Setup${NC}"
    echo ""
    
    check_azure_cli
    prompt_configuration
    create_resource_group
    create_container_registry
    create_mysql_database
    create_redis_cache
    create_app_service_plan
    create_web_app
    output_details
}

# Run main function
main "$@"
