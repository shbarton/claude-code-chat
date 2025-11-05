# Gemini Deep Research Claude Skill

A Claude skill that automates Gemini Deep Research tasks using the Playwright MCP server. This skill enables Claude to drive a browser, run deep research queries in Google Gemini, and save the results as PDFs directly into your repository.

## Overview

This skill teaches Claude how to:
1. Navigate to Gemini in a controlled browser
2. Start a Deep Research task with your brief
3. Wait for completion
4. Export to Google Docs or save the report as a PDF
5. Commit the result to your repository

## Quick Start

**First time setup?** See [SETUP_GUIDE.md](./SETUP_GUIDE.md) for detailed step-by-step instructions on getting Google/Gemini login working with Playwright.

**TL;DR:**
1. Launch Playwright MCP with `--save-session`
2. First run: manually log into Google in the browser that opens
3. Session persists automatically for all future runs!

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
- `--save-session`: Keeps you logged into Google/Gemini across runs

Optional:
- `--user-data-dir <path>`: Use a stable browser profile (recommended: `~/.playwright/gemini-profile`)

### 4. Log into Google/Gemini

Open the controlled browser and log into your Google account once. The session will be saved for future runs.

## Installation

### Method 1: Upload to Claude (Recommended)

1. Zip the `gemini-deep-research` folder (ensure the skill directory is the ZIP root)
2. Open Claude → Settings → Capabilities → Upload skill
3. Upload the zip file and toggle the skill on

### Method 2: Local Skills Directory

For Claude Code, you can place the skill in:
```
~/.claude/skills/gemini-deep-research/
```

Claude will automatically load relevant skills based on your requests.

## Usage

Ask Claude to run deep research with a clear brief:

```
Use the Gemini Deep Research skill to research: "What are the key technological
barriers to fusion energy commercialization by 2030? Include current projects,
funding trends, regulatory landscape, and breakthrough predictions."
Title: Fusion energy barriers 2030
```

Or more simply:

```
Run Gemini Deep Research on: "Future of quantum computing in drug discovery"
```

### What Happens

Claude will:
1. Navigate to `https://gemini.google.com/`
2. Find and click the Deep Research tool
3. Enter your brief
4. Wait for the research to complete (watching for "Research complete", "Sources", or similar markers)
5. Export the report (preferably to Google Docs, then save as PDF) or use direct PDF save
6. Save to `./research-exports/gemini-deep-research-{slug}-{date}.pdf`
7. Commit the file to your repo with a descriptive message

## File Structure

```
gemini-deep-research/
├── Skill.md              # Main skill definition (YAML + instructions)
├── scripts/
│   ├── commit.sh         # Git commit helper script
│   └── slugify.py        # Filename slug generator
├── README.md             # This file
└── SETUP_GUIDE.md        # Detailed login setup guide
```

## How It Works

### Skill.md

The heart of the skill. Contains:
- **YAML front-matter**: Name, description, version (Claude uses this to decide when to load the skill)
- **Instructions**: Step-by-step guide for Claude on how to use the Playwright MCP tools for Gemini

### scripts/commit.sh

Commits the saved PDF to your repository:
```bash
#!/usr/bin/env bash
set -euo pipefail
FILEPATH="${1:?Usage: commit.sh path/to/file.pdf}"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
cd "$REPO_ROOT"
git add "$FILEPATH"
git commit -m "Add Gemini Deep Research: $(basename "$FILEPATH")" >/dev/null
git rev-parse --short HEAD
```

### scripts/slugify.py

Converts titles into filename-safe slugs:
```python
import re, sys, unicodedata
s = sys.argv[1] if len(sys.argv) > 1 else "deep research"
s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode("ascii")
s = re.sub(r"[^a-zA-Z0-9]+", "-", s).strip("-").lower()
print(s or "gemini-deep-research")
```

## Playwright MCP Tools Used

The skill instructs Claude to use these MCP tools:

