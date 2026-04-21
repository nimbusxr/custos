---
group: custos
name: cot_comms
description: Send CoT events and chat messages to other TAK users and groups
script_paths:
  - custos.cot_comms/send_cot.lua
  - custos.cot_comms/send_chat.lua
  - custos.cot_comms/read_chat.lua
tags:
  - cot
  - chat
  - comms
  - messaging
  - network
  - broadcast
examples:
  - "send a chat message to Alpha team"
  - "broadcast position update"
  - "send a CoT event"
  - "message all stations that we're moving to phase line"
  - "read the latest chat messages"
---

# CoT Comms

Send and receive Cursor on Target events and GeoChat messages across the TAK network.

- `send_cot` — Broadcast a CoT event (marker, position, alert) to all connected TAK users
- `send_chat` — Send a GeoChat message to a specific contact or all-chat
- `read_chat` — Read recent GeoChat messages from conversations
