-- write_automation_test.lua
-- End-to-end test for the unified `write_automation` tool.
-- Verifies: trigger auto-detection (interval / schedule / event), body → run()
-- generation with correct ctx param name, load-time validation, event firing
-- through the deterministic Lua path (no LLM), toggle, delete.

local Intent = import("android.content.Intent")
local AtakBroadcast = import("com.atakmap.android.ipc.AtakBroadcast")
local Thread = import("java.lang.Thread")
local File = import("java.io.File")

local TEST_ACTION = "com.nimbusxr.custos.TEST_EVENT_TRIGGER"
local AUTOMATIONS_DIR = "/sdcard/atak/custos/automations"

local function readFile(path)
  local f = File(path)
  if not f:exists() then return nil end
  local Scanner = import("java.util.Scanner")
  local scanner = Scanner(f):useDelimiter("\\A")
  local content = scanner:hasNext() and scanner:next() or ""
  scanner:close()
  return content
end

-- 1. INTERVAL trigger — expect run(interval)
local intv = write_automation({
  name = "TEST_interval_auto",
  trigger = "30s",
  body = "return 'ALL_CLEAR'",
  description = "Interval test",
})
assert(intv.status == "created", "Interval create failed: " .. tostring(intv.status))
assert(intv.ctx_param == "interval", "Interval should use `interval` ctx: " .. tostring(intv.ctx_param))
local intvContent = readFile(intv.file)
assert(intvContent and intvContent:find("function run%(interval%)"), "Interval file missing run(interval)")
assert(intvContent:find("@trigger 30s"), "Interval missing @trigger annotation")
console.log("[interval] created: " .. intv.name)

-- 2. SCHEDULE trigger (cron) — expect run(schedule)
local sched = write_automation({
  name = "TEST_schedule_auto",
  trigger = "0 */5 * * *",
  body = "return 'scheduled fire'",
  description = "Schedule test",
  session = "ISOLATED",
})
assert(sched.status == "created", "Schedule create failed: " .. tostring(sched.status))
assert(sched.ctx_param == "schedule", "Schedule should use `schedule` ctx: " .. tostring(sched.ctx_param))
local schedContent = readFile(sched.file)
assert(schedContent and schedContent:find("function run%(schedule%)"), "Schedule file missing run(schedule)")
console.log("[schedule] created: " .. sched.name)

-- 3. SCHEDULE trigger (one-shot) — also schedule
local oneshot = write_automation({
  name = "TEST_oneshot_auto",
  trigger = "in 10m",
  body = "return 'oneshot fire'",
})
assert(oneshot.status == "created", "Oneshot create failed: " .. tostring(oneshot.status))
assert(oneshot.ctx_param == "schedule", "Oneshot should use `schedule` ctx: " .. tostring(oneshot.ctx_param))
console.log("[oneshot] created: " .. oneshot.name)

-- 4. EVENT trigger — expect run(event)
local evt = write_automation({
  name = "TEST_event_auto",
  trigger = TEST_ACTION,
  body = 'console.log("[TEST_event_auto] fired with action=" .. tostring(event.action))',
  description = "Event test",
  session = "ISOLATED",
})
assert(evt.status == "created", "Event create failed: " .. tostring(evt.status))
assert(evt.ctx_param == "event", "Event should use `event` ctx: " .. tostring(evt.ctx_param))
local evtContent = readFile(evt.file)
assert(evtContent and evtContent:find("function run%(event%)"), "Event file missing run(event)")
console.log("[event] created: " .. evt.name)

-- 5. Validation — missing required params
local errName = write_automation({ trigger = "30s", body = "return true" })
assert(errName.status == "error", "Missing name should error")

local errTrigger = write_automation({ name = "TEST_no_trigger", body = "return true" })
assert(errTrigger.status == "error", "Missing trigger should error")

local errBody = write_automation({ name = "TEST_no_body", trigger = "30s" })
assert(errBody.status == "error", "Missing body should error")

-- 6. Validation — unclassifiable trigger
local errBad = write_automation({
  name = "TEST_bad_trigger",
  trigger = "banana",
  body = "return true",
})
assert(errBad.status == "error", "Unclassifiable trigger should error")
console.log("[validation] all required-param and classification errors confirmed")

-- 6b. Tool-reference validation — body references a nonexistent tool
-- Regression: this test also serves as a smoke check that write_automation.lua
-- itself loads (a syntax/pattern bug caused it to fail at `Script load error`
-- before — catching that here is half the point).
local errUnknownTool = write_automation({
  name = "TEST_unknown_tool",
  trigger = "30s",
  body = 'tools.call("get_tactical_picture_definitely_not_real", {})',
})
assert(errUnknownTool.status == "error",
  "Unknown tool reference should error, got: " .. tostring(errUnknownTool.status))
