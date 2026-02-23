# ai-detach

Extracts AI tool config files from git repos into symlinked sibling directories.

## The problem

AI tools (Claude Code, Cursor, Windsurf, Aider, Copilot, etc.) all drop config files into project roots — `CLAUDE.md`, `.claude/`, `.mcp.json`, `.cursor/`, etc. You might not want these files to live in the project repo but need them to exist in the project directory for the tools to work. Adding them to `.gitignore` might work, but what if you want to store AI files separately, for example, in a separate git repo?

## The solution

`ai-detach` moves AI files to a sibling `<project>-ai/` directory and symlinks them back. The AI tools see the files where they expect them, but project git never touches them. You can then commit `<project>-ai/` contents to its own git repo and store AI configuration separately from the main project codebase.

## Usage

```bash
ai-detach [options] [project-path]
```

```bash
ai-detach ~/code/project          # moves AI files, creates ~/code/project-ai/
ai-detach --dry-run ~/code/project # preview only
ai-detach --list ~/code/project    # just show detected files
ai-detach                     # run in current directory
```

### Options

| Flag | Description |
|------|-------------|
| `-n`, `--dry-run` | Preview operations without making changes |
| `-l`, `--list` | List detected AI files only |
| `-h`, `--help` | Show help |
| `-v`, `--version` | Show version |

## What it does

Given `~/code/project/` with Claude Code files:

```
# Before
~/code/project/
  CLAUDE.md          (real file, cluttering git)
  .claude/           (real directory)
  .mcp.json          (real file)
  src/...

# After
~/code/project/
  CLAUDE.md -> ../project-ai/CLAUDE.md     (symlink)
  .claude/  -> ../project-ai/.claude/     (symlink)
  .mcp.json -> ../project-ai/.mcp.json   (symlink)
  .gitignore                             (updated)
  src/...

~/code/project-ai/
  CLAUDE.md          (real file)
  .claude/           (real directory)
  .mcp.json          (real file)
```

## Detected files

| Pattern | Tool |
|---------|------|
| `CLAUDE.md`, `.claude/` | Claude Code |
| `.mcp.json` | MCP config |
| `.cursorules`, `.cursorrules`, `.cursor/` | Cursor |
| `WARP.md` | Warp |
| `.windsurf/`, `.windsurfrules` | Windsurf |
| `.aider*` | Aider |
| `.copilot/`, `.github/copilot-instructions.md` | GitHub Copilot |
| `.playwright-mcp/` | Playwright MCP |
| `AGENTS.md`, `.agents/` | Agents spec |
| `codex.md`, `.codex/` | OpenAI Codex |

## Key behaviors

- **Relative symlinks** — `../project-ai/CLAUDE.md` survives directory renames if the sibling moves too
- **Git-aware** — runs `git rm --cached` on tracked files before moving
- **Idempotent** — re-running skips already-symlinked files
- **Updates .gitignore** — adds entries under a managed header block
- **Bash 3.2 compatible** — works with macOS default bash

## Install

```bash
# Copy to somewhere on your PATH
cp ai-detach /usr/local/bin/ai-detach
```

## License

MIT
