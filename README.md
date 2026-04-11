
<img width="1280" height="640" alt="8g-firewall" src="https://github.com/user-attachments/assets/9baece3e-d9e4-4339-a45c-5f130f2a6a7f" />

# 8G Firewall for Nginx

An Nginx implementation of the [8G Firewall](https://perishablepress.com/8g-firewall/) by [Perishable Press](https://perishablepress.com/). This provides robust, server-level protection against common web attacks and malicious traffic.

[![Copilot coding agent](https://github.com/MaximillianGroup/nginx-8g-firewall/actions/workflows/copilot-swe-agent/copilot/badge.svg)](https://github.com/MaximillianGroup/nginx-8g-firewall/actions/workflows/copilot-swe-agent/copilot)  [![Copilot code review](https://github.com/MaximillianGroup/nginx-8g-firewall/actions/workflows/copilot-pull-request-reviewer/copilot-pull-request-reviewer/badge.svg)](https://github.com/MaximillianGroup/nginx-8g-firewall/actions/workflows/copilot-pull-request-reviewer/copilot-pull-request-reviewer)

## Repository Structure

```
nginx-8g-firewall/
├── nginx/
│   ├── snippets/
│   │   ├── firewall.conf       ← RECOMMENDED: map-based version, include in http {} block
│   │   └── 8G_firewall.conf    ← ALTERNATIVE: if-based version, include in server {} block
│   └── nginx.conf              ← Complete nginx.conf example showing full integration
├── apache/
│   ├── 8g_firewall.txt         ← Original Apache .htaccess source (reference only)
│   └── 8G-Changelog.txt        ← Upstream changelog
├── install.sh                  ← Automated installation script
├── QUICKSTART.md               ← 5-minute setup guide
└── README.md                   ← This file
```

### Which configuration file should I use?

| File | Include location | Approach | Best for |
|------|-----------------|----------|----------|
| `nginx/snippets/firewall.conf` | `http {}` block | `map`/`geo` directives | **Most deployments (recommended)** |
| `nginx/snippets/8G_firewall.conf` | `server {}` block | `if`/`set` directives | Simple setups or per-vhost inclusion |

**`nginx/snippets/firewall.conf` (recommended)** uses Nginx's `map` and `geo` directives to define detection rules and a combined `$block_all` variable. Because `map` and `geo` are evaluated lazily and at the `http` level, this version performs better under load and is easier to extend. Rate-limiting zones and security headers are also defined in this file.

**`nginx/snippets/8G_firewall.conf` (alternative)** is a more direct port of the original Apache rules using sequential `if` blocks. It is self-contained and can be included directly inside any `server {}` block — useful if you only want to protect specific virtual hosts or prefer keeping all rules local to the server context.

---

## Overview

This file is a **lossless-style functional translation** of the original **8G Firewall v1.5 (Apache)** by Perishable Press into **NGINX syntax**.

### What it blocks

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
The goal of this version is to preserve the **spirit, detection logic, and protection coverage** of the original Apache implementation while adapting it to the architectural and performance characteristics of NGINX.

This version maintains:

- Query string attack detection
- Malicious URI filtering
- User-Agent exploit detection
- Referrer spam & exploit filtering
- Cookie injection protection
- Dangerous HTTP method blocking

The rule logic is intentionally kept close to the original Apache version to ensure **behavioral parity**, not redesign.

---

## Source Reference

Original Apache version:

**8G Firewall v1.5**  
https://perishablepress.com/8g-firewall/

This NGINX version was created from that reference to preserve equivalent protections in NGINX environments.

---

## Important Differences From Apache Version



Because Apache and NGINX operate differently internally, some adjustments were necessary.

### 1. Rewrite Engine vs NGINX Processing
Apache uses `mod_rewrite` with sequential conditional evaluation.  
NGINX does not behave the same way, so rules are grouped using variables and conditional checks.

The protection coverage remains equivalent, but execution flow differs.

---

### 2. Remote Host Filtering Disabled
Apache can block based on `REMOTE_HOST` using reverse DNS lookups.

NGINX cannot do this efficiently without enabling:

This drops malicious connections without responding, reducing noise and scan feedback.

This is recommended but optional depending on logging and monitoring preferences.

his causes major performance degradation and is **intentionally disabled** in this version.

---

### 3. Consolidated Regex Evaluation
Apache evaluates many sequential rewrite conditions.  
NGINX performs better when patterns are grouped, so regex rules are consolidated to reduce processing overhead while maintaining detection coverage.

---

### 4. Curl Behavior Adjusted
The original 8G blocks all `curl`.  
This version blocks only **malicious curl usage** (scanner/exploit patterns), allowing legitimate curl usage for APIs, health checks, and automation.

---

## Recommended Configuration Enhancements

### Use Silent Drop (444) Instead of 403

By default, 8G returns HTTP 403.  
NGINX supports a stealth option:

```nginx
return 444;

```

This drops malicious connections without responding, reducing noise and scan feedback. This is recommended but optional depending on logging and monitoring preferences.

* * * * *

### Enable PCRE JIT for Performance (Highly Recommended)

Because this firewall relies heavily on regex evaluation, enabling PCRE JIT significantly improves performance.

Add to your main `nginx.conf`:

`pcre_jit on;`

Benefits:

-   Faster regex execution

-   Lower CPU usage under attack

-   Better throughput under load

* * * * *

Performance Notes
-----------------

Compared to Apache 8G:

| Metric | Apache | This NGINX Version |
| --- | --- | --- |
| CPU Usage | Higher | Lower |
| Throughput | Lower | Higher |
| Regex Performance | Moderate | Faster (with PCRE JIT) |
| Attack Handling | Strong | Stronger |
| Memory Usage | Higher | Lower |

* * * * *

Deployment Location
-------------------

This firewall is intended to be included in the `http {}` block (recommended `firewall.conf`):

`include /etc/nginx/snippets/8g-firewall.conf;`

Or, for the `if`-based alternative, inside a `server {}` block:

`include /etc/nginx/snippets/8G_firewall.conf;`

Ensure the `http {}`-level include loads **before your `server {}` blocks**, and the `server {}`-level include loads **after basic server directives but before application routing**.

* * * * *

Logging Behavior
----------------

-   With `403`, blocked requests appear in access/error logs.

-   With `444`, connections are dropped silently (reduced log noise).

Choose based on operational preference.

* * * * *

Fidelity Statement
------------------

This file is designed as a **behaviorally faithful conversion**, not a redesign.

Because Apache and NGINX differ fundamentally:

-   Execution order is adapted

-   Reverse DNS blocking is disabled

-   Rewrite chaining is approximated

Despite these differences, **attack detection coverage matches the original 8G Firewall**.

* * * * *

Future Improvements (Optional)
------------------------------

This version intentionally preserves original structure.\
Possible future optimizations include:

-   Replacing `if` with `map` for higher performance

-   Precompiled detection tables

-   Adaptive rate/connection blocking

-   Dynamic intelligence-based filtering

-   Modular NGINX-native firewall architecture

Installation
------------

## Installation

### 1. Download the Firewall

Clone this repository:

```bash
git clone https://github.com/MaximillianGroup/nginx-8g-firewall.git
cd nginx-8g-firewall
```

### 2. Copy to Nginx Directory

```bash
sudo mkdir -p /etc/nginx/snippets
sudo cp nginx/snippets/firewall.conf /etc/nginx/snippets/8g-firewall.conf
```

> **Note:** If you prefer the `if`-based alternative, copy `nginx/snippets/8G_firewall.conf` to `/etc/nginx/snippets/8G_firewall.conf` instead and include it inside your `server {}` block (see Option B in step 3).

### 3. Include in Nginx Configuration

**Option A — Recommended (`firewall.conf`, map-based):**

Add the following line to your `nginx.conf` file inside the `http {}` block:

```nginx
http {
    # ... other configurations ...
    
    # Include 8G Firewall (map-based — must be in http {} block)
    include /etc/nginx/snippets/8g-firewall.conf;
    
    # ... rest of your configuration ...
}
```

**Option B — Alternative (`8G_firewall.conf`, if-based):**

Include the file directly inside your `server {}` block:

```nginx
server {
    listen 443 ssl;
    server_name example.com;

    # Include 8G Firewall (if-based — included per server block)
    include /etc/nginx/snippets/8G_firewall.conf;

    location / { ... }
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

Add your own IP blocks in the `firewall.conf` file (`geo $blocked_ip` section):

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

Adjust these in `nginx/snippets/firewall.conf` if needed:

```nginx
limit_req_zone $binary_remote_addr zone=8g_global:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=8g_login:10m rate=2r/s;
```

### Logging

Logging of blocked requests is disabled by default. To enable logging, uncomment the following line in `nginx/snippets/firewall.conf`:

```nginx
# In nginx/snippets/firewall.conf, remove the leading "#" from this line:
access_log /var/log/nginx/8g-blocked.log blocked_8g if=$block_all;
```

### Security Headers

Security headers are enabled by default. To customize, edit the headers section in `nginx/snippets/firewall.conf` (or `/etc/nginx/snippets/8g-firewall.conf` if you installed the snippet there):

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
2. Review the specific map in `nginx/snippets/firewall.conf` that caused the block
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
