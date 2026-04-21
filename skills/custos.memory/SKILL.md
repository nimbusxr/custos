---
group: custos
name: memory
description: Remember, recall, and forget persistent facts across conversations
script_paths:
  - custos.memory/remember.lua
  - custos.memory/recall.lua
  - custos.memory/forget.lua
tags:
  - memory
  - context
  - persistence
examples:
  - "remember that the patrol leaves at 0600"
  - "what do you remember about the objective"
  - "forget the old rally point"
  - "save this: ROE changed to weapons hold"
  - "do you have any notes on the eastern approach"
---

# Persistent Memory

Tools for managing persistent tactical memory that survives across conversations.
Use `remember` when the operator says "remember this" or shares important facts
(positions, threat info, preferences, SOPs). Use `recall` to search stored facts.
Use `forget` to remove outdated information.

Categories: position, threat, status, preference, sop, reference, general
