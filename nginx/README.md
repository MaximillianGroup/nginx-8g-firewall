8G Firewall for Nginx (Port v1.5)
=================================

This directory contains the **Nginx** port of the famous [8G Firewall](https://perishablepress.com/8g-firewall/) by Perishable Press.

The original firewall is written for Apache (.htaccess). This version has been translated, optimized, and formatted specifically for Nginx server blocks.

---

## Configuration Files

This directory provides **two configuration files**. Choose the one that fits your setup:

### `snippets/firewall.conf` — Recommended (map-based)

**Include location:** Inside the `http {}` block of your `nginx.conf`

> **Note:** The install script copies `nginx/snippets/firewall.conf` to `/etc/nginx/snippets/8g-firewall.conf`.
> The examples below use the installed path.

```nginx
http {
    include /etc/nginx/snippets/8g-firewall.conf;
}
```

**Then activate in each `server {}` block:**

```nginx
server {
    limit_conn 8g_conn 20;
    limit_req zone=8g_global burst=50 nodelay;

    if ($block_all) { return 444; }
}
```

This file uses Nginx's `map` and `geo` directives to define detection rules and a combined `$block_all` variable. It also includes:
- Rate-limiting zones (`limit_req_zone`, `limit_conn_zone`)
- Optional blocked-request logging
- Security headers (`X-Frame-Options`, `X-Content-Type-Options`, etc.)
- Geo-based IP blocking

Because `map` and `geo` directives are evaluated lazily, this approach performs better under heavy load.

> ⚠️ `map`, `geo`, and `limit_req_zone` are **http-context directives** — they cannot be placed inside a `server {}` block.

---

### `snippets/8G_firewall.conf` — Alternative (if-based)

**Include location:** Inside a `server {}` block

```nginx
server {
    listen 443 ssl;
    server_name example.com;

    include /etc/nginx/snippets/8G_firewall.conf;

    location / { ... }
}
```

This file is a near-lossless port of the original Apache 8G rules using sequential `if` blocks and `set` variables. It is self-contained and can be dropped directly into any `server {}` block — useful when you want per-virtual-host control.

> ⚠️ This file uses `set` and `if` directives which are **server/location-context only** — do not include it in the `http {}` block.

---

## Which file should I use?

| | `firewall.conf` | `8G_firewall.conf` |
|---|---|---|
| Include in | `http {}` | `server {}` |
| Approach | `map`/`geo` | `if`/`set` |
| Rate limiting | ✅ Built-in | ❌ Not included |
| Security headers | ✅ Built-in | ❌ Not included |
| Performance | ✅ Better (lazy eval) | Moderate |
| Per-vhost use | Apply `$block_all` per server | ✅ Drop-in per server |

For most deployments, **`firewall.conf` is recommended**.

---

## Conversion Methodology

Converting Apache `mod_rewrite` rules to Nginx is not a 1:1 process due to architectural differences. Apache processes rules sequentially and handles conditional logic natively. Nginx prefers static configurations and discourages excessive use of `if` statements (often referred to as ["If Is Evil"](https://www.nginx.com/resources/wiki/start/topics/depth/ifisevil/)).

### Logic Translation

- **Apache:** Uses `RewriteCond` (Condition) followed by `RewriteRule` (Action).
- **Nginx:** Uses `if ($variable ~* "regex") { return 403; }`.

### Optimization

In the original Apache file, there are over 100 separate conditions. In Nginx, having 100 separate `if` blocks triggers significant performance degradation.

- **Change:** Instead of 100+ separate `if` statements, the rules have been consolidated using the regex `|` (OR) operator.
- **Result:** The logic is condensed into approximately 15 optimized blocks, reducing server overhead while maintaining the exact same security patterns.

### Directives Mapping

Specific Apache directives were mapped to their Nginx equivalents:

| Apache Directive     | Nginx Equivalent   | Function                   |
|----------------------|--------------------|----------------------------|
| ServerSignature Off  | server_tokens off; | Hides server version info  |
| Options -Indexes     | autoindex off;     | Prevents directory listing |
| RewriteRule .* - [F] | return 403;        | Returns "Forbidden" status |
| [NC] flag            | ~* operator        | Case-insensitive matching  |
| [OR] flag            | \| pipe character  | Logical OR within Regex    |

---

## Key Differences & Limitations

### REMOTE_HOST (Reverse DNS)

- **Apache:** Can easily filter by `REMOTE_HOST` (e.g., blocking `*.amazonaws.com`).
- **Nginx:** Nginx does **not** populate `$host` with the client's hostname by default.
- **The Change:** The REMOTE_HOST section has been **commented out** in this port.
- **Reason:** Enabling this requires `hostname_lookups on;`, which forces a reverse DNS lookup for every incoming connection, causing severe latency. Use GeoIP or firewall rules (iptables/UFW) to block IP ranges instead.

### Variable Names

Nginx uses different internal variable names:

| Apache Variable    | Nginx Variable       |
|--------------------|----------------------|
| %{QUERY_STRING}    | $query_string        |
| %{REQUEST_URI}     | $request_uri         |
| %{HTTP_USER_AGENT} | $http_user_agent     |
| %{HTTP_REFERER}    | $http_referer        |
| %{HTTP_COOKIE}     | $http_cookie         |

---

## Limitations

8G Firewall is:

- Not a behavioral firewall
- Not a bot mitigation system
- Not rate limiting (firewall.conf adds rate limiting as an enhancement)
- Not DDoS protection
- Not a replacement for Fail2Ban / Cloudflare WAF

It is a **signature-based request firewall**.

---

## Optional Enhancements

If desired, this NGINX near-lossless version can be extended for performance with:

- Map-based high-performance filtering
- Cloudflare trust chain integration
- AI bot blocking lists
- GeoIP filtering
- Request-rate throttling
- Real-IP enforcement
- Abuse logging
- Adaptive false-positive tuning

---

## Version

NGINX Port aligned with:

**8G Firewall v1.5 (2025-09-27)**

---

## Credits

Original Apache firewall by:

**Jeff Starr — Perishable Press**
https://perishablepress.com/

NGINX port adapted for reverse-proxy architecture and PCRE behavior differences.

---

## License

Refer to original 8G Firewall licensing terms from Perishable Press.
