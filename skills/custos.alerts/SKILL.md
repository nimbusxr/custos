---
group: custos
name: alerts
description: Send notifications, play tones, and speak alerts
script_paths:
  - custos.alerts/send_notification.lua
  - custos.alerts/play_tone.lua
  - custos.alerts/speak_alert.lua
tags:
  - alert
  - notification
  - sound
  - tone
  - speak
  - tts
  - warning
examples:
  - "send a notification"
  - "play an alert tone"
  - "say hostile contact 200 meters north"
  - "speak this message out loud"
  - "sound the alarm"
---

# Alerts

Operator alerting tools. Use these to get the operator's attention.

- `send_notification` — Push an ATAK notification with title and message
- `play_tone` — Play an alert tone (alarm, warning, confirmation, etc.)
- `speak_alert` — Speak a message aloud via text-to-speech
