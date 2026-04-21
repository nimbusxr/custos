-- discover_api_test.lua
-- Tests that discover_api() with a known class returns a table

local result = discover_api({query = "list:com.atakmap.android.maps"})
assert(type(result) == "table", "Expected table, got " .. type(result))
console.log("[discover_api] result is table")
for k, v in pairs(result) do
    console.log("  " .. tostring(k) .. " = " .. type(v))
end
return "PASS"
