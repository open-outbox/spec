# OpenOutbox Specification

[![Status: Draft](https://img.shields.io/badge/Status-Draft-yellow.svg)](./#status)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**Open Outbox** is a language-agnostic specification for the **Transactional Outbox Pattern**. It defines how events move from a primary storage (PostgreSQL, MongoDB) to a message broker (Kafka, NATS, RabbitMQ) with solid reliability.

---

## 🗺️ Specification Roadmap

If you are new to OpenOutbox, start with the **Foundations**. If you are building an implementation, jump to **Technical Contracts**.

### 🏛️ Foundations

* [**Introduction**](docs/01-introduction.md) — The "Why" and the core problem solved.
* [**Terminology**](docs/02-terminology-and-concepts.md) — Definitions for Relays, Producers, and Stores.

### Core Concepts

* [**Event Model**](docs/03-event-model.md) — Anatomy of an outbox record.
* [**Delivery Semantics**](docs/04-delivery-semantics.md) — At-least-once vs. Exactly-once rules.
* [**Processing Lifecycle**](docs/05-processing-lifecycle.md) — State transitions (Pending → Delivering → Published).

### Technical Contracts

* [**Store Contract**](docs/06-store-contract.md) — How the database must behave.
* [**Publisher Contract**](docs/07-publisher-contract.md) — How the broker must behave.

### Reliability & Scale

* [**Retries and Failures**](docs/08-retries-and-failures.md) — Dead-lettering and backoff strategies.
* [**Ordering & Partitioning**](docs/09-ordering-and-partitioning.md) — Maintaining sequence at scale.

### Management

* [**Operations and Replay**](docs/10-replay-and-operations.md) — Manual overrides and disaster recovery.

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
