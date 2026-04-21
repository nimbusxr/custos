--- Speak an alert message aloud
-- @tool speak_alert
-- @description Speak a message to the operator using text-to-speech. Use for urgent alerts or when the operator may not be looking at the screen.
-- @tparam string message Text to speak aloud
-- @impact PROCEDURAL
function speak_alert(params)
  local message = params.message
  if not message or message == "" then
    return { status = "error", message = "No message provided" }
  end

  tts:speak(message)

  return {
    status = "success",
    message = message,
  }
end
