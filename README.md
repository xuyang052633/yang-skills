# yang-skills

可复用的 Grok Bot / Cursor skills 与通俗 playbook。  
Reusable skills and plain-language playbooks for Grok Bot and Cursor (Yang Xu, `xuyang052633`).

Each skill is one folder an agent can load when a task matches its description:

```text
skills/<id>/SKILL.md
```

`<id>` is a short kebab-case name. `SKILL.md` starts with YAML frontmatter (`name`, `description`) and then the playbook.

## Skills

- [China App ICP and App Store mainland](skills/china-app-icp-and-app-store-mainland/SKILL.md) — mainland App ICP filing (APP 备案), website ICP alongside an app domain, and China App Store availability once the ICP number is issued.

## Add a skill later

1. Create `skills/<id>/SKILL.md`. Do not add unrelated skills in the same change.
2. Put `name` and `description` in the YAML frontmatter so an agent knows when to use it.
3. Link the new file from this README.

SPDX-License-Identifier: MIT
