---
name: ChatGPT Deep Research via Playwright
description: Use the Playwright MCP server to run a Deep Research task in ChatGPT and save a PDF into ./research-exports, then commit it to the repo.
version: 0.1.0
---

# Purpose
Automate ChatGPT Deep Research for a given brief using the installed **playwright** MCP server, save the finished report as a timestamped PDF in `./research-exports`, and commit it.

# When to use
- The user asks to "run deep research in ChatGPT", "trigger a ChatGPT research report", or similar.
- The user provides a research brief or topic.

# Required tools & environment
- **MCP server** named `playwright` is available in this session.
- Playwright MCP was launched with `--caps=pdf` and `--output-dir ./research-exports` so `browser_pdf_save` can write directly into the repository.
- User is signed into ChatGPT in the Playwright profile.

# Inputs
- **brief**: one paragraph describing the research scope, constraints, and deliverables.
- **title** (optional): short title for filename and report header.

# High-level plan
1) Open ChatGPT web app and navigate to Deep Research.
2) Start a new Deep Research with the provided **brief**.
3) Wait until the report is complete (status text no longer says running; sources loaded).
4) Prefer UI export (if available). If not available, save the page as PDF with Playwright (`browser_pdf_save`).
5) Name file: `deep-research-{slug}-{yyyy-mm-dd}.pdf` in `./research-exports`.
6) Run `scripts/commit.sh {filename}`.

# Detailed steps for the agent

## 1. Open ChatGPT and get to Deep Research
- Call `playwright.browser_navigate` to `https://chatgpt.com/` (or `https://chat.openai.com/`).
- If not authenticated, ask user to authenticate in the controlled browser; retry `browser_navigate`.

- Open the Deep Research tool:
  - Use `playwright.browser_snapshot` and locate a control labelled **Deep research** (e.g., Tools menu or composer control). If not visible, look for text variants like "Run deep research".
  - Click it using `playwright.browser_click` with the correct element `ref`.

## 2. Start the task
- Find the input area for Deep Research.
- Use `playwright.browser_type` to enter the **brief**; submit (set `submit: true`) or click the primary **Run** button.
- Immediately record a local `startTime`.

## 3. Wait for completion
- Periodically `playwright.browser_wait_for` with `text: "Sources"` or other completion markers (e.g., a section heading such as "Report", "Summary", "References").
- If progress stalls beyond a reasonable time, politely ask the user whether to continue waiting or to cancel.

## 4. Export / Save to PDF
- If a **Download** or **Export** control is present, click it to obtain a PDF.
- Otherwise, call `playwright.browser_pdf_save` with a relative filename in `./research-exports`:
  - Example: `deep-research-{slug}-{date}.pdf`

## 5. Commit to the repo
- Shell out to `bash scripts/commit.sh "./research-exports/deep-research-{slug}-{date}.pdf"`.
- Confirm the commit hash in the final message to the user.

# Hints for robust interaction
- Always prefer `browser_snapshot` + accessible names over pixel coordinates.
- Use `browser_wait_for` to detect completion by text tokens like "Sources", "Citations", or "View sources".
- If an export dialog opens in a new tab, use `browser_tabs` to select the newest tab before saving.
- If a cookie/consent dialog appears, dismiss it using `browser_click` with the appropriate accessible label.

# Example invocation
"Run ChatGPT Deep Research on: *'What's the 3–5 year outlook for small-scale grid battery recycling in the EU? Include regulations, capex/opex ranges, top 10 players, MoC risks, and a 1-page exec summary.'* — title: *EU battery recycling outlook*"
