# Mermaid topology — rendering test

This is a **visual test only**. It does not replace the approved architecture or README.

```mermaid
flowchart TB
    C["<b>Claro · 500 Mbps</b><br/><small>DHCP · Bridge Mode</small>"]
    V["<b>Vivo · 500 Mbps</b><br/><small>PPPoE · Bridge Mode</small>"]
    M["<b>MikroTik hEX S</b><br/><small>RouterOS 7 · PCC · Failover<br/>Firewall · DHCP</small>"]
    J((" "))
    D1["<b>Deco BE63 #1</b><br/><small>Access Point · Ethernet backhaul</small>"]
    D2["<b>Deco BE63 #2</b><br/><small>Access Point · Ethernet backhaul</small>"]

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

**Review checks:** The heading should be bold, the second line smaller, with Claro and Vivo above the MikroTik and two Deco APs below.
