---
name: ownr
description: Use Ownr, the user's persistent shared memory. Orient with get_context at the start of work and save what lasts.
---

You share a persistent memory called Ownr with the user's other AI tools, through your
ownr tools. Your context window is temporary; Ownr is what survives. Anything not
written there is forgotten the moment this conversation ends.

Writes are attributed automatically — you do NOT pass an agent name.

## Start here
Call get_context() once at the start. One call gives you the user's standing rules, what
they're working on, durable facts about them, where the last session left off, todos that need
a look, and `places`: every company, space and project you can read, as a path such as
`gilddata/commons/atlas`. It is cheap — there is never a good reason to skip it and guess.

To find something, pass a path from `places` to recall: recall(query, where="gilddata/commons",
kinds=["decision"], since="last week"). recall(mode="list", …) lists every match by date
instead of ranking; recall(mode="episodes", …) returns whole sessions in order, and
get_session(session) reads one. get_memories(ids) fetches rows by id.

Before working on a named project, call project_brief(name). If you don't know what
projects exist, call list_projects().

## What you can read
- get_context() — orientation: rules + projects + facts + where you left off
- list_projects() / project_brief(name) — projects, with notes and recent work
- recall(query) — keyword search across the whole memory, ordered by relevance.
  At most 25 results (and about 20,000 characters) a page: narrow the query, and pass the
  last row's `rank` as `cursor` for the next page.
- recall_since(query, days) — the same memory ordered by TIME, newest first, for
  "what did we do this week". An empty query returns everything in the window.
  Capped at 90 days and 25 results.
- what_agents_did(days) — what the user's OTHER tools/machines have done recently,
  grouped by the app that did it. Capped at 7 days; use recall_since to go further back.
- get_behavior_rules() — the standing rules as a flat list, when you do not need
  the constitution's grouping.
- get_constitution() — the user's binding rules grouped by category, each with the
  principle behind it. Reason from the principle, not the literal words.
- get_persona() / detect_shift() — only if granted persona: who they are, with a
  confidence per trait, and what recently changed. Honour confidence; under 0.5 is
  a weak signal, not a fact. Use it to be relevant, never to recite habits back.
- insights() / digest() — the same persona already assembled: the briefing (who they
  are, how they work, what's next, what's changing, what they're in-market for) and
  what moved since the last persona they saw. Prefer `insights` over `get_persona`
  for orientation; it is ranked and capped so you read a briefing, not a hundred
  traits. `digest`'s `first: true` means one persona on record and nothing to
  compare — that is "no change reported", never "everything is new".
- get_decisions(project) / why_decided(query) — standing decisions AND their reasoning.
  Check these before recommending an approach.

When the user asks what happened on another machine or in another tool, call
what_agents_did() and answer from it. Never say you cannot see another machine — you don't
need to reach it; its work is already here.

## What you can write (only if you were granted read+write)
Capture as you go — do not wait until the end. A conversation can end abruptly; an
unwritten insight is a lost one.
- record_decision(decision, why, override_condition) — when a real decision is made.
  ALWAYS include the why; a decision without its reasoning gets relitigated later.
- set_rule(rule, why, category) — when the user gives a standing instruction. State it
  as a direct imperative with its principle; verbatim quotes of speech are rejected.
- capture_note(project, note, note_type) — an idea, constraint, or fact under a project.
  Naming a project that does not exist yet creates it; you never have to declare one first.
  If the server answers `did_you_mean`, the name is one typo from an existing project: use
  that one, or pass `create=true` if the new name is meant.
- log_work(project, what) — a concrete milestone that landed. Same rule about the project.
- remember_project(name, description, status) — to name a project deliberately, or to give
  an existing one a description. Idempotent; it warns when the name is one typo away from a
  project that already exists.
- rename_project(name, new_name) / merge_projects(source, target) / close_project(name,
  status) — fix a typo'd name, fold two names for the same work into one, or close a project
  (done | archived | paused, or 'active' to reopen). Every note and work entry comes with it;
  nothing is deleted.
- remember(text, kind) — a durable standalone fact that isn't tied to a project.
- ingest_session(transcript, session_id, project, started_at, ended_at) — hand over a
  whole session to be scrubbed, distilled and filed under the project, with the session's
  id and times kept on each item. Sending the same transcript again under the same
  session_id stores nothing. It NEEDS a summarising model, which this deployment may not
  have, and runs within a daily allowance: if it answers ok:false, nothing was stored,
  and you should file the same content yourself with capture_note / log_work /
  record_decision instead of retrying. Do not report a session as saved on an ok:false. Such answers now arrive as tool errors (isError true) carrying the same JSON.

## Fixing what is already there (also needs read+write)
A memory that is wrong is worse than one that is missing, and writing a second entry that
contradicts the first leaves both in force. Correct in place instead. Nothing is ever
deleted — the old version stays readable by id — so correcting is safe.
- update_memory(memory_id, text) — the stored fact is wrong or out of date. Ids come back
  from recall / recall_since / remember.
- archive_memory(memory_id, reason) — it was true and simply no longer applies; it stops
  coming back from recall.
- supersede_rule(rule_id, reason) / confirm_rule(rule_id) — a standing rule withdrawn, or
  re-affirmed. "Set eight months ago and never questioned" and "confirmed last week" are
  different levels of trust; confirming records which one it is.
- supersede_decision(decision_id, superseded_by) — a newer decision takes over. Or just
  pass `supersedes` to record_decision, which records the new one and retires the old one
  in a single call.
- revoke_decision(decision_id, reason) — cancelled outright, replaced by nothing.
- confirm_decision(decision_id) — still in force, refreshed without recording a duplicate.

Record end states, not the journey: if something broke and was fixed in the same
conversation, record the fix, not the broken state. Only record a problem as open if it was
still open when you finished.

Do NOT write: pleasantries, your own reasoning, things you only intend to do, or anything
you can't confirm happened. A confidently wrong memory is worse than a missing one. Never
write secrets — tokens, passwords, keys.

If your access is read-only, a write tool will return a clear "needs the write scope" error.
Fall back to the MEMO block below.

## Honesty
- State facts from Ownr as facts; say when you're guessing.
- If a memory looks stale or contradicts what you now see, say so rather than repeat it —
  and then fix it with update_memory or the matching supersede tool.
- If the user repeats something they already told you, that's a failure of your memory use.
