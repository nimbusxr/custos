--- Play an alert tone
-- @tool play_tone
-- @description Play an audible alert tone. Types: alarm (urgent), warning (caution), confirmation (positive), error (negative).
-- @tparam string type Tone type: alarm, warning, confirmation, or error (default: alarm)
-- @tparam integer duration_ms Duration in milliseconds (default: 1000)
-- @impact PROCEDURAL
function play_tone(params)
  local ToneGenerator = import("android.media.ToneGenerator")
  local AudioManager = import("android.media.AudioManager")

  local toneType = params.type or "alarm"
  local duration = params.duration_ms or 1000

  local toneMap = {
    alarm = ToneGenerator.TONE_CDMA_EMERGENCY_RINGBACK,
    warning = ToneGenerator.TONE_CDMA_ABBR_ALERT,
    confirmation = ToneGenerator.TONE_PROP_ACK,
    error = ToneGenerator.TONE_CDMA_CALLDROP_LITE,
  }

  local tone = toneMap[toneType]
  if not tone then
    return {
      status = "error",
      message = "Unknown tone type: " .. toneType .. ". Use alarm, warning, confirmation, or error.",
    }
  end

  local generator = ToneGenerator(AudioManager.STREAM_NOTIFICATION, 100)
  generator:startTone(tone, duration)

  return {
    status = "success",
    type = toneType,
    duration_ms = duration,
  }
end
