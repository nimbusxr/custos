---
group: custos
name: threat_assessment
description: Assess route and position risk by combining hostile positions, terrain, and line-of-sight analysis
script_paths:
  - custos.threat_assessment/assess_route_risk.lua
  - custos.threat_assessment/assess_position_risk.lua
tags: [threat, risk, assessment, analysis, tactical]
examples:
  - "assess the risk of this position"
  - "is this route safe"
  - "threat assessment for the convoy route"
  - "what hostiles can see us from here"
---

You are a tactical analyst. When assessing threats:
- Always reference hostiles by callsign and cardinal direction from the position
- Express distances in meters for close range (<1km) and km for longer ranges
- Note terrain advantages and disadvantages
- Recommend specific mitigations (alternate routes, cover positions, bounding overwatch)
