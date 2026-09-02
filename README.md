# Lukida RDS4Docker

🐳 **Complete Docker Compose setup for Lukida** with PHP 8.4-Apache, MariaDB Alpine, and Solr - optimized for performance

## Features

✅ **MariaDB 11 Alpine** - Lightweight database (150MB vs 400MB MySQL)  
✅ **PHP 8.4 Alpine-based Apache** - Minimal footprint, maximum performance  
✅ **Apache 2.4** with rewrite rules  
✅ **Solr 9 Alpine** for full-text search  
✅ **PECL Solr Module** pre-installed  
✅ **File_MARC** support for MARC records  
✅ **Organized volume structure** - Config, logs, application separated  
✅ **Health checks** for all services  
✅ **Production-ready** with security headers  

## Quick Start

### 1. Clone/Download this Repository

```bash
git clone https://github.com/czeyka/lukida_rds4docker.git
cd lukida_rds4docker
```

### 2. Prepare Directory Structure

```bash
# Create necessary directories
mkdir -p rds-config logs/{apache2,php,lukida} solr-config init-db apache-config
```

### 3. Configure Environment

```bash
# Copy and customize .env
cp .env.example .env
nano .env  # Edit with your settings
```

**Critical .env changes:**

```env
MARIADB_ROOT_PASSWORD=your_secure_password
MARIADB_PASSWORD=your_secure_password
APP_MODE=development  # or production
LIBRARY_NAME=Your Library Name
```

### 4. Add Lukida Application

```bash
# Option A: Copy existing installation
cp -r /path/to/lukida/* lukida/

# Option B: Clone from repository
git clone https://github.com/gbv/Lukida.git lukida-src
cp -r lukida-src/* lukida/
```

### 5. Add Database Schema

```bash
# Copy mysql_import.sql from your Lukida installation
cp /path/to/mysql_import.sql init-db/
```

### 6. Start Containers

```bash
# Build and start
docker-compose up -d

# Watch logs
docker-compose logs -f php-apache
```

### 7. Configure Lukida

Edit configuration files:

```bash
# Main configuration
nano ./rds-config/lukida_newlibrary/general.ini

# Discovery settings
nano ./rds-config/lukida_newlibrary/discover.ini

# Add your logo and assets
cp /path/to/logo.png ./rds-config/lukida_newlibrary/assets/

# Customize start page
nano ./rds-config/lukida_newlibrary/start.html
```

### 8. Access Application

```
http://localhost/
or
http://lukida.local/  (if configured in /etc/hosts)
```

## Directory Structure

```
lukida_rds4docker/
├── Dockerfile                              # PHP 8.4-Apache Alpine image
├── docker-entrypoint.sh                    # Container initialization
├── docker-compose.yml                      # Service orchestration
├── docker-compose.override.yml.example     # Development overrides
├── .env.example                            # Configuration template
├── .gitignore
├── README.md
├── lukida/                                 # Lukida source code (read-only)
├── rds-config/                             # Configuration & library data (read-write)
│   └── lukida_newlibrary/
│       ├── general.ini                     # Main configuration
│       ├── discover.ini                    # Discovery config
│       ├── start.html                      # Frontend page
│       ├── assets/                         # Logo, images, CSS
│       └── logs/                           # Application logs
├── logs/                                   # Container logs (mounted)
│   ├── apache2/                            # Apache access & error logs
│   ├── php/                                # PHP error logs
│   └── lukida/                             # Lukida app logs
├── apache-config/
│   └── 000-lukida.conf                     # VirtualHost configuration
├── solr-config/                            # Solr configuration
├── init-db/
│   └── mysql_import.sql                    # Database schema
└── docker-volumes/                         # Docker-managed data
    ├── mariadb_data/                       # Database persistence
    └── solr_data/                          # Solr index persistence
```

## Configuration Examples

### general.ini Example

