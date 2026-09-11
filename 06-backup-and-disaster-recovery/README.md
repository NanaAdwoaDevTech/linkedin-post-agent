# Backup & Disaster Recovery Strategy

## RTO & RPO Objectives
- **Recovery Time Objective (RTO):** 4 Hours
- **Recovery Point Objective (RPO):** 24 Hours

## Backup Policies
1. **Domain Controllers:** Daily System State backups via `SystemStateBackup.ps1` targeting dedicated local volumes.
2. **Container Volumes:** Nightly BorgBackup archive tasks for Docker persistent storage (`04-web-services`).
