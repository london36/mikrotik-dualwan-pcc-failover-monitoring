# Mermaid topology — rendering test v7

**Visual test only.** The Deco units are grouped inside a left-to-right subgraph; the backhaul connects them horizontally, while wireless clients are shown in a separate row below.

```mermaid
%%{init: {"flowchart": {"minNodeWidth": 260, "nodeSpacing": 80, "rankSpacing": 75, "curve": "linear"}}}%%
flowchart TB
    C["<b>Claro · 500 Mbps</b><br/>DHCP · Bridge Mode"]
    V["<b>Vivo · 500 Mbps</b><br/>PPPoE · Bridge Mode"]
    M["<b>MikroTik hEX S</b><br/>RouterOS 7 · PCC · Failover<br/>Firewall · DHCP"]

    subgraph APROW[" "]
      direction LR
      D1["<b>Deco BE63 #1</b><br/>Access Point"] ---|Ethernet backhaul| D2["<b>Deco BE63 #2</b><br/>Access Point"]
    end

    subgraph CLIENTROW[" "]
      direction LR
      W1["Wi-Fi clients"] ~~~ W2["Wi-Fi clients"]
    end

    C --> M
    V --> M
    M --> D1
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
    style APROW fill:none,stroke:none
    style CLIENTROW fill:none,stroke:none
```

**Layout caveat:** GitHub Mermaid auto-layout may still override horizontal subgraph direction when it has external links. If that happens, we should use a tiny SVG for exact geometry rather than promise that Mermaid can enforce it.
