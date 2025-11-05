# ChatGPT Deep Research Claude Skill

A Claude skill that automates ChatGPT Deep Research tasks using the Playwright MCP server. This skill enables Claude to drive a browser, run deep research queries in ChatGPT, and save the results as PDFs directly into your repository.

## Overview

This skill teaches Claude how to:
1. Navigate to ChatGPT in a controlled browser
2. Start a Deep Research task with your brief
3. Wait for completion
4. Export or save the report as a PDF
5. Commit the result to your repository

## Prerequisites

### 1. Enable Skills in Claude

Enable Skills and code execution in your Claude environment:
- **Claude App/Code**: Settings → Capabilities
- Enable "Skills" and "Code execution"

### 2. Install Playwright MCP Server

Install the Playwright MCP server in your Claude environment:

```bash
# For Claude Code CLI
claude mcp add playwright npx @playwright/mcp@latest
```

### 3. Launch Playwright MCP with Required Capabilities

Run Playwright MCP with PDF support and session persistence:

```bash
npx @playwright/mcp@latest \
  --caps=pdf \
  --output-dir ./research-exports \
  --save-session
```

**Important flags:**
- `--caps=pdf`: Enables `browser_pdf_save` capability
- `--output-dir ./research-exports`: Sets where PDFs are saved (inside your repo)
- `--save-session`: Keeps you logged into ChatGPT across runs

Optional:
- `--user-data-dir <path>`: Use a stable browser profile

### 4. Log into ChatGPT

Open the controlled browser and log into ChatGPT once. The session will be saved for future runs.

## Installation

### Method 1: Upload to Claude (Recommended)

1. Zip the `chatgpt-deep-research` folder (ensure the skill directory is the ZIP root)
2. Open Claude → Settings → Capabilities → Upload skill
3. Upload the zip file and toggle the skill on

### Method 2: Local Skills Directory

For Claude Code, you can place the skill in:
```
~/.claude/skills/chatgpt-deep-research/
```

Claude will automatically load relevant skills based on your requests.

## Usage

Ask Claude to run deep research with a clear brief:

```
Use the ChatGPT Deep Research skill to research: "What's the 3-5 year outlook for
small-scale grid battery recycling in the EU? Include regulations, capex/opex ranges,
top 10 players, MoC risks, and a 1-page exec summary." Title: EU battery recycling outlook
```

Or more simply:

```
Run ChatGPT Deep Research on: "Impact of AI on software development in 2025"
```

### What Happens

Claude will:
1. Navigate to `https://chatgpt.com/`
2. Find and click the Deep Research tool
3. Enter your brief
4. Wait for the research to complete (watching for "Sources" or similar markers)
5. Export the report (via UI button) or save as PDF using Playwright
6. Save to `./research-exports/deep-research-{slug}-{date}.pdf`
7. Commit the file to your repo with a descriptive message

## File Structure

```
chatgpt-deep-research/
├── Skill.md              # Main skill definition (YAML + instructions)
├── scripts/
│   ├── commit.sh         # Git commit helper script
│   └── slugify.py        # Filename slug generator
└── README.md             # This file
```

## How It Works

### Skill.md

The heart of the skill. Contains:
- **YAML front-matter**: Name, description, version (Claude uses this to decide when to load the skill)
- **Instructions**: Step-by-step guide for Claude on how to use the Playwright MCP tools

### scripts/commit.sh

Commits the saved PDF to your repository:
```bash
#!/usr/bin/env bash
set -euo pipefail
FILEPATH="${1:?Usage: commit.sh path/to/file.pdf}"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
cd "$REPO_ROOT"
git add "$FILEPATH"
git commit -m "Add ChatGPT Deep Research: $(basename "$FILEPATH")" >/dev/null
git rev-parse --short HEAD
```

### scripts/slugify.py

