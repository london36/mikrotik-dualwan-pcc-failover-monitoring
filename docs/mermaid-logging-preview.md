# Diagram 4 — Router Events & WAN Outage Logs (clean horizontal preview)

**Purpose: Pure observability and troubleshooting.**

This version removes forced minimum-width and SVG-label settings, which caused off-center labels in GitHub. All nodes have two text lines, and Mermaid sizes them naturally.

```mermaid
flowchart LR
    E["RouterOS events<br/>Interfaces, DHCP, PPPoE"]
    F["Event filtering<br/>Excludes debug entries"]
    G["General event records<br/>router-events on USB"]

    W["WANMON aggregator<br/>Confirmed DOWN and UP"]
    R["Outage event records<br/>Approximate outage duration"]
    U["Outage log storage<br/>wan-outages on USB"]

    E --> F --> G
    W --> R --> U

    classDef general fill:#e6f1ff,stroke:#2474c7,color:#173d66
    classDef outage fill:#fff4e6,stroke:#c67a1b,color:#694409
    classDef storage fill:#e7f6ec,stroke:#299653,color:#185a33
    class E,F general
    class W,R outage
    class G,U storage
```

## Notes

- **General events:** Interface, DHCP and PPPoE messages with `!debug` exclusions, stored under `usb1-part1/router-events`.
- **WAN outages:** Confirmed WANMON DOWN/UP events and approximate durations, stored under `usb1-part1/wan-outages`.
- USB is a simple destination for persistent rotating text logs; other local storage may be used where suitable.
- **Purpose: Pure observability and troubleshooting.** Logging does not modify routes or affect failover.
