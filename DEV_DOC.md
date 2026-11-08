# DEVELOPER DOCUMENTATION — Inception

## 1. Project overview

This project builds a multi-container infrastructure using Docker and Docker Compose.

The architecture is composed of the following services:

- **Nginx:** HTTPS web server and reverse proxy.
- **WordPress:** PHP-FPM application.
- **MariaDB:** relational database.
- **Redis:** WordPress object caching service.
- **FTP:** vsftpd server for accessing WordPress files.
- **Adminer:** database administration interface.
- **Mailpit:** SMTP testing service.

The containers communicate through a dedicated Docker bridge network named `Inception`.

The project is organized as follows:

```text
Inception/
├── Makefile
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── nginx/
        ├── wordpress/
        ├── mariadb/
        └── bonus/
            ├── redis/
            ├── ftp/
            ├── adminer/
            ├── static/
            └── mailpit/
```


Before building the project, install the following tools on the host machine:

- Linux environment.
- Docker Engine.
- Docker Compose plugin.
- GNU Make.
- Git.

Verify the installations:

```bash
docker --version
docker compose version
make --version
git --version
```

Docker must be running before launching the project.

## 3. Environment configuration

### 3.1 Environment file

Create the configuration file:

```bash
touch srcs/.env
```

The `.env` file contains the environment variables required by the services (*Check the .env.example for more informations*)

Configure all variables expected by the Dockerfiles, startup scripts and Compose file.

These include:

- Database name.
- Database users and passwords.
- MariaDB root password.
- WordPress administrator username, password and email.
- WordPress additional user credentials.
- Website domain name.
- FTP username and password.
- Mailpit version.

Use strong passwords and avoid committing real credentials to Git.

### 3.2 Mailpit build argument

The Docker Compose configuration uses `MAILPIT_VERSION` as a build argument.

Make sure this variable is defined in the environment configuration.

### 3.3 Host data directories

The persistent data directories must exist before starting the project.

The expected structure is:

```text
/home/<login>/data/
├── mariadb/
└── wordpress/
```

Replace `<login>` with the Linux username of the person running the project.

The Makefile creates these directories automatically when launching the project.

## 4. Building and launching the project

The Makefile is the main entry point for managing the infrastructure.

From the repository root:

```bash
make
```

This command:

1. Creates the host data directories.
2. Builds the Docker images.
3. Starts the containers in detached mode.

The Docker Compose configuration is located at:

```text
srcs/docker-compose.yml
```

The project can also be managed directly through Docker Compose:

```bash
docker compose -f srcs/docker-compose.yml up --build -d
```

To validate the Compose configuration before starting:

```bash
docker compose -f srcs/docker-compose.yml config
```

## 5. Managing containers

### Using the Makefile

The Makefile provides shortcuts for common operations:

```bash
make          # Build and start the project
make down     # Stop and remove containers
make stop     # Stop containers
make start    # Start existing containers
make logs     # Display service logs
make ps       # Display container status
make clean    # Remove containers and unused Docker resources
make fclean   # Full cleanup, including persistent data
make re       # Full cleanup followed by a new build
```

Check the actual Makefile before using destructive targets.

### Using Docker Compose directly

Start the infrastructure:

```bash
docker compose -f srcs/docker-compose.yml up -d
```

Rebuild and start:

```bash
docker compose -f srcs/docker-compose.yml up --build -d
```

Stop and remove containers:

```bash
docker compose -f srcs/docker-compose.yml down
```

Display running containers:

```bash
docker compose -f srcs/docker-compose.yml ps
```

Display logs:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

Display logs for a specific service:

```bash
docker compose -f srcs/docker-compose.yml logs -f wordpress
```

Access a container shell:

```bash
docker exec -it wordpress bash
```

Replace `wordpress` with the appropriate container name.

## 6. Managing Docker volumes

The project uses two named Docker volumes:

| Volume | Container mount point | Purpose |
|---|---|---|
| `mariadb_data` | `/var/lib/mysql` | Database persistence |
| `wordpress_data` | `/var/www/html` | WordPress persistence |

The WordPress volume is shared between the WordPress, Nginx and FTP services.

This allows Nginx to serve the website files and FTP to access the same WordPress directory.

### List volumes

```bash
docker volume ls
```

### Inspect a volume

```bash
docker volume inspect <volume_name>
```

### Inspect the data directories

```bash
sudo ls -la /home/<login>/data/
```

The data must persist independently of the lifecycle of the containers.

Removing and recreating containers must not delete the persistent data.

**Important:** do not use `docker compose down -v` or the full cleanup target unless you intentionally want to delete the volumes and their contents.

## 7. Networking

The project uses a dedicated Docker bridge network:

```yaml
networks:
  inception:
    driver: bridge
```

All services are connected to this network.

Docker's internal DNS allows containers to communicate using their service names.

Examples:

```text
wordpress -> mariadb:3306
wordpress -> redis:6379
wordpress -> mailpit:1025
nginx     -> wordpress:9000
ftp       -> wordpress shared volume
```

The internal service ports do not need to be published on the host for communication between containers on the same network.

Only the Nginx HTTPS port is published to the host in the current configuration:

```yaml
ports:
  - "443:443"
```

## 8. Service processes

Each container runs its main service in the foreground.

Examples:

| Service | Main process |
|---|---|
| Nginx | `nginx -g "daemon off;"` |
| WordPress | `php-fpm8.2 -F` |
| MariaDB | `mysqld` |
| Redis | `redis-server` |
| FTP | `vsftpd` |
| Adminer | PHP built-in web server |
| Mailpit | `mailpit` |

Startup scripts may perform initialization tasks before starting the main service.

They should finish by using `exec "$@"` when the command is provided through Docker's `CMD`.

This replaces the shell process with the actual service process and allows Docker to monitor it correctly.

Containers must not be kept alive using artificial infinite loops such as `tail -f`, `sleep infinity` or `while true`.

## 9. Troubleshooting

### Check container status

```bash
docker compose -f srcs/docker-compose.yml ps -a
```

### Inspect logs

```bash
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
docker compose -f srcs/docker-compose.yml logs nginx
```

### Check network configuration

```bash
docker network inspect inception
```

The actual network name may include the Compose project prefix.

### Check volume configuration

```bash
docker volume ls
docker volume inspect <volume_name>
```

### Rebuild a service

```bash
docker compose -f srcs/docker-compose.yml up --build -d <service_name>
```

## 10. Data persistence and cleanup

The persistent data is stored outside the containers.

The two storage locations are:

```text
/home/<login>/data/mariadb
/home/<login>/data/wordpress
```

This separation allows containers to be recreated without losing the database or website files.

Before performing a full cleanup, back up the data.

The `fclean` target is destructive and removes persistent project data according to the Makefile configuration.

A normal shutdown using:

```bash
make down
```

does not intentionally remove the persistent data.
