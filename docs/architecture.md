# Architecture

## Physical / logical network

```mermaid
%%{init: {"flowchart": {"minNodeWidth": 260, "wrappingWidth": 280, "nodeSpacing": 80, "rankSpacing": 70, "curve": "linear"}}}%%
flowchart TB
    C["<b>Claro · 500 Mbps</b><br/>DHCP · Bridge Mode"]
    V["<b>Vivo · 500 Mbps</b><br/>PPPoE · Bridge Mode"]
    M["<b>MikroTik hEX S</b><br/>RouterOS 7 · PCC · Failover<br/>Firewall · DHCP"]
    D1["<b>Deco BE63 #1</b><br/>AP · Ethernet backhaul"]
    D2["<b>Deco BE63 #2</b><br/>AP · Ethernet backhaul"]

    C --> M
    V --> M
    M --> D1
    D1 -->|Ethernet backhaul| D2

    classDef claro fill:#e6f1ff,stroke:#2474c7,color:#173d66
    classDef vivo fill:#e7f6ec,stroke:#299653,color:#185a33
    classDef router fill:#edf0f4,stroke:#68788c,color:#202b38
    classDef deco fill:#f5f5f5,stroke:#999,color:#333

    class C claro
    class V vivo
    class M router
    class D1,D2 deco
```

## PCC and Mangle

```mermaid
flowchart TB
    LAN["New LAN connection<br/>Client to internet"]
    PCC["PCC / Mangle<br/>both-addresses:  2/0 and 2/1"]
    A["conn-link1<br/>Routing mark: rt-link1"]
    B["conn-link2<br/>Routing mark: rt-link2"]
    R1["rt-link1<br/>Primary: Claro · Backup: Vivo"]
    R2["rt-link2<br/>Primary: Vivo · Backup: Claro"]
    C["Claro · DHCP"]
    V["Vivo · PPPoE"]

    LAN --> PCC
    PCC --> A
    PCC --> B
    A --> R1
    B --> R2
    R1 -->|Primary| C
    R2 -->|Primary| V
    R1 -.->|Backup| V
    R2 -.->|Backup| C

    classDef neutral fill:#edf0f4,stroke:#68788c,color:#202b38
    classDef claro fill:#e6f1ff,stroke:#2474c7,color:#173d66
    classDef vivo fill:#e7f6ec,stroke:#299653,color:#185a33
    classDef routing fill:#fff4e6,stroke:#c67a1b,color:#694409
    class LAN,PCC,A,B neutral
    class R1,R2 routing
    class C claro
    class V vivo
```


The router uses a conventional `both-addresses:2/0` / `both-addresses:2/1` classifier and connection/routing marks to direct traffic to `rt-link1` and `rt-link2`. The less-granular hash keeps the same source/destination IP pair on one WAN under normal conditions, which can help avoid IP-inconsistency problems with security-sensitive services, but does not guarantee 50/50 bandwidth use or complete application affinity.

## Native cross-backup failover

Each policy routing table prioritizes its corresponding ISP and has a secondary route over the other ISP. Route distances determine preference; route availability determines fallback. **No monitoring script modifies production routes.** The DHCP-managed Claro routes adapt automatically to gateway changes.

## Independent ISP reachability monitoring

```mermaid
flowchart TB
    CL["Claro monitoring<br/>mon-claro · ISP only"]
    VI["Vivo monitoring<br/>mon-vivo · ISP only"]

    CQ["Quad9<br/>9.9.9.10"]
    CC["Cloudflare<br/>1.1.1.2"]
    VQ["Quad9<br/>149.112.112.10"]
    VC["Cloudflare<br/>1.0.0.2"]

    AG["WANMON aggregator<br/>Scheduler every 30 seconds"]
    DOWN["INTERNET DOWN<br/>Both probes DOWN in 2 consecutive polls"]
    UP["INTERNET UP<br/>At least 1 probe UP in 2 consecutive polls"]

    CL --> CQ
    CL --> CC
    VI --> VQ
    VI --> VC

    CQ --> AG
    CC --> AG
    VQ --> AG
    VC --> AG

    AG --> DOWN
    AG --> UP

    classDef claro fill:#e6f1ff,stroke:#2474c7,color:#173d66
    classDef vivo fill:#e7f6ec,stroke:#299653,color:#185a33
    classDef central fill:#edf0f4,stroke:#68788c,color:#202b38
    classDef down fill:#fff4e6,stroke:#c67a1b,color:#694409
    classDef up fill:#e7f6ec,stroke:#299653,color:#185a33
    class CL,CQ,CC claro
    class VI,VQ,VC vivo
    class AG central
    class DOWN down
    class UP up
```


Four Netwatch probes test two external public IP destinations for each ISP. Dedicated `mon-claro` and `mon-vivo` routing tables, plus destination-specific `lookup-only-in-table` rules, keep each router-originated test on its ISP without spillover.

The `wanmon-aggregator` scheduler runs every 30 seconds. Both targets must be DOWN on two consecutive polls for an outage; either target UP on two polls signals recovery. Probe/scheduler timing is not synchronized, so logged durations are approximations, not exact outage measurements.

## Event and outage logging

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

## Outage records

Confirmed WANMON DOWN/UP events, with approximate duration, go to rotating text files on USB at `usb1-part1/wan-outages`.

## General router events

Interface, DHCP and PPPoE events are written separately at `usb1-part1/router-events`. Routine topic selections exclude debug output using `!debug`. USB files are a simple persistence option; alternatively, internal flash can be used with appropriate capacity/write-cycle planning, while RAM logs are volatile.

**Neither event log has any role in route selection or failover.** The storage device and `/disk` partition declaration are environment-specific; the public reference does not configure USB partitions.

## Core limitation

An upstream internet outage may be detected by Netwatch while the ISP gateway stays reachable. In that case production traffic is **not guaranteed to fail over** because WANMON does not control routes. Loss of an interface or unavailable preferred route was separately tested.
