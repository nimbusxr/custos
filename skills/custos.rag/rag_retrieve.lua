--- Retrieve entries from the vector store by semantic similarity
-- @tool rag_retrieve
-- @description Search the vector store for entries semantically similar to the query. Returns ranked results with similarity scores.
-- @tparam string query The search query text
-- @tparam integer top_k Maximum number of results to return (default: 5)
-- @tparam string namespace Namespace to search within — omit to search all namespaces
-- @impact READ_ONLY
function rag_retrieve(params)
  if not params.query then
    return { status = "error", message = "query is required" }
  end

  local top_k = params.top_k or 5
  local namespace = params.namespace

  local results = rag:retrieve(params.query, top_k, namespace)

  local entries = {}
  local iter = results:iterator()
  while iter:hasNext() do
    local result = iter:next()
    local entry = result:getEntry()
    table.insert(entries, {
      id = entry:getId(),
      text = entry:getText(),
      score = result:getScore(),
      namespace = entry:getNamespace(),
    })
  end

  return {
    status = "ok",
    query = params.query,
    count = #entries,
    results = entries,
  }
end
