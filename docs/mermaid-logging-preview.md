# Diagram 4 — Router Events & WAN Outage Logs (preview)

**Purpose: Pure observability and troubleshooting.**

The two logging flows are independent. Neither log controls route selection or failover.

```mermaid
flowchart TB
    E["RouterOS events<br/>Interfaces · DHCP · PPPoE"]
    F["Logging filters<br/>Exclude debug with !debug"]
    G["General event log<br/>router-events"]
    W["WANMON aggregator<br/>Confirmed ISP DOWN / UP"]
    R["Outage records<br/>WAN status · Approx. duration"]
    U1["USB text files<br/>Rotating general log"]
    U2["USB text files<br/>Rotating outage log"]

    E --> F
    F --> G
    G --> U1

    W --> R
    R --> U2

    classDef neutral fill:#edf0f4,stroke:#68788c,color:#202b38
    classDef general fill:#e6f1ff,stroke:#2474c7,color:#173d66
    classDef outage fill:#fff4e6,stroke:#c67a1b,color:#694409
    classDef storage fill:#e7f6ec,stroke:#299653,color:#185a33
    class E,F,G general
    class W,R outage
    class U1,U2 storage
```

## Notes

- **General events:** RouterOS interface, DHCP, and PPPoE logs with `!debug` topic exclusions, stored as rotating text files under `usb1-part1/router-events`.
- **WAN outage records:** WANMON writes confirmed ISP DOWN/UP events and approximate durations to rotating text files under `usb1-part1/wan-outages`.
- **Storage:** USB is a simple persistence choice, not a requirement of monitoring or failover. A suitable internal disk location can be used instead.
- **Purpose: Pure observability and troubleshooting.** These records do not affect routing, Mangle, or failover.
