# 8G Firewall for Nginx

An Nginx implementation of the [8G Firewall](https://perishablepress.com/8g-firewall/) by [Perishable Press](https://perishablepress.com/). This provides robust, server-level protection against common web attacks and malicious traffic.

## About

The 8G Firewall is a powerful security ruleset created by Jeff Starr (Perishable Press) to protect web servers from various online threats. This repository contains an Nginx-compatible version that can be easily included in your existing Nginx configuration.

## Features

The 8G Firewall protects against:

- **SQL Injection (SQLi)** - Blocks common SQL injection patterns
- **Cross-Site Scripting (XSS)** - Prevents JavaScript injection attempts
- **Remote Code Execution (RCE)** - Stops shell command injection
- **Directory Traversal** - Blocks attempts to access sensitive files
- **Bad Bots & Scanners** - Identifies and blocks malicious user agents
- **Spam Referrers** - Filters suspicious referrer domains
- **Dangerous HTTP Methods** - Blocks TRACE, TRACK, and other risky methods
- **Rate Limiting** - Prevents brute force and DoS attacks
- **Security Headers** - Adds modern security headers to responses

## Installation

### 1. Download the Firewall

Clone this repository or download the `8g-firewall.conf` file:

```bash
git clone https://github.com/MaximillianGroup/nginx-8g-firewall.git
cd nginx-8g-firewall
```

### 2. Copy to Nginx Directory

```bash
sudo cp 8g-firewall.conf /etc/nginx/
```

### 3. Include in Nginx Configuration

Add the following line to your `nginx.conf` file inside the `http {}` block:

```nginx
http {
    # ... other configurations ...
    
    # Include 8G Firewall
    include /etc/nginx/8g-firewall.conf;
    
    # ... rest of your configuration ...
}
```

### 4. Activate in Server Blocks

Add the blocking logic to your server blocks:

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    
    # Apply rate limiting
    limit_conn 8g_conn 20;
    limit_req zone=8g_global burst=50 nodelay;
    
    # Block malicious requests
    if ($block_all) {
        return 444;  # Close connection without response
    }
    
    # Optional: Block bad bots explicitly
    if ($bad_bot = 1) {
        return 444;
    }
    
    # Optional: Block bad referers with 403
    if ($block_referer = 1) {
        return 403;
    }
    
    # Your normal location blocks
    location / {
        root /var/www/html;
        index index.html;
    }
}
```

### 5. Test Configuration

Before reloading Nginx, test the configuration:

```bash
sudo nginx -t
```

### 6. Reload Nginx

If the test is successful, reload Nginx:

```bash
sudo systemctl reload nginx
```

## Usage Examples

### Protect WordPress Login

Add stricter rate limiting for WordPress login pages:

```nginx
location = /wp-login.php {
    limit_req zone=8g_login burst=3 nodelay;
    
    fastcgi_pass unix:/run/php-fpm/www.sock;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}
```

### Protect Admin Areas

```nginx
location ^~ /admin/ {
    # Require authentication
    auth_basic "Admin Area";
    auth_basic_user_file /etc/nginx/.htpasswd;
    
    # Apply firewall rules
    if ($block_all) {
        return 444;
    }
    
    # Your PHP or proxy configuration
    try_files $uri $uri/ /admin/index.php?$query_string;
}
```

### Custom IP Blocking

Add your own IP blocks in the `8g-firewall.conf` file:

```nginx
geo $blocked_ip {
    default 0;
    # Block specific IPs or ranges
    192.0.2.123 1;
    203.0.113.0/24 1;
}
```

## Configuration Options

### Rate Limiting Zones

The firewall creates three rate limiting zones:

- `8g_global` - 10 requests/second per IP (global baseline)
- `8g_login` - 2 requests/second per IP (for login pages)
- `8g_conn` - Connection limit per IP

Adjust these in `8g-firewall.conf` if needed:

```nginx
limit_req_zone $binary_remote_addr zone=8g_global:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=8g_login:10m rate=2r/s;
```

### Logging

Blocked requests are logged to `/var/log/nginx/8g-blocked.log` by default. To disable:

```nginx
# Comment out this line in 8g-firewall.conf
# access_log /var/log/nginx/8g-blocked.log blocked_8g if=$block_all;
```

### Security Headers

Security headers are enabled by default. To customize, edit the headers section in `8g-firewall.conf`:

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
# ... customize as needed
```

## Customization

### Allow Specific User Agents

If legitimate tools are being blocked, modify the `$bad_bot` map:

```nginx
map $http_user_agent $bad_bot {
    default 0;
    # Comment out tools you want to allow
    # "~*(?i)curl" 1;  # Allow curl
    "~*(?i)nikto" 1;    # Still block nikto
}
```

### Whitelist IPs

Create a whitelist before the firewall rules:

```nginx
geo $whitelisted_ip {
    default 0;
    192.0.2.100 1;  # Your trusted IP
}

# Then modify blocking logic
# Use a helper variable to avoid nested if-statements (not supported in Nginx)
set $block_request 0;

if ($block_all) {
    set $block_request 1;
}

# Whitelisted IPs bypass the block
if ($whitelisted_ip) {
    set $block_request 0;
}

if ($block_request) {
    return 444;
}
```

## Troubleshooting

### False Positives

If legitimate requests are being blocked:

1. Check `/var/log/nginx/8g-blocked.log` to see what triggered the block
2. Review the specific map that caused the block
3. Adjust the regex patterns or comment out overly aggressive rules

### Testing

Test specific patterns:

```bash
# Test for blocked user agent
curl -A "sqlmap" https://example.com

# Test for blocked query string
curl "https://example.com/?q=<script>alert(1)</script>"
```

### Performance

The 8G Firewall is lightweight and uses Nginx's efficient map and geo modules. Typical overhead is negligible (< 1ms per request).

## Credits

- **Original 8G Firewall**: [Jeff Starr](https://perishablepress.com/) @ [Perishable Press](https://perishablepress.com/8g-firewall/)
- **Nginx Implementation**: This repository

## License

MIT License - See [LICENSE](LICENSE) file for details.

The 8G Firewall rules are based on the work by Jeff Starr (Perishable Press). Please maintain attribution when using or redistributing.

## Contributing

Contributions are welcome! Please submit pull requests or open issues for:

- Additional security patterns
- Performance improvements
- Documentation enhancements
- Bug fixes

## Disclaimer

This firewall provides a strong layer of security but should be part of a comprehensive security strategy. Always keep your software updated and follow security best practices.

## Resources

- [Official 8G Firewall](https://perishablepress.com/8g-firewall/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

## Support

For issues specific to this Nginx implementation, please open an issue on GitHub.

For questions about the original 8G Firewall, visit [Perishable Press](https://perishablepress.com/8g-firewall/).
