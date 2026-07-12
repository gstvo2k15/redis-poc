# Redis Deployment Models

## Architecture Recommendation

For most enterprise environments that require **High Availability (HA)**
but **do not require horizontal scaling (sharding)**, **Model 1 (Redis
Replication + Sentinel)** is the recommended architecture.

Redis Cluster (Model 2) should only be selected when a single Redis
Primary is no longer able to handle the required memory capacity or
write throughput.

------------------------------------------------------------------------

# Environment Recommendations
```
  ------------------------------------------------------------------------------------
  Environment     Redis Topology   Sentinel     Recommended Servers Purpose
  --------------- ---------------- ---------- --------------------- ------------------
  DEV             1 Standalone     Optional                   **1** Development and
                  Redis            (0-1)                            functional testing

  STG             1 Primary + 1    3                          **3** Validate HA,
                  Replica                                           failover and
                                                                    production-like
                                                                    behavior

  PRD             1 Primary + 2    3                          **3** Production High
  (Recommended)   Replicas                                          Availability

  PRD (Critical)  1 Primary + 2    5                          **5** Higher resilience
                  Replicas                                          for
                                                                    mission-critical
                                                                    workloads
  ------------------------------------------------------------------------------------
```
> **Best Practice:** Sentinel deployments should always use an **odd
> number of nodes** (3 or 5) to guarantee a majority quorum during
> automatic failover.

------------------------------------------------------------------------

# Model 1: Redis Replication + Sentinel

## Components

-   1 Redis Primary
-   2 Redis Replicas
-   3 Redis Sentinel instances

### Recommended Production Deployment

  Server     Services
  ---------- ----------------------------
  Server 1   Redis Primary + Sentinel
  Server 2   Redis Replica 1 + Sentinel
  Server 3   Redis Replica 2 + Sentinel

## Total Servers Required: **3**

Although six processes are running (3 Redis + 3 Sentinel), only **three
servers** are required because each server hosts one Redis instance and
one Sentinel instance.

### How It Works

1.  Clients connect to Sentinel (TCP 26379) to discover the current
    Primary.
2.  Sentinel returns the active Primary.
3.  Clients perform read/write operations against the Primary (TCP 6379
    using TLS).
4.  Data is replicated to both replicas.
5.  If the Primary fails, Sentinel promotes one replica automatically.
6.  Clients reconnect transparently to the new Primary.

### Advantages

-   Simple architecture
-   High Availability
-   Automatic failover
-   Easy to operate
-   Supported by nearly every Redis client

### Limitations

-   Single writable Primary
-   No sharding
-   Dataset must fit into the memory of one Primary

------------------------------------------------------------------------

# Model 2: Redis Cluster

Redis Cluster is intended for environments requiring **horizontal
scaling**.

Example shown in the diagram:

-   3 Shards
-   Each shard contains:
    -   1 Primary
    -   2 Replicas

## Cluster Totals

  Component             Quantity
  ------------------- ----------
  Primaries                    3
  Replicas                     6
  Total Redis Nodes            9
  Sentinel                     0

## Total Servers Required: **9**

A production deployment typically assigns **one Redis node per server**.

Redis Cluster provides its own automatic failover using the Cluster Bus
(TCP 16379), therefore Sentinel is not required.

### Advantages

-   High Availability
-   Horizontal scaling
-   Automatic sharding
-   Increased capacity
-   Higher throughput

### Limitations

-   More operational complexity
-   Cluster-aware clients are required
-   Cross-slot operations have limitations

------------------------------------------------------------------------

# Recommended Deployment Strategy

For a typical enterprise platform:

## Development

-   1 Server
-   1 Standalone Redis
-   Sentinel optional

## Staging

-   3 Servers
-   1 Primary
-   1 Replica
-   3 Sentinel
-   Validate automatic failover before production

## Production

-   3 Servers
-   1 Primary
-   2 Replicas
-   3 Sentinel

This is the recommended balance between availability, simplicity and
operational cost.

## Mission-Critical Production

-   5 Servers
-   1 Primary
-   2 Replicas
-   5 Sentinel

Recommended only when additional quorum resilience is required.

------------------------------------------------------------------------

# Comparison

  -----------------------------------------------------------------------
  Feature               Model 1                  Model 2
  --------------------- ------------------------ ------------------------
  Recommended Use       High Availability        High Availability +
                                                 Horizontal Scaling

  Total Servers         **3**                    **9**

  Redis Nodes           3                        9

  Sentinel              3 (or 5)                 Not Required

  Automatic Failover    Sentinel                 Native Cluster

  Sharding              No                       Yes

  Operational           Low                      High
  Complexity                                     
  -----------------------------------------------------------------------

------------------------------------------------------------------------

# Suggested Improvement for the Diagram

Add an **Infrastructure Summary** box to each model.

## Model 1

-   Total Servers: **3**
-   Redis Nodes: **3**
-   Sentinel Nodes: **3**

## Model 2

-   Total Servers: **9**
-   Redis Nodes: **9**
-   Sentinel Nodes: **0**
-   Shards: **3**
