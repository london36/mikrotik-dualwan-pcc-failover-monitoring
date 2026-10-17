# Dual-WAN PCC, Script-Free Failover & ISP Monitoring on RouterOS 7 — A Home Network Case Study

**Configuration, architecture and test notes:** [GitHub — london36/mikrotik-dualwan-pcc-failover-monitoring](https://github.com/london36/mikrotik-dualwan-pcc-failover-monitoring)

In 2022, with seven or eight people working remotely at home, I added a second ISP after repeated disruptions. I learned RouterOS from community resources, with **a valuable knowledge boost from a [Redes Brasil](https://www.redesbrasil.com) training course** in June 2024. More recently I revisited the design with help from ChatGPT, Claude and Grok. Their suggestions were useful, but not always correct: practical testing was indispensable.

**Environment:** MikroTik hEX S / RouterOS 7.24.5; Claro 500 Mbps via DHCP and Vivo 500 Mbps via PPPoE, both modems bridged; two Deco BE63 access points with Ethernet backhaul. The MikroTik provides LAN DHCP, NAT, firewall and policy routing.

### The Goal: Simple, Script-Free Failover

Our primary goal was to achieve reliable, automatic failover **without relying on scripts to switch between ISPs**. After several unsuccessful iterations with script-based approaches, we found a simple and elegant solution using dedicated routing tables with primary and backup routes, controlled by route distances. The **cross-backup design** means that ISP1 backs up ISP2, and vice versa.

Standard PCC connection marking through Mangle works alongside this setup, directing connections to their respective routing tables. We chose the `both-addresses:2/0` and `2/1` classifiers for our relatively small home network: connections between the same client and destination IP generally remain on the same WAN, reducing potential issues with security-sensitive sites such as banks. When a preferred route becomes unavailable, RouterOS can use the backup route without scripts modifying routes or connection marks.

### Independent ISP Monitoring

Separately, we use two ISP-pinned Netwatch probes per WAN and a lightweight aggregator to confirm outages and record DOWN, UP and approximate duration. General DHCP, PPPoE and interface events are logged separately; both sets of rotating text logs are stored on USB. **Neither the monitoring script nor the logs controls routing or triggers failover.**

We validated probe failures with temporary blackhole routes and tested physical cable disconnect/reconnect. **Limitation:** an upstream outage with a reachable local ISP gateway can be logged without causing automatic route failover; existing connections can be interrupted after WAN changes.

The linked repository contains the sectioned configuration reference, test evidence, architecture and limitations. It is **not a paste-and-run installer**: hardware interfaces, credentials and USB paths need review and adaptation.

I'd welcome feedback on this minimalist approach to dual-WAN failover and independent observability.
