# Retries and Failures

## Overview

This section defines how failed publish attempts are handled and how retry behavior is applied.

Retry behavior is part of the processing lifecycle but is governed by implementation-defined policies.

---

## Retry Principle

Failed publish attempts MUST result in a retry unless termination conditions are met.

Retries occur within the normal processing lifecycle.

---

## Retry Scheduling

Implementations MAY apply retry scheduling strategies, including:

- immediate retry
- delayed retry using `available_at`
- backoff strategies (e.g., exponential, linear)

When delay is applied:

- `available_at` SHOULD be updated to control when the event becomes eligible again

---

## Retry Policies

Retry policies MUST be defined by the implementation.

Policies MAY include:

- maximum number of attempts
- time-based retry limits
- backoff strategies
- prioritization rules

Retry policies MUST NOT violate:

- delivery semantics
- processing lifecycle rules

---

## Failure Classification

Implementations MAY classify failures to determine retry behavior.

Examples include:

- transient failures (e.g., network issues, temporary broker unavailability)
- permanent failures (e.g., invalid payload, schema mismatch)

Classification MAY influence:

- retry timing
- termination decisions

---

## Termination Conditions

Termination conditions define when an event is no longer eligible for automatic retry.

When termination conditions are met:

- the event MUST transition to `DEAD`
- the event MUST NOT be retried automatically

Termination conditions are implementation-defined.

---

## Dead Events

Events in the `DEAD` state:

- MUST NOT be retried automatically
- MAY require operator intervention
- MAY be replayed

---

## Operator Intervention

Operators MAY:

- inspect failed or dead events
- trigger replay of events
- override retry behavior

Operator actions MUST respect:

- state transition rules
- delivery semantics

---

## Backoff and Scheduling

Implementations MAY use backoff strategies to avoid overwhelming the target system.

Backoff strategies SHOULD:

- reduce retry frequency over time
- prevent tight retry loops

---

## Failure Visibility

Implementations SHOULD provide visibility into failures, including:

- error details (`last_error`)
- retry attempts (`attempts`)
- timing (`available_at`, `claimed_at`)

This information SHOULD support debugging and operational monitoring.

---

## Idempotency Considerations

Since retries may result in duplicate delivery:

- consumers SHOULD be idempotent
- implementations MAY use `event_id` for deduplication

---

## Guarantees

Retry behavior MUST preserve:

- delivery semantics
- state transition correctness
- event durability