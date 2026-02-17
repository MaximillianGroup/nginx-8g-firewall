<img width="1280" height="640" alt="8g-firewall" src="https://github.com/user-attachments/assets/44627767-7764-4642-9e17-c939132c74a1" />

8G FIREWALL
for Nginx
=====================

An Nginx translation of the [8G Firewall v1.5](https://perishablepress.com/8g-firewall/) by Perishable Press --- originally written for Apache/.htaccess.

All 122 firewall rules have been translated 1:1 from Apache `mod_rewrite` directives into Nginx `if` blocks with `return 403`, preserving every regex pattern from the original.

What it blocks
--------------

| Section | Rules | Description |
| --- | --- | --- |
| Query String | 43 | SQL injection, XSS, path traversal, shell commands, PHP exploits |
| Request URI | 58 | Malicious scripts, backdoors, sensitive files, vulnerability scanners |
| User Agent | 14 | Bad bots, scrapers, attack tools, known malicious crawlers |
| Remote Host | 1 | Hosting providers commonly associated with attacks |
| HTTP Referrer | 4 | Referrer spam, injection attempts |
| HTTP Cookie | 1 | Cookie-based injection characters |
| Request Method | 1 | Disallowed HTTP methods (CONNECT, DEBUG, MOVE, TRACE, TRACK) |

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
