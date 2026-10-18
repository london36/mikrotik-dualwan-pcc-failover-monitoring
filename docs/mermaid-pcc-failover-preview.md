# Diagram 2 — PCC, Mangle & Cross-Backup Failover (v2 preview)

**Review only.** The backup relationship is expressed inside each routing table to avoid crossing arrows and uneven auto-layout.

```mermaid
%%{init: {"flowchart": {"minNodeWidth": 230, "nodeSpacing": 65, "rankSpacing": 60, "curve": "linear"}}}%%
flowchart TB
    LAN["<b>New LAN connection</b><br/>Client to internet"]
    PCC["<b>PCC / Mangle</b><br/>both-addresses:2/0 and 2/1"]

    A["<b>conn-link1</b><br/>mark-routing: rt-link1"]
    B["<b>conn-link2</b><br/>mark-routing: rt-link2"]

    R1["<b>rt-link1</b><br/>Primary: Claro (distance 1)<br/>Backup: Vivo (distance 2)"]
    R2["<b>rt-link2</b><br/>Primary: Vivo (distance 1)<br/>Backup: Claro (distance 2)"]

    C["<b>Claro · DHCP</b><br/>Primary for rt-link1"]
    V["<b>Vivo · PPPoE</b><br/>Primary for rt-link2"]

    LAN --> PCC
    PCC --> A
    PCC --> B
    A --> R1
    B --> R2
    R1 --> C
    R2 --> V

    classDef neutral fill:#edf0f4,stroke:#68788c,color:#202b38
    classDef claro fill:#e6f1ff,stroke:#2474c7,color:#173d66
    classDef vivo fill:#e7f6ec,stroke:#299653,color:#185a33
    classDef routing fill:#fff4e6,stroke:#c67a1b,color:#694409
    class LAN,PCC,A,B neutral
    class R1,R2 routing
    class C claro
    class V vivo
```

**Cross-backup:** `rt-link1` prefers Claro and falls back to Vivo; `rt-link2` prefers Vivo and falls back to Claro. Native route distances determine preference. Mangle performs ordinary PCC classification; **no script switches routes**.

**Limitation:** an external upstream failure may be logged by Netwatch without triggering route fallback if the preferred route remains available.
