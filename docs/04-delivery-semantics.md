# Delivery Semantics

## Overview

Delivery semantics define the guarantees provided by the outbox system when publishing events to external systems.

This specification defines a default delivery model and allows stronger guarantees when supported by the storage, relay, and publisher collectively.

---

## Delivery Models

Common delivery models include:

- **At-most-once**: messages may be lost, but are not duplicated
- **At-least-once**: messages are delivered one or more times (duplicates possible)
- **Effectively-once**: duplicates may occur, but the final outcome is as if delivered once
- **Exactly-once**: messages are delivered once and only once

This specification defines at-least-once delivery as the default model.

---

## Default Guarantee

By default, implementations MUST provide:

- **at-least-once delivery**

This means:

- the system MUST attempt delivery until success or terminal state is reached
- duplicate delivery MAY occur

---

## Delivery Success

An event is considered successfully delivered when the publisher reports success.

- Delivery MUST be determined solely based on publisher acknowledgement
- Delivery does NOT imply downstream processing or consumption

---

## Duplicate Delivery

Under the default at-least-once delivery model, implementations MUST assume that an event MAY be delivered more than once.

Duplicate delivery MAY occur due to, but not limited to:

- relay crashes after publishing but before state update
- retries after timeouts or failures
- claim expiration and reprocessing

When stronger delivery guarantees (e.g., effectively-once or exactly-once) are enabled and correctly configured, duplicate delivery MAY be avoided within the documented constraints.

Implementations MUST NOT assume exactly-once delivery unless explicitly configured and supported.

---

## Ordering and Delivery

This specification does NOT guarantee global ordering.

When ordering is enabled:

- ordering MUST be enforced within the scope of an [`ordering_key`](./03-event-model.md/#ordering_key)
- ordering guarantees apply only within that scope

Delivery semantics MUST remain independent of ordering configuration.

---

## Stronger Guarantees

Implementations MAY provide stronger delivery guarantees, including:

- effectively-once delivery
- exactly-once delivery

Such guarantees MUST:

- clearly document required conditions (e.g., idempotency, transactional support)
- define their limitations and failure modes
- remain compatible with the core event model and processing lifecycle

Stronger guarantees MUST NOT be assumed unless explicitly enabled.

---

## Idempotency

The outbox system does NOT guarantee idempotent delivery.

Consumers MAY use the `event_id` field to detect and discard duplicate events.

---

## Failure Handling

If a publish attempt fails:

- the event MUST remain eligible for retry according to retry rules
- the event MUST NOT be considered delivered

If retries are exhausted:

- the event MUST transition to [`DEAD`](./02-terminology-and-concepts.md/#dead-event)
