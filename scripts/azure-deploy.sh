#!/bin/bash

# Azure Deployment Script for Laravel Docker Project
# This script builds and deploys the application to Azure

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

# Configuration variables
RESOURCE_GROUP_NAME=""
ACR_NAME=""
WEB_APP_NAME=""
IMAGE_TAG="latest"
ENVIRONMENT="production"

# Function to show usage
show_usage() {
    echo "Laravel Docker Azure Deployment Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -g, --resource-group    Azure Resource Group name"
    echo "  -r, --registry          Azure Container Registry name"
    echo "  -w, --webapp           Azure Web App name"
    echo "  -t, --tag              Docker image tag (default: latest)"
    echo "  -e, --environment      Environment (production|staging, default: production)"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -g laravel-rg -r myacr -w mywebapp"
    echo "  $0 --resource-group laravel-rg --registry myacr --webapp mywebapp --tag v1.0.0"
    echo ""
}

# Function to parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -g|--resource-group)
                RESOURCE_GROUP_NAME="$2"
                shift 2
                ;;
            -r|--registry)
                ACR_NAME="$2"
                shift 2
                ;;
            -w|--webapp)
                WEB_APP_NAME="$2"
                shift 2
                ;;
            -t|--tag)
                IMAGE_TAG="$2"
                shift 2
                ;;
            -e|--environment)
                ENVIRONMENT="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate required parameters
    if [[ -z "$RESOURCE_GROUP_NAME" || -z "$ACR_NAME" || -z "$WEB_APP_NAME" ]]; then
        print_error "Missing required parameters!"
        show_usage
        exit 1
    fi
}

# Function to check prerequisites
check_prerequisites() {
    print_step "Checking prerequisites..."
    
    # Check Azure CLI
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed."
        exit 1
    fi
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed."
        exit 1
    fi
    
    # Check if logged in to Azure
    if ! az account show &> /dev/null; then
        print_error "Not logged in to Azure CLI. Run: az login"
        exit 1
    fi
    
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running."
        exit 1
    fi
    
    print_status "Prerequisites check passed!"
}

# Function to get ACR login server
get_acr_details() {
    print_step "Getting Azure Container Registry details..."
    
    ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query loginServer --output tsv)
    
    if [[ -z "$ACR_LOGIN_SERVER" ]]; then
        print_error "Could not get ACR login server. Check your ACR name and resource group."
        exit 1
    fi
    
    print_status "ACR Login Server: $ACR_LOGIN_SERVER"
}

# Function to login to Azure Container Registry
login_to_acr() {
    print_step "Logging in to Azure Container Registry..."
    
    az acr login --name "$ACR_NAME"
    
    print_status "Successfully logged in to ACR!"
}

# Function to build and push Docker images
build_and_push_images() {
    print_step "Building and pushing Docker images..."
    
    # Define image names
    APP_IMAGE="$ACR_LOGIN_SERVER/laravel-docker-app:$IMAGE_TAG"
    NGINX_IMAGE="$ACR_LOGIN_SERVER/laravel-docker-app-nginx:$IMAGE_TAG"
    
    # Build application image (production target)
    print_status "Building Laravel application image..."
    docker build \
        --target production \
        -t "$APP_IMAGE" \
        -f docker/app/Dockerfile \
        .
    
    # Build Nginx image
    print_status "Building Nginx image..."
    docker build \
        -t "$NGINX_IMAGE" \
        -f docker/nginx/Dockerfile \
        .
    
    # Push images to ACR
    print_status "Pushing Laravel application image..."
    docker push "$APP_IMAGE"
    
    print_status "Pushing Nginx image..."
    docker push "$NGINX_IMAGE"
    
    print_status "Images built and pushed successfully!"
}

# Function to update Web App container image
update_webapp_image() {
    print_step "Updating Web App container image..."
    
    # Update the container image
    az webapp config container set \
        --name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --docker-custom-image-name "$ACR_LOGIN_SERVER/laravel-docker-app:$IMAGE_TAG"
    
    print_status "Web App container image updated!"
}

# Function to run database migrations
run_migrations() {
    print_step "Running database migrations..."
    
    print_warning "Database migrations should be handled through the application."
    print_warning "Make sure your Laravel app runs migrations on startup or use a separate job."
    
    # Example of running a one-time command (if needed)
    # az webapp ssh --name "$WEB_APP_NAME" --resource-group "$RESOURCE_GROUP_NAME" --command "php artisan migrate --force"
}

# Function to restart the Web App
restart_webapp() {
    print_step "Restarting Web App..."
    
    az webapp restart \
        --name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME"
    
    print_status "Web App restarted successfully!"
}

# Function to check deployment health
check_deployment_health() {
    print_step "Checking deployment health..."
    
    WEB_APP_URL="https://$WEB_APP_NAME.azurewebsites.net"
    
    print_status "Waiting for application to start..."
    sleep 30
    
    # Test health endpoint
    for i in {1..5}; do
        print_status "Health check attempt $i/5..."
        
        if curl -s -f "$WEB_APP_URL/health" > /dev/null; then
            print_status "✅ Health check passed!"
            break
        elif [[ $i -eq 5 ]]; then
            print_warning "❌ Health check failed after 5 attempts"
            print_warning "Check the application logs in Azure portal"
        else
            print_status "Health check failed, retrying in 30 seconds..."
            sleep 30
        fi
    done
}

# Function to show deployment summary
show_deployment_summary() {
    print_step "Deployment Summary"
    echo ""
    echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}Deployment Details:${NC}"
    echo "• Environment: $ENVIRONMENT"
    echo "• Resource Group: $RESOURCE_GROUP_NAME"
    echo "• Container Registry: $ACR_LOGIN_SERVER"
    echo "• Web App: $WEB_APP_NAME"
    echo "• Image Tag: $IMAGE_TAG"
    echo "• Application URL: https://$WEB_APP_NAME.azurewebsites.net"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo "1. Visit your application: https://$WEB_APP_NAME.azurewebsites.net"
    echo "2. Check application logs in Azure portal if needed"
    echo "3. Monitor application performance and health"
    echo ""
}

# Function to clean up local Docker images (optional)
cleanup_local_images() {
    print_step "Cleaning up local Docker images..."
    
    read -p "Do you want to remove local Docker images to free up space? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker rmi "$ACR_LOGIN_SERVER/laravel-docker-app:$IMAGE_TAG" 2>/dev/null || true
        docker rmi "$ACR_LOGIN_SERVER/laravel-docker-app-nginx:$IMAGE_TAG" 2>/dev/null || true
        print_status "Local images cleaned up!"
    else
        print_status "Skipping cleanup."
    fi
}

# Main execution
main() {
    echo -e "${BLUE}🚀 Laravel Docker Azure Deployment${NC}"
    echo ""
    
    parse_arguments "$@"
    check_prerequisites
    get_acr_details
    login_to_acr
    build_and_push_images
    update_webapp_image
    restart_webapp
    check_deployment_health
    show_deployment_summary
    cleanup_local_images
}

# Run main function with all arguments
main "$@"
