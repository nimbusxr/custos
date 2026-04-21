<!-- Thanks for opening a PR. Fill out the sections below so review can move fast. -->

## What this PR does

<!-- One or two sentences. "Adds custos.foo skill for X" or "Fixes Y bug in custos.bar's baz tool". -->

## Type of change

<!-- Check all that apply. -->

- [ ] New skill
- [ ] Fix or improvement to an existing skill
- [ ] Scratch / test addition or fix
- [ ] `custos.yaml` change
- [ ] `install.sh` / tooling change
- [ ] Docs (README, CONTRIBUTING, SKILL.md)
- [ ] Other — describe below

## Related issue

<!-- Link the issue this PR addresses: "Closes #123" or "Relates to #456". Issues first is the usual flow for anything non-trivial. -->

## Impact level justification (skills only)

<!-- For any tool with @impact SIGNIFICANT, STRATEGIC, or LETHAL, explain why that level is correct.
     Under-declaring bypasses the approval gate. Over-declaring creates operator friction. -->

## Test coverage

<!-- How did you verify this works? Options:
     - New scratch test under scratches/ (preferred for any new tool)
     - Manual verification via the in-app editor's Run button
     - Full scratch suite run (run_all_tests.lua)
     - For high-impact tools, existence-check is acceptable — note that here. -->

## Devices / environments tested

<!-- Device and ATAK-CIV version at minimum. Bonus points for multiple devices. -->

## Dependencies

<!-- Does this skill / change require anything else? External services, API keys, specific ATAK plugins, model weights. -->

## Breaking changes

<!-- Anything that would break an existing operator's setup after they pull this? Config key renames, removed tools, changed return shapes. -->

## Checklist

- [ ] I read [CONTRIBUTING.md](../CONTRIBUTING.md).
- [ ] Lua follows project style (two-space indent, snake_case, `local` by default).
- [ ] All tools have LDoc annotations with accurate `@tparam` and `@impact`.
- [ ] `SKILL.md` has `examples:` written the way an operator would actually speak.
- [ ] New / changed scripts were installed and exercised on a real device.
- [ ] Docs updated if the contribution changes configuration keys, install steps, or operator-visible behavior.
