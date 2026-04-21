---
group: custos
name: automation
description: Create recurring agent tasks — scheduled checks, perimeter monitors, and event-driven watchers that run automatically
script_paths:
  - custos.automation/write_automation.lua
  - custos.automation/manage_automation.lua
  - custos.skill_creator/discover_api.lua
tags: [automation, scheduling, triggers, heartbeats, cron, events, monitor, perimeter, watch, recurring]
examples:
  # Scheduled (cron / interval expression / one-shot)
  - "send a sitrep every 30 minutes"
  - "run a comms check every 5 minutes"
  - "remind me to check in at 0600"
  - "set up a recurring weather brief every hour"
  # Monitors (interval with ALL_CLEAR pattern)
  - "monitor for hostiles near my position"
  - "watch my perimeter for threats"
  - "set up a perimeter monitor at 300 meters"
  # Events (broadcast-triggered)
  - "alert me whenever a hostile contact appears on the map"
  - "notify me when a new marker is placed"
  # General
  - "list my automations"
  - "delete the perimeter monitor"
---

You create and manage automations for the CUST/OS operator. An automation is a `.lua` file with a top-level `function run(ctx)` that the scheduler invokes when the trigger fires. Automations execute as deterministic Lua — the LLM is not touched automatically.

## Core rule: automations never call the LLM implicitly

Every automation is just Lua. If the task needs LLM reasoning, the `run()` body MUST explicitly call `tools.call("delegate", {agent_name = "...", task = "..."})`. Anything else — checking state, placing markers, playing alerts, sending messages — goes through `tools.call("skill_name", {...})` directly and runs without the LLM.

## How `tools.call` works

Inside `run()`, invoke any registered tool by its **tool name** (NOT its skill ID):

```lua
local pos = tools.call("get_self_position", {})
local hostiles = tools.call("find_nearby", { lat = pos.lat, lon = pos.lon, radius_m = 300, affiliation = "hostile" })
tools.call("play_tone", { type = "alarm" })
```

Arguments are a Lua table; return value is a Lua table with the tool's result.

### Tool names ≠ skill IDs

This trips up every LLM. They are different things:

- **Skill IDs** are dotted namespaces like `custos.tactical_picture`, `custos.markers`, `custos.fires`. They group related tools.
- **Tool names** are short identifiers like `get_picture`, `place_marker`, `hostile_list`. They're the `@tool` annotation in a `.lua` file and the thing you pass to `tools.call`.

You do NOT call `tools.call("custos.tactical_picture", ...)`. You call `tools.call("get_picture", ...)`.

Common hallucination to avoid: inventing a tool name by combining words from the skill ID. The skill `custos.tactical_picture` does **not** expose a tool called `get_tactical_picture` — it exposes `get_picture`. The skill `custos.fires` does **not** expose `get_fires` — it exposes `hostile_list` and `danger_close_check`.

### Before writing an automation: verify tool names

If you're not 100% sure a tool exists by the name you're about to use, call `discover_api(query="<topic>")` from `custos.skill_creator` first to enumerate the real tool names. `write_automation` validates every `tools.call(...)` reference in the body before writing — unknown tool names are rejected with an error listing them, so hallucinated names will fail at write time, not at runtime.

## The `run(ctx)` signature

The parameter name matches the trigger type (self-documenting convention — Lua doesn't enforce names):

- **Schedule (cron or one-shot)**: `function run(schedule)` → `ctx = { fired_at, cron }`
- **Interval (duration)**: `function run(interval)` → `ctx = { fired_at, interval }`
- **Event (broadcast)**: `function run(event)` → `ctx = { fired_at, action, cot_type, uid, lat, lon, callsign, hae, how, cot_xml, extra_* }`

`fired_at` is milliseconds since epoch. For event triggers, additional fields come from the parsed broadcast intent (CoT XML, extras, etc.).

## Examples

**Interval — perimeter monitor:**
```
write_automation(
    name = "perimeter_monitor",
    trigger = "15s",
    body = [[
        local pos = tools.call("get_self_position", {})
        local result = tools.call("find_nearby", { lat = pos.lat, lon = pos.lon, radius_m = 300, affiliation = "hostile" })
        if result.count > 0 then
            tools.call("play_tone", { type = "alarm" })
        end
    ]],
    description = "300m hostile perimeter sweep every 15 seconds",
    session = "ISOLATED"
)
```

**Schedule — morning SITREP with LLM reasoning via delegate:**
```
write_automation(
    name = "morning_sitrep",
    trigger = "0 6 * * *",
    body = [[
        local result = tools.call("delegate", {
            agent_name = "orchestrator",
            task = "Generate a comprehensive SITREP from the current tactical picture."
        })
        tools.call("speak_alert", { message = result.response })
    ]],
    description = "Daily 0600 SITREP",
    session = "MAIN"
)
```

**Event — hostile CoT alert with inline filter:**
```
write_automation(
    name = "hostile_alert",
    trigger = "com.atakmap.android.maps.COT_RECD",
    body = [[
        if not (event.cot_type and event.cot_type:find("a-h-")) then return end
        tools.call("speak_alert", { message = "Hostile: " .. (event.callsign or "unknown") })
    ]],
    description = "Fire when a hostile CoT is received",
    session = "ISOLATED"
)
```

## Filter and debounce patterns

- **Filter** — put a guard clause at the top of `run()`: `if not (event.cot_type and event.cot_type:find("a-h-")) then return end`. No separate `@filter` annotation.
- **Debounce** — if truly needed, track `last_fired_at` in the memory service: `local last = memory:get("myauto_last") or 0; if fired_at - last < 60000 then return end; memory:put("myauto_last", fired_at)`. Rarely needed — deterministic Lua is cheap.

## Managing automations

Use `manage_automation` to list, toggle, or delete existing automations.

## Critical rules

- Always use `write_automation` to create automations — never write raw `.lua` files manually.
- Prefer deterministic `tools.call` chains over `delegate`. Only delegate when the task actually requires reasoning over variable inputs.
- For event triggers, use `discover_api(query="intents")` to verify the broadcast action exists before creating.
- Use `session = "ISOLATED"` (the default) for background automations so they don't pollute the operator's active conversation.
