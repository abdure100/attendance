# Fix Server File Permission Error

## Error Message
```
file_put_contents(/var/www/adc/config/database_connections.php):
Failed to open stream: Permission denied
```

## Problem
The web server (usually `www-data` or `apache` user) doesn't have write permissions to the configuration file.

## Solution: Fix File Permissions

### Option 1: Fix Permissions via SSH (Recommended)

**SSH into your server and run:**

```bash
# Navigate to the config directory
cd /var/www/adc/config

# Set proper ownership (replace 'www-data' with your web server user if different)
sudo chown www-data:www-data database_connections.php

# Set proper permissions (read/write for owner, read for group/others)
sudo chmod 644 database_connections.php

# If the directory also needs write access:
sudo chown -R www-data:www-data /var/www/adc/config
sudo chmod -R 755 /var/www/adc/config
```

### Option 2: Make File Writable by Web Server

```bash
# Make the file writable by the web server user
sudo chmod 666 database_connections.php

# Or more secure (only owner can write):
sudo chmod 664 database_connections.php
sudo chown www-data:www-data database_connections.php
```

### Option 3: Set Directory Permissions

```bash
# Make the entire config directory writable
sudo chmod -R 775 /var/www/adc/config
sudo chown -R www-data:www-data /var/www/adc/config
```

## Find Your Web Server User

**Check which user runs your web server:**

```bash
# For Apache
ps aux | grep apache | head -1

# For Nginx
ps aux | grep nginx | head -1

# Or check the process
ps aux | grep -E 'apache|httpd|nginx' | grep -v grep
```

Common web server users:
- `www-data` (Ubuntu/Debian)
- `apache` (CentOS/RHEL)
- `nginx` (Nginx)
- `_www` (macOS)

## Verify the Fix

**After fixing permissions, test:**

```bash
# Check current permissions
ls -la /var/www/adc/config/database_connections.php

# Should show something like:
# -rw-rw-r-- 1 www-data www-data 1234 Dec  3 06:00 database_connections.php
```

## Alternative: Use Environment Variables

**Instead of writing to a file, consider using environment variables:**

1. Store database config in `.env` file
2. Load via environment variables
3. No file writing needed

## Security Best Practices

**Don't use overly permissive permissions:**

```bash
# ❌ BAD - Too open
chmod 777 database_connections.php

# ✅ GOOD - Secure
chmod 644 database_connections.php
chown www-data:www-data database_connections.php
```

## Quick Fix Command

**Run this on your server (replace `www-data` if needed):**

```bash
sudo chown www-data:www-data /var/www/adc/config/database_connections.php && \
sudo chmod 664 /var/www/adc/config/database_connections.php && \
echo "✅ Permissions fixed!"
```

## If You Don't Have SSH Access

**Contact your server administrator or hosting provider** to:
1. Fix file permissions on `/var/www/adc/config/database_connections.php`
2. Ensure the web server user has write access
3. Or configure the app to use environment variables instead

---

**After fixing permissions, try adding a user again. The error should be resolved.**

