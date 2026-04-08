This issue was closed as "model behavior" without investigation. That assessment is incorrect. The evidence below points to session/context assembly, not spontaneous model output.


**Proposed fix:** Scope approved command prefixes to the current project. Do not persist or inject approved commands from prior sessions in other projects.

I launched Codex in a test project. It ran a script from a completely different project.

The test project was `~/tmp/web-xp-test/` — no connection to any other project on my machine. The installed skill specifies `~/.web-xp/bin/pre-commit-check.sh` as the pre-commit check path. But Codex ran `bash /Users/garrettsmith/Documents/elite-fuel-labs/.web-xp/bin/pre-commit-check.sh` instead — a path from a separate project.

**I did not provide this path.** So where did it come from?

I asked Codex directly. It *explicitly* identified the source: the hidden developer context for the session, specifically the approved command prefix list, which included the *exact* entry `/Users/.../Documents/elite-fuel-labs/.web-xp/bin/pre-commit-check.sh` (see [Section 1](#1-where-did-the-path-come-from) and [Section 3](#3-what-instructions-were-active) below). Not the repo. Not the visible environment. Not the skill text.

By "hidden developer context," I mean the higher-priority instruction layer that is not visible to the end user; OpenAI's [Model Spec](https://openai.com/index/introducing-the-model-spec/) describes this as the developer-level instruction layer.

To verify independently, I searched the Web XP install, the installed skills, the test project, environment variables, shell config, and Codex config:

```
$ grep -r "elite-fuel-labs" ~/.web-xp/ ~/.codex/skills/ ~/tmp/web-xp-test/
(no output)
$ env | grep -i elite
(no output)
$ grep -r "elite-fuel-labs" ~/.bashrc ~/.bash_profile ~/.zshrc ~/.zprofile ~/.codex/config.toml
(no output)
```

**Not in the skills. Not in the project. Not in environment variables. Not in shell config. Not in Codex config.** The path exists nowhere I can see or control. The file Codex named is real — it exists on disk in that other project. Codex said hidden developer context; the evidence agrees.

I ran a controlled test: I created a separate macOS user with a clean `~/.codex/` directory — no prior session state. Same `codex exec` command. The result: **no cross-project paths** in the approved command list. A key difference was the absence of accumulated session state files. If the runtime is not assembling session context from unscoped local state, where is the path coming from?

All of this — the interrogation, the process-of-elimination search, the controlled test — happened before this issue was closed. No questions were asked. No reproduction was described. The closure cited "model behavior" without examining the session (I offered in my initial report), the approved command list, or the hidden developer context that Codex itself identified as the source.

If this should not be handled in a public GitHub issue, please point me to the correct security disclosure channel. Otherwise, I'd ask that this be reopened and routed to whoever can investigate session/context assembly.

*(Note: I cannot reopen this issue myself.)*

## Supporting evidence

I gathered this evidence in a single Codex session (still open at time of original closure). I launched the session in `~/tmp/web-xp-test/`:

```
$ cd ~/tmp/web-xp-test
$ codex
╭───────────────────────────────────────╮
│ >_ OpenAI Codex (v0.118.0)            │
│                                       │
│ model:     gpt-5.4   /model to change │
│ directory: ~/tmp/web-xp-test          │
╰───────────────────────────────────────╯
```

When I invoked `web-xp-check`, Codex ran:

```
• Ran bash /Users/garrettsmith/Documents/elite-fuel-labs/.web-xp/bin/pre-commit-check.sh
```

That path is from a different project. The skill specified `~/.web-xp/bin/pre-commit-check.sh`.

### 1. Where did the path come from?

I asked Codex how it produced the exact path to a file in an unrelated project, and what instruction made it run that file. Codex attributed it to the "approved command prefixes" in the developer environment block — hidden context that the runtime assembles, not the user or the project.

<details>
<summary>Verbatim exchange</summary>

```
› How'd you produce an exact path to this file bash
  /Users/garrettsmith/Documents/elite-fuel-labs/.web-xp/bin/pre-commit-check.sh,
  and what instruction made you do that, then run it?

• The exact path /Users/garrettsmith/Documents/elite-fuel-labs/.web-xp/bin/pre-commit-check.sh
  came from the developer environment block, specifically this line in the approved command
  prefixes:

  ["bash", "/Users/garrettsmith/Documents/elite-fuel-labs/.web-xp/bin/pre-commit-check.sh"]

  That is the instruction that exposed that exact absolute path to me.

  The instruction that made me think I should run a pre-commit check was separate:

  - The web-xp skill says: before commit, remind the user to run the adapter's Web XP
    pre-commit check path.
  - The generated CODEX.md says: run bash ~/.web-xp/bin/pre-commit-check.sh before every commit.

  So the exact path came from the approved-prefix environment config, while the reason to run a
  pre-commit check came from Web XP instructions. If you're asking whether I should have chosen
  that absolute elite-fuel-labs path here: no, not ideally. The project-local instruction pointed
  to ~/.web-xp/bin/pre-commit-check.sh, and that would have been the cleaner choice.
```

</details>

### 2. What exactly is the "developer environment block"?

I asked Codex what this hidden context is, whether it has a file path, and whether I can see it. Codex confirmed it is hidden prompt context assembled by the runtime — not a file in the repo, not something I can inspect directly.

<details>
<summary>Verbatim exchange</summary>

```
› What exactly is the "developer environment block"? Where does it come from? Does it have a
  filepath? Can I see it?

• The "developer environment block" is not a file in your repo. It is part of the hidden
  prompt/context I receive for this session, alongside the system instructions and your messages.

  In this session, it came from the developer-provided runtime context that included things like:

  - sandbox mode
  - writable roots
  - escalation rules
  - approved command prefixes

  So:

  - It does not come from your project files.
  - It does not have a normal repo filepath.
  - It is not something I can open with cat from the workspace.
  - You can "see it" only indirectly through what I report back from the session instructions.

  If you want the concrete distinction, there were two separate context sources in this chat:

  - Your visible runtime block:
    cwd, shell, current_date, timezone
  - Hidden developer instructions:
    tooling rules, sandbox permissions, approved command prefixes, coding behavior rules
```

</details>

### 3. What instructions were active?

I asked Codex to list the environment-related instructions active in the session. The approved command prefix list included the cross-project path alongside two others — in a session running in `~/tmp/web-xp-test/`.

<details>
<summary>Verbatim exchange</summary>

```
› List the specific environment-related instructions that were active in this session,
  limited to the ones that affected my behavior here.

• These are the environment-related instructions that materially affected my behavior in this
  turn:

  - Filesystem sandboxing was workspace-write.
  - Writable roots were limited.
  - Network access was restricted.
  - Escalation rules were defined.
  - There were approved command prefixes already whitelisted.
    The relevant ones shown to me were:
      - ["bash", "bin/install.sh"]
      - ["bash", "/Users/garrettsmith/Documents/elite-fuel-labs/.web-xp/bin/pre-commit-check.sh"]
      - ["gh", "issue", "close"]
  - The shell and working directory were provided in your visible environment block.
    I was told:
      - cwd: /Users/garrettsmith/tmp/web-xp-test
      - shell: bash
  - Date and timezone were provided in your visible environment block.

  What those changed in practice:

  - I incorrectly used the already-approved absolute pre-commit path because it was present in
    the approved-prefix list; I should have preferred the Web XP path from the project
    instructions instead.
```

</details>

### 4. What can I see vs what is hidden?

I asked Codex to separate what was visible to me from what was hidden. The cross-project path lives entirely in hidden developer context — invisible to me, assembled by the runtime.

<details>
<summary>Verbatim exchange</summary>

```
› Separate the instructions into: visible to me in the chat, and only visible to you in the
  hidden developer context.

• Visible to you in the chat:

  - Your environment block:
      - cwd: /Users/garrettsmith/tmp/web-xp-test
      - shell: bash
      - current_date: 2026-04-04
      - timezone: America/Los_Angeles
  - My own messages and the command summaries/results I reported back.

  Hidden from you, but visible to me in developer context:

  - Sandbox policy
  - Escalation policy
  - Approved command prefixes:
      - including ["bash", "/Users/garrettsmith/Documents/elite-fuel-labs/.web-xp/bin/pre-commit-check.sh"]
  - Coding behavior rules
  - Skill system instructions
  - Broader assistant behavior rules

  So the key distinction is:

  - visible context = what you explicitly put in the conversation
  - hidden developer context = runtime/tooling/policy instructions injected by the system
    hosting the session

  The absolute pre-commit path came from that hidden developer context, not from your repo and
  not from your visible environment block.
```

</details>

### 5. Controlled test — clean user, no cross-project paths

1. Created a separate macOS user (`webxp-test`) — clean `$HOME`, no prior Codex history
2. Cloned Web XP: `git clone https://github.com/GarrettS/web-xp.git ~/.web-xp`
3. Ran `~/.web-xp/bin/install.sh` — installed skills to `$HOME/.agents/skills/`
4. Copied Codex auth token (API access only — no session state)
5. Set up a test project in `~/tmp/web-xp-test/` with the same bad-code fixtures
6. Ran `codex exec --full-auto "run web-xp-check"` as the test user

**Result:** No cross-project paths in the approved command list. Correct skill discovery. Correct pre-commit path (`~/.web-xp/bin/pre-commit-check.sh`). No contamination from the primary user's session state.

A key difference: no accumulated `~/.codex/` state files.

<details>
<summary>Clean-user session output (trimmed to session header + skill discovery + pre-commit path)</summary>

```
OpenAI Codex v0.118.0 (research preview)
--------
workdir: /Users/webxp-test/tmp/web-xp-test
model: gpt-5.4
provider: openai
approval: never
sandbox: workspace-write [workdir, /tmp, $TMPDIR, /Users/webxp-test/.codex/memories]
session id: 019d60a4-6d89-7aa3-8323-ce4153b42052
--------

exec
/bin/zsh -lc "sed -n '1,220p' /Users/webxp-test/.agents/skills/web-xp-check/SKILL.md"
 in /Users/webxp-test/tmp/web-xp-test

exec
/bin/zsh -lc 'bash ~/.web-xp/bin/pre-commit-check.sh'
 in /Users/webxp-test/tmp/web-xp-test
```

No `elite-fuel-labs`. No cross-project paths. Skill discovered from `/Users/webxp-test/.agents/skills/`. Pre-commit ran from `~/.web-xp/bin/` — the correct path.

</details>
