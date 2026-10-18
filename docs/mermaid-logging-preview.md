# Diagram 4 — Router Events & WAN Outage Logs (horizontal, equal-width preview)

**Purpose: Pure observability and troubleshooting.**

Two independent, left-to-right logging paths. Neither affects routing or failover.

```mermaid
%%{init: {"flowchart": {"minNodeWidth": 300, "nodeSpacing": 60, "rankSpacing": 65, "curve": "linear"}}}%%
flowchart LR
    E["RouterOS events<br/>Interfaces · DHCP · PPPoE"]
    F["Filter: !debug"]
    G["router-events<br/>Rotating USB text files"]

    W["WANMON aggregator<br/>Confirmed ISP DOWN / UP"]
    R["WAN outage records<br/>Approximate duration"]
    U["wan-outages<br/>Rotating USB text files"]

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

- **General events:** interface, DHCP and PPPoE messages with `!debug` exclusions; stored under `usb1-part1/router-events`.
- **WAN outages:** WANMON's confirmed DOWN/UP events and approximate durations; stored under `usb1-part1/wan-outages`.
- USB is a convenient destination for persistent rotating text logs; internal storage is possible if capacity and write endurance allow.
- **Purpose: Pure observability and troubleshooting.** Neither logging stream changes routing or failover.
