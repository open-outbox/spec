# Delivery Semantics

## Overview

Delivery semantics define the reliability contract between the Outbox system and external consumers. This document outlines the default expectations for message arrival and sequence.

---

## Delivery Models

While various distributed systems support different models, OpenOutbox focuses on the following:

- **At-least-once (Default)**: Events are guaranteed to be delivered one or more times.
Data loss is prevented, but duplicates may occur.
- **Exactly-once**: Events are delivered once and only once. This requires specialized
support from both the Store and the Publisher (e.g., Kafka Transactions or SQS FIFO).

---

## Default Guarantee: At-Least-Once

By default, all OpenOutbox implementations MUST provide **at-least-once delivery**.

### Why Duplicates Occur

Under this model, the system prioritizes **durability over uniqueness**. Duplicates
typically occur in "partial failure" scenarios, such as:

- A Relay successfully publishes an event but crashes before it can update
the status in the Store.
- A network timeout occurs where the Broker receives the message,
but the Relay never receives the acknowledgement.
- A [Lease](./02-terminology-and-concepts.md#lease) expires and a
second Relay picks up the event while the first is still processing.

---

## Delivery Success

An event is considered successfully delivered when the
[Publisher](./02-terminology-and-concepts.md#publisher) reports a successful acknowledgement (ACK).

- **Scope:** Delivery success is determined solely by the Publisher's response.
- **Limitation:** Success does NOT imply that a downstream consumer has
successfully processed or even received the message—only that the 
Broker has accepted responsibility for it.

---

## Ordering and Delivery

This specification does NOT guarantee global ordering across the entire Outbox Store.

When [Ordering](./03-event-model.md#ordering_key) is enabled:

- Sequence MUST be enforced only within the scope of a specific `ordering_key`.
- Events sharing an `ordering_key` MUST be delivered in the order they were persisted.
- Delivery semantics (At-least-once) remain the same even when ordering is active.

---

## Idempotency

The Outbox system provides the tools for idempotency but does not enforce it.

To handle the default at-least-once behavior, **Downstream Consumers**
SHOULD use the `event_id` provided in the event headers or payload to
detect and discard duplicate processing.

---

## Failure Handling & Retries

If a publish attempt fails or the Publisher returns an error:

1. **Retry Eligibility:** The event MUST remain eligible for retry.
2. **Backoff:** The Relay SHOULD update the `available_at` timestamp to delay the next attempt.
3. **Attempt Count:** The `attempts` counter MUST be incremented.
4. **Terminal State:** If the maximum number of attempts is reached, or if the publisher
returns a non-retriable error (e.g., message format error or payload size limit),
the event MUST transition to the DEAD status.

---

## Stronger Guarantees

Implementations MAY offer Exactly-once delivery. Such implementations MUST:

- Document the specific requirements (e.g., "Requires Kafka 3.x with Idempotent Producer enabled").
- Clearly define the performance trade-offs or limitations.
