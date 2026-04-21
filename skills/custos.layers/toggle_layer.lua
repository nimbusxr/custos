--- Toggle a map layer's visibility
-- @tool toggle_layer
-- @description Toggle a map overlay layer's visibility on or off. Matches by layer name (case-insensitive partial match).
-- @tparam string layer_name Name of the layer to toggle
-- @tparam boolean visible Whether the layer should be visible
-- @impact PROCEDURAL
function toggle_layer(params)
  local MapView = import("com.atakmap.android.maps.MapView")

  local layerName = params.layer_name
  local visible = params.visible
  if visible == nil then
    visible = true
  end

  if not layerName or layerName == "" then
    return { status = "error", message = "layer_name is required" }
  end

  local query = layerName:lower()
  local matched = false
  local matchedName = nil

  -- Try map groups first
  local ok, err = pcall(function()
    local mapView = MapView:getMapView()
    local rootGroup = mapView:getRootGroup()
    local groups = rootGroup:getMapGroups()
    if groups then
      local iter = groups:iterator()
      while iter:hasNext() do
        local group = iter:next()
        local name = ""
        pcall(function()
          name = group:getFriendlyName()
        end)
        if not name or name == "" then
          pcall(function()
            name = group:toString()
          end)
        end
        if name and name:lower():find(query, 1, true) then
          runOnUiThread(function()
            group:setVisible(visible)
          end)
          matched = true
          matchedName = name
        end
      end
    end
  end)

  -- Also try map layer stack
  if not matched then
    pcall(function()
      local mapView = MapView:getMapView()
      local layerList = mapView:getLayers()
      if layerList then
        local iter = layerList:iterator()
        while iter:hasNext() do
          local layer = iter:next()
          local name = ""
          pcall(function()
            name = layer:getName()
          end)
          if name and name:lower():find(query, 1, true) then
            runOnUiThread(function()
              layer:setVisible(visible)
            end)
            matched = true
            matchedName = name
          end
        end
      end
    end)
  end

  if not matched then
    return { status = "error", message = "No layer found matching: " .. layerName }
  end

  return {
    status = "success",
    layer_name = matchedName,
    visible = visible,
  }
end
