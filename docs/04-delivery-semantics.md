# Delivery Semantics

## Overview

Delivery semantics define the reliability contract
between the Outbox system and external consumers.
This document outlines the default expectations for
message arrival and sequence across different
implementation strategies.

---

## Delivery Models

While various distributed systems support different models,
OpenOutbox focuses on the following:

- **At-least-once (Default)**: Events are guaranteed
to be delivered one or more times. Data loss is
prevented, but duplicates may occur.
- **Exactly-once**: Events are delivered once and
only once. This requires specialized support from
both the Store and the Publisher (e.g., Kafka Idempotent Producers).

---

## Default Guarantee: At-Least-Once

By default, all OpenOutbox implementations MUST
provide **at-least-once delivery**.

### Why Duplicates Occur

The system prioritizes durability over uniqueness.
Duplicates typically occur in "partial failure" or
"state-sync" scenarios:

- **Relay Failure**: A Relay crashes after successful
publication but before the status update is persisted
in the Store.
- **Ack Timeout**: A network timeout occurs where the
Broker receives the message, but the Relay never
receives the acknowledgement (ACK).
- **Lease Expiry**: In Polling strategies, a
[Lease](./02-terminology.md#lease) expires and a
second Relay picks up the event while the first is
still processing.
- **Offset Reset**: In Log-tailing strategies (CDC),
the reader restarts from a previous position in the
transaction log, re-processing events already sent.

---

## Delivery Success

An event is considered successfully delivered when the [Publisher](./07-publisher-contract.md) confirms the broker has accepted responsibility for the message.

- **Acknowledgement**: For Polling Relays, delivery
is determined by a successful broker ACK. For CDC
Relays, success is defined by the successful
persistence of the transport offset.
- **Scope**: Delivery success indicates the Broker
has accepted responsibility for the message; it does
not imply downstream consumption or successful
processing by the end-user.

---

## Idempotency

The Outbox system provides the tools for idempotency
but does not enforce it.

Downstream consumers SHOULD use the `event_id`
provided in the event to detect and discard duplicate
processing. Providing a unique `event_id` is a core
requirement of the [Event Model](./03-event-model.md).

---

## Stronger Guarantees

Implementations MAY offer Exactly-once delivery. Such
implementations MUST:

- Document the specific technical requirements (e.g.,
Transactional Producers).
- Clearly define performance trade-offs
