# MikroTik RouterOS 7.24.5 | Dual-WAN PCC + failover + WAN monitoring
# Sanitized reference from a tested home network. REVIEW ONLY.
# Adapt interfaces, LAN, ISP credentials and USB paths before use.
# Do not import on a live router without a backup and rule-by-rule review.

# ====================================================================
# 01 — LAN BRIDGE AND ETHERNET INTERFACES
# ====================================================================
/interface bridge
add comment="Main LAN bridge" name=bridge-lan
/interface ethernet
set [ find default-name=ether3 ] comment="LAN port 3" name=LAN-ether3
set [ find default-name=ether4 ] comment="LAN port 4" name=LAN-ether4
set [ find default-name=ether5 ] comment="LAN port 5 / PoE-out if used" name=\
    LAN-ether5
set [ find default-name=ether1 ] comment=\
    "ISP1 Claro via DHCP - public dynamic IPv4" name=Link1-DHCP
set [ find default-name=ether2 ] comment="ISP2 via PPPoE" name=Link2-PPPoE

# ====================================================================
# 02 — VIVO PPPoE CLIENT (SET OWN CREDENTIALS)
# ====================================================================
/interface pppoe-client
add comment="ISP2 PPPoE" disabled=no interface=Link2-PPPoE name=pppoe-link2 \
    user="REPLACE_WITH_YOUR_PPPOE_USERNAME"
/interface pppoe-client set [find where name="pppoe-link2"] \
    password="YOUR_PASSWORD_HERE"

# ====================================================================
# 03 — LAN/WAN INTERFACE LISTS
# ====================================================================
/interface list
add comment="All WAN interfaces" name=WAN
add comment="All LAN interfaces" name=LAN

# ====================================================================
# 04 — LAN DHCP POOL AND SERVER
# ====================================================================
/ip pool
add name=pool-lan ranges=192.168.88.100-192.168.88.254
/ip dhcp-server
add address-pool=pool-lan interface=bridge-lan lease-time=1d name=dhcp-lan

# ====================================================================
# 05 — POLICY AND MONITOR ROUTING TABLES
# ====================================================================
/routing table
add comment="Policy table preferring Link1-DHCP" fib name=rt-link1
add comment="Policy table preferring Link2-PPPoE" fib name=rt-link2
add comment="Monitoramento exclusivo Claro" fib name=mon-claro
add comment="Monitoramento exclusivo Vivo" fib name=mon-vivo

# ====================================================================
# 06 — DISK LOG DESTINATIONS (ADAPT USB PATH)
# ====================================================================
# usb1-part1 is a sample mounted volume name, not a required identifier.
/system logging action
add disk-file-count=12 disk-file-name=usb1-part1/router-events \
    disk-lines-per-file=2000 name=usbevents target=disk
add disk-file-name=usb1-part1/wan-outages disk-lines-per-file=500 name=\
    wanoutages target=disk

