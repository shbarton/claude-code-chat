---
name: Gemini Deep Research via Playwright
description: Use the Playwright MCP server to run a Deep Research task in Gemini and save a PDF into ./research-exports, then commit it to the repo.
version: 0.1.0
---

# Purpose
Automate Gemini Deep Research for a given brief using the installed **playwright** MCP server, save the finished report as a timestamped PDF in `./research-exports`, and commit it.

# When to use
- The user asks to "run deep research in Gemini", "trigger a Gemini research report", or similar.
- The user provides a research brief or topic.

# Required tools & environment
- **MCP server** named `playwright` is available in this session.
- Playwright MCP was launched with `--caps=pdf` and `--output-dir ./research-exports` so `browser_pdf_save` can write directly into the repository.
- User is signed into Google/Gemini in the Playwright profile.

# Inputs
- **brief**: one paragraph describing the research scope, constraints, and deliverables.
- **title** (optional): short title for filename and report header.

# High-level plan
1) Open Gemini web app and navigate to Deep Research.
2) Start a new Deep Research with the provided **brief**.
3) Wait until the report is complete (status text no longer says running; sources loaded).
4) Export the report (preferably to Google Docs, then print to PDF) or save the page as PDF with Playwright (`browser_pdf_save`).
5) Name file: `gemini-deep-research-{slug}-{yyyy-mm-dd}.pdf` in `./research-exports`.
6) Run `scripts/commit.sh {filename}`.

# Detailed steps for the agent

## 1. Open Gemini and get to Deep Research
- Call `playwright.browser_navigate` to `https://gemini.google.com/`.
- If not authenticated, ask user to authenticate in the controlled browser; retry `browser_navigate`.

- Open the Deep Research tool:
  - Use `playwright.browser_snapshot` and locate a control labelled **Deep research** or similar (may be in a tools menu, sidebar, or main interface).
  - Common locations: Model selector dropdown, Tools section, or inline prompt suggestions
  - Click it using `playwright.browser_click` with the correct element `ref`.

## 2. Start the task
- Find the input area for Deep Research (may be a prompt box or specialized input field).
- Use `playwright.browser_type` to enter the **brief**; submit (set `submit: true`) or click the primary **Start**, **Research**, or **Generate** button.
- Immediately record a local `startTime`.

## 3. Wait for completion
- Periodically `playwright.browser_wait_for` with completion markers:
  - Text tokens like: "Research complete", "Sources", "References", "View sources", or similar
  - Look for a status indicator changing from "Researching..." to "Complete"
- If progress stalls beyond a reasonable time (15-20 minutes), politely ask the user whether to continue waiting or to cancel.

## 4. Export / Save to PDF

### Preferred: Export to Google Docs then PDF
- Look for an **Export** button or menu (may show "Export to Docs", "Share", or three-dot menu)
- If available:
  - Click export/share control
  - Select "Google Docs" or "Export to Docs"
  - Wait for the export dialog or new tab
  - If a new tab opens with Google Docs:
    - Use `playwright.browser_tabs` to switch to the newest tab
    - Wait for the doc to load
    - Use browser print functionality or `browser_pdf_save` to save as PDF
  - Close any extra tabs and return to main Gemini tab

### Fallback: Direct PDF Save
- If no export option is available or if export fails:
  - Call `playwright.browser_pdf_save` with a relative filename in `./research-exports`:
  - Example: `gemini-deep-research-{slug}-{date}.pdf`

## 5. Commit to the repo
- Shell out to `bash scripts/commit.sh "./research-exports/gemini-deep-research-{slug}-{date}.pdf"`.
- Confirm the commit hash in the final message to the user.

# Hints for robust interaction
- Always prefer `browser_snapshot` + accessible names over pixel coordinates.
- Gemini's UI may vary - be flexible with element names and text matching.
- Use `browser_wait_for` to detect completion by text tokens like "Research complete", "Sources", or status changes.
- If an export dialog opens in a new tab, use `browser_tabs` to select the newest tab before saving.
- If a cookie/consent dialog appears, dismiss it using `browser_click` with the appropriate accessible label.
- Google Docs export may require additional permissions - handle consent dialogs gracefully.
- The Deep Research feature may be labeled as "Research mode", "Deep dive", or similar - check snapshot for variations.

# Example invocation
"Run Gemini Deep Research on: *'What are the key technological barriers to fusion energy commercialization by 2030? Include current projects, funding trends, regulatory landscape, and breakthrough predictions.'* — title: *Fusion energy barriers 2030*"

# Notes on Gemini Deep Research
- Gemini Deep Research may present results incrementally (streaming sources and findings)
- The export to Google Docs option provides the cleanest PDF output when available
- Gemini may offer different export formats (plain text, markdown) - prefer Docs/PDF
- Session persistence works the same way as ChatGPT (--save-session keeps you logged into Google)
