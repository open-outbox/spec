# OpenOutbox Spec

OpenOutbox is a specification for implementing the transactional outbox 
pattern across different storages and message brokers.

This specification defines:

- [Introduction](docs/01-introduction.md)
- [Terminology and Concepts](docs/02-terminology-and-concepts.md)
- [Event Model](docs/03-event-model.md)
- [Delivery Semantics](docs/04-delivery-semantics.md)
- [Processing Lifecycle](docs/05-processing-lifecycle.md)
- [Store Contract](docs/06-store-contract.md)
- [Publisher Contract](docs/07-publisher-contract.md)
- [Retries and Failures](docs/08-retries-and-failures.md)
- [Ordering and Partitioning](docs/09-ordering-and-partitioning.md)
- [Operations and Replay](docs/10-replay-and-operations.md)

The goal is to standardize outbox behavior independently from a specific 
database, broker, or framework.

## Goals

- define a portable outbox contract
- separate semantics from implementation
- support multiple storage and broker backends
- make delivery guarantees explicit
- enable conformance testing across implementations

## Non-goals

- defining a single required database schema
- defining broker-specific wire protocols
- guaranteeing exactly-once delivery across all systems
- replacing broker-native semantics

## Status

Draft
