# Publisher Contract

## Overview

The publisher contract defines the responsibilities and required behavior of a publisher component.

A publisher is responsible for delivering events to an external system.

---

## Core Responsibilities

An implementation of the publisher contract MUST:

- accept an event for publishing
- attempt to deliver the event to the target system
- report the outcome of the publish attempt

---

## Publish Operation

The publisher MUST expose a publish operation that:

- accepts an event
- attempts to deliver the event to the target system
- returns a result indicating success or failure

The publish operation MUST be treated as a single attempt.

---

## Success and Failure

For each publish attempt, the publisher MUST report:

- **success** when the event is accepted by the target system
- **failure** when the event cannot be delivered

The publisher MUST NOT perform retries internally unless explicitly documented.

---

## Acknowledgement

- A successful publish attempt MUST correspond to an acknowledgement from the target system
- The definition of acknowledgement MAY vary depending on the system (e.g., broker acknowledgement, HTTP success response)

The publisher MUST clearly define what constitutes success.

---

## Headers and Payload

The publisher MUST:

- deliver the `payload` as provided by the event
- include `headers` when supported by the target system

The publisher MUST NOT modify the payload.

The publisher MAY:

- enrich or modify headers prior to publishing

---

## Partitioning

If the target system supports partitioning:

- the publisher SHOULD use `partition_key` when provided

If not supported:

- the publisher MAY ignore the `partition_key`

---

## Ordering

The publisher does NOT guarantee ordering.

Ordering guarantees, if any, are defined by:

- the relay
- the target system

---

## Idempotency

The publisher does NOT guarantee idempotent delivery.

If the target system supports idempotency:

- the publisher MAY use `event_id` or equivalent mechanisms

---

## Error Reporting

On failure, the publisher SHOULD provide error information that:

- helps diagnose the failure
- can be recorded in `last_error`

Error formats are implementation-specific.

---

## Concurrency

The publisher MUST be safe to use under concurrent invocation.

---

## Stronger Guarantees

If the publisher supports stronger guarantees (e.g., transactional publishing):

- such guarantees MUST be explicitly documented
- required conditions and limitations MUST be defined

The publisher MUST NOT imply stronger guarantees unless explicitly configured.