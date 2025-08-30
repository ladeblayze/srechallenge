# DumbKV – Service Level Objectives (SLOs)

## Overview
DumbKV is a demo key-value store with intentional limitations for SRE training.

- Simple architecture  
- SHA256 key hashing (irreversible lookups)  
- Values encrypted with hashed keys  
- Designed to be DoS vulnerable  
- Supports SQLite and PostgreSQL backends  

---

## Service Level Objectives

| Objective        | Target                       | Measurement              | Alert Condition                |
|------------------|------------------------------|--------------------------|--------------------------------|
| Availability     | 95% uptime over 7 days       | `/health` returns 200    | <90% over 2 hours              |
| Response Time    | 90% of requests <1000ms      | Request duration         | P90 >2000ms over 10 minutes    |
| Error Rate       | <5% of requests return 5xx   | Ratio of 5xx responses   | >10% over 5 minutes            |
| DB Consistency   | 99% identical results        | Cross-check test results | >2% difference in failure rate |

---

## Monitoring and Alerts

**Metrics**
- Availability: `/health` endpoint  
- Latency: HTTP request duration histograms  
- Errors: HTTP status code distribution  
- Database performance: query execution time by backend  
- Resource usage: container CPU, memory, and storage  

**Monitoring Stack**
- Metrics: Prometheus (`/metrics` endpoint)  
- Alerting: ServiceMonitor  
- Dashboards: application and container-level metrics  
- Health checks: Kubernetes liveness and readiness probes  

**Alert Scenarios**
- Service down for >5 minutes  
- Latency P90 exceeds threshold for >10 minutes  
- 5xx error rate >10% for >5 minutes  
- Resource exhaustion (CPU, memory, or storage near limits)  
- Database inconsistency between backends  

---

## SLO Exclusions

The following are excluded from SLO calculations:
- Intentional DoS attacks or abuse  
- Planned maintenance windows  
- Infrastructure failures (cluster, storage, network)  
- Container startup (first 30 seconds)  
- Client-side errors (4xx)  

---

## Review Cadence

- Weekly: Review metrics and SLO compliance  
- Monthly: Adjust thresholds as needed  
- Quarterly: Full SLO framework review  

**Success Criteria**
- All SLOs consistently met  
- Alerts are actionable and reduce noise  
- SLOs guide service improvements  

---

## Implementation Notes

**Kubernetes**
- Single replica (no load balancing)  
- Resource requests and limits configured  
- Persistent storage (PVC) for availability tracking  
- Ingress configuration influences latency  

**Database Backends**
- SQLite: faster, simpler, single-node  
- PostgreSQL: adds latency, requires connection pooling  
- Both must meet minimum SLOs  

---

## Development vs Production

These SLOs are designed for training/demo environments.  
For production, the following would be required:

- 99.9%+ availability  
- Response times <500ms  
- Error rate <0.1%  
- Additional security and performance objectives  