# ====================================================================
# 07 — WANMON AGGREGATOR SCRIPT (OBSERVABILITY ONLY)
# ====================================================================
/system script
add dont-require-permissions=no name=wanmon-aggregator policy=\
    read,write,policy,test source="\
    \n\
    \n    :global wmClaroState\
    \n    :global wmClaroDownCount\
    \n    :global wmClaroUpCount\
    \n    :global wmClaroStart\
    \n\
    \n    :global wmVivoState\
    \n    :global wmVivoDownCount\
    \n    :global wmVivoUpCount\
    \n    :global wmVivoStart\
    \n\
    \n    :local now [/system resource get uptime]\
    \n\
    \n    :if ([:typeof \$wmClaroState] = \"nothing\") do={\
    \n        :set wmClaroState \"unknown\"\
    \n        :set wmClaroDownCount 0\
    \n        :set wmClaroUpCount 0\
    \n        :set wmClaroStart \$now\
    \n    }\
    \n\
    \n    :if ([:typeof \$wmVivoState] = \"nothing\") do={\
    \n        :set wmVivoState \"unknown\"\
    \n        :set wmVivoDownCount 0\
    \n        :set wmVivoUpCount 0\
    \n        :set wmVivoStart \$now\
    \n    }\
    \n\
    \n    :local cq [/tool netwatch find where name=\"WANMON-Claro-Quad9\"]\
    \n    :local cf [/tool netwatch find where name=\"WANMON-Claro-Cloudflare\
    \"]\
    \n    :local vq [/tool netwatch find where name=\"WANMON-Vivo-Quad9\"]\
    \n    :local vf [/tool netwatch find where name=\"WANMON-Vivo-Cloudflare\"\
    ]\
    \n\
    \n    :if (([:len \$cq] != 1) || ([:len \$cf] != 1) || ([:len \$vq] != 1) \
    || ([:len \$vf] != 1)) do={\
    \n        :log error \"WANMON ERROR Netwatch ausente ou duplicado\"\
    \n        :error \"WANMON Netwatch ausente ou duplicado\"\
    \n    }\
    \n\
    \n    :local c1 [/tool netwatch get (\$cq->0) status]\
    \n    :local c2 [/tool netwatch get (\$cf->0) status]\
    \n    :local v1 [/tool netwatch get (\$vq->0) status]\
    \n    :local v2 [/tool netwatch get (\$vf->0) status]\
    \n\
    \n    # CLARO\
    \n    :if ((\$c1 = \"down\") && (\$c2 = \"down\")) do={\
    \n\
    \n        :set wmClaroUpCount 0\
    \n\
    \n        :if (\$wmClaroState != \"down\") do={\
    \n            :if (\$wmClaroDownCount = 0) do={\
    \n                :set wmClaroStart \$now\
    \n            }\
    \n\
    \n            :set wmClaroDownCount (\$wmClaroDownCount + 1)\
    \n\
    \n            :if (\$wmClaroDownCount >= 2) do={\
    \n                :set wmClaroState \"down\"\
    \n                :set wmClaroDownCount 0\
    \n                :log warning \"WANMON Claro INTERNET DOWN\"\
    \n            }\
    \n        }\
    \n\
    \n    } else={\
    \n\
    \n        :if ((\$c1 = \"up\") || (\$c2 = \"up\")) do={\
    \n\
    \n            :set wmClaroDownCount 0\
    \n\
    \n            :if (\$wmClaroState = \"unknown\") do={\
    \n                :set wmClaroState \"up\"\
    \n            }\
    \n\
    \n            :if (\$wmClaroState = \"down\") do={\
    \n                :set wmClaroUpCount (\$wmClaroUpCount + 1)\
    \n\
    \n                :if (\$wmClaroUpCount >= 2) do={\
    \n                    :local duration 0s\
    \n                    :if (\$now >= \$wmClaroStart) do={\
    \n                        :set duration (\$now - \$wmClaroStart)\
    \n                    }\
    \n\
    \n                    :set wmClaroState \"up\"\
    \n                    :set wmClaroUpCount 0\
    \n\
    \n                    :log warning (\"WANMON Claro INTERNET UP duration=\"\
    \_. \$duration)\
    \n                }\
    \n            }\
    \n\
    \n        } else={\
    \n            :set wmClaroDownCount 0\
    \n            :set wmClaroUpCount 0\
    \n        }\
    \n    }\
    \n\
    \n    # VIVO\
    \n    :if ((\$v1 = \"down\") && (\$v2 = \"down\")) do={\
    \n\
    \n        :set wmVivoUpCount 0\
    \n\
    \n        :if (\$wmVivoState != \"down\") do={\
    \n            :if (\$wmVivoDownCount = 0) do={\
    \n                :set wmVivoStart \$now\
    \n            }\
    \n\
    \n            :set wmVivoDownCount (\$wmVivoDownCount + 1)\
    \n\
    \n            :if (\$wmVivoDownCount >= 2) do={\
    \n                :set wmVivoState \"down\"\
    \n                :set wmVivoDownCount 0\
    \n                :log warning \"WANMON Vivo INTERNET DOWN\"\
    \n            }\
    \n        }\
    \n\
    \n    } else={\
    \n\
    \n        :if ((\$v1 = \"up\") || (\$v2 = \"up\")) do={\
    \n\
    \n            :set wmVivoDownCount 0\
    \n\
    \n            :if (\$wmVivoState = \"unknown\") do={\
    \n                :set wmVivoState \"up\"\
    \n            }\
    \n\
    \n            :if (\$wmVivoState = \"down\") do={\
    \n                :set wmVivoUpCount (\$wmVivoUpCount + 1)\
    \n\
    \n                :if (\$wmVivoUpCount >= 2) do={\
    \n                    :local duration 0s\
    \n                    :if (\$now >= \$wmVivoStart) do={\
    \n                        :set duration (\$now - \$wmVivoStart)\
    \n                    }\
    \n\
    \n                    :set wmVivoState \"up\"\
    \n                    :set wmVivoUpCount 0\
    \n\
    \n                    :log warning (\"WANMON Vivo INTERNET UP duration=\" \
    . \$duration)\
    \n                }\
    \n            }\
    \n\
    \n        } else={\
    \n            :set wmVivoDownCount 0\
    \n            :set wmVivoUpCount 0\
    \n        }\
    \n    }\
    \n"

