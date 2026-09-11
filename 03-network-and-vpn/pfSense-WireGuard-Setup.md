# Secure Perimeter & WireGuard VPN Architecture

## Network Subnet Topology
- LAN Subnet: 192.168.10.0/24 (Domain Controllers & Internal Services)
- DMZ Subnet: 172.16.10.0/24 (Public Web Services & Nginx Proxy)
- WireGuard Tunnel Subnet: 10.0.100.0/24 (Remote Access Clients)

---

## WireGuard Client Profile Template (wg0.conf)

[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.0.100.2/32
DNS = 192.168.10.10

[Peer]
PublicKey = <PFSENSE_PUBLIC_KEY>
Endpoint = vpn.enterprise.com:51820
AllowedIPs = 192.168.10.0/24, 172.16.10.0/24
PersistentKeepalive = 25

---

## Firewall Rules Summary
- WAN Interface: Pass UDP 51820 (WireGuard Inbound).
- WireGuard Interface: Allow access to LAN DNS (192.168.10.10:53) and SMB (192.168.10.10:445).
