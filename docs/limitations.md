# Known limitations and non-goals

1. **No upstream-aware failover of production routes:** if the ISP gateway remains reachable but internet fails upstream, monitoring can log DOWN without forcing traffic onto the other provider.
2. **No bandwidth bonding:** PCC distributes connection hashes; it does not combine both ISPs into one higher-speed single flow.
3. **Session interruption:** an ISP switch may break existing NAT sessions.
4. **Not an exact detection SLA:** Netwatch and aggregator each run every 30 seconds; their schedules are independent and require confirmation.
5. **Uptime-derived durations:** reported outage durations are operational estimates and do not continue through a router restart.
6. **Installation-specific configuration:** interface names, addressing, IPv6 choice, MSS/MTU, firewall and USB paths require adaptation.
7. **Distinct signals:** link/gateway availability used for route selection is not the same as external internet reachability reported by Netwatch.

**The WANMON script only observes and logs. It does not switch routes.**
