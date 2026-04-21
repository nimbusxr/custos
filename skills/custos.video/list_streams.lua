--- List available video streams
-- @tool list_streams
-- @description List all video streams registered in ATAK VideoManager. Returns alias, protocol, address, and port for each stream.
-- @impact READ_ONLY
function list_streams(params)
  local streams = {}

  local ok, err = pcall(function()
    local VideoManager = import("com.atakmap.android.video.VideoManager")
    local vm = VideoManager:getInstance()
    if not vm then
      return
    end

    local entries = vm:getEntries()
    if not entries then
      return
    end

    local iter = entries:iterator()
    while iter:hasNext() do
      local entry = iter:next()
      local stream = {}

      pcall(function()
        stream.alias = entry:getAlias()
      end)
      pcall(function()
        stream.protocol = tostring(entry:getProtocol())
      end)
      pcall(function()
        stream.address = entry:getAddress()
      end)
      pcall(function()
        stream.port = entry:getPort()
      end)
      pcall(function()
        stream.path = entry:getPath()
      end)
      pcall(function()
        stream.uid = entry:getUID()
      end)

      table.insert(streams, stream)
    end
  end)

  return {
    streams = streams,
    count = #streams,
  }
end
