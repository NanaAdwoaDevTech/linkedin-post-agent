his repository contains the full Infrastructure-as-Code (IaC), automation scripts, and step-by-step configuration guides for a production-ready enterprise hybrid IT lab environment.

## Architecture Highlights
- **Identity & Access Management:** Automated Active Directory provisioning of users, OUs, and security groups via PowerShell.
- **Network & Perimeter Security:** pfSense virtual firewall with WireGuard Remote Access VPN.
- **Web Infrastructure & Containers:** Docker Compose stack with Nginx Reverse Proxy, Prometheus metrics collection, and Grafana dashboards.
- **Storage & Security:** AGDLP role-based permissions model for SMB shares and Access-Based Enumeration (ABE).
- **Disaster Recovery:** Automated Windows System State backup scripts and Docker volume archiving.

## Repository Index
- `01-active-directory/`: PowerShell onboarding script (`UserOnboarding.ps1`) & GPO guides.
- `02-storage-and-permissions/`: AGDLP permission matrices & SMB share rules.
- `03-network-and-vpn/`: WireGuard VPN & pfSense firewall rules.
- `04-web-services/`: `docker-compose.yml` for Nginx, Prometheus, & Grafana.
- `05-logging-and-monitoring/`: Observability stack configurations.
- `06-backup-and-disaster-recovery/`: Backup strategies & automation scripts.
