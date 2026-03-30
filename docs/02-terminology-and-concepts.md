# Terminology and Concepts

## Event

An **event** is a record representing a message intended to be published to an external system.

Events are stored in a durable [outbox store](#outbox-store).

An event consists of:

- identity
- payload
- metadata
- processing state

An event MUST be persisted before any publish attempt.

---

## Outbox Store

The **outbox store** is the durable storage system that holds events prior to publication.

Examples include:

- relational databases
- document databases
- append-only stores

The outbox store is the source of truth for event state.

---

## Publisher

A **publisher** is a component responsible for delivering events to an external system.

Examples include:

- Kafka producers
- NATS (core or JetStream) publishers
- RabbitMQ publishers
- SQS clients
- Redis publishers
- HTTP dispatchers

A publisher reports success or failure for each publish attempt.

---

## Relay

A **relay** is a runtime component that processes events from the outbox store.

A relay MUST:

1. read eligible events
2. claim events for processing
3. publish events using a publisher
4. update event state based on the outcome

Multiple relays MAY operate concurrently.

---

## Claim

A **claim** is a temporary ownership marker that allows a relay to process an event.

A claim:

- A claim MAY grant exclusive processing for a limited period of time.
- MAY expire
- DOES NOT guarantee that only one relay will ever process the event

Implementations MUST assume that the same event can be processed more than once.

---

## Acknowledgement

An **acknowledgement** is the point at which a publish attempt is considered successful.

Unless explicitly defined otherwise:

- acknowledgement occurs when the publisher reports success

Acknowledgement does NOT imply downstream consumption.

---

## Delivery

**Delivery** refers to the act of successfully publishing an event to an external system.

This specification assumes:

- delivery MAY occur more than once
- delivery is considered successful based on publisher acknowledgement

---

## Delivery Guarantee

A **delivery guarantee** defines how reliably events are delivered.

Unless otherwise specified, implementations SHOULD provide:

- **at-least-once delivery**

This means:

- an event will be delivered one or more times
- duplicate delivery is possible

> **Note**: Implementations MAY provide stronger delivery guarantees, such as effectively-once or exactly-once delivery, when supported by the underlying storage and broker.
>
> Such guarantees MUST clearly document:
>
> - required conditions (e.g., idempotency, transactional support)
> - limitations and failure modes

---

## Retry

A **retry** is a subsequent publish attempt for an event that has not yet been successfully delivered.

Retries occur automatically within the normal processing lifecycle and typically apply to events in a non-terminal state.

---

## Replay

A **replay** is an explicit action that re-schedules an event for processing after it has reached a terminal or completed state.

Replay is used to reprocess events that were previously considered finished (e.g., published or [dead](#dead-event)).

Replay is distinct from retry:

- [retry](#retry) occurs within the same processing lifecycle
- replay starts a new processing lifecycle

---

## Dead Event

A **dead event** is an event that is no longer automatically retried.

Dead events:

- MAY require manual intervention
- MAY be [replayed](#replay)

---

## Attempt

An **attempt** is a single publish execution for an event.

An event MAY have multiple attempts as part of retries or replay.

Implementations MAY track the number of attempts for each event.

---

## Processing State

**Processing state** represents the lifecycle stage of an event within the outbox system.

The state MUST be one of:

- `PENDING`
- `CLAIMED`
- `PUBLISHED`
- `DEAD`

The exact state model is defined in the [Event Model](./03-event-model.md) section.

---

## Partition Key

A partition key is a value used to select routing or partitioning behavior in the target transport or broker.

Events with the same partition key MAY be routed to the same broker partition or equivalent destination.

Partition keys do not, by themselves, define ordering guarantees unless explicitly stated by an implementation.

---

## Ordering Key

An ordering key is a value used to define the scope within which event ordering is preserved.

When ordering is supported, events with the same ordering key MUST be processed in order according to the applicable ordering rules.

---

## Ordering

Ordering defines the relative sequence in which events are processed or delivered.

This specification does NOT guarantee global ordering.

Ordering MAY be guaranteed within the scope of an [ordering key](#ordering-key).

When ordering is supported, events sharing the same [ordering key](#ordering-key) MUST be processed in order according to the defined ordering rules.

> **Note**: The [partition key](#partition-key) does NOT define ordering semantics and is used only for routing or transport-level partitioning.

---

## Operator

An **operator** is a human or automated system responsible for managing the outbox system.

Operators MAY:

- inspect [event state](#processing-state)
- trigger [replay](#replay)
- intervene in failure scenarios

---

## Operational Inspection

**Operational inspection** refers to querying and analyzing event state for monitoring and debugging.

Examples include:

- listing dead events
- filtering events by time range
- inspecting retry counts
- identifying stuck or unprocessed events

---

## Termination Condition

A **termination condition** defines when an event is no longer eligible for automatic retry.

When a termination condition is met:

- the event MUST transition to `DEAD`
- the event MUST NOT be retried automatically

Termination conditions are implementation-defined and MAY include:

- maximum number of attempts
- time-based limits
- explicit operator intervention
- implementation-specific policies