assert(errUnknownTool.error_type == "unknown_tool",
  "Expected error_type=unknown_tool, got: " .. tostring(errUnknownTool.error_type))
assert(
  errUnknownTool.unknown_tools and #errUnknownTool.unknown_tools > 0,
  "Expected unknown_tools list to include the hallucinated name"
)
assert(
  errUnknownTool.unknown_tools[1] == "get_tactical_picture_definitely_not_real",
  "Expected the unknown tool name to be surfaced, got: " ..
    tostring(errUnknownTool.unknown_tools[1])
)
console.log("[validation] unknown_tool rejection confirmed: " ..
  errUnknownTool.unknown_tools[1])

-- 6c. Tool-reference validation — valid tool name should NOT be flagged
-- Uses get_self_position (from custos.tactical_picture) which is known to exist
-- in the default skill set.
local okKnownTool = write_automation({
  name = "TEST_known_tool",
  trigger = "30s",
  body = 'local pos = tools.call("get_self_position", {})',
})
assert(okKnownTool.status == "created",
  "Known tool reference should succeed, got: " .. tostring(okKnownTool.status) ..
    " / " .. tostring(okKnownTool.message))
console.log("[validation] known-tool reference accepted: " .. okKnownTool.name)

-- 6d. Tool-reference validation — multiple tools, one bad
-- Confirms the validator reports ALL unknown names, not just the first.
local errMultiBad = write_automation({
  name = "TEST_multi_bad",
  trigger = "30s",
  body = [[
    local pos = tools.call("get_self_position", {})
    tools.call("bogus_one", {})
    tools.call("bogus_two", {})
  ]],
})
assert(errMultiBad.status == "error", "Multi-unknown should error")
assert(#errMultiBad.unknown_tools == 2,
  "Expected 2 unknown tools, got: " .. tostring(#errMultiBad.unknown_tools))
console.log("[validation] multi-unknown rejection confirmed: " ..
  table.concat(errMultiBad.unknown_tools, ", "))

-- Clean up the one test automation that was successfully written
manage_automation({ action = "delete", name = "TEST_known_tool" })

-- 7. Reload and verify all four are loaded
local loaded = scheduling:reload()
console.log("[reload] " .. tostring(loaded) .. " automations loaded")

local list = manage_automation({ action = "list" })
local found = { interval = false, schedule = false, oneshot = false, event = false }
for _, a in ipairs(list.automations) do
  if a.name == "TEST_interval_auto" then found.interval = true end
  if a.name == "TEST_schedule_auto" then found.schedule = true end
  if a.name == "TEST_oneshot_auto" then found.oneshot = true end
  if a.name == "TEST_event_auto" then found.event = true end
end
assert(found.interval and found.schedule and found.oneshot and found.event,
  "Not all test automations found in list")
console.log("[list] all 4 found")

-- 8. Fire event broadcast — deterministic path, no LLM
console.log("[event] sending broadcast: " .. TEST_ACTION)
runOnUiThread(function()
  local intent = Intent(TEST_ACTION)
  intent:putExtra("test_key", "test_value")
  AtakBroadcast:getInstance():sendBroadcast(intent)
end)
Thread:sleep(2000)

-- The run() Lua should have executed synchronously through the Lua sandbox.
-- If we see the console.log from run(), the deterministic path worked.
-- (Verify in logcat: `adb logcat | grep "TEST_event_auto"`)
local list2 = manage_automation({ action = "list" })
for _, a in ipairs(list2.automations) do
  if a.name == "TEST_event_auto" then
    if a.lastStatus then
      console.log("[event] fired — status=" .. a.lastStatus)
    else
      console.log("[event] trigger dispatched, check logcat for run() execution")
    end
    break
  end
end

-- 9. Toggle test
local tog = manage_automation({ action = "toggle", name = "TEST_event_auto", enabled = false })
assert(tog.status == "success", "Toggle failed")

local tog2 = manage_automation({ action = "toggle", name = "TEST_event_auto", enabled = true })
assert(tog2.status == "success", "Re-toggle failed")
console.log("[toggle] disable/enable confirmed")

-- 10. Cleanup
for _, name in ipairs({
  "TEST_interval_auto", "TEST_schedule_auto", "TEST_oneshot_auto", "TEST_event_auto",
}) do
  local del = manage_automation({ action = "delete", name = name })
  assert(del.status == "success", "Delete failed: " .. name)
end
console.log("[cleanup] all deleted")

local list3 = manage_automation({ action = "list" })
for _, a in ipairs(list3.automations) do
  assert(not a.name:find("^TEST_"), "Leftover: " .. a.name)
end
console.log("[cleanup] verified clean")

return "PASS"
