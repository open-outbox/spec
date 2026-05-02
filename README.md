<p align="center">
  <!-- Use an absolute URL for the logo if it's not in the spec repo yet -->
  <a href="https://github.com/open-outbox/spec">
    <img src="https://raw.githubusercontent.com/open-outbox/relay/main/docs/src/assets/logo.svg" width="250" alt="Open Outbox Specification">
  </a>
</p>

<p align="center">
    <em>The language-agnostic standard for reliable Transactional Outbox implementations.</em>
</p>

<p align="center">
<a href="https://img.shields.io/badge/Status-Draft-yellow">
    <img src="https://img.shields.io/badge/Status-Draft-yellow" alt="Status">
</a>
<a href="https://img.shields.io/badge/Version-1.0.0-blue">
    <img src="https://img.shields.io/badge/Version-1.0.0-blue" alt="Version">
</a>
<a href="https://pkg.go.dev/github.com/open-outbox/relay">
    <img src="https://img.shields.io/badge/Implementation-Go-007d9c?logo=go&logoColor=white" alt="Reference Implementation">
</a>
</p>

# Open Outbox Specification

**Open Outbox** is a language-agnostic specification for the **Transactional Outbox Pattern**. It defines how events move from a primary storage (PostgreSQL, MySQL) to a message broker (Kafka, NATS, RabbitMQ) with solid reliability.

---

## Specification Roadmap

If you are new to Open Outbox, start with the **Foundations**. If you are building an implementation, jump to **Technical Contracts**.

### Foundations

* [**Introduction**](docs/01-introduction.md) — The "Why" and the core problem solved.
* [**Terminology**](docs/02-terminology.md) — Definitions for Relays, Producers, and Stores.

### Core Concepts

* [**Event Model**](docs/03-event-model.md) — Anatomy of an outbox record.
* [**Delivery Semantics**](docs/04-delivery-semantics.md) — At-least-once vs. Exactly-once rules.
* [**Processing Lifecycle**](docs/05-processing-lifecycle.md) — State transitions (Pending → Delivering → Published).

### Technical Contracts

* [**Store Contract**](docs/06-store-contract.md) — How the database must behave.
* [**Publisher Contract**](docs/07-publisher-contract.md) — How the broker must behave.

### Reliability & Scale

* [**Retries and Failures**](docs/08-retries-and-failures.md) — Dead-lettering and backoff strategies.
* [**Ordering and Partitioning**](docs/09-ordering-and-partitioning.md) — Maintaining sequence at scale.

### Management

* [**Replay and Operations**](docs/10-replay-and-operations.md) — Manual overrides and disaster recovery.

---

## Goals

* **Portability:** Write your logic once, swap Postgres for MySQL or Kafka for NATS easily.
* **Separation of Concerns:** Decouple delivery semantics from business logic.
* **Explicit Guarantees:** No "magic" delivery; every failure mode is defined.
* **Conformance:** Enable automated testing to prove an implementation follows the spec.

## Non-Goals

* We do **not** dictate a specific SQL schema (only the required fields).
* We do **not** replace broker-native features (like Kafka's idempotent producer).

---

## Status

Currently in **Draft**. We are validating the spec against the [Go-based Relay implementation](https://github.com/openoutbox/relay).
