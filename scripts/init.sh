#!/bin/bash

# Laravel Docker Project Initialization Script
# This script sets up the Laravel application in Docker environment

set -e

echo "🚀 Initializing Laravel Docker Project..."

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

# Check if Docker and Docker Compose are installed
check_requirements() {
    print_step "Checking requirements..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_status "Requirements check passed!"
}

# Setup environment file
setup_environment() {
    print_step "Setting up environment file..."
    
    if [ ! -f "src/.env" ]; then
        if [ -f "src/env.template" ]; then
            cp src/env.template src/.env
            print_status "Environment file created from template"
        else
            print_warning "No environment template found. Please create src/.env manually"
        fi
    else
        print_status "Environment file already exists"
    fi
}

# Create necessary directories
create_directories() {
    print_step "Creating necessary directories..."
    
    # Application directories
    mkdir -p src/{app,bootstrap,config,database/{factories,migrations,seeders},public,resources/{css,js,views},routes,storage/{app,framework/{cache,sessions,views},logs},tests/{Feature,Unit}}
    
    # Ensure storage subdirectories exist
    mkdir -p src/storage/app/public
    mkdir -p src/storage/framework/cache
    mkdir -p src/storage/framework/sessions
    mkdir -p src/storage/framework/views
    mkdir -p src/storage/logs
    mkdir -p src/bootstrap/cache
    
    # Docker directories
    mkdir -p docker/{nginx/ssl,mysql/init}
    
    # Set permissions
    if [ -d "src/storage" ]; then
        chmod -R 755 src/storage
        chmod -R 755 src/bootstrap/cache 2>/dev/null || true
    fi
    
    print_status "Directories created successfully!"
}

# Build and start Docker containers
start_containers() {
    print_step "Building and starting Docker containers..."
    
    # Stop any existing containers
    docker-compose down 2>/dev/null || true
    
    # Build and start containers
    docker-compose up --build -d
    
    print_status "Docker containers started successfully!"
}

# Install Laravel dependencies
install_dependencies() {
    print_step "Installing Laravel dependencies..."
    
    # Wait for containers to be ready
    sleep 10
    
    # Install Composer dependencies
    docker-compose exec app composer install --no-interaction --prefer-dist --optimize-autoloader
    
    print_status "Dependencies installed successfully!"
}

# Setup Laravel application
setup_laravel() {
    print_step "Setting up Laravel application..."
    
    # Generate application key
    docker-compose exec app php artisan key:generate --ansi
    
    # Run database migrations (if any)
    docker-compose exec app php artisan migrate --force 2>/dev/null || print_warning "No migrations to run"
    
    # Clear and cache configuration
    docker-compose exec app php artisan config:clear
    docker-compose exec app php artisan config:cache
    
    # Clear and cache routes
    docker-compose exec app php artisan route:clear
    docker-compose exec app php artisan route:cache 2>/dev/null || true
    
    # Clear and cache views
    docker-compose exec app php artisan view:clear
    docker-compose exec app php artisan view:cache 2>/dev/null || true
    
    print_status "Laravel application setup completed!"
}

# Install Node.js dependencies (if package.json exists)
install_node_dependencies() {
    if [ -f "src/package.json" ]; then
        print_step "Installing Node.js dependencies..."
        docker-compose run --rm node npm install
        print_status "Node.js dependencies installed successfully!"
    fi
}

# Display success message and next steps
display_success() {
    echo ""
    echo -e "${GREEN}🎉 Laravel Docker Project initialized successfully!${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Visit http://localhost:8080 to see your Laravel application"
    echo "2. Access MySQL: mysql -h 127.0.0.1 -P 3306 -u laravel -p (password: laravel)"
    echo "3. Access Redis: redis-cli -h 127.0.0.1 -p 6379"
    echo "4. View emails in Mailhog: http://localhost:8025"
    echo ""
    echo -e "${BLUE}Useful commands:${NC}"
    echo "• docker-compose exec app bash - Access application container"
    echo "• docker-compose exec app php artisan - Run Artisan commands"
    echo "• docker-compose logs app - View application logs"
    echo "• docker-compose down - Stop all containers"
    echo "• docker-compose up -d - Start all containers"
    echo ""
}

# Main execution
main() {
    check_requirements
    setup_environment
    create_directories
    start_containers
    install_dependencies
    setup_laravel
    install_node_dependencies
    display_success
}

# Run main function
main "$@"
