# Validation results

These are observations from supervised tests on 17 October 2026, not a guarantee for every network.

## Controlled Claro probe failure

- One monitoring target DOWN and one UP: aggregated ISP remained UP.
- Both targets blocked: `WANMON Claro INTERNET DOWN` at 09:09:12.
- After removal of test blackhole routes: UP at 09:11:42 with `duration=00:03:00`.

## Physical Claro cable disconnection

- Dynamic DHCP routes disappeared and the corresponding policy table used the Vivo PPPoE backup route.
- Both Claro probes went DOWN; both Vivo probes remained UP.
- Claro DOWN recorded at 09:20:12; recovery UP at 09:24:12 with `duration=00:04:30`.
- A Mac ping stream briefly stopped and resumed; no measured transition-time or packet-loss rate is claimed.

## Vivo checks

Vivo monitoring-table isolation and physical cable-disconnection failover were also tested. No unsupported numeric timing claims are made.

## Distinction

The external probes report internet reachability. **They do not decide routing failover.** Tested physical-link failures do not prove automatic rerouting during an upstream outage with a reachable gateway.
