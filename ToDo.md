Rename Storage to Store in relay
Rename status to state
Rename status values e.g. Delivering to Claimed
Event Model:
    event_id
    event_type
    payload
    state
    created_at
    partition_key
    ordering_key
    metadata
    headers
    attempts
    last_error
    available_at
    claimed_at
    published_at

