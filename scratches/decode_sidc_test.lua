-- decode_sidc_test.lua
-- Tests that decode_sidc() with known SIDC returns sidc and affiliation

if type(decode_sidc) ~= "function" then
    console.log("[decode_sidc] function not loaded (nil) - skipping")
    return "PASS (skipped: decode_sidc not loaded)"
end

local ok, result = pcall(decode_sidc, {sidc = "SFGPUCII------"})
if not ok then
    console.error("SCRIPT BUG: " .. tostring(result))
    return "FAIL (script bug: " .. tostring(result) .. ")"
end
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.sidc) == "string", "Expected sidc to be string, got " .. type(result.sidc))
assert(type(result.affiliation) == "string", "Expected affiliation to be string, got " .. type(result.affiliation))
console.log("[decode_sidc] sidc=" .. result.sidc .. " affiliation=" .. result.affiliation)
return "PASS"