# ====================================================================
# 08 — LAN PORT MEMBERSHIP
# ====================================================================
/interface bridge port
add bridge=bridge-lan interface=LAN-ether3
add bridge=bridge-lan interface=LAN-ether4
add bridge=bridge-lan interface=LAN-ether5

# ====================================================================
# 09 — DISCOVERY AND IPv6 SETTINGS
# ====================================================================
/ip neighbor discovery-settings
set discover-interface-list=LAN
/ipv6 settings
set disable-ipv6=yes

# ====================================================================
# 10 — INTERNET DETECTION FOR MOBILE APP
# ====================================================================
/interface detect-internet
set detect-interface-list=all

# ====================================================================
# 11 — INTERFACE LIST MEMBERSHIP
# ====================================================================
/interface list member
add interface=Link1-DHCP list=WAN
add interface=pppoe-link2 list=WAN
add interface=bridge-lan list=LAN

# ====================================================================
# 12 — LAN GATEWAY ADDRESS
# ====================================================================
/ip address
add address=192.168.88.1/24 comment="LAN gateway" interface=bridge-lan \
    network=192.168.88.0

# ====================================================================
# 13 — CLARO DHCP CLIENT + DYNAMIC GATEWAY ROUTES
# ====================================================================
/ip dhcp-client
add check-gateway=ping comment="ISP1 Claro DHCP - dynamic public IPv4 routes" \
    default-route-tables=main:2,rt-link1:1,rt-link2:2,mon-claro:1 interface=\
    Link1-DHCP name=client1 use-peer-dns=no use-peer-ntp=no

# ====================================================================
# 14 — DHCP-ADVERTISED LAN GATEWAY AND DNS
# ====================================================================
/ip dhcp-server network
add address=192.168.88.0/24 comment="LAN network" dns-server=192.168.88.1 \
    gateway=192.168.88.1

# ====================================================================
# 15 — ROUTER DNS RESOLVER
# ====================================================================
/ip dns
set allow-remote-requests=yes servers=1.1.1.1,8.8.8.8,9.9.9.9

# ====================================================================
# 16 — OPTIONAL LOCAL DNS ENTRY
# ====================================================================
/ip dns static
add address=192.168.88.1 comment="Router DNS" name=router.lan type=A

