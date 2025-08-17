# Azure DevOps CI/CD Deployment Guide

Complete guide for deploying the Laravel Docker project to Azure using Azure DevOps pipelines and hosting it online.

## 📋 Prerequisites

- Azure subscription with sufficient credits/budget
- Azure DevOps organization and project
- Azure CLI installed locally (for manual setup)
- Docker Desktop installed locally
- Git repository with the Laravel Docker project

## 🏗️ Azure Infrastructure Setup

### Option 1: Automated Setup (Recommended)

Use the provided setup script to create all Azure resources automatically:

```bash
# Make the script executable
chmod +x scripts/azure-setup.sh

# Run the setup script
./scripts/azure-setup.sh
```

The script will create:
- Resource Group
- Azure Container Registry (ACR)
- Azure Database for MySQL
- Azure Cache for Redis
- App Service Plan
- Web App

### Option 2: Manual Setup

#### 1. Create Resource Group

```bash
az group create --name laravel-docker-rg --location "East US"
```

#### 2. Create Azure Container Registry

```bash
az acr create \
  --resource-group laravel-docker-rg \
  --name laraveldockeracr \
  --sku Basic \
  --admin-enabled true
```

#### 3. Create Azure Database for MySQL

```bash
az mysql flexible-server create \
  --resource-group laravel-docker-rg \
  --name laravel-mysql \
  --admin-user laraveladmin \
  --admin-password "YourSecurePassword123!" \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --storage-size 20 \
  --version "8.0.21"

# Create Laravel database
az mysql flexible-server db create \
  --resource-group laravel-docker-rg \
  --server-name laravel-mysql \
  --database-name laravel
```

#### 4. Create Azure Cache for Redis

```bash
az redis create \
  --resource-group laravel-docker-rg \
  --name laravel-redis \
  --location "East US" \
  --sku Basic \
  --vm-size c0
```

#### 5. Create App Service Plan and Web App

```bash
# Create App Service Plan
az appservice plan create \
  --resource-group laravel-docker-rg \
  --name laravel-asp \
  --location "East US" \
  --sku P1V3 \
  --is-linux true

# Create Web App
az webapp create \
  --resource-group laravel-docker-rg \
  --plan laravel-asp \
  --name laravel-docker-webapp \
  --deployment-container-image-name "nginx:latest"
```

## 🔧 Azure DevOps Setup

### 1. Create Azure DevOps Project

