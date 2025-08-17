# Laravel Docker Project

A professional Laravel application setup with Docker Compose, featuring a complete development environment with all necessary services and tools.

## 🚀 Features

- **Laravel 10** with PHP 8.2
- **Docker Compose** setup with multiple services
- **Nginx** web server with optimized configuration
- **MySQL 8.0** database
- **Redis** for caching and sessions
- **Mailhog** for email testing
- **Node.js** for asset compilation
- **Queue workers** and **scheduler** for production
- **Development tools**: PHPUnit, PHPStan, PHP CS Fixer, Rector
- **Professional project structure** with best practices

## 📋 Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Git

## 🛠️ Services

| Service | Container Name | Port | Description |
|---------|---------------|------|-------------|
| **App** | `laravel_app` | 9000 | Laravel application (PHP-FPM) |
| **Nginx** | `laravel_nginx` | 80, 443 | Web server |
| **MySQL** | `laravel_mysql` | 3306 | Database server |
| **Redis** | `laravel_redis` | 6379 | Cache and session storage |
| **Node** | `laravel_node` | - | Asset compilation (dev profile) |
| **Queue** | `laravel_queue` | - | Queue worker (prod profile) |
| **Scheduler** | `laravel_scheduler` | - | Task scheduler (prod profile) |
| **Mailhog** | `laravel_mailhog` | 1025, 8025 | Email testing (dev profile) |

## ⚡ Quick Start

### 1. Clone and Initialize

```bash
git clone <repository-url>
cd Docker-laravel-project

# Make scripts executable
chmod +x scripts/*.sh

# Initialize the project
make install
# or
./scripts/init.sh
```

### 2. Access Your Application

- **Web Application**: http://localhost:8080
- **Mailhog Interface**: http://localhost:8025
- **Database**: `mysql -h 127.0.0.1 -P 3306 -u laravel -p` (password: `laravel`)

## 🔧 Development Workflow

### Using Make Commands (Recommended)

```bash
# Start development environment
make start

# Access application shell
make shell

# Run artisan commands
make artisan cmd="migrate"
make artisan cmd="make:controller UserController"

# Install packages
make composer cmd="require vendor/package"

# Run tests
make test
make test-coverage

# Code quality
make format        # Format code
make lint         # Lint code
make analyse      # Static analysis
make quality      # All quality checks

# Database operations
make migrate
make migrate-fresh
make seed

# Cache management
make cache-clear
make cache-warm

# View logs
make logs

# Stop environment
make stop
```

### Using Development Script

```bash
# Start containers
./scripts/dev.sh start

# Access shell
./scripts/dev.sh shell

# Run artisan commands
./scripts/dev.sh artisan -- migrate
./scripts/dev.sh artisan -- make:model User

# Run composer commands
./scripts/dev.sh composer -- install
./scripts/dev.sh composer -- require vendor/package

# Run npm commands
./scripts/dev.sh npm -- install
./scripts/dev.sh npm -- run dev

# Quality checks
./scripts/dev.sh test
./scripts/dev.sh format
./scripts/dev.sh analyse

# Fresh start
./scripts/dev.sh fresh
```

### Using Docker Compose Directly

```bash
# Start all services
docker-compose up -d

# Access application container
docker-compose exec app bash

# Run artisan commands
docker-compose exec app php artisan migrate
docker-compose exec app php artisan tinker

# View logs
docker-compose logs -f app

# Stop all services
docker-compose down
```

## 📁 Project Structure

```
├── docker/
│   ├── app/
│   │   ├── Dockerfile          # Application container
│   │   ├── php.ini            # PHP configuration
│   │   └── xdebug.ini         # Xdebug configuration
│   ├── nginx/
│   │   └── conf.d/
│   │       └── default.conf   # Nginx configuration
│   └── mysql/
│       └── init/              # Database initialization scripts
├── scripts/
│   ├── init.sh                # Project initialization script
│   └── dev.sh                 # Development helper script
├── src/                       # Laravel application
│   ├── app/
│   ├── config/
│   ├── database/
│   ├── public/
│   ├── resources/
│   ├── routes/
│   ├── storage/
│   ├── tests/
│   ├── composer.json
│   ├── phpunit.xml
│   ├── phpstan.neon
│   ├── .php-cs-fixer.php
│   ├── phpcs.xml
│   ├── rector.php
│   └── env.template           # Environment template
├── docker-compose.yml         # Docker services configuration
├── Makefile                   # Development shortcuts
└── README.md
```

## 🔧 Configuration

### Environment Setup

1. Copy the environment template:
   ```bash
   cp src/env.template src/.env
   ```

