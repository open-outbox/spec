# OpenOutbox Spec

OpenOutbox is a specification for implementing the transactional outbox 
pattern across different storages and message brokers.

This specification is organized into the following sections:

### Foundations

* [Introduction](docs/01-introduction.md) — Overview and purpose.
* [Terminology and Concepts](docs/02-terminology-and-concepts.md) — Key definitions and actors.

### Core Concepts

* [Event Model](docs/03-event-model.md) — The structure of outbox records.
* [Delivery Semantics](docs/04-delivery-semantics.md) — Guarantees and acknowledgement rules.
* [Processing Lifecycle](docs/05-processing-lifecycle.md) — State transitions and flow.

### Technical Contracts

* [Store Contract](docs/06-store-contract.md) — Requirements for storage backends.
* [Publisher Contract](docs/07-publisher-contract.md) — Requirements for message dispatchers.

### Reliability & Scale

* [Retries and Failures](docs/08-retries-and-failures.md) — Error handling and terminal states.
* [Ordering and Partitioning](docs/09-ordering-and-partitioning.md) — Concurrency and sequence guarantees.

### Management

* [Operations and Replay](docs/10-replay-and-operations.md) — Inspection, recovery, and manual overrides.

The goal is to standardize outbox behavior independently from a specific 
database, broker, or framework.

## Goals

* define a portable outbox contract
* separate semantics from implementation
* support multiple storage and broker backends
* make delivery guarantees explicit
* standardize ordering and partitioning behaviors
* enable conformance testing across implementations

## Non-goals

* defining a single required database schema
* defining broker-specific wire protocols
* guaranteeing exactly-once delivery across all systems
* replacing broker-native semantics

## Status

Draft
