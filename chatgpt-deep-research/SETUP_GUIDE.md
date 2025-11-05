# ChatGPT Deep Research - Initial Setup Guide

This guide walks you through the one-time setup to get ChatGPT login working with Playwright MCP.

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
  --user-data-dir ~/.playwright/chatgpt-profile
```

**What each flag does:**
- `--caps=pdf`: Enables the `browser_pdf_save` tool
- `--output-dir ./research-exports`: PDFs save directly into your repo
- `--save-session`: Persists cookies and login state between runs
- `--user-data-dir ~/.playwright/chatgpt-profile`: Uses a stable browser profile directory

**Important:** Keep this process running! It's the MCP server that Claude will connect to.

### Step 3: Manually Log Into ChatGPT (First Time Only)

The **first time** you use the skill, you need to log into ChatGPT manually:

#### Option A: Use the Skill and Log In When Prompted

1. Ask Claude to run a deep research task:
   ```
   Run ChatGPT Deep Research on: "Test research topic"
   ```

2. Claude will navigate to ChatGPT and detect you're not logged in

3. The Playwright browser will stay open - **manually log in** to ChatGPT in that browser window:
   - Enter your email/password
   - Complete any 2FA if required
   - Accept any terms of service

4. Once logged in, tell Claude to continue/retry

5. **Future runs will automatically be logged in!**

#### Option B: Pre-Login Before Using the Skill

You can also log in manually before the first skill use:

1. While Playwright MCP is running, use the MCP tools directly to open ChatGPT:

   In Claude Code:
   ```
   Use the playwright MCP server to navigate to https://chatgpt.com/ and keep the browser open
   ```

2. Claude will open the browser to ChatGPT

3. **Manually log in** in the browser window that opens

4. Once logged in, you can close the browser or leave it open

5. The session is now saved! Future skill runs will be automatically logged in

### Step 4: Verify It Works

Test that your session persists:

1. Close any open Playwright browsers

2. Ask Claude:
   ```
   Use the playwright MCP to navigate to https://chatgpt.com/ and take a snapshot
   ```

3. Claude should report that you're already logged in (it will see your account info/chat history)

### Step 5: Use the Skill

Now you're ready! The skill will work seamlessly:

```
Run ChatGPT Deep Research on: "Future of renewable energy storage in 2025-2030"
```

Claude will:
- Navigate to ChatGPT (already logged in ✓)
- Start your Deep Research task
- Wait for completion
- Save the PDF
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
     --user-data-dir ~/.playwright/chatgpt-profile
   ```

3. **Don't change the `--user-data-dir` path** - use the same path every time

### 2FA/Security Challenges

If ChatGPT requires 2FA or security verification:

1. The Playwright browser will stay open showing the 2FA prompt
2. Complete the 2FA manually in that browser
3. The session will be saved after successful 2FA
4. Tell Claude to retry/continue

### Browser Closes Immediately

If the browser closes before you can log in:

1. Use Option B above - ask Claude to navigate to ChatGPT and keep it open
2. Or, use the `browser_wait_for` tool to keep the browser open:
   ```
   Navigate to ChatGPT and wait for me to log in manually
   ```

### ChatGPT Session Expired

Sessions can expire after some time (days/weeks). If this happens:

1. The skill will detect you're not logged in
2. Simply log in again manually when the browser opens
3. The new session will be saved

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
        "~/.playwright/chatgpt-profile"
      ]
    }
  }
}
```

### Option 2: Shell Alias

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias playwright-chatgpt='npx @playwright/mcp@latest --caps=pdf --output-dir ./research-exports --save-session --user-data-dir ~/.playwright/chatgpt-profile'
```

Then just run:
```bash
playwright-chatgpt
```

### Option 3: Systemd Service (Linux)

Create `~/.config/systemd/user/playwright-mcp.service`:

```ini
[Unit]
Description=Playwright MCP Server for ChatGPT
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/npx @playwright/mcp@latest --caps=pdf --output-dir %h/your-repo/research-exports --save-session --user-data-dir %h/.playwright/chatgpt-profile
Restart=on-failure

[Install]
WantedBy=default.target
```

Enable and start:
```bash
systemctl --user enable playwright-mcp
systemctl --user start playwright-mcp
```

## Quick Reference

**Minimal setup (after first login):**

1. Start Playwright MCP:
   ```bash
   npx @playwright/mcp@latest --caps=pdf --output-dir ./research-exports --save-session
   ```

2. Use the skill:
   ```
   Run ChatGPT Deep Research on: "your research topic"
   ```

**First-time setup checklist:**

- [ ] Install Playwright MCP
- [ ] Launch with `--caps=pdf`, `--output-dir`, and `--save-session`
- [ ] Manually log into ChatGPT in the Playwright browser (one time)
- [ ] Verify session persists by re-navigating to ChatGPT
- [ ] Test the skill with a simple research query
- [ ] Confirm PDF was saved to `./research-exports/`
- [ ] Confirm git commit was created

You're all set! 🎉
