<img width="1280" height="640" alt="8g-firewall" src="https://github.com/user-attachments/assets/44627767-7764-4642-9e17-c939132c74a1" />

# 8G FIREWALL — NGINX Lossless Conversion

An Nginx translation of the [8G Firewall v1.5](https://perishablepress.com/8g-firewall/) by Perishable Press --- originally written for Apache/.htaccess.

## Overview

This file is a **lossless-style functional translation** of the original **8G Firewall v1.5 (Apache)** by Perishable Press into **NGINX syntax**.

### What it blocks

| Section | Rules | Description |
| --- | --- | --- |
| Query String | 43 | SQL injection, XSS, path traversal, shell commands, PHP exploits |
| Request URI | 58 | Malicious scripts, backdoors, sensitive files, vulnerability scanners |
| User Agent | 14 | Bad bots, scrapers, attack tools, known malicious crawlers |
| Remote Host | 1 | Hosting providers commonly associated with attacks |
| HTTP Referrer | 4 | Referrer spam, injection attempts |
| HTTP Cookie | 1 | Cookie-based injection characters |
| Request Method | 1 | Disallowed HTTP methods (CONNECT, DEBUG, MOVE, TRACE, TRACK) |

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

This firewall file is intended to be included inside a `server` block or via include:

`include /etc/nginx/firewall/8g-nginx.conf;`

Ensure it loads **after basic server directives but before application routing**.

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

1.  Copy `8g-firewall.conf` into your Nginx configuration directory (e.g. `/etc/nginx/`).

2.  Include it inside the appropriate `server` block:

    ```
    server {
        listen 80;
        server_name example.com;

        include /etc/nginx/8g-firewall.conf;

        # ... rest of your server config
    }

    ```

3.  Test the configuration:

    ```
    sudo nginx -t

    ```

4.  Reload Nginx:

    ```
    sudo systemctl reload nginx

    ```

Compatibility notes
-------------------

-   **Nginx `if` directive** --- Nginx's `if` is evaluated at a different phase than Apache's `RewriteCond`. The rules in this file use `if` within a `server` context, which is the supported pattern for simple `return` directives. See the [Nginx "if is evil" documentation](https://www.nginx.com/resources/wiki/start/topics/depth/ifisevil/) for caveats if you plan to combine these rules with other `if` or `try_files` logic.

-   **REMOTE_HOST** --- Apache's `%{REMOTE_HOST}` performs a reverse DNS lookup on the client IP. The Nginx translation uses `$host` (the request's Host header), which is not equivalent. To replicate the original behavior you would need a Lua module or an external reverse-DNS lookup. Depending on your threat model, this section may need adjustment or removal.

-   **Case sensitivity** --- All rules use case-insensitive matching (`~*`), matching the `[NC]` flag in the original Apache rules.

Customization
-------------

-   **Whitelisting** --- If a rule produces false positives, comment out or remove the specific `if` block. Each line is self-contained.
-   **Logging** --- To log blocked requests before returning 403, you can set a variable and use `access_log` with a custom format, or add an `error_log` directive at the appropriate level.
-   **AI bot blocking** --- The original 8G Firewall offers a companion [AI bot block list](https://perishablepress.com/ultimate-ai-block-list/). User-agent rules for AI crawlers can be added to the User Agent section following the same pattern.

Credits
-------

-   **Original firewall** --- [8G Firewall v1.5](https://perishablepress.com/8g-firewall/) by Jeff Starr / Perishable Press
-   **Nginx translation** --- MaximillianGroup (Max Barrett)
-   **License** --- MIT License
-   **Copyright** --- Copyright (c) 2026 MaximillianGroup (Max Barrett)
