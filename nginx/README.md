8G Firewall for Nginx (Port v1.5)
=================================

This repository contains the **Nginx** port of the famous [8G Firewall](https://www.google.com/url?sa=E&q=https%3A%2F%2Fperishablepress.com%2F8g-firewall%2F) by Perishable Press.

The original firewall is written for Apache (.htaccess). This version has been translated, optimized, and formatted specifically for Nginx server blocks.

This Nginx version is a near lossless converstion of the apache2 8G FIREWALL by Perishable Press. Firewall runs at the edge (NGINX) before requests reach Varnish or backend.

📋 Conversion Methodology
-------------------------

Converting Apache mod_rewrite rules to Nginx is not a 1:1 process due to architectural differences. Apache processes rules sequentially and handles conditional logic natively. Nginx prefers static configurations and discourages excessive use of if statements (often referred to as ["If Is Evil"](https://www.google.com/url?sa=E&q=https%3A%2F%2Fwww.nginx.com%2Fresources%2Fwiki%2Fstart%2Ftopics%2Fdepth%2Fifisevil%2F)).

### 1\. Logic Translation

-   **Apache:** Uses RewriteCond (Condition) followed by RewriteRule (Action).

    -   **Nginx:** Uses if ($variable ~* "regex") { return 403; }.

### 2\. Optimization (Crucial)

In the original Apache file, there are over 100 separate conditions. In Nginx, having 100 separate if blocks triggers significant performance degradation.

-   **Change:** Instead of 100+ separate if statements, the rules have been consolidated using the RegEx | (OR) operator.

    -   **Result:** The logic is condensed into approximately 15 optimized blocks, reducing server overhead while maintaining the exact same security patterns.

### 3\. Directives Mapping

Specific Apache directives were mapped to their Nginx equivalents:

| Apache Directive     | Nginx Equivalent   | Function                   |
|----------------------|--------------------|----------------------------|
| ServerSignature Off  | server_tokens off; | Hides server version info  |
| Options -Indexes     | autoindex off;     | Prevents directory listing |
| RewriteRule .* - [F] | return 403;        | Returns "Forbidden" status |
| [NC] flag            | ~* operator        | Case-insensitive matching  |
| [OR] flag            | \| pipe character  | Logical OR within Regex    |


⚠️ Key Differences & Limitations
--------------------------------

### 1\. REMOTE_HOST (Reverse DNS)

-   **Apache:** Can easily filter by REMOTE_HOST (e.g., blocking *.amazonaws.com).

    -   **Nginx:** Nginx does **not** populate the $host variable with the client's hostname by default. It only contains the server's domain name.

    -   **The Change:** The REMOTE_HOST section has been **commented out** in this port.

    -   **Reason:** Enabling this in Nginx requires setting hostname_lookups on;, which forces a Reverse DNS lookup for every incoming connection. This causes severe latency and performance issues. It is recommended to block these via IP ranges (GeoIP) or Firewall (iptables/UFW) instead.

### 2\. Variable Names

Nginx uses different internal variable names:

```

-   %{QUERY_STRING} 

     $query_string-   %{REQUEST_URI} 

     $request_uri-   %{HTTP_USER_AGENT} 

     $http_user_agent-   %{HTTP_REFERER} 

     $http_referer-   %{HTTP_COOKIE} 


     $http_cookie

```

### 3\. Syntax Improvements

The original translation attempt contained syntax errors (incomplete if blocks and typos like $http_user_ag#ent). These have been corrected to ensure the configuration passes nginx -t.

🚀 Usage
--------

### Step 1: Create the File

Create a file named 8g-firewall.conf in your Nginx configuration directory (usually /etc/nginx/conf.d/ or /etc/nginx/snippets/).

### Step 2: Include in Server Block

Open your website's configuration file (e.g., /etc/nginx/sites-available/example.com) and include the file inside the server block:

codeNginx

```
server {
    listen 80;
    server_name example.com;

    # Include the 8G Firewall
    include /etc/nginx/snippets/8g-firewall.conf;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

### Step 3: Test and Reload

Always test your configuration before reloading:

codeBash

```
sudo nginx -t
sudo systemctl reload nginx
```

⚖️ License & Credits
--------------------

-   **Original 8G Firewall:** Copyright © Jeff Starr ([Perishable Press](https://www.google.com/url?sa=E&q=https%3A%2F%2Fperishablepress.com%2F)).

    -   **Nginx Port:** Adapted by Starisian Technologies (2026).

Disclaimer: This firewall script is provided "as is". While it filters common malicious patterns, always test in a staging environment to ensure it does not block legitimate traffic for your specific application.




# Limitations

8G Firewall is:

- Not a behavioral firewall
- Not a bot mitigation system
- Not rate limiting
- Not DDoS protection
- Not a replacement for Fail2Ban / Cloudflare WAF

It is a **signature-based request firewall**.

---

# Optional Enhancements

If desired, this NGINX near lossless version can be extended and enhanced for performance with:

- Map-based high-performance filtering
- Cloudflare trust chain integration
- AI bot blocking lists
- GeoIP filtering
- Request-rate throttling
- Real-IP enforcement
- Abuse logging
- Adaptive false-positive tuning

---

# Version

NGINX Port aligned with:

**8G Firewall v1.5 (2025-09-27)**

---

# Credits

Original Apache firewall by:

**Jeff Starr — Perishable Press**  
https://perishablepress.com/

NGINX port adapted for reverse-proxy architecture and PCRE behavior differences.

---

# License

Refer to original 8G Firewall licensing terms from Perishable Press.
