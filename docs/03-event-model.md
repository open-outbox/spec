# Event Model

## Overview

An **event** represents a **unit of work** to be published to an external system.
The event model defines the canonical structure and semantics of an event:

- required fields
- optional fields
- field semantics
- mutability constraints

---

## Required Fields

An event MUST include at least the following fields:

- `event_id`
- `event_type`
- `payload`
- `status`  
- `attempts`
- `created_at`
- `available_at`

### event_id

A unique identifier for the event.

- MUST be unique within the outbox store.
- MUST be immutable.
- SHOULD use a globally unique format (e.g., UUID or ULID).

### event_type

A logical identifier describing the type of the event.

- **Stable & Versionable:** MUST be a clear identifier (e.g., `user.created`).
- **Logical Mapping:** Serves as the default destination (e.g., Kafka Topic or SQS Queue).
- **Transport Independence:** MUST NOT include transport-specific protocols (e.g., `sqs://`).

### payload

The business data to be delivered to the external system.

- MUST be treated as opaque by the outbox system.
- MUST NOT be modified after persistence.

### status

The current **processing state** of the event.

- MUST be one of: `PENDING`, `DELIVERING`, `DELIVERED`, `DEAD`.
- MUST be managed by the relay according to the [Processing Lifecycle](./05-processing-lifecycle.md).

### created_at

The timestamp at which the event was created.

- MUST be set when the event is persisted and MUST be immutable.

### attempts

The number of publish attempts for the event.

- MUST be monotonically increasing.

### available_at

The timestamp at which the event becomes eligible for processing.

- **Eligibility:** Events MUST NOT be claimed if `available_at` is in the future.
- **Functionality:** Used for both retry backoff and scheduled (delayed) delivery.

---

## Optional Fields

### partition_key

A value used for routing or partitioning in the target transport.

- MAY be used by the publisher to determine shard or partition placement.

### ordering_key

A value used to define ordering scope. Events with the same key MUST be processed in order.

### metadata

Internal operational data (e.g., tracing IDs). **NOT intended for the external system.**

### headers

Key-value pairs intended for the **message consumer** (transport-level headers).

- If present, MUST be included in the publish operation when the target system supports equivalent header semantics.
- SHOULD be preserved as-is during the publish operation.
- MAY be used by consumers for routing, filtering, or processing logic.

### last_error

Information about the last failure.

- MAY include error message or code.
- SHOULD be updated on every failed attempt.

### locked_at

The timestamp at which the event was claimed for delivery.

- MUST be set when the event transitions to `DELIVERING`.

### locked_by

An identifier for the specific relay instance that has claimed the event.

- SHOULD be used in conjunction with `locked_at` to provide fencing in distributed environments.

### delivered_at

The timestamp at which the event was successfully published.

- MUST be set when the event transitions to `DELIVERED`.

### updated_at

The timestamp at which the event was last modified.

- MUST be updated whenever any field change occurs.

---

## Mutability Rules

### Immutable fields

- `event_id`, `event_type`, `ordering_key`, `partition_key`, `payload`, `headers`, `created_at`

### Mutable fields

- `status`, `attempts`, `locked_by`, `last_error`, `available_at`, `locked_at`, `delivered_at`, `updated_at`

---

## Field Consistency Constraints

The following invariants MUST hold:

- `locked_at` MUST be set if and only if `status = DELIVERING`.
- `delivered_at` MUST be set if and only if `status = DELIVERED`.
- `locked_by` MUST be set when `status = DELIVERING` if supported by the implementation.

---

## Extensibility

Implementations MAY extend the event model with additional fields. Additional fields MUST NOT violate delivery semantics, ordering guarantees, or core field definitions.