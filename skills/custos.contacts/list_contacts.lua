---@class ContactEntry
---@field uid string TAK contact UID
---@field callsign string contact callsign / display name
---@field team string|nil ATAK team color, nil if not set
---@field role string|nil ATAK role type, nil if not set

---@class ListContactsResult
---@field contacts ContactEntry[] matching contacts
---@field count integer number of contacts returned

--- List all known TAK contacts with their status
-- @tool list_contacts
-- @description List all contacts on the TAK network with callsign, UID, team, role, and last known position
-- @tparam string filter Filter by callsign substring
-- @tparam integer max_results Maximum contacts to return (default: 50)
---@return ListContactsResult
-- @impact READ_ONLY
function list_contacts(params)
    local Contacts = import("com.atakmap.android.contact.Contacts")
    local instance = Contacts:getInstance()
    local allContacts = instance:getAllContacts()
    local iter = allContacts:iterator()
    local maxResults = params.max_results or 50
    local filter = params.filter and params.filter:lower() or nil

    local results = {}
    while iter:hasNext() and #results < maxResults do
        local contact = iter:next()
        local ok, name = pcall(function() return contact:getName() end)
        if not ok or not name then goto continue end

        if filter and not name:lower():find(filter, 1, true) then goto continue end

        local uid = contact:getUID()
        local entry = {
            uid = uid,
            callsign = name,
        }

        -- Try to get extended info
        local ok2, extras = pcall(function()
            return {
                team = contact:getMetaString("team", nil),
                role = contact:getMetaString("atakRoleType", nil),
            }
        end)
        if ok2 and extras then
            entry.team = extras.team
            entry.role = extras.role
        end

        table.insert(results, entry)
        ::continue::
    end

    return { contacts = results, count = #results }
end
