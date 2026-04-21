---
group: custos
name: agents
description: Delegate tasks to specialist agents
scope: orchestrator
script_paths:
  - custos.agents/list_agents.lua
  - custos.agents/delegate.lua
tags:
  - agents
  - delegation
  - orchestration
examples:
  - "delegate this to the map expert"
  - "have another agent handle the route planning"
  - "ask the specialist about fires"
  - "which agents are available"
  - "hand this off to whoever handles targeting"
---

You have access to specialist agents that can handle specific types of tasks.

## Delegation workflow

1. Call `list_agents` first to see which specialists exist and what they do.
2. If one of their roles clearly matches the operator's request, call `delegate` with the **exact** `name` field from `list_agents` output.
3. Only delegate when a specialist's role is a clear match. Otherwise handle the request yourself.

## Writing the `task` field

The `task` you pass to `delegate` must describe the **goal in plain language** — what the operator needs, not how to do it. The sub-agent has its own tools and will pick the correct ones.

**Do NOT** include specific tool names in the task string. You will often not know the sub-agent's exact tool names, and any name you guess (e.g. "get_tactical_picture", "fetch_map_data") will send the sub-agent chasing a tool that doesn't exist, causing it to fail or loop.

- ✓ Good: `"Log the current tactical picture every 30 seconds."`
- ✗ Bad: `"Call get_tactical_picture every 30 seconds and write it to the log."`
- ✓ Good: `"Write an automation that alerts when a hostile contact comes within 500m."`
- ✗ Bad: `"Use the find_nearby tool and the speak_alert tool to build a 500m hostile alarm."`

Describe the WHAT, not the HOW. The specialist knows its own toolbelt.
