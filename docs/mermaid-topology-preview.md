# Mermaid topology — rendering test v2

This is a **visual test only**. It does not replace the approved architecture or README.

GitHub rendered bold headings, but ignored `<small>`. This version tests `<font size="2">` for subtitles and nonbreaking-space padding to make the rectangles wider.

```mermaid
flowchart TB
    C["&nbsp;&nbsp;&nbsp;<b>Claro · 500 Mbps</b>&nbsp;&nbsp;&nbsp;<br/><font size='2'>DHCP · Bridge Mode</font>"]
    V["&nbsp;&nbsp;&nbsp;<b>Vivo · 500 Mbps</b>&nbsp;&nbsp;&nbsp;<br/><font size='2'>PPPoE · Bridge Mode</font>"]
    M["&nbsp;&nbsp;&nbsp;&nbsp;<b>MikroTik hEX S</b>&nbsp;&nbsp;&nbsp;&nbsp;<br/><font size='2'>RouterOS 7 · PCC · Failover<br/>Firewall · DHCP</font>"]
    J((" "))
    D1["&nbsp;&nbsp;&nbsp;<b>Deco BE63 #1</b>&nbsp;&nbsp;&nbsp;<br/><font size='2'>Access Point · Ethernet backhaul</font>"]
    D2["&nbsp;&nbsp;&nbsp;<b>Deco BE63 #2</b>&nbsp;&nbsp;&nbsp;<br/><font size='2'>Access Point · Ethernet backhaul</font>"]

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

If GitHub also ignores `<font>`, we should avoid fragile HTML-size tricks and use consistent node fonts, keeping the subtitle concise.
