-- generate_sitrep_test.lua
-- Tests that generate_sitrep() returns dtg, own_position, friendly_count

local ok, result = pcall(generate_sitrep, {})
if not ok then
    console.error("SCRIPT BUG: " .. tostring(result))
    return "FAIL (script bug: " .. tostring(result) .. ")"
end
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.dtg) == "string", "Expected dtg to be string, got " .. type(result.dtg))
console.log("[generate_sitrep] dtg=" .. result.dtg .. " friendly_count=" .. tostring(result.friendly_count))
return "PASS"
