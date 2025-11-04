# Complete Guide: Connecting to Databases from Terminal

This guide covers how to connect to the most common databases from the command line on Windows, macOS, and Linux.

---

## Table of Contents
1. [PostgreSQL](#postgresql)
2. [MySQL](#mysql)
3. [MariaDB](#mariadb)
4. [MongoDB](#mongodb)
5. [SQLite](#sqlite)
6. [Microsoft SQL Server](#microsoft-sql-server)
7. [Oracle Database](#oracle-database)

---

## PostgreSQL

### Installation Check
```bash
psql --version
```

### Basic Connection
```bash
psql -h hostname -p port -U username -d database_name
```

### Common Examples

**Connect to local database:**
```bash
psql -U postgres -d mydatabase
```

**Connect to remote database:**
```bash
psql -h 192.168.1.100 -p 5432 -U myuser -d production_db
```

**Connect using connection string:**
```bash
psql "postgresql://username:password@hostname:5432/database_name"
```

### Windows-Specific

**Using full path (if not in PATH):**
```powershell
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres
```

**Using SQL Shell:**
- Search for "SQL Shell (psql)" in Start menu
- Follow the prompts

### Common Commands Inside psql
```sql
\l                    -- List all databases
\c database_name      -- Connect to database
\dt                   -- List all tables
\d table_name         -- Describe table structure
\du                   -- List all users
\q                    -- Quit
SELECT * FROM table;  -- Query data
```

### Connection Parameters
- `-h` or `--host`: Server hostname (default: localhost)
- `-p` or `--port`: Port number (default: 5432)
- `-U` or `--username`: Username
- `-d` or `--dbname`: Database name
- `-W`: Force password prompt

---

## MySQL

### Installation Check
```bash
mysql --version
```

### Basic Connection
```bash
mysql -h hostname -P port -u username -p database_name
```

### Common Examples

**Connect to local database:**
```bash
mysql -u root -p
```

**Connect to specific database:**
```bash
mysql -u root -p mydatabase
```

**Connect to remote database:**
```bash
mysql -h 192.168.1.100 -P 3306 -u myuser -p production_db
```

**Connect with password in command (not recommended for security):**
```bash
mysql -u root -pMyPassword123 mydatabase
```

### Windows-Specific

**Using full path:**
```cmd
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p
```

**Add to PATH:**
Add `C:\Program Files\MySQL\MySQL Server 8.0\bin` to system PATH

### Common Commands Inside MySQL
```sql
SHOW DATABASES;              -- List all databases
USE database_name;           -- Switch to database
SHOW TABLES;                 -- List all tables
DESCRIBE table_name;         -- Show table structure
SHOW COLUMNS FROM table;     -- Show columns
SELECT USER();               -- Show current user
EXIT;                        -- Quit (or \q)
SELECT * FROM table;         -- Query data
```

### Connection Parameters
- `-h` or `--host`: Server hostname (default: localhost)
- `-P` or `--port`: Port number (default: 3306)
- `-u` or `--user`: Username
- `-p` or `--password`: Prompt for password
- `-D` or `--database`: Database name

---

## MariaDB

### Installation Check
```bash
mariadb --version
# or
mysql --version
```

### Basic Connection

MariaDB uses the same client as MySQL:

```bash
mariadb -h hostname -P port -u username -p database_name
# or
mysql -h hostname -P port -u username -p database_name
```

### Common Examples

**Connect to local database:**
```bash
mariadb -u root -p
```

**Connect to specific database:**
```bash
mariadb -u root -p mydatabase
```

### Commands
Same as MySQL (see MySQL section above)

---

## MongoDB

### Installation Check
```bash
mongosh --version
# or (older versions)
mongo --version
```

### Basic Connection

**Modern MongoDB (mongosh):**
```bash
mongosh "mongodb://hostname:port/database" --username user --password
```

### Common Examples

**Connect to local MongoDB:**
```bash
mongosh
```

**Connect to specific database:**
```bash
mongosh "mongodb://localhost:27017/mydatabase"
```

**Connect with authentication:**
```bash
mongosh "mongodb://username:password@localhost:27017/mydatabase"
```

**Connect to MongoDB Atlas (cloud):**
```bash
mongosh "mongodb+srv://cluster0.xxxxx.mongodb.net/myDatabase" --username myUser
```

### Windows-Specific

**Using full path:**
```cmd
"C:\Program Files\MongoDB\Server\7.0\bin\mongosh.exe"
```

### Common Commands Inside mongosh
```javascript
show dbs                     // List all databases
use database_name            // Switch to database
show collections             // List all collections (tables)
db.collection.find()         // Query all documents
db.collection.findOne()      // Query one document
db.collection.find().limit(10) // Limit results
exit                         // Quit
```

### Connection String Format
```
mongodb://[username:password@]host[:port][/database][?options]
```

---

## SQLite

### Installation Check
```bash
sqlite3 --version
```

### Basic Connection

**Connect to database file:**
```bash
sqlite3 /path/to/database.db
```

**Create new database:**
```bash
sqlite3 mydatabase.db
```

### Common Examples

**Connect to existing database:**
```bash
sqlite3 ./data/app.db
```

**Open in-memory database:**
```bash
sqlite3 :memory:
```

### Windows-Specific

**Using full path:**
```cmd
sqlite3.exe C:\path\to\database.db
```

### Common Commands Inside SQLite
```sql
.databases               -- List all databases
.tables                  -- List all tables
.schema table_name       -- Show table schema
.headers on              -- Show column headers
.mode column             -- Better column display
.quit                    -- Exit (or .exit)
SELECT * FROM table;     -- Query data
```

### Useful Settings
```sql
.headers on
.mode column
.width auto
```

---

## Microsoft SQL Server

### Installation Check
```bash
sqlcmd -?
```

### Basic Connection

**Using sqlcmd:**
```bash
sqlcmd -S server_name -d database_name -U username -P password
```

### Common Examples

**Connect with Windows Authentication:**
```cmd
sqlcmd -S localhost -d mydatabase -E
```

**Connect with SQL Authentication:**
```cmd
sqlcmd -S localhost -d mydatabase -U sa -P MyPassword123
```

**Connect to named instance:**
```cmd
sqlcmd -S localhost\SQLEXPRESS -d mydatabase -E
```

**Connect to remote server:**
```cmd
sqlcmd -S 192.168.1.100,1433 -d mydatabase -U myuser -P password
```

### Windows-Specific

**Using full path:**
```cmd
"C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S localhost -E
```

### Common Commands Inside sqlcmd
```sql
SELECT name FROM sys.databases;          -- List databases
GO                                       -- Execute batch
USE database_name;                       -- Switch database
GO
SELECT * FROM sys.tables;                -- List tables
GO
SELECT * FROM table_name;                -- Query data
GO
EXIT                                     -- Quit
```

### Connection Parameters
- `-S`: Server name or IP (with optional port)
- `-d`: Database name
- `-U`: Username (SQL Authentication)
- `-P`: Password (SQL Authentication)
- `-E`: Use Windows Authentication
- `-Q`: Execute query and exit

---

## Oracle Database

### Installation Check
```bash
sqlplus -v
```

### Basic Connection

**Using SQL*Plus:**
```bash
sqlplus username/password@hostname:port/service_name
```

### Common Examples

**Connect to local database:**
```bash
sqlplus system/password@localhost:1521/ORCLPDB
```

**Connect as SYSDBA:**
```bash
sqlplus / as sysdba
```

**Connect with Easy Connect:**
```bash
sqlplus username/password@//hostname:port/service_name
```

**Connect using TNS:**
```bash
sqlplus username/password@TNS_ALIAS
```

### Windows-Specific

**Using full path:**
```cmd
"C:\app\oracle\product\19c\dbhome\bin\sqlplus.exe" username/password
```

### Common Commands Inside SQL*Plus
```sql
SELECT username FROM all_users;          -- List users
SELECT table_name FROM user_tables;      -- List tables
DESCRIBE table_name;                     -- Show table structure
SELECT * FROM table_name;                -- Query data
CONNECT username/password;               -- Change connection
EXIT;                                    -- Quit
```

### Useful SQL*Plus Settings
```sql
SET LINESIZE 200
SET PAGESIZE 100
SET SERVEROUTPUT ON
```

---

## Quick Reference Table

| Database | Default Port | Command | Default User |
|----------|--------------|---------|--------------|
| PostgreSQL | 5432 | `psql` | postgres |
| MySQL | 3306 | `mysql` | root |
| MariaDB | 3306 | `mariadb`/`mysql` | root |
| MongoDB | 27017 | `mongosh` | (none) |
| SQLite | N/A | `sqlite3` | (none) |
| SQL Server | 1433 | `sqlcmd` | sa |
| Oracle | 1521 | `sqlplus` | system |

---

## Troubleshooting Common Issues

### Command Not Found
- **Windows**: Add database bin directory to PATH or use full path
- **macOS/Linux**: Install client tools or check if service is running

### Connection Refused
- Check if database service is running
- Verify firewall settings
- Confirm correct hostname and port

### Authentication Failed
- Verify username and password
- Check user permissions
- Ensure user has access to specific database

### Permission Denied
- Run with appropriate privileges
- Check database user permissions
- Verify file permissions (for SQLite)

---

## Security Best Practices

1. **Never store passwords in scripts or command history**
2. **Use environment variables for credentials**
3. **Use connection configuration files when possible**
4. **Always use SSL/TLS for remote connections**
5. **Limit user permissions to minimum required**
6. **Use connection pooling in applications**
7. **Regularly update database client tools**

---

## Additional Resources

- PostgreSQL: https://www.postgresql.org/docs/
- MySQL: https://dev.mysql.com/doc/
- MariaDB: https://mariadb.com/kb/
- MongoDB: https://docs.mongodb.com/
- SQLite: https://www.sqlite.org/docs.html
- SQL Server: https://docs.microsoft.com/sql/
- Oracle: https://docs.oracle.com/database/

---

*Last Updated: November 2025*