# ====================================================================
# 17 — LOCAL/PCC EXEMPTION/BOGON ADDRESS LISTS
# ====================================================================
/ip firewall address-list
add address=192.168.88.0/24 comment="Local LAN subnet" list=LAN-local
add address=10.0.0.0/8 list=PCC-exempt
add address=172.16.0.0/12 list=PCC-exempt
add address=192.168.0.0/16 list=PCC-exempt
add address=100.64.0.0/10 list=PCC-exempt
add address=169.254.0.0/16 list=PCC-exempt
add address=10.0.0.0/8 list=RFC1918
add address=172.16.0.0/12 list=RFC1918
add address=192.168.0.0/16 list=RFC1918
add address=0.0.0.0/8 list=BOGON
add address=100.64.0.0/10 list=BOGON
add address=127.0.0.0/8 list=BOGON
add address=169.254.0.0/16 list=BOGON
add address=192.0.0.0/24 list=BOGON
add address=192.0.2.0/24 list=BOGON
add address=198.18.0.0/15 list=BOGON
add address=198.51.100.0/24 list=BOGON
add address=203.0.113.0/24 list=BOGON
add address=224.0.0.0/4 list=BOGON
add address=240.0.0.0/4 list=BOGON

# ====================================================================
# 18 — INPUT + FORWARD FIREWALL
# ====================================================================
/ip firewall filter
add action=accept chain=input comment="INPUT established/related" \
    connection-state=established,related,untracked
add action=drop chain=input comment="INPUT drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="INPUT ICMP from LAN" \
    in-interface-list=LAN protocol=icmp
add action=accept chain=input comment="INPUT DNS UDP from LAN" dst-port=53 \
    in-interface-list=LAN protocol=udp
add action=accept chain=input comment="INPUT DNS TCP from LAN" dst-port=53 \
    in-interface-list=LAN protocol=tcp
add action=accept chain=input comment="INPUT DHCP from LAN" dst-port=67-68 \
    in-interface-list=LAN protocol=udp
add action=accept chain=input comment="INPUT Winbox from LAN" dst-port=8291 \
    in-interface-list=LAN protocol=tcp
add action=drop chain=input comment="INPUT drop WAN to router" \
    connection-state=new in-interface-list=WAN
add action=drop chain=input comment="INPUT drop everything else"
add action=accept chain=forward comment="FWD established/related" \
    connection-state=established,related,untracked
add action=drop chain=forward comment="FWD drop invalid" connection-state=\
    invalid
add action=drop chain=forward comment="FWD drop RFC1918 from WAN" \
    in-interface-list=WAN src-address-list=RFC1918
add action=drop chain=forward comment="FWD drop bogon from WAN" \
    in-interface-list=WAN src-address-list=BOGON
add action=drop chain=forward comment="FWD drop unsolicited WAN" \
    connection-nat-state=!dstnat connection-state=new in-interface-list=WAN
add action=accept chain=forward comment="FWD permit dstnat" \
    connection-nat-state=dstnat connection-state=new in-interface-list=WAN
add action=accept chain=forward comment="FWD LAN to internet" \
    in-interface-list=LAN out-interface-list=WAN
add action=accept chain=forward comment="FWD LAN to LAN" in-interface-list=\
    LAN out-interface-list=LAN
add action=drop chain=forward comment="FWD drop everything else"

# ====================================================================
# 19 — TCP MSS, OPTIONAL BYPASS, PCC MARKS & PASSTHROUGH
# ====================================================================
# Disabled force-isp1/force-isp2 examples depend on lists not created here.
/ip firewall mangle
add action=change-mss chain=forward comment="MSS clamp out PPPoE" new-mss=\
    clamp-to-pmtu out-interface=pppoe-link2 protocol=tcp tcp-flags=syn
add action=change-mss chain=forward comment=\
    "OPTIONAL MSS clamp Claro (disabled)" disabled=yes new-mss=clamp-to-pmtu \
    out-interface=Link1-DHCP protocol=tcp tcp-flags=syn
add action=mark-connection chain=prerouting comment=\
    "BYPASS ISP1 mark connection" connection-mark=no-mark connection-state=\
    new disabled=yes new-connection-mark=conn-link1 src-address-list=\
    force-isp1
add action=mark-routing chain=prerouting comment="BYPASS ISP1 route" \
    connection-mark=conn-link1 disabled=yes new-routing-mark=rt-link1 \
    passthrough=no src-address-list=force-isp1
