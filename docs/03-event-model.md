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

- MUST be unique within the outbox store
- MUST be immutable
- SHOULD use a globally unique format (e.g., UUID or ULID) to facilitate distributed tracing and idempotency

---

### event_type

A logical identifier describing the type of the event.

- **Stable & Versionable:** MUST be a clear identifier (e.g., `user.created`).
- **Logical Mapping:** In many implementations, the `event_type` serves as the default **Destination** (e.g., the Kafka Topic or NATS Subject name).
- **Transport Independence:** While the value may be used as a destination name, it MUST NOT include transport-specific protocols or wire-format details (e.g., `sqs://queue-name`).

---

### payload

The data to be delivered to the external system.

- MAY be any structured or unstructured data
- MUST be treated as opaque by the outbox system
- MUST NOT be modified after persistence, as it defines the canonical content to be delivered

---

### status

The current [processing state](./02-terminology-and-concepts.md#processing-state) of the event.

- MUST be one of:
  - `PENDING`
  - `DELIVERING`
  - `DELIVERED`
  - `DEAD`
- MUST be managed by the relay according to the processing lifecycle

---

### created_at

The timestamp at which the event was created.

- MUST be set when the event is persisted
- MUST be immutable

---

### attempts

The number of publish attempts for the event.

- MUST be monotonically increasing
- MUST be incremented before each publish attempt
- MAY be used to determine retry behavior

---

### available_at

The timestamp at which the event becomes eligible for processing.

- MAY be used for delayed processing, retry backoff, or scheduling
- If present, defines when the event becomes eligible for claiming
- Events MUST NOT be claimed before this time
- If not present, the event is immediately eligible
- Lease expiration MAY override `available_at` and make the event immediately eligible for re-claiming

---

## Optional Fields

An event MAY include additional fields depending on implementation needs.

---

### partition_key

A value used for routing or partitioning in the target transport.

- MAY be used by the publisher
- DOES NOT define ordering semantics

---

### ordering_key

A value used to define ordering scope.

- When ordering is enabled, events with the same ordering key MUST be processed in order

---

### metadata

Additional information associated with the event for internal or operational use.
**This data is NOT intended for the external system.**

- MAY include tracing identifiers, source information, or annotations
- MAY be used by the relay for processing, debugging, or observability
- MUST NOT affect delivery semantics unless explicitly defined
- MUST NOT be assumed to be propagated to the external system
- SHOULD be used to store internal trace contexts (e.g., the span that created the event)

---

### headers

A set of key-value pairs intended to be delivered to the external system as transport-level headers.
**This data is intended for the message consumer.**

- If present, MUST be included in the publish operation when the target system supports equivalent header semantics
- MUST be preserved as-is during the publish operation
- MAY be used by consumers for routing, filtering, or processing logic
- MAY be empty

---

### last_error

Information about the last failure.

- MAY include error message or code
- SHOULD be updated on failure

---

### locked_at

The timestamp at which the event was claimed.

- MUST be set when the event transitions to `DELIVERING`
- MAY be used for lease expiration or stuck detection
- MUST be cleared when the event leaves the `DELIVERING` status unless retained for debugging purposes

---

### locked_by

An identifier for the specific relay instance that has claimed the event.

- SHOULD be set when the event transitions to `DELIVERING`
- SHOULD be used in conjunction with `locked_at` to provide fencing 
and identify ownership in distributed environments

---

### delivered_at

The timestamp at which the event was successfully published.

- MUST be set when the event transitions to `DELIVERED`
- MUST NOT be modified afterward

---

### updated_at

The timestamp at which the event was updated.

- MUST be set when any change happens to the event.

---

## Mutability Rules

Event fields MUST follow these mutability constraints:

### Immutable fields

The following fields MUST NOT change after creation:

- `event_id`
- `event_type`
- `ordering_key`
- `partition_key`
- `payload`
- `headers`
- `created_at`

---

### Mutable fields

The following fields MAY change during processing:

- `status`
- `attempts`
- `locked_by`
- `last_error`
- `available_at`
- `locked_at`
- `delivered_at`
- `updated_at`

---

## Status Constraints

Status transitions MUST follow the processing lifecycle defined in the
[Processing Lifecycle](./05-processing-lifecycle.md) section.

Invalid transitions MUST NOT occur.

---

## Field Consistency Constraints

The following invariants MUST hold:

- `locked_at` MUST be set if and only if `status = DELIVERING`
- `delivered_at` MUST be set if and only if `status = DELIVERED`
- `locked_by` MUST be set when `status = DELIVERING` if supported by the implementation

## Identity and Delivery Semantics

The `event_id` field MAY be used by downstream systems to detect and discard duplicate events.

By default, this specification assumes at-least-once delivery, and events MAY be delivered more than once.

Implementations MAY provide stronger guarantees, including effectively-once or exactly-once delivery, when supported by the underlying storage, broker, and processing model.

Such guarantees MUST clearly document:

- required conditions
- limitations
- failure modes

---

## Extensibility

Implementations MAY extend the event model with additional fields for internal processing, coordination, observability, or storage-specific behavior.

Additional fields MUST NOT violate:

- delivery semantics
- ordering guarantees
- status transitions
- core field definitions
