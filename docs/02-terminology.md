# Terminology and Concepts

## Application (Producer)

The system responsible for executing business logic and persisting an [Event](#event)
into the [Outbox Store](#outbox-store) within a single atomic boundary.

## Event

A durable record representing a message intended for an external system.
It is the primary unit of work and is considered immutable once persisted.

## Outbox Store

The authoritative storage system (Relational, Document, or Key-Value) that
holds Events and tracks their processing state.

## Relay

The runtime service that identifies, claims, and orchestrates
the delivery of Events from the Store to the Publisher.

## Publisher

The component or driver responsible for the technical handoff of an Event to an external broker (e.g., Kafka, NATS, SQS).

## Claim & Lease

A **Claim** is a temporary lock on an Event by a Relay. The **Lease** is the duration for which that lock is valid. If a lease expires without a state update, the event becomes eligible for re-claiming.

## Delivery & Acknowledgement

**Delivery** is the act of handing an event to a Publisher. Success is
defined by **Acknowledgement**, where the Publisher confirms receipt of the message.

## Delivery Guarantee

The reliability contract of the system. OpenOutbox defaults to **at-least-once delivery**, 
meaning duplicates are possible but data loss is prevented.

## Retry vs. Replay

A **Retry** is an automatic attempt to publish an event that failed or timed out.
A **Replay** is a manual or operator-triggered action to re-process an event that
has already reached a terminal state.

## Dead Event

An event that has reached a **Termination Condition** (e.g., max attemts) and is
no longer eligible for automatic processing.

## Partitioning & Ordering

**Partitioning** is a routing mechanism used for broker-side scaling.
**Ordering** is the guarantee that events within a specific scope 
(defined by an **Ordering Key**) are delivered in sequence.

## Operational Inspection

The ability for an **Operator** to query, filter, and analyze the state of the Outbox Store for monitoring or debugging.