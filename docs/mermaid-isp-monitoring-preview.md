# Diagram 3 — Independent ISP Monitoring (preview)

**Review only.** Monitoring is separate from production failover routing. Four router-originated Netwatch probes are constrained to their respective ISP through dedicated monitoring routing tables and `lookup-only-in-table` rules.

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

## Notes

- **Purpose:** Independent ISP monitoring provides observability and supports further troubleshooting by recording connectivity changes and helping distinguish ISP outages from local network events.
- Each ISP has **two Netwatch targets** with a 30-second probe interval and 2-second timeout.
- Four specific routing rules pin the targets to `mon-claro` or `mon-vivo`; the monitoring tables have **no other-ISP fallback**.
- The aggregator reads all four states every 30 seconds, independently evaluating each ISP. The DOWN/UP conditions shown in the shared diagram apply **per ISP**, not across both ISPs combined.
- DOWN requires **both** targets DOWN in two consecutive scheduler readings. UP requires **at least one** target UP in two consecutive readings.
- The aggregator writes log events but **does not alter routes**. Outage log storage is documented separately in Diagram 4.