```ini
[general]
title=My Library
softwarename=Lukida
language=ger
iln=123456789
isil=DE-ABC-001
frontpage=false
imprint=https://my-library.de/imprint

[domains]
devurl=lukida.local
testurl=lukida.test.tld
produrl=https://lukida.my-library.de

[database]
type=mysql
hostname=mariadb
username=lukida_user
password=lukida_password
database=lukida_db

[solr]
host=solr
port=8983
```

## Database Management

### Access MariaDB CLI

```bash
# As application user
docker-compose exec mariadb mariadb -u lukida_user -p lukida_db

# As root
docker-compose exec mariadb mariadb -u root -p
```

### Backup Database

```bash
docker-compose exec mariadb \
  mariadb-dump -u lukida_user -p lukida_db > backup_$(date +%Y%m%d).sql
```

### Restore Database

```bash
docker-compose exec -T mariadb mariadb -u lukida_user -p lukida_db < backup.sql
```

## Logs

```bash
# Apache error log
tail -f logs/apache2/error.log

# PHP error log
tail -f logs/php/error.log

# Apache access log
tail -f logs/apache2/access.log

# Follow all container logs
docker-compose logs -f

# Specific service
docker-compose logs -f php-apache
```

## Solr Management

### Solr Admin Interface

```
http://localhost:8983/solr/
```

### Create Collection

```bash
docker-compose exec solr bash
solr create_collection -c lukida_index
```

## Development

### Enable XDebug

```bash
cp docker-compose.override.yml.example docker-compose.override.yml
docker-compose up -d --build
```

XDebug listens on port 9003.

### Live Editing

With override file, edit files locally and changes are immediately reflected:

```bash
nano ./lukida/kernel/application/modules/MyModule.php
# Changes visible at http://localhost/ instantly
```

### PHP CLI

```bash
docker-compose exec php-apache php -r "phpinfo();"
docker-compose exec php-apache bash
```

## Production Deployment

### Security Checklist

- [ ] Strong passwords in `.env`
- [ ] `APP_MODE=production` set
- [ ] Volumes read-only (except logs/config)
- [ ] Only necessary ports exposed
- [ ] Regular database backups
- [ ] Log rotation configured
- [ ] Reverse proxy (nginx) in front
- [ ] SSL/TLS certificate installed

### Production docker-compose.yml

```bash
# Only expose :80, use reverse proxy for SSL
# Keep volumes read-only except config and logs
# Use environment-specific .env file
```

## Troubleshooting

### MariaDB won't start

```bash
docker-compose logs mariadb
docker-compose down -v
docker-compose up -d
```

### Check service health

```bash
docker-compose ps
docker-compose exec php-apache nc -zv mariadb 3306
```

### Permission issues

```bash
sudo chown -R $USER:$USER ./rds-config ./logs
chmod -R 755 ./rds-config ./logs
```

### Container shell access

```bash
docker-compose exec php-apache bash
docker-compose exec mariadb bash
docker-compose exec solr bash
```

## Useful Commands

```bash
# Start all
docker-compose up -d

# Stop all
docker-compose down

# Restart specific service
docker-compose restart php-apache

# View logs
docker-compose logs -f [service]

# Rebuild image
docker-compose build --no-cache

# Clean everything (⚠️ deletes data)
docker-compose down -v
```

## Performance Optimizations

This setup includes:

- **MariaDB 11 Alpine**: 150MB vs 400MB MySQL, faster startup
- **PHP 8.4 Alpine**: Minimal base image, latest features
- **Solr 9 Alpine**: Optimized search engine
- **Connection pooling**: 100 max connections in MariaDB
- **Memory limits**: Optimized for typical library installations
- **Health checks**: Automatic service availability verification

## Resources

- 🔗 [Lukida Homepage](https://www.lukida.org/)
- 🔗 [Lukida GitHub](https://github.com/gbv/Lukida)
- 🔗 [MariaDB Documentation](https://mariadb.com/docs/)
- 🔗 [Docker Documentation](https://docs.docker.com/)

## License

This Docker setup follows the same license as Lukida.

## Support

For Lukida-specific questions: https://www.lukida.org/  
For Docker-specific questions: https://docs.docker.com/
