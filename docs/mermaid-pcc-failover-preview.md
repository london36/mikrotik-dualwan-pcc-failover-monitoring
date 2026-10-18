# Diagram 2 — PCC, Mangle & Cross-Backup Failover (v3 preview)

**Review only.** Restores the original crossed-backup flow. Labels now use plain Mermaid text with explicit line breaks, without HTML markup or minimum-node-width overrides, to diagnose GitHub's misaligned text.

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

**How it works:** PCC/Mangle classifies connections into policy routing tables. Each table prefers one ISP, and the other ISP is its backup when the preferred route is unavailable. Netwatch and logs do not modify routes.
