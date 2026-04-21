--- List map overlay layers
-- @tool list_layers
-- @description List all map overlay layers with their name, type, and visibility status.
-- @impact READ_ONLY
function list_layers(params)
  local MapView = import("com.atakmap.android.maps.MapView")

  local layers = {}

  local ok, err = pcall(function()
    local mapView = MapView:getMapView()

    -- Iterate map groups to find overlay layers
    local rootGroup = mapView:getRootGroup()
    local groups = rootGroup:getMapGroups()
    if groups then
      local iter = groups:iterator()
      while iter:hasNext() do
        local group = iter:next()
        local name = ""
        local visible = true

        pcall(function()
          name = group:getFriendlyName()
        end)
        if not name or name == "" then
          pcall(function()
            name = group:toString()
          end)
        end
        pcall(function()
          visible = group:getVisible()
        end)

        table.insert(layers, {
          name = name,
          type = "group",
          visible = visible,
        })
      end
    end
  end)

  -- Also try to list RasterLayer entries via the map's layer stack
  pcall(function()
    local mapView = MapView:getMapView()
    local layerList = mapView:getLayers()
    if layerList then
      local iter = layerList:iterator()
      while iter:hasNext() do
        local layer = iter:next()
        local name = ""
        local visible = true

        pcall(function()
          name = layer:getName()
        end)
        pcall(function()
          visible = layer:isVisible()
        end)

        table.insert(layers, {
          name = name,
          type = "layer",
          visible = visible,
        })
      end
    end
  end)

  return {
    layers = layers,
    count = #layers,
  }
end
