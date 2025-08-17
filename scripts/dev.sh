#!/bin/bash

# Laravel Docker Development Helper Script
# This script provides common development tasks

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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Show usage information
show_usage() {
    echo "Laravel Docker Development Helper"
    echo ""
    echo "Usage: ./scripts/dev.sh [command]"
    echo ""
    echo "Available commands:"
    echo "  start       - Start all containers"
    echo "  stop        - Stop all containers"
    echo "  restart     - Restart all containers"
    echo "  build       - Build containers"
    echo "  shell       - Access application shell"
    echo "  artisan     - Run artisan command (pass arguments after --)"
    echo "  composer    - Run composer command (pass arguments after --)"
    echo "  npm         - Run npm command (pass arguments after --)"
    echo "  test        - Run PHPUnit tests"
    echo "  format      - Format code using PHP CS Fixer"
    echo "  analyse     - Run static analysis with PHPStan"
    echo "  quality     - Run all quality checks (lint, analyse, test)"
    echo "  fresh       - Fresh start (rebuild and restart everything)"
    echo "  logs        - Show application logs"
    echo "  status      - Show container status"
    echo "  cleanup     - Clean up Docker resources"
    echo ""
    echo "Examples:"
    echo "  ./scripts/dev.sh start"
    echo "  ./scripts/dev.sh artisan -- migrate"
    echo "  ./scripts/dev.sh composer -- require package/name"
    echo "  ./scripts/dev.sh npm -- install"
    echo ""
}

# Check if Docker Compose is available
check_docker_compose() {
    if docker-compose version &> /dev/null; then
        DOCKER_COMPOSE_CMD="docker-compose"
    elif docker compose version &> /dev/null; then
        DOCKER_COMPOSE_CMD="docker compose"
    else
        print_error "Docker Compose is not available"
        exit 1
    fi
}

# Start containers
start_containers() {
    print_step "Starting containers..."
    $DOCKER_COMPOSE_CMD up -d
    print_status "Containers started successfully!"
}

# Stop containers
stop_containers() {
    print_step "Stopping containers..."
    $DOCKER_COMPOSE_CMD down
    print_status "Containers stopped successfully!"
}

# Restart containers
restart_containers() {
    print_step "Restarting containers..."
    $DOCKER_COMPOSE_CMD restart
    print_status "Containers restarted successfully!"
}

# Build containers
build_containers() {
    print_step "Building containers..."
    $DOCKER_COMPOSE_CMD build --no-cache
    print_status "Containers built successfully!"
}

# Access application shell
access_shell() {
    print_step "Accessing application shell..."
    $DOCKER_COMPOSE_CMD exec app bash
}

# Run artisan command
run_artisan() {
    shift # Remove 'artisan' from arguments
    if [ "$1" = "--" ]; then
        shift # Remove '--' separator
    fi
    print_step "Running artisan command: $*"
    $DOCKER_COMPOSE_CMD exec app php artisan "$@"
}

# Run composer command
run_composer() {
    shift # Remove 'composer' from arguments
    if [ "$1" = "--" ]; then
        shift # Remove '--' separator
    fi
    print_step "Running composer command: $*"
    $DOCKER_COMPOSE_CMD exec app composer "$@"
}

# Run npm command
run_npm() {
    shift # Remove 'npm' from arguments
    if [ "$1" = "--" ]; then
        shift # Remove '--' separator
    fi
    print_step "Running npm command: $*"
    $DOCKER_COMPOSE_CMD run --rm node npm "$@"
}

# Run tests
run_tests() {
    print_step "Running PHPUnit tests..."
    $DOCKER_COMPOSE_CMD exec app php artisan test
}

# Format code
format_code() {
    print_step "Formatting code with PHP CS Fixer..."
    $DOCKER_COMPOSE_CMD exec app ./vendor/bin/php-cs-fixer fix --verbose
    print_status "Code formatting completed!"
}

# Run static analysis
run_analysis() {
    print_step "Running static analysis with PHPStan..."
    $DOCKER_COMPOSE_CMD exec app ./vendor/bin/phpstan analyse
}

# Run quality checks
run_quality() {
    print_step "Running quality checks..."
    
    print_step "1. Linting with PHPCS..."
    $DOCKER_COMPOSE_CMD exec app ./vendor/bin/phpcs || true
    
    print_step "2. Static analysis with PHPStan..."
    $DOCKER_COMPOSE_CMD exec app ./vendor/bin/phpstan analyse || true
    
    print_step "3. Running tests..."
    $DOCKER_COMPOSE_CMD exec app php artisan test || true
    
    print_status "Quality checks completed!"
}

# Fresh start
fresh_start() {
    print_step "Fresh start - rebuilding everything..."
    
    # Stop and remove containers
    $DOCKER_COMPOSE_CMD down -v
    
    # Remove images
    docker rmi $(docker images -q -f "reference=*laravel*") 2>/dev/null || true
    
    # Build and start
    $DOCKER_COMPOSE_CMD up --build -d
    
    # Install dependencies
    $DOCKER_COMPOSE_CMD exec app composer install
    
    # Generate key
    $DOCKER_COMPOSE_CMD exec app php artisan key:generate
    
    # Run migrations
    $DOCKER_COMPOSE_CMD exec app php artisan migrate --force
    
    print_status "Fresh start completed!"
}

# Show logs
show_logs() {
    print_step "Showing application logs..."
    $DOCKER_COMPOSE_CMD logs -f app
}

# Show container status
show_status() {
    print_step "Container status:"
    $DOCKER_COMPOSE_CMD ps
}

# Cleanup Docker resources
cleanup_docker() {
    print_step "Cleaning up Docker resources..."
    
    # Stop containers
    $DOCKER_COMPOSE_CMD down -v
    
    # Remove unused containers, networks, images
    docker system prune -f
    
    # Remove unused volumes
    docker volume prune -f
    
    print_status "Docker cleanup completed!"
}

# Main script logic
main() {
    check_docker_compose
    
    case "${1:-}" in
        "start")
            start_containers
            ;;
        "stop")
            stop_containers
            ;;
        "restart")
            restart_containers
            ;;
        "build")
            build_containers
            ;;
        "shell")
            access_shell
            ;;
        "artisan")
            run_artisan "$@"
            ;;
        "composer")
            run_composer "$@"
            ;;
        "npm")
            run_npm "$@"
            ;;
        "test")
            run_tests
            ;;
        "format")
            format_code
            ;;
        "analyse"|"analyze")
            run_analysis
            ;;
        "quality")
            run_quality
            ;;
        "fresh")
            fresh_start
            ;;
        "logs")
            show_logs
            ;;
        "status")
            show_status
            ;;
        "cleanup")
            cleanup_docker
            ;;
        "help"|"--help"|"-h"|"")
            show_usage
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
