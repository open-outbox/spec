# Event Model

## Overview

An **event** represents a **unit of work** to be published to an external system.
This model defines the structure and semantics of an event, categorized by its
role in the delivery lifecycle.

To support the principle of **Implementation Neutrality**, fields are divided into
**Core Fields** (the message itself) and **Operational Metadata** (the control plane).

---

## Core Fields (Mandatory)

These fields represent the event's identity and data. They MUST be present in all
implementations (Polling, CDC, etc.) to ensure identity, sequence, and observability.

### event_id

- **Definition:** A unique identifier for the event.
- **Requirements:** MUST be unique within the store and MUST be immutable.
- **Recommendation:** SHOULD use globally unique formats like UUID or ULID.

### event_type

- **Definition:** A logical identifier describing the nature of the event (e.g., `user.created`).

- **Stable & Versionable:** MUST be a clear identifier (e.g., `user.created`).
- **Requirements:** MUST be transport-independent. It serves as the primary hint for routing but
SHOULD NOT contain protocol-specific strings (e.g., `topic://`).

### payload

- **Definition:** The business data intended for the external system.
- **Requirements:** MUST be treated as opaque by the outbox system and MUST NOT be modified after persistence.

### created_at

- **Definition:** The wall-clock time the event was persisted.
- **Requirements:** MUST be set at creation and MUST be immutable.
- **Purpose:** Essential for ordering tie-breakers, lag monitoring, and data retention policies.

---

## Operational Metadata (Strategy-Dependent)

The requirement for these fields depends on the retrieval strategy and the desired reliability profile.

| Field | Requirement | Context |
| :--- | :--- | :--- |
| `status` | **REQUIRED** | For all Polling and Sequential strategies. |
| `attempts` | **REQUIRED** | For implementations supporting retries and backoff. |
| `available_at` | **REQUIRED** | For scheduled delivery and retry eligibility. |
| `locked_at` | **OPTIONAL** | Required for **Distributed Lease** (High-Availability) profiles. |
| `locked_by` | **OPTIONAL** | Required for worker fencing in multi-node environments. |
| `updated_at` | **OPTIONAL** | Required for **Implicit Heartbeat** or auto-healing strategies. |

### status

The processing state of the event. Valid states MUST include:

- `PENDING`: Ready for processing.
- `DELIVERING`: Currently claimed by a worker.
- `DELIVERED`: Successfully published.
- `DEAD`: Terminally failed; requires manual intervention.

### available_at

The timestamp when an event becomes eligible for processing. 

- **Constraint:** A relay MUST NOT claim an event if `available_at > NOW()`.
- **Usage:** Used for implementing exponential backoff and delayed event publication.

### attempts

A monotonically increasing counter of publish attempts.

---

## Routing & Transport Fields (Optional)

### partition_key

Used by the publisher to determine shard or partition placement in the
target transport (e.g., Kafka partition).

### ordering_key

Defines a specific ordering scope. Events sharing the same key MUST be processed
in strict chronological order relative to each other.

### headers

Key-value pairs intended for the **message consumer** (e.g., `trace_id`, `content-type`).
If present, these SHOULD be preserved and mapped to transport-level headers by the relay.

### last_error

Information regarding the most recent failure (e.g., error message or stack trace). 
SHOULD be updated on every failed attempt to facilitate observability.

---

## Mutability Rules

To ensure data integrity, implementations MUST enforce the following mutability constraints:

- **Immutable Fields:** `event_id`, `event_type`, `payload`, `created_at`, `partition_key`, `ordering_key`, `headers`.
- **Mutable Fields:** `status`, `attempts`, `available_at`, `locked_at`, `locked_by`, `last_error`, `updated_at`, `delivered_at`.

---

## Field Consistency Constraints

In implementations utilizing lifecycle metadata, the following invariants MUST hold:

1. **Lease Invariant:** `locked_at` MUST be set if and only if `status = DELIVERING`.
2. **Completion Invariant:** `delivered_at` MUST be set if and only if `status = DELIVERED`.
3. **Fencing Invariant:** In distributed environments, `locked_by` MUST be set 
when `status = DELIVERING` to identify the owning worker and prevent collisions.
4. **Backoff Invariant:** Upon a retryable failure, `available_at` MUST be updated to a 
future timestamp, and `status` MUST be reset to `PENDING`.

---

## Extensibility

Implementations MAY extend the event model with additional fields
(e.g., `tenant_id` or `source_service`). Additional fields MUST NOT violate
delivery semantics, ordering guarantees, or core field definitions.
