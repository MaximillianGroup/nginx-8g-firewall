# Nginx 8G FIREWALL

This Nginx version is a near lossless converstion of the apache2 8G FIREWALL by Perishable Press. Firewall runs at the **edge (NGINX)** before requests reach Varnish or backend.

---

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
