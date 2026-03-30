# OpenOutbox Specification v1 (Draft)

## 1. Purpose

This specification defines a **minimal, explicit semantic contract** for the
**transactional outbox pattern**.

The goal is to standardize how application events are:
- durably recorded inside a database transaction
- safely dispatched to an asynchronous messaging system
- retried, replayed, and operated under failure

This spec describes **semantics**, not a specific implementation.

---

## 2. Scope and Non-Goals

### In scope (v1)
- Explicit outbox tables written by applications
- Event envelope semantics
- Dispatch state machine
- Claim/lease protocol for concurrent dispatchers

### Out of scope (v1)
- CDC / log-based capture as the primary mechanism
- Exactly-once end-to-end delivery
- Consumer processing semantics
- Broker-specific APIs
- Workflow orchestration

---

## 3. Event Envelope (Normative)

An event **MUST** include the following immutable fields:

- `event_id` (UUID): globally unique identifier
- `event_type` (string): domain-defined event name
- `occurred_at` (timestamp): time of business occurrence
- `partition_key` (string): ordering and routing key
- `payload` (object or binary): event data
- `headers` (map): metadata (trace, correlation, idempotency)

The envelope **MUST NOT** change across retries or replays.

---

## 4. Outbox Storage Contract (Reference)

Events are stored durably in an outbox table together with dispatch metadata.

A compliant storage model **MUST** represent:
- event identity and envelope
- dispatch status
- retry attempts
- lease ownership and timing
- failure diagnostics

A reference PostgreSQL schema is provided separately.

---

## 5. Dispatch State Machine (Normative)

Each outbox record **MUST** be in exactly one of the following states:

- `PENDING` – eligible for dispatch
- `DELIVERING` – claimed by a dispatcher
- `DELIVERED` – successfully published
- `DEAD` – permanently failed

### Valid transitions
- `PENDING → DELIVERING`
- `DELIVERING → DELIVERED`
- `DELIVERING → PENDING` (retry/lease expiry)
- `PENDING|DELIVERING → DEAD`

### Invariants
- Only `PENDING` records are claimable
- `attempts` is monotonically increasing
- `DELIVERED` records are immutable

---

## 6. Claim / Lease Protocol

Dispatchers claim records using a **lease-based protocol**.

A lease:
- grants temporary ownership of a record
- expires after a defined timeout
- allows recovery after crashes or restarts

A record with an expired lease **MAY** be reclaimed.

The protocol **MUST** prevent multiple dispatchers from delivering the same record concurrently.

---

## 7. Delivery Semantics

This specification guarantees **at-least-once delivery** to the message broker.

A record is considered `DELIVERED` when the broker acknowledges acceptance.

Exactly-once processing requires **idempotent consumers** and is out of scope.

---

## 8. Conformance

An implementation is compliant with OpenOutbox v1 if it:

- preserves the event envelope semantics
- enforces the state machine and invariants
- correctly implements the claim/lease protocol
- provides no-loss delivery under failures consistent with at-least-once semantics