add action=mark-connection chain=prerouting comment=\
    "BYPASS ISP2 mark connection" connection-mark=no-mark connection-state=\
    new disabled=yes new-connection-mark=conn-link2 src-address-list=\
    force-isp2
add action=mark-routing chain=prerouting comment="BYPASS ISP2 route" \
    connection-mark=conn-link2 disabled=yes new-routing-mark=rt-link2 \
    passthrough=no src-address-list=force-isp2
add action=mark-connection chain=prerouting comment="IN-WAN1 mark connection" \
    connection-mark=no-mark connection-state=new in-interface=Link1-DHCP \
    new-connection-mark=conn-link1 passthrough=no
add action=mark-connection chain=prerouting comment="IN-WAN2 mark connection" \
    connection-mark=no-mark connection-state=new in-interface=pppoe-link2 \
    new-connection-mark=conn-link2 passthrough=no
add action=mark-connection chain=prerouting comment="PCC WAN1 1/2" \
    connection-mark=no-mark connection-state=new dst-address-list=!PCC-exempt \
    dst-address-type=!local in-interface=bridge-lan new-connection-mark=\
    conn-link1 per-connection-classifier=both-addresses:2/0 src-address-list=\
    LAN-local
add action=mark-connection chain=prerouting comment="PCC WAN2 2/2" \
    connection-mark=no-mark connection-state=new dst-address-list=!PCC-exempt \
    dst-address-type=!local in-interface=bridge-lan new-connection-mark=\
    conn-link2 per-connection-classifier=both-addresses:2/1 src-address-list=\
    LAN-local
add action=mark-routing chain=prerouting comment="ROUTE WAN1" \
    connection-mark=conn-link1 dst-address-list=!PCC-exempt dst-address-type=\
    !local in-interface=bridge-lan new-routing-mark=rt-link1 passthrough=no \
    src-address-list=LAN-local
add action=mark-routing chain=prerouting comment="ROUTE WAN2" \
    connection-mark=conn-link2 dst-address-list=!PCC-exempt dst-address-type=\
    !local in-interface=bridge-lan new-routing-mark=rt-link2 passthrough=no \
    src-address-list=LAN-local

# ====================================================================
# 20 — NAT MASQUERADE
# ====================================================================
/ip firewall nat
add action=masquerade chain=srcnat comment="NAT LAN to internet" \
    out-interface-list=WAN

# ====================================================================
# 21 — STATIC PPPoE ROUTES; CLARO ROUTES COME FROM DHCP
# ====================================================================
# Claro default routes are installed dynamically via DHCP default-route-tables.
/ip route
add check-gateway=none comment="MAIN: Link2 preferred" distance=1 \
    dst-address=0.0.0.0/0 gateway=pppoe-link2 routing-table=main
add check-gateway=none comment="rt-link1: backup via Link2" distance=2 \
    dst-address=0.0.0.0/0 gateway=pppoe-link2 routing-table=rt-link1
add check-gateway=none comment="rt-link2: preferred via Link2" distance=1 \
    dst-address=0.0.0.0/0 gateway=pppoe-link2 routing-table=rt-link2
add comment="MONITOR Vivo - somente PPPoE" disabled=no distance=1 \
    dst-address=0.0.0.0/0 gateway=pppoe-link2 routing-table=mon-vivo

# ====================================================================
# 22 — DISABLED REMOTE SERVICES
# ====================================================================
/ip service
set ftp disabled=yes
set ssh disabled=yes
set telnet disabled=yes
set www disabled=yes
set reverse-proxy disabled=yes
set api disabled=yes
set api-ssl disabled=yes

# ====================================================================
# 23 — LAN-TO-LAN AND PROBE ROUTING RULES
# ====================================================================
/routing rule
add action=lookup comment="LAN to LAN via main" dst-address=192.168.88.0/24 \
    src-address=192.168.88.0/24 table=main
