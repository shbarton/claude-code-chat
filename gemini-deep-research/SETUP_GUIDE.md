# Gemini Deep Research - Initial Setup Guide

This guide walks you through the one-time setup to get Gemini/Google login working with Playwright MCP.

## Step-by-Step Setup

### Step 1: Install Playwright MCP

If you haven't already, install the Playwright MCP server:

```bash
# For Claude Code CLI
claude mcp add playwright npx @playwright/mcp@latest
```

### Step 2: Launch Playwright MCP with Session Persistence

Start Playwright MCP with the flags needed for PDF export and session persistence:

```bash
npx @playwright/mcp@latest \
  --caps=pdf \
  --output-dir ./research-exports \
  --save-session \
  --user-data-dir ~/.playwright/gemini-profile
```

**What each flag does:**
- `--caps=pdf`: Enables the `browser_pdf_save` tool
- `--output-dir ./research-exports`: PDFs save directly into your repo
- `--save-session`: Persists cookies and login state between runs
- `--user-data-dir ~/.playwright/gemini-profile`: Uses a stable browser profile directory

**Important:** Keep this process running! It's the MCP server that Claude will connect to.

### Step 3: Manually Log Into Google/Gemini (First Time Only)

The **first time** you use the skill, you need to log into Google manually:

#### Option A: Use the Skill and Log In When Prompted

1. Ask Claude to run a deep research task:
   ```
   Run Gemini Deep Research on: "Test research topic"
   ```

2. Claude will navigate to Gemini and detect you're not logged in

3. The Playwright browser will stay open - **manually log in** to your Google account in that browser window:
   - Enter your email/password
   - Complete any 2FA if required (authenticator app, SMS, etc.)
   - Accept any terms of service
   - Verify you see the Gemini interface

4. Once logged in, tell Claude to continue/retry

5. **Future runs will automatically be logged in!**

#### Option B: Pre-Login Before Using the Skill

You can also log in manually before the first skill use:

1. While Playwright MCP is running, use the MCP tools directly to open Gemini:

   In Claude Code:
   ```
   Use the playwright MCP server to navigate to https://gemini.google.com/ and keep the browser open
   ```

2. Claude will open the browser to Gemini

3. **Manually log in** to your Google account in the browser window that opens

4. Once logged in, you can close the browser or leave it open

5. The session is now saved! Future skill runs will be automatically logged in

### Step 4: Verify Deep Research Availability

Before using the skill, verify that Deep Research is available in your Gemini account:

1. Navigate to Gemini (while logged in)
2. Look for "Deep research" in:
   - The model selector dropdown (top of page)
   - Tools or features menu
   - Inline suggestions when typing a prompt

**Note:** Deep Research may require:
- Gemini Advanced subscription
- Availability in your region
- Specific account settings

If you don't see Deep Research, you may need to upgrade or check feature availability.

### Step 5: Verify Session Persistence

Test that your session persists:

1. Close any open Playwright browsers

2. Ask Claude:
   ```
   Use the playwright MCP to navigate to https://gemini.google.com/ and take a snapshot
   ```

3. Claude should report that you're already logged in (it will see your Google account profile/avatar)

### Step 6: Use the Skill

Now you're ready! The skill will work seamlessly:

```
Run Gemini Deep Research on: "Impact of renewable energy on grid stability 2025-2030"
```

Claude will:
- Navigate to Gemini (already logged in ✓)
- Start your Deep Research task
- Wait for completion
- Export/save the PDF
- Commit to your repo

## Troubleshooting

### Session Not Persisting

If you're getting logged out between runs:

1. **Make sure you used `--save-session`** when launching Playwright MCP

2. **Use `--user-data-dir`** for more reliable persistence:
   ```bash
   npx @playwright/mcp@latest \
     --caps=pdf \
     --output-dir ./research-exports \
     --save-session \
     --user-data-dir ~/.playwright/gemini-profile
   ```

3. **Don't change the `--user-data-dir` path** - use the same path every time

4. **Check file permissions** on the profile directory:
   ```bash
   ls -la ~/.playwright/gemini-profile
   ```

### 2FA/Security Challenges

If Google requires 2FA or security verification:

1. The Playwright browser will stay open showing the 2FA prompt
2. Complete the 2FA manually in that browser:
   - Enter code from authenticator app
   - Confirm SMS code
   - Select security key option
3. Check "Don't ask again on this device" if available
4. The session will be saved after successful 2FA
5. Tell Claude to retry/continue

### Multiple Google Accounts

If you have multiple Google accounts:

1. **Choose one account** for Gemini Deep Research
2. When logging in for the first time, select that account
3. The session will persist for that specific account
4. To switch accounts:
   - Stop Playwright MCP
   - Clear the profile: `rm -rf ~/.playwright/gemini-profile`
   - Restart Playwright MCP and log in with the new account

