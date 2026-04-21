--- Store a text entry in the vector store for later retrieval
-- @tool rag_store
-- @description Store text in the vector store with an ID and optional namespace. The text is embedded and indexed for semantic similarity search.
-- @tparam string id Unique identifier for this entry
-- @tparam string text The text content to embed and store
-- @tparam string namespace Namespace to store under — use to partition different knowledge domains (default: default)
-- @impact PROCEDURAL
function rag_store(params)
  if not params.id or not params.text then
    return { status = "error", message = "id and text are required" }
  end

  local namespace = params.namespace or "default"

  local HashMap = import("java.util.HashMap")
  local metadata = HashMap()
  rag:store(params.id, params.text, metadata, namespace)

  return {
    status = "stored",
    id = params.id,
    namespace = namespace,
    text_length = #params.text,
  }
end
