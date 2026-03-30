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
- `state`
- `created_at`

### event_id

A unique identifier for the event.

- MUST be unique within the outbox store
- MUST be immutable

---

### event_type

A logical identifier describing the type of the event.

- MUST be a stable, versionable identifier (e.g., `user.created`, `order.updated`)
- MUST be immutable
- MUST NOT depend on the underlying transport or broker

---

### payload

The data to be delivered to the external system.

- MAY be any structured or unstructured data
- MUST be treated as opaque by the outbox system
- MUST NOT be modified by the relay

---

### state

The current [processing state](./02-terminology-and-concepts.md/#processing-state) of the event.

- MUST be one of:
  - `PENDING`
  - `CLAIMED`
  - `PUBLISHED`
  - `DEAD`
- MUST be managed by the relay according to the processing lifecycle

---

### created_at

The timestamp at which the event was created.

- MUST be set when the event is persisted
- MUST be immutable

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

- When relay-level ordering is enabled, events with the same ordering key MUST be processed in order according to the configured ordering rules.

---

### metadata

Additional information associated with the event for internal or operational use.

- MAY include tracing identifiers, source information, or annotations
- MAY be used by the relay for processing, debugging, or observability
- MUST NOT affect delivery semantics unless explicitly defined
- MUST NOT be assumed to be propagated to the external system

---

### headers

A set of key-value pairs intended to be delivered to the external system as transport-level headers.

- If present, MUST be included in the publish operation when the target system supports equivalent header semantics
- MUST be preserved as-is during the publish operation
- MAY be modified by the relay or publisher prior to publishing (e.g., for enrichment or tracing)
- MAY be used by consumers for routing, filtering, or processing logic
- MAY be empty

---

### attempts

The number of publish attempts for the event.

- MUST be monotonically increasing
- MUST be incremented on each publish attempt, including retries and replay
- MAY be used to determine retry behavior

---

### last_error

Information about the last failure.

- MAY include error message or code
- SHOULD be updated on failure

---

### available_at

The timestamp at which the event becomes eligible for processing.

- MAY be used for delayed processing, retry backoff, or scheduling
- Events MUST NOT be claimed before this time when the field is used
- If not present, the event is considered immediately eligible for processing

---

### claimed_at

The timestamp at which the event was claimed.

- MUST be set when the event transitions to `CLAIMED`
- MAY be used for lease expiration or stuck detection

---

### published_at

The timestamp at which the event was successfully published.

- MUST be set when the event transitions to `PUBLISHED`
- MUST NOT be modified afterward

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
- `created_at`

---

### Mutable fields

The following fields MAY change during processing:

- `headers`
- `state`
- `attempts`
- `last_error`
- `available_at`
- `claimed_at`
- `published_at`

---

## State Constraints

State transitions MUST follow the processing lifecycle defined in the Processing Lifecycle section.

Invalid transitions MUST NOT occur.

---

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
- state transitions
- core field definitions
