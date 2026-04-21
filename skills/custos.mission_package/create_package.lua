--- Create a mission package with map items
-- @tool create_package
-- @description Create a mission package containing specified map items (markers, routes, drawings) for sharing with other TAK users
-- @tparam string name Package name
-- @tparam string items Comma-separated list of item callsigns or UIDs to include
-- @impact PROCEDURAL
function create_package(params)
  if not params.name or not params.items then
    return { status = "error", message = "name and items required" }
  end

  local AtakBroadcast = import("com.atakmap.android.ipc.AtakBroadcast")
  local Intent = import("android.content.Intent")
  local UUID = import("java.util.UUID")

  -- Resolve items
  local resolved = {}
  for item_ref in params.items:gmatch("[^,]+") do
    local trimmed = item_ref:match("^%s*(.-)%s*$")
    local resolveResult = tools.call("resolve_item", { identifier = trimmed })
    if resolveResult.status ~= "error" then
      local item = resolveResult.item
      table.insert(resolved, {
        uid = item:getUID(),
        callsign = item:getTitle() or trimmed,
      })
    end
  end

  if #resolved == 0 then
    return { status = "error", message = "No valid items found from: " .. params.items }
  end

  -- Build UID list for the mission package intent
  local uidList = {}
  for _, r in ipairs(resolved) do
    table.insert(uidList, r.uid)
  end

  local packageUid = UUID:randomUUID():toString()

  -- Trigger mission package creation via intent
  local intent = Intent("com.atakmap.android.missionpackage.CREATE")
  intent:putExtra("name", params.name)
  intent:putExtra("uid", packageUid)
  -- Pass UIDs as comma-separated string
  intent:putExtra("items", table.concat(uidList, ","))

  runOnUiThread(function()
    AtakBroadcast:getInstance():sendBroadcast(intent)
  end)

  return {
    status = "created",
    package_uid = packageUid,
    name = params.name,
    items = resolved,
    item_count = #resolved,
  }
end
