# Ordering and Partitioning

## Overview

This section defines how ordering and partitioning are expressed within the outbox system.

Ordering and partitioning are distinct concerns:

- **ordering** defines the relative sequence in which events are processed or delivered
- **partitioning** defines how events are routed to the target system

This specification does NOT require ordering or partitioning, but defines how they are represented when supported.

---

## Ordering Model

This specification does NOT guarantee global ordering.

When ordering is enabled:

- ordering MUST be scoped to an `ordering_key`
- events with the same `ordering_key` MUST be processed in order according to the configured ordering rules

When ordering is not enabled:

- events MAY be processed in any order

---

## Ordering Scope

The `ordering_key` defines the scope within which ordering is preserved.

Examples of ordering scope include:

- per aggregate
- per entity
- per tenant
- per logical stream

The meaning of the `ordering_key` is application-defined.

---

## Ordering Guarantees

When relay-level ordering is enabled:

- events sharing the same `ordering_key` MUST NOT be processed out of order
- implementations MAY restrict concurrency within the same ordering scope
- implementations MAY allow concurrent processing across different ordering scopes

Ordering guarantees apply only within the same `ordering_key`.

---

## Ordering and Concurrency

Ordering MAY require coordination that limits concurrency.

Implementations that enforce ordering MAY:

- serialize processing within an ordering scope
- delay processing of later events until earlier events are completed
- prevent duplicate claiming within an ordering scope

Such coordination MUST NOT violate delivery semantics or processing lifecycle rules.

---

## Partitioning Model

The `partition_key` is used for routing or partition selection in the target system.

When the target system supports partitioning:

- the publisher SHOULD use `partition_key` when provided

When the target system does not support partitioning:

- the `partition_key` MAY be ignored

Partitioning by itself does NOT define ordering semantics.

---

## Relationship Between Ordering and Partitioning

The `ordering_key` and `partition_key` are distinct fields and MAY have different values.

Implementations MAY choose to map them to the same value, but this specification does NOT require that.

Examples:

- ordering by aggregate, partitioning by tenant
- ordering by tenant, partitioning by broker-specific routing key
- no ordering, but partitioning enabled for transport routing

---

## Ordered Reprocessing

When ordering is enabled and an event becomes eligible for retry or reprocessing:

- implementations SHOULD preserve ordering within the same `ordering_key`
- later events in the same ordering scope MAY need to wait until earlier events are completed or terminated

The exact coordination strategy is implementation-defined.

---

## Failure and Ordering

Failures within an ordering scope MAY affect later events in the same scope.

Implementations MAY choose to:

- block later events until the failed event is resolved
- allow limited progress under documented constraints

Such behavior MUST be explicitly documented when ordering is enabled.

---

## Partitioning and Delivery

Partitioning MAY influence how events are delivered to the target system, but MUST NOT alter the delivery semantics defined by this specification.

In particular:

- partitioning MUST NOT change the meaning of success or failure
- partitioning MUST NOT weaken delivery guarantees

---

## Extensibility

Implementations MAY define additional ordering or partitioning strategies.

Such strategies MUST NOT violate:

- delivery semantics
- processing lifecycle rules
- core definitions of `ordering_key` and `partition_key`