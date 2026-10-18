# Mermaid topology — rendering test v6

**Visual test only.** Side-by-side Deco access points with a labeled Ethernet backhaul and Wi-Fi clients beneath each AP.

```mermaid
%%{init: {"flowchart": {"minNodeWidth": 260, "wrappingWidth": 280, "nodeSpacing": 80, "rankSpacing": 70, "curve": "linear"}}}%%
flowchart TB
    C["<b>Claro · 500 Mbps</b><br/>DHCP · Bridge Mode"]
    V["<b>Vivo · 500 Mbps</b><br/>PPPoE · Bridge Mode"]
    M["<b>MikroTik hEX S</b><br/>RouterOS 7 · PCC · Failover<br/>Firewall · DHCP"]
    D1["<b>Deco BE63 #1</b><br/>Access Point"]
    D2["<b>Deco BE63 #2</b><br/>Access Point"]
    W1["Wi-Fi clients"]
    W2["Wi-Fi clients"]

    C --> M
    V --> M
    M --> D1

    subgraph APs[" "]
      direction LR
      D1 ---|Ethernet backhaul| D2
    end

    D1 -.-> W1
    D2 -.-> W2

    classDef claro fill:#e6f1ff,stroke:#2474c7,color:#173d66
    classDef vivo fill:#e7f6ec,stroke:#299653,color:#185a33
    classDef router fill:#edf0f4,stroke:#68788c,color:#202b38
    classDef deco fill:#f5f5f5,stroke:#999,color:#333
    classDef clients fill:#ffffff,stroke:#adb5bd,color:#555

    class C claro
    class V vivo
    class M router
    class D1,D2 deco
    class W1,W2 clients
    style APs fill:none,stroke:none
```

Note: GitHub's Mermaid layout engine may adjust positions depending on subgraph constraints. Dashed lines represent wireless client associations.