### Browser Closes Immediately

If the browser closes before you can log in:

1. Use Option B above - ask Claude to navigate to Gemini and keep it open
2. Or, use the `browser_wait_for` tool to keep the browser open:
   ```
   Navigate to Gemini and wait for me to log in manually
   ```

### Google Session Expired

Sessions can expire after some time (days/weeks). If this happens:

1. The skill will detect you're not logged in
2. Simply log in again manually when the browser opens
3. The new session will be saved

### Deep Research Not Available

If Deep Research isn't showing up:

1. **Check subscription**: You may need Gemini Advanced
   - Visit https://gemini.google.com/advanced
   - Consider upgrading if Deep Research is a required feature

2. **Check region**: Deep Research may not be available in all regions
   - Try using a VPN if appropriate for your use case

3. **Check UI variations**: Deep Research might be labeled:
   - "Research mode"
   - "Deep dive"
   - "Advanced research"
   - Look in model selector dropdown or tools menu

4. **Manual test**: Try starting a Deep Research manually first to confirm it works

### Cookie Consent Dialogs

If you see cookie/consent dialogs:

1. Claude will attempt to dismiss them automatically
2. If they persist, manually click "Accept all" or "Agree"
3. These should only appear on first login

## Advanced: Launch Playwright MCP Automatically

To avoid manually starting Playwright MCP every time:

### Option 1: Add to Claude Code Config

Edit your Claude Code MCP settings to auto-start Playwright:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--caps=pdf",
        "--output-dir",
        "./research-exports",
        "--save-session",
        "--user-data-dir",
        "~/.playwright/gemini-profile"
      ]
    }
  }
}
```

### Option 2: Shell Alias

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias playwright-gemini='npx @playwright/mcp@latest --caps=pdf --output-dir ./research-exports --save-session --user-data-dir ~/.playwright/gemini-profile'
```

Then just run:
```bash
playwright-gemini
```

### Option 3: Systemd Service (Linux)

Create `~/.config/systemd/user/playwright-mcp-gemini.service`:

```ini
[Unit]
Description=Playwright MCP Server for Gemini
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/npx @playwright/mcp@latest --caps=pdf --output-dir %h/your-repo/research-exports --save-session --user-data-dir %h/.playwright/gemini-profile
Restart=on-failure

[Install]
WantedBy=default.target
```

Enable and start:
```bash
systemctl --user enable playwright-mcp-gemini
systemctl --user start playwright-mcp-gemini
```

## Using Multiple Skills (ChatGPT + Gemini)

You can use both ChatGPT and Gemini skills side-by-side:

### Option 1: Same Playwright Instance, Different Profiles

Use different `--user-data-dir` for each:

```bash
# For ChatGPT
npx @playwright/mcp@latest --caps=pdf --output-dir ./research-exports --save-session --user-data-dir ~/.playwright/chatgpt-profile

# For Gemini (separate terminal)
npx @playwright/mcp@latest --caps=pdf --output-dir ./research-exports --save-session --user-data-dir ~/.playwright/gemini-profile
```

**Note:** This runs two separate MCP servers. Claude can only connect to one at a time, so start the one you need for your current task.

### Option 2: Single Profile for Both

If you don't mind mixing sessions, use the same profile:

```bash
npx @playwright/mcp@latest --caps=pdf --output-dir ./research-exports --save-session --user-data-dir ~/.playwright/ai-research-profile
```

Log into both ChatGPT and Gemini in separate tabs/windows. Both sessions will persist.

### Switching Between Skills

Just ask Claude which one to use:

```
# Use ChatGPT
Run ChatGPT Deep Research on: "topic"

# Use Gemini
Run Gemini Deep Research on: "topic"
```

Claude will automatically invoke the correct skill based on your request.

## Quick Reference

**Minimal setup (after first login):**

1. Start Playwright MCP:
   ```bash
   npx @playwright/mcp@latest --caps=pdf --output-dir ./research-exports --save-session
   ```

2. Use the skill:
   ```
   Run Gemini Deep Research on: "your research topic"
   ```

**First-time setup checklist:**

- [ ] Install Playwright MCP
- [ ] Launch with `--caps=pdf`, `--output-dir`, and `--save-session`
- [ ] Manually log into Google in the Playwright browser (one time)
- [ ] Verify Deep Research feature is available in your Gemini account
- [ ] Verify session persists by re-navigating to Gemini
- [ ] Test the skill with a simple research query
- [ ] Confirm PDF was saved to `./research-exports/`
- [ ] Confirm git commit was created

You're all set! 🎉
