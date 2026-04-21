-- toggle_layer_test.lua
-- Tests that toggle_layer() can toggle a layer off and back on

local layers = list_layers({})
assert(type(layers) == "table", "list_layers must return a table")

if layers.count == 0 or not layers.layers or #layers.layers == 0 then
  console.log("[toggle_layer] no layers found, skipping toggle test")
  return "PASS"
end

local target = layers.layers[1]
local name = target.name
console.log("[toggle_layer] toggling layer: " .. tostring(name))

-- Toggle off
local off = toggle_layer({ layer_name = name, visible = false })
assert(type(off) == "table", "Expected table from toggle off")
assert(off.status == "success", "Expected status=success toggling off, got " .. tostring(off.status))

-- Toggle back on
local on = toggle_layer({ layer_name = name, visible = true })
assert(type(on) == "table", "Expected table from toggle on")
assert(on.status == "success", "Expected status=success toggling on, got " .. tostring(on.status))

console.log("[toggle_layer] toggled " .. tostring(name) .. " off and back on")
return "PASS"
