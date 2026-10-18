# Diagram 2 — PCC, Mangle & Cross-Backup Failover (review)

**Visual preview only.** This describes routing logic for LAN-originated traffic. It does not depict Netwatch or logging.

```mermaid
%%{init: {"flowchart": {"minNodeWidth": 250, "nodeSpacing": 85, "rankSpacing": 65, "curve": "linear"}}}%%
flowchart TB
    LAN["<b>New LAN connection</b><br/>Client → internet destination"]
    PCC["<b>PCC in Mangle</b><br/>both-addresses:2/0 · both-addresses:2/1"]
    A["<b>Connection mark: conn-link1</b><br/>Routing mark → rt-link1"]
    B["<b>Connection mark: conn-link2</b><br/>Routing mark → rt-link2"]
    R1["<b>rt-link1</b><br/>Primary: Claro · Backup: Vivo"]
    R2["<b>rt-link2</b><br/>Primary: Vivo · Backup: Claro"]
    C["<b>Claro · DHCP</b><br/>Preferred for rt-link1"]
    V["<b>Vivo · PPPoE</b><br/>Preferred for rt-link2"]

    LAN --> PCC
    PCC --> A
    PCC --> B
    A --> R1
    B --> R2
    R1 -->|Preferred| C
    R2 -->|Preferred| V
    R1 -.->|Backup if primary route unavailable| V
    R2 -.->|Backup if primary route unavailable| C

    classDef neutral fill:#edf0f4,stroke:#68788c,color:#202b38
    classDef claro fill:#e6f1ff,stroke:#2474c7,color:#173d66
    classDef vivo fill:#e7f6ec,stroke:#299653,color:#185a33
    classDef routing fill:#fff4e6,stroke:#c67a1b,color:#694409
    class LAN,PCC,A,B neutral
    class R1,R2 routing
    class C claro
    class V vivo
```

**Reading the diagram:** Mangle marks connections and selects the relevant policy routing table; each table has a preferred ISP and the other as a backup through route distances. A backup route is selected when the preferred route becomes unavailable. No custom failover script changes routes.

**Known limitation:** external reachability loss alone, while a primary gateway/route stays available, does not necessarily switch traffic to the other ISP.
