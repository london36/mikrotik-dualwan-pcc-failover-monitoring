# Mermaid topology — rendering test v3

**Review only:** natural wider boxes using meaningful labels, without HTML padding tricks. GitHub controls Mermaid text metrics.

```mermaid
flowchart TB
    C["<b>Claro · 500 Mbps</b><br/>DHCP WAN · Modem in Bridge Mode"]
    V["<b>Vivo · 500 Mbps</b><br/>PPPoE WAN · Modem in Bridge Mode"]
    M["<b>MikroTik hEX S</b><br/>RouterOS 7 · PCC 50/50 · Native Failover<br/>Firewall · NAT · LAN DHCP"]
    J((" "))
    D1["<b>Deco BE63 #1</b><br/>Access Point · Ethernet Backhaul"]
    D2["<b>Deco BE63 #2</b><br/>Access Point · Ethernet Backhaul"]

    C --> M
    V --> M
    M --- J
    J --> D1
    J --> D2

    classDef claro fill:#e6f1ff,stroke:#2474c7,color:#173d66
    classDef vivo fill:#e7f6ec,stroke:#299653,color:#185a33
    classDef router fill:#edf0f4,stroke:#68788c,color:#202b38
    classDef deco fill:#f5f5f5,stroke:#999,color:#333
    classDef junction fill:transparent,stroke:transparent,color:transparent

    class C claro
    class V vivo
    class M router
    class D1,D2 deco
    class J junction
```

Note: GitHub did not honor the prior subtitle-size approach. This test emphasizes reliable rendering and naturally wider nodes.
