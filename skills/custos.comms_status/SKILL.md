---
group: custos
name: comms_status
description: Monitor network health, TAK server connectivity, and active feeds
script_paths:
  - custos.comms_status/get_network_status.lua
tags:
  - network
  - comms
  - server
  - status
  - connectivity
examples:
  - "check network status"
  - "are we connected to the TAK server"
  - "what's our comms health"
  - "is the server up"
---

# Comms Status

Network and connectivity monitoring tools.

- `get_network_status` — Query TAK server connectivity, active streams, and network health
