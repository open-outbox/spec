# Storage Contract

## Overview

The storage contract defines the responsibilities and required behavior of the outbox store.

The storage is responsible for:

- persisting events durably
- exposing events for processing
- supporting claiming and state transitions
- ensuring correctness under concurrent access

---

## Core Responsibilities

An implementation of the storage contract MUST:

- persist events before they are eligible for processing
- provide a mechanism to retrieve eligible events
- support claiming of events
- support state transitions as defined in the processing lifecycle
- ensure that no event is lost once persisted

---

## Event Persistence

- Events MUST be durably persisted before any publish attempt
- Persistence MUST succeed before the event becomes visible for processing
- Persisted events MUST be retrievable until they reach a terminal state

---

## Event Retrieval

The storage MUST provide a way to retrieve events that are eligible for processing.

An event is eligible when:

- its state is `PENDING`
- if `available_at` is present, it is in the past or equal to the current time

If `available_at` is not present, the event MUST be considered immediately eligible for processing.

The retrieval operation MUST accept a caller-provided limit on the number of events to return.

The storage MAY return fewer events than requested, but MUST NOT return more.

Implementations MAY apply ordering or prioritization strategies, unless explicitly defined by the caller.

---

## Claiming

The storage MUST support claiming of events.

Claiming MUST:

- transition the event from `PENDING` to `CLAIMED`
- set `claimed_at` if the field is supported by the implementation

Claiming MUST be safe under concurrent access.

Implementations MUST ensure:

- events are not permanently lost due to concurrent claims
- duplicate claims MAY occur and MUST be tolerated

---

## State Updates

The storage MUST support updating event state according to the processing lifecycle.

State updates MUST:

- follow valid transitions only
- be atomic at the event level
- be durable

Invalid state transitions MUST NOT occur.

---

## Retry Support

The storage MUST support retry execution by allowing an event to become eligible for subsequent processing when termination conditions are not met.

If supported by the implementation, retry-related updates MAY include:

- incrementing `attempts`
- updating `last_error`
- updating `available_at`

The storage MUST NOT define retry policy itself unless explicitly specified by the implementation.

---

## Terminal State Handling

Events in terminal states (`PUBLISHED`, `DEAD`) MUST:

- remain accessible for inspection
- NOT be returned as eligible for processing

---

## Concurrency Requirements

The storage MUST operate correctly under concurrent access.

Implementations MUST ensure:

- no event is lost due to concurrent operations
- state transitions remain valid under concurrency
- partial updates do not corrupt event state

---

## Claim Expiration

Implementations MAY support claim expiration.

If supported:

- expired claims MUST allow the event to be reprocessed
- the event MUST become eligible for reprocessing again (e.g., transition to `PENDING` or equivalent behavior)

---

## Ordering Support

The storage MAY support ordering-aware retrieval.

If ordering is enabled:

- events with the same `ordering_key` SHOULD be retrieved in order
- implementations MAY restrict concurrent claims within an ordering scope

---

## Extensibility

Implementations MAY include additional mechanisms such as:

- partitioning or sharding strategies
- indexing for efficient retrieval
- lease or lock metadata (e.g., `claimed_by`)

Such extensions MUST NOT violate:

- delivery semantics
- state transitions
- processing lifecycle guarantees