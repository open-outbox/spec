# Introduction

## Purpose

The transactional outbox pattern is a critical building block for reliable
distributed systems, ensuring events are published only when database
changes are committed. However, implementations often vary wildly in storage
models, retry handling, and failure semantics.

**Open Outbox** defines a common behavioral model to standardize these
systems, ensuring consistency regardless of the underlying technology.

## Scope

This specification defines the requirements for:

* **Event Lifecycle:** From atomic persistence to successful broker acknowledgement.
* **Strategy Compatibility**: Defining how different relaying strategies
(e.g., Log Tailing vs. Polling) interact with the outbox store.
* **Delivery Semantics:** Explicit rules for at-least-once delivery and retry behavior.
* **Reliability:** Handling ordering constraints, partitioning, and terminal failure states.
* **Interoperability:** Standardized contracts for Storage (Stores) and Transports (Publishers).
* **Operations:** Protocols for inspection, manual replay, and observability (metrics/tracing).

## Key Assumptions

* **Atomic Persistence:** The outbox record and the application state change MUST
be persisted within the same atomic durability boundary to prevent "dual-writes."
This may be achieved via database transactions or atomic document writes.
* **Eventual Consistency:** Publication to the external transport is asynchronous;
the delay between persistence and publication is expected but should be minimized.

## Design Principles

OpenOutbox is built on the **Decoupling of Semantics from Implementation**.
This allows for a "plug-and-play" architecture:

1. **Semantics:** What the system guarantees (e.g., "Ordered Delivery").
2. **Contracts:** What a component must provide (e.g., "Atomic Claiming").
3. **Implementation (The Driver):** The specific code or library fulfilling a
contract for a specific technology (e.g., postgres-store-v1, kafka-publisher-v2).
4. **Implementation Neutrality**: The specification defines what must be achieved
(reliable relaying) rather than how the data is moved. This allows for diverse
operational strategies, including Polling, Database Triggers, or Change Data Capture (CDC).

## Intended Audience

* **Library Authors:** Building outbox implementations in any language.
* **Platform Engineers:** Standardizing event-driven infrastructure across an organization.
* **System Architects:** Evaluating delivery guarantees and failure modes.

## Terminology

The key words **MUST**, **MUST NOT**, **REQUIRED**, **SHALL**, **SHALL NOT**,
**SHOULD**, **SHOULD NOT**, **RECOMMENDED**, **MAY**, and **OPTIONAL** in this
document are to be interpreted as described in 
[RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119).
