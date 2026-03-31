# Introduction

## Purpose

The transactional outbox pattern is widely used to publish events reliably after database changes.  
However, implementations often differ in storage model, broker integration, retry handling, and failure semantics.

This specification defines a common behavioral model for outbox systems.

## Scope

This specification focuses on:

- **event production**: application-side requirements
- durable event storage
- event claiming and processing
- publishing to an external broker or transport
- delivery guarantees and semantics
- acknowledgement and retry behavior
- failure handling
- ordering guarantees and constraints
- operational inspection and querying of event state
- replay and recovery operations
- observability, metrics, and tracing

## Key Assumptions

This specification assumes that:

- **Atomic Persistence**: The outbox record and the application state change MUST be persisted within the same atomic durability boundary. Implementations MAY satisfy this using a single atomic write unit or a database transaction, depending on the storage system.
- **Eventual Consistency**: After atomic persistence succeeds, publication to the external transport occurs asynchronously and may be delayed

## Design Principle

This specification separates:

- **semantics**: what the system guarantees
- **contracts**: what storage and publisher components must provide
- **implementation**: how a specific backend fulfills those contracts

This separation allows for a **plug-and-play** architecture where storage (e.g., Postgres, MySQL) and publishers (e.g., Kafka, NATS) can be swapped without changing the delivery guarantees.

## Intended Audience

This document is intended for:

- library authors
- platform engineers
- infrastructure teams
- teams building reusable event delivery systems

## Terminology

The key words **MUST**, **SHOULD**, and **MAY** in this specification are to be interpreted as requirement levels:

- **MUST**: required behavior
- **SHOULD**: recommended behavior
- **MAY**: optional behavior
