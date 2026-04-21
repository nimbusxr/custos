--- Get network and TAK server connectivity status
-- @tool get_network_status
-- @description Query active TAK server connections, network streams, and connectivity status using CotStreamListener.
-- @impact READ_ONLY
function get_network_status(params)
  local MapView = import("com.atakmap.android.maps.MapView")

  local connections = {}
  local totalConnected = 0
  local totalDisconnected = 0

  -- Query CotService for active streams via CotMapComponent
  local ok, err = pcall(function()
    local CotMapComponent = import("com.atakmap.android.cot.CotMapComponent")
    local cmc = CotMapComponent:getInstance()
    if not cmc then
      return
    end

    -- Try to get the CotServiceRemote streams
    local ok2, cotService = pcall(function()
      return cmc:getCotServiceRemote()
    end)
    if ok2 and cotService then
      local ok3, streams = pcall(function()
        return cotService:getStreams()
      end)
      if ok3 and streams then
        local iter = streams:iterator()
        while iter:hasNext() do
          local stream = iter:next()
          local connected = false
          local ok4, c = pcall(function()
            return stream:isConnected()
          end)
          if ok4 then
            connected = c
          end

          local desc = ""
          local ok5, d = pcall(function()
            return stream:getDescription()
          end)
          if ok5 and d then
            desc = d
          end

          if connected then
            totalConnected = totalConnected + 1
          else
            totalDisconnected = totalDisconnected + 1
          end

          table.insert(connections, {
            description = desc,
            connected = connected,
          })
        end
      end
    end
  end)

  -- Also check basic network availability
  local networkAvailable = false
  local ok6 = pcall(function()
    local context = MapView:getMapView():getContext()
    local ConnectivityManager = import("android.net.ConnectivityManager")
    local cm = context:getSystemService("connectivity")
    if cm then
      local activeNetwork = cm:getActiveNetworkInfo()
      if activeNetwork then
        networkAvailable = activeNetwork:isConnected()
      end
    end
  end)

  return {
    network_available = networkAvailable,
    connections = connections,
    connected_streams = totalConnected,
    disconnected_streams = totalDisconnected,
    total_streams = #connections,
  }
end
