# Farm2Market API

## Endpoints

-   `GET /api/health`  
    Returns service status, version, timestamp, and uptime.

-   `GET /api/produce`  
    Returns all produce items.

## Configuration

Set PostgreSQL connection details in `Config.toml`:

```toml
[Farm2Market_backend.utils.db]
# Database host address
dbHost = "database_host"
# Database port number
dbPort = 5432
# Database username
dbUser = "database_username"
# Database password
dbPass = "database_password"
# Database name
dbName = "database_name"
```

### Usage

Run the service with:

```
bal run
```
