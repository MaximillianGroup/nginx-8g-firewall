# 8G Firewall — Apache Source Archive

This directory contains the **original 8G Firewall files for Apache2**, exactly as obtained from **Perishable Press**.

**Source:** https://perishablepress.com/8g-firewall/  
**Downloaded:** February 17, 2026  

These files are preserved in their original Apache format and **have not been modified**.

---

## Purpose of This Archive

This directory serves as the **reference source** from which the NGINX implementation of the 8G Firewall in this project was derived.

The Apache version remains here for:

- Historical reference
- Regex and rule validation
- Security comparison
- Upgrade tracking when new 8G versions are released
- Verification of behavioral equivalence between Apache and NGINX ports

---

## Relationship to NGINX Version

The NGINX firewall included elsewhere in this project was **created by translating these Apache rules** into NGINX-compatible syntax while preserving:

- Security intent
- Pattern coverage
- Blocking behavior
- Threat categories

Because Apache `mod_rewrite` and NGINX process requests differently, the NGINX version is **functionally equivalent but not byte-identical**.

---

## Integrity Statement

These files represent the **original upstream Apache implementation** as provided by Perishable Press at the time of download.

No modifications, optimizations, or behavioral changes have been applied within this directory.

---

## Upstream Project

Original author: **Jeff Starr — Perishable Press**  
Project page: https://perishablepress.com/8g-firewall/

For licensing, updates, and official releases, refer to the upstream project.

---

## Version Reference

Corresponds to:

**8G Firewall v1.5 (2025-09-27)**

---

## Notes

- Do **not** edit files in this directory.
- Any modifications should be applied only to the NGINX port.
- When updating to a newer 8G release, retain this archive for comparison and change tracking.

---
