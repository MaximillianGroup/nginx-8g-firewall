# Quick Start Guide - 8G Firewall for Nginx

This guide will help you get the 8G Firewall running in 5 minutes.

## Prerequisites

- Nginx installed and running
- Root or sudo access
- Basic knowledge of Nginx configuration

## Installation (3 Steps)

### Step 1: Install the Firewall

**Option A: Using the install script (recommended)**

```bash
git clone https://github.com/MaximillianGroup/nginx-8g-firewall.git
cd nginx-8g-firewall
sudo ./install.sh
```

**Option B: Manual installation**

```bash
sudo mkdir -p /etc/nginx/snippets
sudo cp nginx/snippets/firewall.conf /etc/nginx/snippets/8g-firewall.conf
```

> **Which file?** The repository contains two configuration files:
>
> | File | Include in | Description |
> |------|-----------|-------------|
> | `nginx/snippets/firewall.conf` | `http {}` block | **Recommended** — map-based, includes rate limiting & security headers |
> | `nginx/snippets/8G_firewall.conf` | `server {}` block | Alternative — direct if-based port of original Apache rules |
>
> See [README.md](README.md) for a full comparison.

### Step 2: Update Your Nginx Configuration

Edit your main nginx.conf file:

```bash
sudo nano /etc/nginx/nginx.conf
```

Add this line inside the `http {}` block:

```nginx
http {
    # ... other config ...
    
    include /etc/nginx/snippets/8g-firewall.conf;
    
    # ... rest of config ...
}
```

### Step 3: Activate in Your Server Block

Edit your site configuration (e.g., `/etc/nginx/sites-available/default`):

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    
    # Activate 8G Firewall
    limit_conn 8g_conn 20;
    limit_req zone=8g_global burst=50 nodelay;
    
    if ($block_all) {
        return 444;
    }
    
    # Your existing configuration
    location / {
        root /var/www/html;
        index index.html;
    }
}
```

## Test and Apply

1. **Test the configuration:**
   ```bash
   sudo nginx -t
   ```

2. **If test passes, reload Nginx:**
   ```bash
   sudo systemctl reload nginx
   ```

## Verify It's Working

### Test 1: Normal Request (should work)

**Note:** curl is blocked by default in the firewall. Use a web browser or temporarily comment out the curl blocking in `nginx/snippets/firewall.conf` for testing.

```bash
# Option 1: Use a web browser to visit your domain
# Open https://your-domain.com in Firefox, Chrome, etc.

# Option 2: Temporarily allow curl for testing
# Edit /etc/nginx/snippets/8g-firewall.conf and comment out the curl line:
# "~*(?i)(curl|wget|python-requests|libwww-perl|go-http-client|axios)" 1;
# Then reload nginx: sudo systemctl reload nginx
# After testing, uncomment the line to restore full protection
```

### Test 2: Malicious Pattern (should be blocked)

Use a browser's developer console or a tool that's not blocked:

```bash
# Visit these URLs in a web browser - they should be blocked:
# https://your-domain.com/?q=<script>alert(1)</script>
# https://your-domain.com/?union+select+1,2,3

# Or use wget (if not blocked) to test:
wget "https://your-domain.com/?q=<script>alert(1)</script>"
```

### Test 3: Check Logs
```bash
# If you enabled logging, check blocked requests
sudo tail -f /var/log/nginx/8g-blocked.log
```

## Common Configurations

### WordPress Site

```nginx
server {
    listen 443 ssl http2;
    server_name wordpress-site.com;
    root /var/www/wordpress;
    
    # 8G Firewall activation
    limit_conn 8g_conn 20;
    limit_req zone=8g_global burst=50 nodelay;
    
    if ($block_all) {
        return 444;
    }
    
    # Extra protection for wp-login
    location = /wp-login.php {
        limit_req zone=8g_login burst=3 nodelay;
        
        fastcgi_pass unix:/run/php-fpm/www.sock;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/run/php-fpm/www.sock;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

### Static Website

```nginx
server {
    listen 443 ssl http2;
    server_name static-site.com;
    root /var/www/static;
    
    # 8G Firewall activation
    limit_conn 8g_conn 20;
    limit_req zone=8g_global burst=50 nodelay;
    
    if ($block_all) {
        return 444;
    }
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 30d;
        add_header Cache-Control "public";
    }
}
```

### API Server

```nginx
server {
    listen 443 ssl http2;
    server_name api.example.com;
    
    # Stricter limits for API
    limit_conn 8g_conn 10;
    limit_req zone=8g_global burst=20 nodelay;
    
    if ($block_all) {
        return 444;
    }
    
    location /api/ {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Troubleshooting

### Problem: Legitimate Requests Blocked

**Solution:** Check the logs to see what triggered the block:
```bash
sudo tail -100 /var/log/nginx/8g-blocked.log
```

Then adjust the corresponding rule in `/etc/nginx/snippets/8g-firewall.conf`

### Problem: Configuration Test Fails

**Solution:** Check for syntax errors:
```bash
sudo nginx -t
```

Common issues:
- Forgot to close brackets `{}`
- Missing semicolons `;`
- Typos in variable names
- Included `firewall.conf` inside `server {}` instead of `http {}` (map directives are http-level only)

### Problem: Firewall Not Blocking Attacks

**Solution:** Make sure you added the `if ($block_all)` block in your server configuration.

## Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Review [nginx/nginx.conf](nginx/nginx.conf) for a complete example configuration
- Customize the firewall rules in `nginx/snippets/firewall.conf` for your specific needs
- Enable logging to monitor blocked requests
- Set up rate limiting appropriate for your traffic patterns

## Support

- **GitHub Issues**: Report bugs or ask questions
- **Documentation**: See README.md for full details
- **Original 8G Firewall**: https://perishablepress.com/8g-firewall/

## Security Tips

1. **Keep Nginx Updated**: Always run the latest stable version
2. **Enable HTTPS**: Use SSL/TLS certificates (Let's Encrypt is free)
3. **Monitor Logs**: Regularly check for suspicious activity
4. **Backup Configs**: Keep backups before making changes
5. **Test Changes**: Always run `nginx -t` before reloading

---

**Important**: The 8G Firewall is one layer of security. Use it as part of a comprehensive security strategy including:
- Regular software updates
- Strong passwords
- Database security
- File permissions
- Intrusion detection
- Regular backups
