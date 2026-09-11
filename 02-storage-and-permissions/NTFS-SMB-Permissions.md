# Enterprise Storage & Access Control Matrix (AGDLP & ABE)

## Overview
This document outlines the zero-trust permissions architecture deployed across enterprise file shares using the **AGDLP** (Account -> Global Group -> Domain Local Group -> Permission) framework and **Access-Based Enumeration (ABE)**.

---

## Permission Architecture Matrix

| Folder Path | Global Group | Domain Local Group | NTFS Permission | SMB Share Permission |
| :--- | :--- | :--- | :--- | :--- |
| `\\DC01\Shares$\Engineering` | `GRP_Engineering` | `DLG_Engineering_Modify` | Modify / Read & Execute | Full Control (`Authenticated Users`) |
| `\\DC01\Shares$\Finance` | `GRP_Finance` | `DLG_Finance_Modify` | Modify / Read & Execute | Full Control (`Authenticated Users`) |
| `\\DC01\Shares$\HR` | `GRP_HR` | `DLG_HR_Modify` | Modify / Read & Execute | Full Control (`Authenticated Users`) |
| `\\DC01\Shares$\IT` | `GRP_IT` | `DLG_IT_FullControl` | Full Control | Full Control (`Authenticated Users`) |

---

## Access-Based Enumeration (ABE) Policy
- **Feature:** Access-Based Enumeration is enabled on `Shares$`.
- **Enforcement:** Users only see folders and files for which they explicitly hold read permissions. Unauthorized department folders are hidden from view completely to minimize administrative visibility.
