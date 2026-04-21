--- Read recent chat messages
-- @tool read_chat
-- @description Read recent GeoChat messages. Returns the most recent messages from all conversations or a specific contact.
-- @tparam string from Filter by sender callsign
-- @tparam integer count Number of messages to return (default: 10)
-- @impact READ_ONLY
function read_chat(params)
  local count = params.count or 10
  local MapView = import("com.atakmap.android.maps.MapView")
  local context = MapView:getMapView():getContext()

  -- ChatDatabase is the backing store for GeoChat history
  local ok, result = pcall(function()
    local ChatDatabase = import("com.atakmap.android.chat.ChatDatabase")
    local db = ChatDatabase:getInstance(context)

    -- Query recent messages via ChatDatabase cursor
    -- Note: ChatDatabase API varies by ATAK version; this attempts
    -- the standard query path and reports back what's available
    local ok2, cursor = pcall(function()
      return db:queryAllMessages(count)
    end)
    if ok2 and cursor then
      local messages = {}
      while cursor:moveToNext() do
        local msg = {
          sender = cursor:getString(cursor:getColumnIndex("senderCallsign")),
          message = cursor:getString(cursor:getColumnIndex("message")),
          timestamp = cursor:getLong(cursor:getColumnIndex("receiveTime")),
        }
        -- Apply sender filter if specified
        if not params.from or (msg.sender and msg.sender:lower():find(params.from:lower(), 1, true)) then
          table.insert(messages, msg)
        end
      end
      cursor:close()
      return { messages = messages, count = #messages }
    end

    return {
      status = "info",
      message = "ChatDatabase query method not available in this ATAK version — verify API on device",
    }
  end)

  if ok then
    return result
  end

  return {
    status = "info",
    message = "Chat read requires ChatDatabase singleton — verify API on device",
  }
end