- `playwright.browser_navigate`: Navigate to Gemini
- `playwright.browser_snapshot`: Inspect page elements
- `playwright.browser_click`: Click controls (Deep Research button, export, etc.)
- `playwright.browser_type`: Enter the research brief
- `playwright.browser_wait_for`: Wait for completion markers
- `playwright.browser_pdf_save`: Save page as PDF (requires `--caps=pdf`)
- `playwright.browser_tabs`: Switch between tabs (useful for Google Docs export)

## Troubleshooting

### Not Logged In / 2FA

If Claude detects you're not authenticated:
1. The skill will prompt you to log in
2. Log in manually in the controlled browser (Google account)
3. Complete 2FA if required
4. Claude will retry navigation

### Export Options

The skill has multiple export strategies:

1. **Preferred**: Export to Google Docs, then save as PDF
   - Provides cleanest formatting
   - Preserves links and citations

2. **Fallback**: Direct `browser_pdf_save`
   - Captures the Gemini page as-is
   - Works when export buttons aren't available

### Deep Research Feature Availability

Gemini Deep Research may be:
- Available only in certain regions
- Require Gemini Advanced subscription
- Labeled differently ("Research mode", "Deep dive", etc.)

If Claude can't find the Deep Research option, manually start one first to verify it's available in your account.

### Multiple Tabs

If Google Docs export opens in a new tab:
- Claude uses `browser_tabs` to select the newest tab
- Saves the PDF from the Google Doc
- Returns to the main Gemini tab

### Persistence Issues

Use `--save-session` and `--user-data-dir` for reliable session persistence:
```bash
npx @playwright/mcp@latest \
  --caps=pdf \
  --output-dir ./research-exports \
  --save-session \
  --user-data-dir ~/.playwright/gemini-profile
```

### Google Account Session Expired

Sessions can expire after some time. If this happens:
1. The skill will detect you're not logged in
2. Simply log in again manually when the browser opens
3. The new session will be saved

## Example Workflow

1. **User request**:
   ```
   Run Gemini deep research: "Impact of CRISPR gene editing on agriculture 2025-2030"
   ```

2. **Claude invokes skill**:
   - Loads `Skill.md` instructions
   - Calls Playwright MCP tools in sequence

3. **Browser automation**:
   - Opens Gemini
   - Clicks Deep Research
   - Types brief and submits
   - Waits for completion

4. **PDF export**:
   - Exports to Google Docs (if available)
   - Saves as `gemini-deep-research-impact-crispr-gene-editing-2025-11-05.pdf`

5. **Git commit**:
   ```bash
   git add ./research-exports/gemini-deep-research-impact-crispr-gene-editing-2025-11-05.pdf
   git commit -m "Add Gemini Deep Research: gemini-deep-research-impact-crispr-gene-editing-2025-11-05.pdf"
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
- **Google Docs integration**: Handle exports to Docs seamlessly

### Local Repository Integration

- PDFs saved directly into `./research-exports/`
- Automatic git commits with descriptive messages
- Full version history of research outputs

## Customization

### Change Output Directory

Edit `Skill.md` and update:
```
--output-dir ./path/to/your/gemini-reports
```

Also update the commit.sh path expectations.

### Adjust Completion Detection

In `Skill.md`, modify the wait conditions:
```
browser_wait_for { text: "Your custom completion marker" }
```

### Handle Different Gemini Versions

Gemini's UI may vary by region or account type. Update `Skill.md` with:
- Alternative element names for Deep Research
- Different completion markers
- Account-specific export flows

## Gemini vs ChatGPT Deep Research

Both skills use the same underlying technology (Playwright MCP) but differ in:

| Feature | Gemini | ChatGPT |
|---------|--------|---------|
| URL | gemini.google.com | chatgpt.com |
| Login | Google Account | OpenAI Account |
| Export | Google Docs → PDF (preferred) | Direct download or PDF save |
| UI Labels | "Research mode", "Deep research" | "Deep research" |
| Completion markers | "Research complete", "Sources" | "Sources", "Citations" |

Both skills can coexist and be used interchangeably based on your preference or subscription status.

## Credits

- Built for Claude Code, Claude App, and Claude API
- Uses [Playwright MCP](https://github.com/microsoft/playwright-mcp) by Microsoft
- Inspired by Google Gemini's Deep Research feature

## License

MIT