Converts titles into filename-safe slugs:
```python
import re, sys, unicodedata
s = sys.argv[1] if len(sys.argv) > 1 else "deep research"
s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode("ascii")
s = re.sub(r"[^a-zA-Z0-9]+", "-", s).strip("-").lower()
print(s or "deep-research")
```

## Playwright MCP Tools Used

The skill instructs Claude to use these MCP tools:

- `playwright.browser_navigate`: Navigate to ChatGPT
- `playwright.browser_snapshot`: Inspect page elements
- `playwright.browser_click`: Click controls (Deep Research button, export, etc.)
- `playwright.browser_type`: Enter the research brief
- `playwright.browser_wait_for`: Wait for completion markers
- `playwright.browser_pdf_save`: Save page as PDF (requires `--caps=pdf`)
- `playwright.browser_tabs`: Switch between tabs if needed

## Troubleshooting

### Not Logged In / 2FA

If Claude detects you're not authenticated:
1. The skill will prompt you to log in
2. Log in manually in the controlled browser
3. Claude will retry navigation

### Export Button Missing

The skill has a fallback:
- First tries to find and click an **Export** or **Download** button
- If not found, uses `browser_pdf_save` to capture the page

### Multiple Tabs

If an export dialog opens in a new tab:
- Claude uses `browser_tabs` to select the newest tab before saving

### Persistence Issues

Use `--save-session` and optionally `--user-data-dir` to keep your ChatGPT session:
```bash
npx @playwright/mcp@latest \
  --caps=pdf \
  --output-dir ./research-exports \
  --save-session \
  --user-data-dir ~/.playwright/chatgpt-profile
```

### File Path Issues

Ensure Playwright MCP's `--output-dir` points to a directory inside your repo:
```bash
--output-dir ./research-exports
```

This ensures PDFs are saved in a location Git can track.

## Example Workflow

1. **User request**:
   ```
   Run deep research: "Future of edge AI chips for robotics applications"
   ```

2. **Claude invokes skill**:
   - Loads `Skill.md` instructions
   - Calls Playwright MCP tools in sequence

3. **Browser automation**:
   - Opens ChatGPT
   - Clicks Deep Research
   - Types brief and submits
   - Waits for completion

4. **PDF export**:
   - Saves as `deep-research-future-edge-ai-chips-2025-11-05.pdf`

5. **Git commit**:
   ```bash
   git add ./research-exports/deep-research-future-edge-ai-chips-2025-11-05.pdf
   git commit -m "Add ChatGPT Deep Research: deep-research-future-edge-ai-chips-2025-11-05.pdf"
   ```

6. **Claude reports**: Commit hash and file location

## Why This Approach?

### Claude Skills

- **Reusable**: Install once, invoke automatically
- **Declarative**: YAML description tells Claude when to use it
- **Official**: Native Claude mechanism for teaching workflows

### Playwright MCP

- **Robust**: LLM-friendly browser automation
- **No screenshots**: Uses accessible names and semantic selectors
- **PDF support**: `browser_pdf_save` with `--caps=pdf`
- **Session persistence**: Stay logged in with `--save-session`

### Local Repository Integration

- PDFs saved directly into `./research-exports/`
- Automatic git commits with descriptive messages
- Full version history of research outputs

## Customization

### Change Output Directory

Edit `Skill.md` and update:
```
--output-dir ./path/to/your/reports
```

Also update the commit.sh path expectations.

### Adjust Completion Detection

In `Skill.md`, modify the wait conditions:
```
browser_wait_for { text: "Your custom completion marker" }
```

### Add Gemini Deep Research Variant

Create a sibling skill `gemini-deep-research/` with similar structure but:
- Navigate to `https://gemini.google.com/`
- Locate "Deep Research" tool
- After completion, export to Google Docs then print to PDF

## Credits

- Built for Claude Code, Claude App, and Claude API
- Uses [Playwright MCP](https://github.com/microsoft/playwright-mcp) by Microsoft
- Inspired by OpenAI's ChatGPT Deep Research feature

## License

MIT
