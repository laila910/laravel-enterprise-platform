#!/bin/bash

# Laravel 12 Update Script
# This script updates the Laravel Docker project from version 10 to 12

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

# Main update process
main() {
    echo -e "${BLUE}🚀 Updating Laravel to Version 12${NC}"
    echo ""
    
    print_step "1. Stopping existing containers..."
    docker-compose down || print_warning "No containers were running"
    
    print_step "2. Removing old images to force rebuild..."
    docker-compose down --rmi all || print_warning "No images to remove"
    
    print_step "3. Cleaning up old containers and volumes..."
    docker system prune -f
    docker volume prune -f
    
    print_step "4. Building new containers with PHP 8.3 and Laravel 12..."
    docker-compose build --no-cache
    
    print_step "5. Starting containers..."
    docker-compose up -d
    
    print_step "6. Waiting for containers to be ready..."
    sleep 30
    
    print_step "7. Removing old vendor directory and composer.lock..."
    docker-compose exec app rm -rf vendor composer.lock || print_warning "Vendor directory not found"
    
    print_step "8. Installing Laravel 12 dependencies..."
    docker-compose exec app composer install --no-interaction --prefer-dist --optimize-autoloader
    
    print_step "9. Generating new application key..."
    docker-compose exec app php artisan key:generate --force
    
    print_step "10. Publishing Laravel 12 assets and configuration..."
    docker-compose exec app php artisan vendor:publish --tag=laravel-assets --force || print_warning "No assets to publish"
    
    print_step "11. Running database migrations..."
    docker-compose exec app php artisan migrate --force || print_warning "No migrations to run"
    
    print_step "12. Clearing all caches..."
    docker-compose exec app php artisan cache:clear
    docker-compose exec app php artisan config:clear
    docker-compose exec app php artisan route:clear
    docker-compose exec app php artisan view:clear
    
    print_step "13. Optimizing for performance..."
    docker-compose exec app php artisan config:cache
    docker-compose exec app php artisan route:cache || print_warning "Route caching skipped"
    docker-compose exec app php artisan view:cache || print_warning "View caching skipped"
    
    print_step "14. Updating Composer autoloader..."
    docker-compose exec app composer dump-autoload --optimize
    
    print_step "15. Checking Laravel version..."
    LARAVEL_VERSION=$(docker-compose exec app php artisan --version)
    print_status "Current Laravel version: $LARAVEL_VERSION"
    
    print_step "16. Running health checks..."
    sleep 10
    
    # Test if the application is accessible
    if curl -s -f http://localhost:8080/health > /dev/null; then
        print_status "✅ Application health check passed!"
    else
        print_warning "❌ Application health check failed. Check the logs with: docker-compose logs app"
    fi
    
    echo ""
    echo -e "${GREEN}🎉 Laravel 12 update completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Visit http://localhost:8080 to test your application"
    echo "2. Check the application logs: docker-compose logs app"
    echo "3. Run your test suite: make test"
    echo "4. Update your code for Laravel 12 compatibility if needed"
    echo ""
    echo -e "${YELLOW}Important Laravel 12 Changes:${NC}"
    echo "• PHP 8.3+ is now required"
    echo "• Some package versions have been updated"
    echo "• Review Laravel 12 upgrade guide for breaking changes"
    echo "• Update your custom code for any deprecated features"
    echo ""
}

# Run main function
main "$@"