2. Update the `.env` file with your specific configuration:
   ```env
   APP_NAME="Your Laravel App"
   APP_URL=http://localhost:8080
   
   DB_DATABASE=your_database
   DB_USERNAME=your_username
   DB_PASSWORD=your_password
   ```

### Database Configuration

The MySQL service comes pre-configured with:
- **Database**: `laravel`
- **Username**: `laravel`
- **Password**: `laravel`
- **Root Password**: `secret`

### Redis Configuration

Redis is configured for:
- Cache storage
- Session storage
- Queue driver

### Email Configuration

Mailhog is configured for email testing:
- **SMTP Host**: `mailhog`
- **SMTP Port**: `1025`
- **Web Interface**: http://localhost:8025

## 🧪 Testing

### Running Tests

```bash
# Run all tests
make test

# Run tests with coverage
make test-coverage

# Run specific test suite
make artisan cmd="test --testsuite=Feature"

# Run specific test
make artisan cmd="test --filter=UserTest"
```

### Test Configuration

- Tests use SQLite in-memory database
- Test environment is isolated from development
- Coverage reports are generated in `storage/framework/coverage/`

## 🔍 Code Quality Tools

### PHP CS Fixer

```bash
# Format code
make format

# Check formatting (dry-run)
docker-compose exec app ./vendor/bin/php-cs-fixer fix --dry-run
```

### PHPStan

```bash
# Run static analysis
make analyse

# Analyze specific directory
docker-compose exec app ./vendor/bin/phpstan analyse app/
```

### PHPCS

```bash
# Lint code
make lint

# Check specific files
docker-compose exec app ./vendor/bin/phpcs app/Models/
```

### Rector

```bash
# Refactor code
docker-compose exec app ./vendor/bin/rector process

# Dry run
docker-compose exec app ./vendor/bin/rector process --dry-run
```

## 🚀 Production Deployment

### Build for Production

```bash
# Build production images
make prod-build

# Deploy with production profile
make prod-deploy
```

### Production Services

Production deployment includes:
- Queue workers for background job processing
- Task scheduler for cron jobs
- Optimized PHP configuration
- Cached configuration and routes

### Environment Variables

For production, ensure these environment variables are set:
```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=your-32-character-secret-key

# Database
DB_HOST=your-production-db-host
DB_DATABASE=your-production-database
DB_USERNAME=your-production-username
DB_PASSWORD=your-production-password

# Cache
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

# Redis
REDIS_HOST=your-production-redis-host
```

## 📊 Monitoring and Debugging

### Logs

```bash
# Application logs
make logs

# Specific service logs
docker-compose logs nginx
docker-compose logs mysql
docker-compose logs redis
```

### Debugging with Xdebug

Xdebug is pre-configured for development:
- **Port**: 9003
- **IDE Key**: PHPSTORM
- **Host**: host.docker.internal

Configure your IDE to listen on port 9003 for incoming connections.

### Laravel Telescope

Laravel Telescope is included for application monitoring:
- Access via `/telescope` route (development only)
- Monitor requests, queries, jobs, and more

### Laravel Horizon

Laravel Horizon is included for queue monitoring:
- Access via `/horizon` route
- Monitor queue workers and failed jobs

## 🔧 Customization

### Adding New Services

1. Add service to `docker-compose.yml`
2. Update network configuration
3. Add environment variables as needed
4. Update documentation

### Modifying PHP Configuration

Edit `docker/app/php.ini` and rebuild containers:
```bash
make build
make restart
```

### Customizing Nginx

Edit `docker/nginx/conf.d/default.conf` and restart:
```bash
docker-compose restart nginx
```

## 🆘 Troubleshooting

### Common Issues

**Port Conflicts**
```bash
# Check what's using the port
sudo lsof -i :80
sudo lsof -i :3306

# Stop conflicting services
sudo service apache2 stop
sudo service mysql stop
```

**Permission Issues**
```bash
# Fix storage permissions
sudo chown -R $USER:$USER src/storage
sudo chmod -R 755 src/storage
```

**Container Won't Start**
```bash
# Check logs
docker-compose logs app

# Rebuild containers
make fresh
```

**Database Connection Issues**
```bash
# Check MySQL container
docker-compose logs mysql

# Verify environment variables
cat src/.env | grep DB_
```

### Getting Help

1. Check container logs: `make logs`
2. Verify container status: `make status`
3. Try fresh start: `make fresh`
4. Check Docker and Docker Compose versions

## 📚 Additional Resources

- [Laravel Documentation](https://laravel.com/docs)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PHP CS Fixer Documentation](https://cs.symfony.com/)
- [PHPStan Documentation](https://phpstan.org/)

## 📄 License

This project is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

**Happy Coding! 🎉**
