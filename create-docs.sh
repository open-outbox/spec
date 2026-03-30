#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="openoutbox-spec"

mkdir -p "$ROOT_DIR/docs" "$ROOT_DIR/examples"

touch "$ROOT_DIR/README.md"
touch "$ROOT_DIR/docs/01-introduction.md"
touch "$ROOT_DIR/docs/02-core-concepts.md"
touch "$ROOT_DIR/docs/03-event-model.md"
touch "$ROOT_DIR/docs/04-delivery-semantics.md"
touch "$ROOT_DIR/docs/05-processing-lifecycle.md"
touch "$ROOT_DIR/docs/06-storage-contract.md"
touch "$ROOT_DIR/docs/07-publisher-contract.md"
touch "$ROOT_DIR/docs/08-retries-and-failures.md"
touch "$ROOT_DIR/docs/09-ordering-and-partitioning.md"
touch "$ROOT_DIR/docs/10-operations-replay.md"
touch "$ROOT_DIR/examples/postgres-kafka.md"
touch "$ROOT_DIR/examples/mongodb-rabbitmq.md"

echo "Created directory structure and empty files in $ROOT_DIR"