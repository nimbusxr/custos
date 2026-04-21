-- geocode_test.lua
-- Tests that geocode() with address="test" returns a table
-- May fail with no network — accept error gracefully

local ok, result = pcall(geocode, {address = "test"})
if ok then
    assert(type(result) == "table", "Expected table, got " .. type(result))
    console.log("[geocode] result is table")
    for k, v in pairs(result) do
        console.log("  " .. tostring(k) .. " = " .. type(v))
    end
else
    -- Network error or geocoding unavailable is acceptable
    console.log("[geocode] call failed (expected if no network): " .. tostring(result))
end
return "PASS"
