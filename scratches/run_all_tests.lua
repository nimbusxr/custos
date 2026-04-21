-- run_all_tests.lua
-- Test runner for all skill tests. Reads each test file from disk and executes it.
-- Runs in the scratch pad where tool functions are globals and import() is available.


-- Hardcoded list of ALL test files (87 tests)
local tests = {
    -- CRITICAL/SIGNIFICANT: existence checks
    "activate_beacon_test",
    "create_package_test",
    "create_skill_test",
    "delegate_test",
    "delete_markers_test",
    "send_chat_test",
    "send_cot_test",
    "send_package_test",
    "write_automation_test",
    "write_skill_test",
    "write_skill_script_test",
    -- READ_ONLY: queries, lists, calculations
    "analyze_movement_test",
    "assess_position_risk_test",
    "assess_route_risk_test",
    "bearing_from_bullseye_test",
    "convert_coords_test",
    "danger_close_check_test",
    "decode_sidc_test",
    "discover_api_test",
    "elevation_profile_test",
    "estimate_arrival_test",
    "find_by_type_test",
    "find_items_test",
    "find_nearby_test",
    "find_skill_test",
    "generate_salute_test",
    "generate_sitrep_test",
    "geocode_test",
    "get_contact_detail_test",
    "get_declination_test",
    "get_elevation_test",
    "get_illumination_test",
    "get_item_detail_test",
    "get_network_status_test",
    "get_picture_test",
    "get_self_position_test",
    "get_track_history_test",
    "grg_bounds_test",
    "hostile_list_test",
    "line_of_sight_test",
    "list_agents_test",
    "list_attachments_test",
    "list_contacts_test",
    "list_geofences_test",
    "list_layers_test",
    "list_routes_test",
    "list_streams_test",
    "measure_distance_test",
    "measure_rab_test",
    "predict_position_test",
    "rag_retrieve_test",
    "read_chat_test",
    "recall_test",
    "search_by_tag_test",
    "tactical_summary_test",
    "track_target_test",
    -- PROCEDURAL: create/modify with cleanup
    "build_grg_test",
    "create_9line_test",
    "create_bpha_test",
    "create_bullseye_test",
    "create_geofence_test",
    "create_range_circle_test",
    "create_route_test",
    "create_sensor_fov_test",
    "create_spot_report_test",
    "draw_circle_test",
    "draw_polygon_test",
    "draw_rectangle_test",
    "export_kml_test",
    "focus_map_test",
    "forget_test",
    "import_file_test",
    "manage_automation_test",
    "mark_hlz_test",
    "place_marker_test",
    "place_tactical_graphic_test",
    "place_vehicle_test",
    "play_tone_test",
    "rag_store_test",
    "read_skill_test",
    "read_skill_script_test",
    "remember_test",
    "send_notification_test",
    "speak_alert_test",
    "tag_item_test",
    "toggle_layer_test",
    "zoom_map_test",
}

local TEST_DIR = "/sdcard/atak/custos/scratch/"

local File = import("java.io.File")
local Scanner = import("java.util.Scanner")

--- Read a file's full contents as a string
local function readFile(path)
    local f = File(path)
    if not f:exists() then
        return nil, "File not found: " .. path
    end
    local sc = Scanner(f):useDelimiter("\\A")
    local content = sc:hasNext() and sc:next() or ""
    sc:close()
    return content, nil
end

-- Run all tests
local passed = 0
local failed = 0
local results = {}

console.log("CUST/OS Skill Test Runner — " .. #tests .. " tests")

for i, testName in ipairs(tests) do
    local path = TEST_DIR .. testName .. ".lua"
    local source, readErr = readFile(path)

    if readErr then
        failed = failed + 1
        results[#results + 1] = {name = testName, ok = false, msg = readErr}
        console.error("FAIL  " .. testName)
        console.error("      " .. readErr)
    else
        local chunk, loadErr = load(source, testName)
        if not chunk then
            failed = failed + 1
            results[#results + 1] = {name = testName, ok = false, msg = "Load error: " .. tostring(loadErr)}
            console.error("FAIL  " .. testName)
            console.error("      Load error: " .. tostring(loadErr))
        else
            local ok, result = pcall(chunk)
            if ok then
                passed = passed + 1
                local msg = tostring(result or "PASS")
                results[#results + 1] = {name = testName, ok = true, msg = msg}
                console.log("PASS  " .. testName .. " — " .. msg)
            else
                failed = failed + 1
                local msg = tostring(result)
                results[#results + 1] = {name = testName, ok = false, msg = msg}
                console.error("FAIL  " .. testName)
                console.error("      " .. msg)
            end
        end
    end
end

local total = passed + failed

if failed == 0 then
    console.log("ALL " .. total .. " TESTS PASSED")
else
    console.warn(passed .. " passed, " .. failed .. " failed out of " .. total)
end

-- Cleanup all TEST_ artifacts
console.log("Cleaning up...")
local ok_del, del = pcall(delete_markers, {query = "TEST_"})
if ok_del and del and del.deleted then
    console.log("Removed " .. del.deleted .. " map items")
end
pcall(forget, {category = "test", key = "test_key"})
pcall(forget, {category = "test", key = "forget_test_key"})
console.log("Done")

return {passed = passed, failed = failed, total = total}