1. Go to [Azure DevOps](https://dev.azure.com)
2. Create a new organization (if needed)
3. Create a new project for your Laravel application

### 2. Set Up Service Connections

#### Azure Resource Manager Connection

1. Go to **Project Settings** → **Service connections**
2. Create new service connection → **Azure Resource Manager**
3. Choose **Service principal (automatic)**
4. Select your subscription and resource group
5. Name it `azure-service-connection`

#### Docker Registry Connection

1. Create new service connection → **Docker Registry**
2. Choose **Azure Container Registry**
3. Select your subscription and container registry
4. Name it `docker-registry-connection`

### 3. Configure Pipeline Variables

Go to **Pipelines** → **Library** → **Variable groups** and create a variable group named `azure-deployment-vars`:

| Variable Name | Value | Secret |
|---------------|-------|--------|
| `registryName` | Your ACR name (e.g., `laraveldockeracr`) | No |
| `webAppName` | Your Web App name (e.g., `laravel-docker-webapp`) | No |
| `resourceGroupName` | Your resource group name | No |
| `databaseHost` | Your MySQL server FQDN | No |
| `databaseName` | `laravel` | No |
| `databaseUsername` | Your database admin username | No |
| `databasePassword` | Your database admin password | Yes |
| `redisHost` | Your Redis cache FQDN | No |
| `redisPassword` | Your Redis primary key | Yes |
| `appKey` | Laravel APP_KEY (generate with `php artisan key:generate --show`) | Yes |

### 4. Set Up Secure Files

Upload environment files as secure files:

1. Go to **Pipelines** → **Library** → **Secure files**
2. Upload `.env.production` (from `azure/env.production.template`)
3. Upload `.env.staging` (from `azure/env.staging.template`)

## 📦 Repository Setup

### 1. Add Azure Pipeline File

The `azure-pipelines.yml` file is already created in your repository root. Update the variable values to match your Azure resources:

```yaml
variables:
  dockerRegistryServiceConnection: 'docker-registry-connection'
  imageRepository: 'laravel-docker-app'
  containerRegistry: 'laraveldockeracr.azurecr.io'  # Update with your ACR name
  azureSubscription: 'azure-service-connection'
  webAppName: 'laravel-docker-webapp'  # Update with your Web App name
  resourceGroupName: 'laravel-docker-rg'  # Update with your resource group
```

### 2. Create Branch Policies

Set up branch policies for `master` and `develop` branches:

1. Go to **Repos** → **Branches**
2. Click on `master` branch → **Branch policies**
3. Enable:
   - Require a minimum number of reviewers (2)
   - Check for linked work items
   - Require build validation with your pipeline

## 🚀 Deployment Process

### Automatic Deployment (CI/CD)

The pipeline automatically deploys when:

- **Staging**: Push/merge to `develop` branch
- **Production**: Push/merge to `master` branch

### Manual Deployment

Use the deployment script for manual deployments:

```bash
# Make the script executable
chmod +x scripts/azure-deploy.sh

# Deploy to production
./scripts/azure-deploy.sh \
  --resource-group laravel-docker-rg \
  --registry laraveldockeracr \
  --webapp laravel-docker-webapp \
  --tag latest
```

## 🔍 Pipeline Stages Explained

### 1. Build and Test Stage

- Checks out code
- Sets up test environment with Docker
- Installs dependencies
- Runs code quality checks (PHPStan, PHP CS Fixer, PHPCS)
- Executes unit and feature tests
- Publishes test results and coverage

### 2. Build Production Images

- Builds production Docker images
- Pushes images to Azure Container Registry
- Tags images with build ID and 'latest'

### 3. Deploy to Staging

- Deploys to staging environment (develop branch)
- Uses staging environment variables
- Runs on Azure Container Apps or Web App staging slot

### 4. Deploy to Production

- Deploys to production environment (master branch)
- Uses production environment variables
- Updates Azure Web App with new container image

### 5. Post-deployment Tests

- Runs smoke tests against deployed application
- Checks health endpoints
- Validates API responses

## 🌐 Accessing Your Application

After successful deployment:

- **Production**: `https://your-webapp-name.azurewebsites.net`
- **Staging**: `https://your-webapp-name-staging.azurewebsites.net`

### Health Check Endpoints

- `/health` - Application health status
- `/api/status` - API status and version information

## 📊 Monitoring and Logging

### Application Insights

Enable Application Insights for monitoring:

```bash
az extension add --name application-insights

az monitor app-insights component create \
  --app laravel-insights \
  --location "East US" \
  --resource-group laravel-docker-rg
```

Add the instrumentation key to your Web App settings:

```bash
az webapp config appsettings set \
  --name laravel-docker-webapp \
  --resource-group laravel-docker-rg \
  --settings APPINSIGHTS_INSTRUMENTATIONKEY="your-instrumentation-key"
```

### Log Streaming

View real-time logs:

```bash
az webapp log tail \
  --name laravel-docker-webapp \
  --resource-group laravel-docker-rg
```

## 🔧 Environment Configuration

### Production Environment Variables

Key environment variables for production:

```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-webapp-name.azurewebsites.net
DB_HOST=your-mysql-server.mysql.database.azure.com
DB_DATABASE=laravel
REDIS_HOST=your-redis-cache.redis.cache.windows.net
REDIS_PORT=6380
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
```

### Staging Environment Variables

Similar to production but with staging-specific values:

```env
APP_ENV=staging
APP_DEBUG=true
APP_URL=https://your-webapp-name-staging.azurewebsites.net
# ... other staging-specific values
```

## 🛠️ Troubleshooting

### Common Issues

#### 1. Container Registry Authentication

If you get authentication errors:

```bash
az acr login --name your-acr-name
```

#### 2. Database Connection Issues

Check firewall rules:

```bash
az mysql flexible-server firewall-rule create \
  --resource-group laravel-docker-rg \
  --name laravel-mysql \
  --rule-name "AllowAllAzureIps" \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

#### 3. Web App Not Starting

Check application logs:

```bash
az webapp log download \
  --name laravel-docker-webapp \
  --resource-group laravel-docker-rg
```

#### 4. Performance Issues

Scale up your App Service Plan:

```bash
az appservice plan update \
  --name laravel-asp \
  --resource-group laravel-docker-rg \
  --sku P2V3
```

### Debug Commands

```bash
# Check Web App status
az webapp show --name laravel-docker-webapp --resource-group laravel-docker-rg

# View Web App configuration
az webapp config show --name laravel-docker-webapp --resource-group laravel-docker-rg

# Check container logs
az webapp log tail --name laravel-docker-webapp --resource-group laravel-docker-rg

# SSH into container (if enabled)
az webapp ssh --name laravel-docker-webapp --resource-group laravel-docker-rg
```

## 💰 Cost Optimization

### Azure Resource Costs

Typical monthly costs for a small to medium Laravel application:

- **App Service Plan (P1V3)**: ~$73/month
- **Azure Database for MySQL (B1ms)**: ~$12/month
- **Azure Cache for Redis (Basic C0)**: ~$16/month
- **Container Registry (Basic)**: ~$5/month
- **Application Insights**: ~$2/month (based on usage)

**Total**: ~$108/month

### Cost Reduction Tips

1. **Use staging slots** instead of separate staging resources
2. **Scale down during off-hours** using auto-scaling rules
3. **Use Basic tier** for non-production environments
4. **Monitor usage** with Azure Cost Management

## 🔒 Security Best Practices

### 1. Secure Environment Variables

- Store sensitive data in Azure Key Vault
- Use managed identities for authentication
- Enable HTTPS only for Web Apps

### 2. Database Security

- Use SSL connections to MySQL
- Restrict firewall rules to specific IP ranges
- Enable audit logging

### 3. Container Security

- Regularly update base images
- Scan images for vulnerabilities
- Use minimal base images (Alpine Linux)

### 4. Network Security

- Use Virtual Network integration
- Configure private endpoints for database and Redis
- Enable Web Application Firewall (WAF)

## 📚 Additional Resources

- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/)
- [Azure DevOps Pipelines Documentation](https://docs.microsoft.com/en-us/azure/devops/pipelines/)
- [Laravel Documentation](https://laravel.com/docs)
- [Docker Documentation](https://docs.docker.com/)

## 🆘 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review Azure DevOps pipeline logs
3. Check Azure portal for resource status
4. Review application logs in Azure

---

**Happy Deploying! 🚀**