add action=lookup-only-in-table comment="WANMON Claro Quad9" dst-address=\
    9.9.9.10/32 table=mon-claro
add action=lookup-only-in-table comment="WANMON Claro Cloudflare" \
    dst-address=1.1.1.2/32 table=mon-claro
add action=lookup-only-in-table comment="WANMON Vivo Quad9" dst-address=\
    149.112.112.10/32 table=mon-vivo
add action=lookup-only-in-table comment="WANMON Vivo Cloudflare" dst-address=\
    1.0.0.2/32 table=mon-vivo

# ====================================================================
# 24 — CLOCK
# ====================================================================
/system clock
set time-zone-name=America/Sao_Paulo

# ====================================================================
# 25 — GENERIC ROUTER IDENTITY
# ====================================================================
/system identity
set name=EXAMPLE-DUALWAN-ROUTER

# ====================================================================
# 26 — WAN OUTAGES VS GENERAL EVENTS (!debug)
# ====================================================================
/system logging
add action=usbevents topics=error
add action=usbevents topics=warning
add action=usbevents topics=critical
add action=usbevents topics=ppp,!debug
add action=usbevents topics=dhcp,!debug
add action=usbevents topics=interface,!debug
add action=wanoutages regex="^WANMON " topics=warning

# ====================================================================
# 27 — LOGIN NOTES
# ====================================================================
/system note
set show-at-login=no

# ====================================================================
# 28 — NTP CLIENT
# ====================================================================
/system ntp client
set enabled=yes

# ====================================================================
# 29 — TIME SERVERS
# ====================================================================
/system ntp client servers
add address=a.ntp.br comment="NTP Brasil 1"
add address=b.ntp.br comment="NTP Brasil 2"
add address=time.cloudflare.com comment="NTP Cloudflare"
add address=time.google.com comment="NTP Google"

# ====================================================================
# 30 — WANMON SCHEDULER PERMISSIONS
# ====================================================================
/system scheduler
add comment="WANMON - agregador a cada 30 segundos" !days interval=30s name=\
    wanmon-aggregator-run on-event="/system script run wanmon-aggregator" \
    policy=read,write,policy,test start-date=2026-10-16 start-time=21:12:42

# ====================================================================
# 31 — OPTIONAL INTERFACE GRAPHING
# ====================================================================
/tool graphing interface
add allow-address=192.168.88.0/24 interface=Link1-DHCP
add allow-address=192.168.88.0/24 interface=pppoe-link2

# ====================================================================
# 32 — OPTIONAL RESOURCE GRAPHING
# ====================================================================
/tool graphing resource
add allow-address=192.168.88.0/24

# ====================================================================
# 33 — MAC ACCESS LIMITED TO LAN
# ====================================================================
/tool mac-server
set allowed-interface-list=LAN

# ====================================================================
# 34 — MAC WINBOX LIMITED TO LAN
# ====================================================================
/tool mac-server mac-winbox
set allowed-interface-list=LAN

# ====================================================================
# 35 — FOUR ISOLATED INTERNET PROBES
# ====================================================================
/tool netwatch
add comment="Monitor Internet Claro - Quad9" host=9.9.9.10 \
    ignore-initial-down=yes ignore-initial-up=yes interval=30s name=\
    WANMON-Claro-Quad9 timeout=2s type=simple
add comment="Monitor Internet Claro - Cloudflare" host=1.1.1.2 \
    ignore-initial-down=yes ignore-initial-up=yes interval=30s name=\
    WANMON-Claro-Cloudflare timeout=2s type=simple
add comment="Monitor Internet Vivo - Quad9" host=149.112.112.10 \
    ignore-initial-down=yes ignore-initial-up=yes interval=30s name=\
    WANMON-Vivo-Quad9 timeout=2s type=simple
add comment="Monitor Internet Vivo - Cloudflare" host=1.0.0.2 \
    ignore-initial-down=yes ignore-initial-up=yes interval=30s name=\
    WANMON-Vivo-Cloudflare timeout=2s type=simple