# Operations and Replay

## Overview

This section defines the operational capabilities of the outbox system.

It covers:

- inspection of event state
- replay of events
- manual intervention
- operational control and safety

---

## Operational Inspection

Implementations MUST provide a way to inspect event state.

Inspection capabilities SHOULD include:

- listing events by state (e.g., `PENDING`, `CLAIMED`, `PUBLISHED`, `DEAD`)
- filtering events by time range (e.g., `created_at`, `published_at`)
- viewing event details, including:
  - `payload`
  - `headers`
  - `metadata`
  - `attempts`
  - `last_error`

Inspection MUST NOT modify event state.

---

## Replay

Replay is an explicit operation that re-schedules an event for processing.

Replay:

- MUST transition an event to a processable state (e.g., `PENDING`)
- MUST reset or update fields required for reprocessing

Replay MAY be applied to events in:

- `DEAD`
- `PUBLISHED`

Replay MUST NOT violate:

- state transition rules
- delivery semantics

---

## Replay Semantics

When an event is replayed:

- it enters a new processing lifecycle
- duplicate delivery MAY occur
- ordering constraints MUST be respected when ordering is enabled

Replay MUST NOT assume idempotency.

---

## Replay Behavior

Implementations MAY define replay behavior, including:

- resetting `attempts`
- clearing `last_error`
- updating `available_at`

Replay behavior MUST be documented.

---

## Manual Intervention

Operators MAY perform manual actions, including:

- triggering replay
- modifying retry scheduling (e.g., updating `available_at`)
- moving events to `DEAD`
- restoring events to `PENDING`

Manual actions MUST:

- respect valid state transitions
- preserve delivery semantics

---

## Stuck Event Handling

Implementations SHOULD provide mechanisms to detect and handle stuck events.

Examples include:

- events in `CLAIMED` state beyond expected duration
- events repeatedly failing without progress

Implementations MAY:

- release expired claims
- reprocess stuck events
- surface alerts for operator action

---

## Safety Considerations

Operational actions MUST be safe.

In particular:

- actions MUST NOT cause event loss
- actions MAY result in duplicate delivery
- actions MUST preserve system correctness

Operators MUST assume that:

- replay can produce duplicates
- manual intervention can affect ordering

---

## Bulk Operations

Implementations MAY support bulk operations, such as:

- replaying multiple events
- filtering and replaying by time range
- retrying all events in a given state

Bulk operations MUST:

- respect ordering constraints when enabled
- avoid violating delivery semantics

---

## Observability

Implementations SHOULD expose metrics and logs related to:

- publish success and failure rates
- retry counts and backoff behavior
- number of events in each state
- processing latency

Observability MUST support debugging and operational monitoring.

---

## Auditability

Implementations SHOULD provide auditability for operational actions.

Examples include:

- tracking replay operations
- recording manual state changes
- logging operator interventions

---

## Guarantees

Operational features MUST NOT violate:

- delivery semantics
- processing lifecycle rules
- event durability guarantees