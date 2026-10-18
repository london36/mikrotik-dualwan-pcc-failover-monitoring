# Mermaid topology — rendering test v5

This version tests a chained Deco layout: MikroTik → Deco BE63 #1 → Deco BE63 #2, with the second link labeled **Ethernet backhaul**. Wide node settings are retained.

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

Expected: wide horizontal rectangles without padding text hacks. If unchanged, GitHub's bundled Mermaid likely does not apply the config directive, and a small SVG exported from the same diagram may be more reliable.
