# Delivery Semantics

## Overview

Delivery semantics define the reliability contract between the Outbox system and external consumers. This document outlines the default expectations for message arrival and sequence.

---

## Delivery Models

While various distributed systems support different models, OpenOutbox focuses on the following:

- **At-least-once (Default)**: Events are guaranteed to be delivered one or more times.
Data loss is prevented, but duplicates may occur.
- **Exactly-once**: Events are delivered once and only once. This requires specialized
support from both the Store and the Publisher.

---

## Default Guarantee: At-Least-Once

By default, all OpenOutbox implementations MUST provide **at-least-once delivery**.

### Why Duplicates Occur

The system prioritizes durability over uniqueness. Duplicates
typically occur in "partial failure" scenarios:

- A Relay crashes after successful publication but before the status update.
- A network timeout occurs where the Broker receives the message, but the Relay never receives the ACK.
- A [Lease](./02-terminology-and-concepts.md#lease) expires and a
second Relay picks up the event while the first is still processing.

---

## Delivery Success

An event is considered successfully delivered when the
[Publisher](./02-terminology-and-concepts.md#publisher) reports a successful acknowledgement (ACK).

- **Acknowledgement:** Delivery MUST be determined solely based on publisher response.
- **Scope:** Delivery success indicates the Broker has accepted responsibility for the message; it does not imply downstream consumption.

---

## Ordering and Delivery

This specification does NOT guarantee global ordering across the entire Outbox Store.

When [Ordering](./03-event-model.md#ordering_key) is enabled:

- Sequence MUST be enforced within the scope of a specific `ordering_key`.
- Events sharing an `ordering_key` MUST be delivered in the order they were persisted.
- Delivery semantics (At-least-once) remain the same even when ordering is active.

---

## Idempotency

The Outbox system provides the tools for idempotency but does not enforce it.

Downstream consumers SHOULD use the `event_id` provided in the event to detect and discard duplicate processing.

---

## Stronger Guarantees

Implementations MAY offer Exactly-once delivery. Such implementations MUST:

- Document the specific technical requirements (e.g., Kafka Idempotent Producer).
- Clearly define performance trade-offs and limitations.
- Ensure compatibility with the core [Processing Lifecycle](./05-processing-lifecycle.md).