# Neovim, tmux, and Vim Grammar Cheat Sheets

Four references in one file: a Vim grammar tutorial, a lookup table for your actual `nvim/` config, a lookup table for your actual `tmux.conf`, and a lookup table for your `superfile/` config. Use the Contents below to jump straight to what you need instead of scrolling.

## Contents

- [Part 1: Vim Grammar Cheat Sheet](#part-1-vim-grammar-cheat-sheet)
  - [1. The Core Operators (The Verbs)](#1-the-core-operators-the-verbs)
    - [Single-character actions](#single-character-actions-do-not-take-motions)
  - [2. Modifiers (Inside vs. Around)](#2-modifiers-inside-vs-around)
  - [3. Text Objects (The Nouns)](#3-text-objects-the-nouns)
  - [4. Normal Mode Navigation (Motions)](#4-normal-mode-navigation-motions)
    - [Word navigation](#word-navigation)
    - [Line navigation](#line-navigation)
    - [Inline searching](#inline-searching-the-sneak-jumps)
    - [File-wide navigation](#file-wide-navigation)
  - [5. Line-wise Shortcuts](#5-line-wise-shortcuts)
  - [6. Repeating and Undoing](#6-repeating-and-undoing)
  - [7. Quick Combos and Real-World Examples](#7-quick-combos-and-real-world-examples)
  - [Mental Model](#mental-model)
- [Part 2: Your Neovim Config Cheat Sheet](#part-2-your-neovim-config-cheat-sheet)
  - [File and window basics](#file-and-window-basics)
  - [Command-line completion (blink.cmp)](#command-line-completion-blinkcmp-plugin)
  - [Editing quality-of-life](#editing-quality-of-life)
  - [Diagnostics](#diagnostics)
  - [Inline diagnostics (tiny-inline-diagnostic.nvim)](#inline-diagnostics-tiny-inline-diagnosticnvim-plugin)
  - [Sticky context (treesitter-context)](#sticky-context-nvim-treesitter-context-plugin)
  - [LSP progress (fidget.nvim)](#lsp-progress-fidgetnvim-plugin)
  - [Mode indicator (cursor line number color)](#mode-indicator-cursor-line-number-color)
  - [Git (gitsigns)](#git-gitsigns)
  - [Clipboard and file paths](#clipboard-and-file-paths)
  - [LSP](#lsp)
  - [Linting (nvim-lint)](#linting-nvim-lint-plugin)
  - [Fuzzy finding (fzf-lua)](#fuzzy-finding-fzf-lua-plugin)
  - [Navigation (harpoon)](#navigation-harpoon-plugin)
  - [Trouble](#trouble-plugin)
  - [Aerial (outline)](#aerial-outline-plugin)
  - [Oil (file explorer)](#oil-plugin)
  - [Image preview (image.nvim & focal.nvim)](#image-preview-imagenvim--focalnvim-plugin)
  - [File tree (neo-tree)](#file-tree-neo-treenvim-plugin)
  - [Session tracking (vim-obsession)](#session-tracking-vim-obsession-plugin)
  - [Floating terminal (floaterm)](#floating-terminal-floaterm-plugin)
  - [Formatting (conform.nvim)](#formatting-conformnvim-plugin)
  - [Statusline (lualine.nvim)](#statusline-lualinenvim-plugin)
  - [Discoverability (which-key)](#discoverability-which-key-plugin)
  - [Text objects and surround (mini.nvim)](#text-objects-and-surround-mininvim-plugin)
  - [Completion (blink.cmp)](#completion-blinkcmp-plugin)
- [Part 3: Your tmux Config Cheat Sheet](#part-3-your-tmux-config-cheat-sheet)
  - [Sessions](#sessions)
  - [Windows](#windows)
  - [Panes](#panes)
    - [Moving between panes](#moving-between-panes)
    - [Resizing and arranging](#resizing-and-arranging)
    - [Pane titles](#pane-titles)
  - [Copy Mode](#copy-mode)
  - [Config and Plugins](#config-and-plugins)
  - [Session Persistence (resurrect + continuum)](#session-persistence-resurrect--continuum-plugin)
    - [What actually comes back](#what-actually-comes-back)
    - [Managing saved snapshots (`trs`)](#managing-saved-snapshots-trs)
    - [The Friday/Monday routine](#the-fridaymonday-routine)
  - [Discoverability (tmux)](#discoverability-tmux)
- [Part 4: Your superfile Config Cheat Sheet](#part-4-your-superfile-config-cheat-sheet)
  - [Config choices](#config-choices)
  - [Launching and quitting](#launching-and-quitting)
  - [Navigation (spf)](#navigation-spf)
  - [Panels and focus](#panels-and-focus)
  - [File operations](#file-operations)
  - [Select mode](#select-mode)
  - [Other actions](#other-actions)
  - [Discoverability (spf)](#discoverability-spf)

---

## Part 1: Vim Grammar Cheat Sheet

In Neovim, editing is structured like a language. You combine **Operators** (verbs) with **Motions** and **Text Objects** (nouns) to perform precise edits instantly. Once the grammar clicks, you stop memorizing individual commands and start composing them.

The general shape of a command is:

```
[count] operator + text object / motion
```

The `count` is optional. For example, `d2w` deletes two words, and `3dd` deletes three lines.

### 1. The Core Operators (The Verbs)

These commands perform an action on a text target.

| Key | Action | What it does |
|-----|--------|--------------|
| `v` | Visual | Starts highlighting text (technically a mode switch, but it takes motions like an operator). |
| `d` | Delete | Deletes (cuts) text into a register. |
| `y` | Yank | Copies text into a register. |
| `c` | Change | Deletes text and drops you into Insert mode. |
| `>` | Indent | Shifts text one shiftwidth to the right. |
| `<` | Outdent | Shifts text one shiftwidth to the left. |
| `=` | Format | Auto-indents the target using the current indent settings. |
| `gU` | Uppercase | Makes the target UPPERCASE. |
| `gu` | Lowercase | Makes the target lowercase. |
| `g~` | Toggle case | Swaps upper and lower case across the target. |

#### Single-character actions (do not take motions)

These act on the character under the cursor directly, so they are not composed with text objects.

| Key | Action | What it does |
|-----|--------|--------------|
| `r` | Replace char | Replaces the single character under the cursor, then stays in Normal mode. |
| `R` | Replace mode | Enters overtype mode until you press Escape. |
| `x` | Delete char | Deletes the character under the cursor. |
| `s` | Substitute char | Deletes the character under the cursor and enters Insert mode. |
| `~` | Toggle case | Swaps the case of the character under the cursor and moves right. |

Note on `~`: by default it only affects the single character under the cursor. It only behaves as a motion-taking operator (for example `g~w`) if you set `tildeop`. In practice, most people use `g~`, `gU`, and `gu` when they want to act on a larger target.

### 2. Modifiers (Inside vs. Around)

When targeting grouped text such as quotes, parentheses, or blocks, these modifiers decide whether the surrounding symbols are included.

- `i` (**i**nside): targets only the content inside the delimiters.
- `a` (**a**round / an): targets the content plus the surrounding delimiters, and any trailing whitespace where it makes sense.

Example: with the cursor inside `"hello"`, `di"` leaves the empty quotes `""`, while `da"` removes the quotes as well.

### 3. Text Objects (The Nouns)

Pair these with a modifier (`i` or `a`) and an operator to target a specific unit of text.

| Key | Text Object | Example usage |
|-----|-------------|---------------|
| `w` | Word | `diw` (delete inside word) |
| `p` | Paragraph | `yap` (yank around paragraph) |
| `s` | Sentence | `cis` (change inside sentence) |
| `"` | Double quotes | `vi"` (visually select inside `""`) |
| `'` | Single quotes | `ca'` (change around `''`, removing the quotes too) |
| `` ` `` | Backticks | ``di` `` (delete inside backticks) |
| `(`, `)`, or `b` | Parentheses | `di)` or `dib` (delete inside `()`) |
| `{`, `}`, or `B` | Curly braces | `da}` or `daB` (delete around `{}`) |
| `[`, `]` | Square brackets | `ci]` (change inside `[]`) |
| `<`, `>` | Angle brackets | `di<` (delete inside `<>`) |
| `t` | HTML/XML tag | `cit` (change inside `<div>tag</div>`) |

Tip: text objects work from anywhere within the object. You do not need to place the cursor on the opening delimiter first, which is what makes them so fast.

### 4. Normal Mode Navigation (Motions)

Motions double as both nouns (targets for operators) and fast ways to move around a file.

#### Word navigation

| Key | Action |
|-----|--------|
| `w` | Jump to the start of the next word |
| `e` | Jump to the end of the next word |
| `b` | Jump backward to the start of the previous word |
| `W` / `E` / `B` | Same as `w`/`e`/`b`, but ignore punctuation, so `my-variable_name` counts as one word |

#### Line navigation

| Key | Action |
|-----|--------|
| `0` | Jump to the absolute beginning of the line |
| `^` | Jump to the first non-blank character of the line (useful for indented code) |
| `$` | Jump to the end of the line |

#### Inline searching (the sneak jumps)

| Key | Action |
|-----|--------|
| `f{char}` | Find the next occurrence of `{char}` forward on the current line |
| `t{char}` | Jump till (just before) the next `{char}` forward |
| `F{char}` | Find `{char}` backward on the current line |
| `T{char}` | Jump till `{char}` backward |
| `;` | Repeat the last inline search in the same direction |
| `,` | Repeat the last inline search in the opposite direction |

#### File-wide navigation

| Key | Action |
|-----|--------|
| `gg` | Jump to the first line of the file |
| `G` | Jump to the last line of the file |
| `:{num}` | Go to a specific line number (for example `:45` then Enter) |
| `%` | Jump to the matching bracket or parenthesis under the cursor |
| `*` | Search forward for the word under the cursor |
| `#` | Search backward for the word under the cursor |

### 5. Line-wise Shortcuts

Doubling an operator makes it act on the whole current line. Uppercase variants act from the cursor to the end of the line.

| Key | Action |
|-----|--------|
| `dd` | Delete the entire line. |
| `yy` | Yank (copy) the entire line. |
| `cc` | Wipe the entire line and enter Insert mode. |
| `>>` / `<<` | Indent / outdent the current line. |
| `D` | Delete from the cursor to the end of the line (shortcut for `d$`). |
| `C` | Change from the cursor to the end of the line (shortcut for `c$`). |
| `Y` | Yank the current line (equivalent to `yy` in Neovim defaults). |

### 6. Repeating and Undoing

These are what turn the grammar into real speed. Learn them early.

| Key | Action |
|-----|--------|
| `.` | Repeat the last change. The single most valuable command in Vim — make an edit once, then move and press `.` to apply it again. |
| `u` | Undo. |
| `<C-r>` | Redo. |

A common workflow is to make a small precise edit (for example `ciw` to change a word), then use `n` or `f` to jump to the next target and press `.` to repeat it, rather than retyping the whole command.

### 7. Quick Combos and Real-World Examples

The fastest way to internalize this is to combine the pieces like building blocks. These are the combos you will reach for daily.

**Code cleanups**

| Key | Action |
|-----|--------|
| `ci"` | Clear everything inside a string, ready to retype it |
| `da(` | Delete a function's argument list, brackets included |
| `gUiw` | Uppercase the word under the cursor |
| `guiw` | Lowercase the word under the cursor |
| `cit` | Rewrite the contents of an HTML/XML tag |

**Formatting**

| Key | Action |
|-----|--------|
| `>i{` | Indent the whole block inside curly braces |
| `=i{` | Auto-format (re-indent) the block inside curly braces |

**Fast line operations**

| Key | Action |
|-----|--------|
| `cc` | Wipe the whole line and start typing |
| `dd` | Delete the whole line |
| `yy` | Copy the whole line |
| `D` | Delete from the cursor to end of line |
| `C` | Change from the cursor to end of line |

**Counts**

| Key | Action |
|-----|--------|
| `d2w` | Delete two words |
| `3dd` | Delete three lines |
| `y5j` | Yank the current line plus the five below it |

### Mental Model

If you remember one thing, remember this: you are not memorizing commands, you are speaking a language. Pick a verb (operator), then describe what it acts on (a motion or text object), optionally with a count. Any valid combination works, even ones you have never used before. That composability is the whole point.

---

## Part 2: Your Neovim Config Cheat Sheet

This section reflects your own `nvim/` config, not generic Vim defaults. Bindings tagged **(plugin)** in a section heading come from a plugin's own default keymap; everything else is a custom mapping you defined. Your leader key is **Space** (`vim.g.mapleader = " "`), so "leader" below always means Space.

### File and window basics

| Key | Action |
|-----|--------|
| `<leader>w` | Save file |
| `<leader>q` | Quit window |
| `<Esc>` | Clear search highlight |

### Command-line completion (blink.cmp, plugin)

Handled by blink.cmp's built-in cmdline support (`lua/plugins/lsp.lua`), not native Neovim. `:` and `@` (command-line/prompt) use `cmdline` + `path` sources; `/` and `?` (search) use the `buffer` source. The menu is forced to always show (`menu.auto_show = true`) rather than only inside the cmdline window (`q:`/`q/`).

Uses blink's own `"cmdline"` keymap preset — separate from the `"default"` preset used for buffer completion below, since blink treats cmdline as its own mode.

| Key | Action |
|-----|--------|
| `<Tab>` | Open the menu, or accept if there's a single match; otherwise select next |
| `<S-Tab>` | Select previous |
| `<C-n>` / `<Right>` | Select next item |
| `<C-p>` / `<Left>` | Select previous item |
| `<C-y>` | Accept the selected item (without running the command) |
| `<C-e>` | Cancel/close the menu |
| `<C-space>` | Force-show the menu |
| `<End>` | Hide the menu |
| `<Enter>` | Run the command (accepts the highlighted selection first, if any) |

(A `wilder.nvim`-based fuzzy cmdline popup was tried and removed — it rendered its popup in the wrong position and hid the text you were typing. Before blink.cmp's cmdline support was configured, the native `wildoptions = "pum"` popup was used instead — it only completed on `<Tab>`, no live fuzzy-as-you-type.)

### Editing quality-of-life

| Key | Mode | Action |
|-----|------|--------|
| `<` / `>` | Visual | Indent/outdent, then reselect so you can repeat |
| `J` | Visual | Move the selected lines down one line |
| `K` | Visual | Move the selected lines up one line |
| `<C-d>` / `<C-u>` | Normal | Half-page down/up, keeping the cursor centered (`zz`) |
| `n` / `N` | Normal | Next/previous search result, centered on screen |

### Diagnostics

| Key | Action |
|-----|--------|
| `<leader>e` | Show the diagnostic(s) on the current line in a float |
| `<leader>uv` | Toggle inline diagnostics on/off (tiny-inline-diagnostic.nvim — see below) |
| `<leader>xq` | Send buffer diagnostics to the location list |
| `[d` / `]d` | Previous/next diagnostic (opens a float) |
| `[e` / `]e` | Previous/next diagnostic of severity ERROR |

### Inline diagnostics (tiny-inline-diagnostic.nvim, plugin)

Replaces Neovim's native `virtual_text` diagnostics (which were off in this config — long Terraform/module errors were unreadable as virtual text). Renders at the end of the line and wraps/truncates instead of overflowing. No keymaps of its own beyond the `<leader>uv` toggle above.

### Sticky context (nvim-treesitter-context, plugin)

No keymaps — automatic. Pins the enclosing function/class/block as a sticky header at the top of the window once you scroll past its definition, capped at 3 lines (`max_lines = 3`).

### LSP progress (fidget.nvim, plugin)

No keymaps — automatic. Shows LSP progress (indexing, workspace scans, Mason installs) as a small transient notification in the corner instead of blocking or cluttering the command line.

### Mode indicator (cursor line number color)

No keymaps, no plugin — a small custom module (`lua/config/mode-cursorline.lua`). Colors the cursor's line number (`CursorLineNr`) based on the current mode (insert/visual/replace/command/terminal), so the mode is visible at a glance without a statusline mode block. Colors are pulled from semantic highlight groups (`String`, `Constant`, `DiagnosticError`, `Function`, `Type`) rather than hardcoded, so it stays correct across every theme in `colortheme.lua`.

### Git (gitsigns)

| Key | Action |
|-----|--------|
| `]h` / `[h` | Next/previous git hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame current line |

### Clipboard and file paths

| Key | Mode | Action |
|-----|------|--------|
| `<leader>y` | Normal/Visual | Yank to the system clipboard |
| `<leader>Y` | Normal | Yank the line to the system clipboard |
| `<leader>p` | Normal/Visual | Paste from the system clipboard |
| `<leader>cp` | Normal | Copy the relative file path |
| `<leader>cP` | Normal | Copy the absolute file path |
| `<leader>cL` | Normal | Copy `path:line` for the current line |

Note: this used to be `<leader>cl` (lowercase), but that collided with Trouble's LSP definitions/references toggle (`tools.lua`) — Trouble's `keys` spec loaded after `config.keymaps` in `init.lua` and always won, silently shadowing the path-copy. Renamed to capital `<leader>cL` to give both bindings their own key.

### LSP

Enabled servers (`lua/config/lsp.lua`):

| Server | Filetypes |
|--------|-----------|
| `gopls` | go, gomod, gowork, gotmpl |
| `basedpyright` | python |
| `lua_ls` | lua |
| `terraformls` | terraform, terraform-vars |
| `ts_ls` | javascript, javascriptreact, typescript, typescriptreact |
| `svelte` | svelte |
| `cssls` | css, scss, less |
| `html` | html |

Global, works everywhere:

| Key | Action |
|-----|--------|
| `<leader>li` | `:LspInfo` |
| `<leader>lr` | `:LspRestart` |

Buffer-local, only active once an LSP attaches (set in the `LspAttach` autocommand):

| Key | Action |
|-----|--------|
| `K` | Hover docs |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Find references |
| `gt` | Go to type definition |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>oi` | Organize imports |
| `<leader>ds` | Document symbols |
| `<leader>ws` | Workspace symbols |
| `<leader>ih` | Toggle inlay hints (only if the server supports them) |

### Linting (nvim-lint, plugin)

No keymaps — runs automatically on `BufWritePost`/`BufReadPost`/`InsertLeave`. Separate from the LSP servers above (some filetypes have no LSP-based lint rules at all).

| Filetype | Linter |
|----------|--------|
| javascript, javascriptreact, typescript, typescriptreact, svelte | `eslint_d` |
| python | `ruff` — routed through `uv run -- ruff ...` instead of the mason-installed global binary, so it resolves your project's pinned version (requires `ruff` to actually be a project dependency, e.g. in `pyproject.toml`) |

The `ruff_format` formatter (below) is routed through `uv` the same way, for the same reason.

### Fuzzy finding (fzf-lua, plugin)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fs` | Document symbols |
| `<leader>fS` | Workspace symbols |
| `<leader>fr` | Recent files |

### Navigation (harpoon, plugin)

Pin a handful of files you're actively bouncing between and jump straight to them, instead of re-fuzzy-finding each time.

| Key | Action |
|-----|--------|
| `<leader>a` | Add the current file to the harpoon list |
| `<C-e>` | Toggle the harpoon quick-menu (floating window) |
| `<leader>1` … `<leader>4` | Jump directly to pinned file 1–4 |

### Trouble (plugin)

| Key | Action |
|-----|--------|
| `<leader>xx` | Toggle diagnostics list |
| `<leader>xX` | Toggle diagnostics for current buffer only |
| `<leader>cs` | Toggle symbols outline |
| `<leader>cl` | Toggle LSP definitions/references |
| `<leader>xL` | Toggle location list |
| `<leader>xQ` | Toggle quickfix list |

### Aerial (outline, plugin)

A symbols outline window, sourced from the LSP (falls back to treesitter where there's no LSP attached). Indent guides are on (`show_guides = true`).

| Key | Action |
|-----|--------|
| `<leader>co` | Toggle the outline window |

Inside the outline window (aerial's default keymaps):

| Key | Action |
|-----|--------|
| `<CR>` / `o` | Jump to the symbol, focus moves to the source window |
| `<C-v>` / `<C-s>` / `<C-t>` | Jump in a vsplit/split/tab |
| `p` | Peek the symbol's location without leaving the outline |
| `{` / `}` | Previous/next symbol |
| `[[` / `]]` | Previous/next symbol at the same nesting level |
| `za` / `zA` | Toggle fold on a symbol with children |
| `zR` / `zM` | Open/close all folds |
| `q` | Close the outline |

To move focus between the outline and your file without jumping, use the same split navigation as everywhere else: `<C-l>` into the outline, `<C-h>` back into the file (vim-tmux-navigator).

### Oil (plugin)

| Key | Action |
|-----|--------|
| `<leader>o` | Open Oil in the current directory |

Inside an Oil buffer:

| Key | Action |
|-----|--------|
| `<CR>` | Open file/directory under cursor |
| `<C-v>` | Open in a vertical split |
| `<C-s>` | Open in a horizontal split |
| `<C-t>` | Open in a new tab |
| `-` | Go to parent directory |
| `_` | Open the current working directory |
| `g.` | Toggle hidden files |
| `q` / `<C-c>` | Close Oil |
| `<C-p>` | Preview the file under the cursor, opened as a right-hand split — **custom override**: oil's own default derives the split side from `&splitright` (off in this config, so it would open left); this pins it right explicitly without touching `splitright` globally |

### Image preview (image.nvim & focal.nvim, plugin)

No keymaps — both are automatic/hover-based.

| Trigger | Action |
|---------|--------|
| Open a `.png`/`.jpg`/`.jpeg`/`.gif`/`.webp`/`.avif`/`.svg` file directly | Renders inline in the buffer via the Kitty graphics protocol (image.nvim) instead of showing raw bytes |
| Rest the cursor on an image entry inside Oil (or Neo-tree) | Shows a floating hover preview after a moment (focal.nvim, reuses image.nvim's renderer) |

Requires the `magick`/`convert` CLI (ImageMagick) installed system-wide — image.nvim shells out to it to decode/resize images — and tmux's `allow-passthrough on` so the graphics escape codes reach WezTerm through the tmux layer. See [Config and Plugins](#config-and-plugins) in Part 3.

### File tree (neo-tree.nvim, plugin)

| Key | Action |
|-----|--------|
| `<leader>ft` | Toggle the Neo-tree file tree window |

Off by default and lazy-loaded on that key (or the `:Neotree` command) — Oil stays the primary explorer for day-to-day editing; reach for Neo-tree when you specifically want to see the whole project structure at a glance.

### Session tracking (vim-obsession, plugin)

Exists purely to feed tmux's session persistence — see [Session Persistence](#session-persistence-resurrect--continuum-plugin) in Part 3 for the whole picture.

| Key | Action |
|-----|--------|
| `<leader>us` | Toggle session tracking for this project (`:Obsession`) |

Press it once in a project. Obsession writes a `Session.vim` in the cwd and keeps it current as you open/close buffers and rearrange splits. On a reboot, tmux-resurrect sees that file and relaunches the pane as `nvim -S` instead of bare `nvim`, so your buffers and splits come back.

Details worth knowing:

- **It's per-directory, not global.** `Session.vim` lands in nvim's cwd, so tracking only helps panes whose cwd matches. Untracked projects still reopen nvim, just empty.
- **It re-arms itself.** Obsession bakes a hook into `Session.vim`, so an `nvim -S` restore resumes tracking automatically. You never press `<leader>us` twice for the same project.
- **Press it again to stop.** `:Obsession` toggles; a second call stops tracking and leaves the file frozen. `:Obsession!` stops tracking *and* deletes the file.
- **`Session.vim` is gitignored globally** (added to `~/.config/git/ignore`), so it will never show up in `git status` or get committed.
- Loaded with `lazy = false` rather than on the keymap, because a restored session needs the plugin already present before `Session.vim` runs its hook.

### Floating terminal (floaterm, plugin)

| Key | Mode | Action |
|-----|------|--------|
| `<C-\>` | Normal | Open/toggle the floating terminal |
| `<C-\>` | Terminal (inside floaterm only) | Toggle it away again — scoped to floaterm's own buffer filetype, so it does not shadow Neovim's default `<C-\><C-n>` escape sequence in ordinary `:terminal` buffers elsewhere |

Inside the sidebar that lists your terminals (floaterm's own default keymaps, shown when more than one terminal exists):

| Key | Action |
|-----|--------|
| `a` | Add a new terminal |
| `e` | Rename the terminal under the cursor |
| `d` | Delete the terminal under the cursor |
| `<C-l>` | Switch focus between the sidebar and the terminal window |

Note: `<C-\>` used to be bound by vim-tmux-navigator (as "jump to previous tmux pane") — that default was disabled specifically to free up this key for floaterm; see the navigator note in [Moving between panes](#moving-between-panes) in Part 3.

### Formatting (conform.nvim, plugin)

| Key | Action |
|-----|--------|
| `<leader>f` | Format the buffer (also runs automatically on save) |

Formatters by filetype: `go` (gofumpt, goimports), `python` (ruff_format, via `uv` — see [Linting](#linting-nvim-lint-plugin)), `lua` (stylua), `json`/`jsonc` (jq), `terraform`/`hcl` (terraform_fmt), `sh`/`bash` (shfmt), `javascript`/`javascriptreact`/`typescript`/`typescriptreact`/`svelte`/`html`/`css`/`scss` (prettier).

Conform notifies on formatter failure by default (`notify_on_error = true`) — no separate keymap or config needed for that.

### Statusline (lualine.nvim, plugin)

No keymaps. Deliberately minimal: no mode block (redundant with the [mode indicator](#mode-indicator-cursor-line-number-color) above), no chevrons/section separators, theme-adaptive (`theme = "auto"`) so it stays correct across every theme in `colortheme.lua`.

| Side | Shows |
|------|-------|
| Left | Filename + modified marker |
| Right | Diagnostics count, git branch |

### Discoverability (which-key, plugin)

| Key | Action |
|-----|--------|
| `<leader>?` | Show which-key popup for buffer-local keymaps |

Labeled groups (shown instead of a flat list when you press the prefix and pause): `<leader>f` find, `<leader>h` git hunk, `<leader>x` diagnostics/trouble, `<leader>c` code, `<leader>l` lsp, `<leader>u` toggle.

### Text objects and surround (mini.nvim, plugin)

`mini.surround` — add/change/delete surrounding pairs (quotes, brackets, tags):

| Key | Action |
|-----|--------|
| `sa` | Add surround (e.g. `saiw"` to surround a word with quotes) |
| `sd` | Delete surround (e.g. `sd"`) |
| `sr` | Replace surround (e.g. `sr"'`) |
| `sf` / `sF` | Find surround, searching right/left |
| `sh` | Highlight surround |
| `sn` | Update `n_lines` search scope for this session |

`mini.ai` extends the built-in `i`/`a` text objects with smarter, often treesitter-aware detection, and adds a few extra objects (e.g. `if`/`af` for a function call's arguments). See `:h mini.ai-textobject-builtin` for the full list — no custom mappings were configured, so all of this rides on the standard `i`/`a` prefixes from [Part 1](#2-modifiers-inside-vs-around).

### Completion (blink.cmp, plugin)

Using the `"default"` keymap preset, with one override (`<CR>` always accepts if a completion is selected). These are blink.cmp's stock bindings, not ones you wrote by hand:

| Key | Action |
|-----|--------|
| `<CR>` | Accept selected completion, or fall back to a normal Enter — **custom override** |
| `<C-space>` | Show completion menu / toggle documentation |
| `<C-n>` / `<C-p>` | Select next/previous item |
| `<Up>` / `<Down>` | Select previous/next item |
| `<C-e>` | Hide the menu |
| `<Tab>` / `<S-Tab>` | Jump forward/backward through snippet placeholders |
| `<C-b>` / `<C-f>` | Scroll the documentation window |

---

## Part 3: Your tmux Config Cheat Sheet

This section reflects your own `tmux.conf`. Bindings marked **(custom)** are your overrides; the rest are tmux defaults that still apply because you did not rebind them. Your prefix is **Ctrl-a** (not the tmux default Ctrl-b), so everywhere below "prefix" means Ctrl-a.

Mental model: like Vim, tmux is prefix then command. Press the prefix once, release, then press the command key. The exceptions are the no-prefix bindings (Alt and Ctrl navigation) called out below.

### Sessions

A session is a collection of windows. You detach from a session and reattach later with everything still running inside it.

From the shell:

```
tmux                     # start a new unnamed session
tmux new -s work         # start a new session named "work"
tmux ls                  # list running sessions
tmux attach -t work      # attach to session "work"  (short form: tmux a -t work)
tmux kill-session -t work # stop one session
tmux kill-server         # stop every session
```

Inside tmux:

| Binding | Action |
|---------|--------|
| prefix + d | Detach from the session (leaves it running in the background) |
| prefix + s | Interactive session and window tree |
| prefix + $ | Rename the current session |
| prefix + ( / ) | Previous / next session |

### Windows

A window is like a tab. Your status bar shows them as `index:name`, numbered from 1 (your `base-index` is custom).

| Binding | Action |
|---------|--------|
| prefix + c | Create a new window |
| prefix + h | Previous window **(custom, replaces p)** |
| prefix + l | Next window **(custom, replaces n)** |
| prefix + 1..9 | Jump straight to a window by number |
| prefix + , | Rename the current window |
| prefix + & | Kill the current window (asks to confirm) |
| prefix + w | Choose a window from a list |

Note: your `h` and `l` window bindings are not repeatable, so each switch needs the prefix again.

### Panes

Panes split a single window. Your split keys are chosen so the symbol matches the result:

| Binding | Action |
|---------|--------|
| prefix + \| | Split side by side, vertical divider **(custom, replaces %)** |
| prefix + - | Split stacked, horizontal divider **(custom, replaces ")** |

#### Moving between panes

You have two no-prefix ways to move, and they behave differently:

| Binding | Action |
|---------|--------|
| Ctrl + h/j/k/l | Seamless move between Neovim splits and tmux panes (vim-tmux-navigator, no prefix). If the pane runs Neovim it moves the nvim split, otherwise it moves the tmux pane. **(plugin)** |
| Alt + h/j/k/l | Raw tmux pane select, no prefix, ignores Neovim **(custom)** |
| prefix + o | Cycle to the next pane |
| prefix + ; | Jump to the last active pane |
| prefix + q | Show pane numbers, then press a number to jump **(custom, matches default)** |

Use Ctrl + hjkl for everyday movement. The Alt bindings are a fallback for when you specifically want tmux to move even while inside Neovim.

Note: vim-tmux-navigator also ships a 5th default binding, `<C-\>` for "jump to previous pane" — this repo's `nvim/lua/plugins/editing.lua` explicitly disables it (`vim.g.tmux_navigator_no_mappings = 1`, then only h/j/k/l are re-declared) so that key is free for Neovim's floating terminal instead. See [Floating terminal (floaterm)](#floating-terminal-floaterm-plugin) in Part 2. tmux's own root key table still has a conditional binding for `C-\` (installed by the plugin) that forwards the raw key into the pane whenever Neovim is the foreground process, and falls back to `select-pane -l` otherwise — that part is unchanged and is why it still works during a plain shell too.

#### Resizing and arranging

| Binding | Action |
|---------|--------|
| prefix + H/J/K/L | Resize the pane by 5 cells, repeatable **(custom)** |
| prefix + z | Zoom the pane to fullscreen, press again to restore |
| prefix + space | Cycle through the built-in layouts |
| prefix + { / } | Swap the pane with the previous / next one |
| prefix + x | Kill the current pane (asks to confirm) |

Because the resize keys are repeatable, after prefix + H you can keep tapping H/J/K/L for about 0.8s (your `repeat-time`) without pressing the prefix again.

Since mouse mode is on, you can also click a pane to focus it, drag a border to resize, and scroll to enter copy mode.

#### Pane titles

| Binding | Action |
|---------|--------|
| prefix + P | Set a custom title for the current pane **(custom)** |

### Copy Mode

Copy mode lets you scroll back through output and select text to copy.

| Binding | Action |
|---------|--------|
| prefix + [ | Enter copy mode, then scroll or search (q or Enter to exit) |
| prefix + ] | Paste the last copied text |

Your config has `set-clipboard on`, so text you copy in tmux is pushed to the system clipboard through WezTerm's OSC 52 support. That means you can paste it into other applications, not just back into tmux.

Tip: you did not set `mode-keys`, so copy mode may fall back to emacs-style keys depending on your `$EDITOR`. If you want guaranteed Vim-style selection (`v` to start, `y` to yank, Vim motions to move around), add this and it stops being ambiguous:

```
setw -g mode-keys vi
```

### Config and Plugins

| Binding | Action |
|---------|--------|
| prefix + r | Reload `~/.tmux.conf` and flash "Config reloaded" **(custom)** |
| prefix + I | Install plugins declared in the config (TPM) |
| prefix + U | Update installed plugins (TPM) |
| prefix + Alt-u | Remove plugins that are no longer listed (TPM) |
| prefix + F | Fuzzy session/window/pane switcher (tmux-fzf, needs the fzf binary) **(plugin)** |

Not a binding, but worth knowing: `set -gq allow-passthrough on` is set so that terminal-graphics escape codes (Kitty protocol) from image.nvim can reach WezTerm through tmux — needed for the [image preview](#image-preview-imagenvim--focalnvim-plugin) feature to render anything instead of showing raw file bytes.

### Session Persistence (resurrect + continuum, plugin)

Why this matters here specifically: on WSL2, a Windows shutdown (or `wsl --shutdown`) destroys the whole VM, so the tmux server dies with it. There is no "just leave it running" escape hatch like on a Linux box you only lock. These two plugins write the layout to disk so it survives.

| Binding | Action |
|---------|--------|
| prefix + Ctrl-s | Save the current session now (tmux-resurrect) **(plugin)** |
| prefix + Ctrl-r | Restore from the saved snapshot (tmux-resurrect) **(plugin)** |

Division of labour between the two:

- **tmux-resurrect** does the actual save/restore. Manual, via the two keys above.
- **tmux-continuum** automates it: autosaves every 15 minutes (`@continuum-save-interval '15'`) and auto-restores when the tmux server starts (`@continuum-restore 'on'`). This is why you normally never press either key — you just run `tmux` and it's back.

Config notes:

- Snapshots live in `~/.local/share/tmux/resurrect/`. The plugin only falls back to the legacy `~/.tmux/resurrect/` if that directory already exists, and here it doesn't.
- `@resurrect-capture-pane-contents 'on'` saves scrollback too, into a `pane_contents.tar.gz` alongside the snapshot.
- **continuum must be the last plugin declared** in `tmux.conf`. It appends its save timestamp to `status-right`, and anything declared after it can clobber that.

#### What actually comes back

This is the part that surprises people. Panes are recreated with the right layout and cwd, but the **program** inside only restarts if it's on the restore whitelist.

| Pane was running | After restore | Why |
|------------------|---------------|-----|
| A plain shell | Shell at the same cwd | Nothing to relaunch |
| `nvim` | `nvim -S`, buffers and splits intact | `@resurrect-strategy-nvim 'session'` + a `Session.vim` from [vim-obsession](#session-tracking-vim-obsession-plugin) |
| `nvim`, project not tracked | Bare `nvim`, no buffers | No `Session.vim` in that cwd to load |
| `ssh`, `psql`, `lazygit`, `btop`, `watch …` | Relaunched | Added via `@resurrect-processes` |
| `less`, `man`, `top`, `htop`, `tail`, `emacs` | Relaunched | Resurrect's built-in default list |
| **`claude`** | **Plain shell at the right cwd** | **Not whitelisted — see below** |

The whitelist is filtered at *restore* time, not save time: the snapshot records `claude` for those panes, restore just declines to run it. That's deliberate — bare `claude` would start a *fresh* conversation, not resume your work, and auto-launching six of them on every boot is heavy. To resume a conversation, cd into the pane's directory and run `claude --continue` yourself.

If you'd rather it were automatic, add `"~claude --continue"` to `@resurrect-processes` in `tmux.conf` (the leading `~` means "match this command even when it has arguments").

Window and pane **titles** are saved, but your `PROMPT_COMMAND` (`set_tmux_pane_title` in `shell/functions.sh`) rewrites shell pane titles to `sh:<dir>` on the first prompt, so restored shell panes get their generic title back rather than whatever they showed before.

#### Managing saved snapshots (`trs`)

Every save writes a new timestamped file and repoints a `last` symlink at it. `prefix + Ctrl-r` **only ever restores `last`** — resurrect ships no way to browse or choose an older snapshot. The `trs` shell function (`shell/functions.sh`) is a wrapper for exactly that gap.

```
trs               # list snapshots, newest first; * marks the restore target
trs save          # save now (same as prefix + Ctrl-s)
trs use 3         # point `last` at snapshot 3, so Ctrl-r picks it up
trs restore       # restore now
trs restore 3     # restore from snapshot 3 directly
trs rm 3          # delete snapshot 3
trs prune         # keep only the newest 20 (continuum's autosaves pile up)
trs prune 5       # keep only the newest 5
trs help          # usage
```

Sample output — the count columns let you spot the snapshot you want without opening files:

```
#   SAVED             WINDOWS PANES  SESSIONS
*1  2026-07-31 15:35  5       12     0
 2  2026-07-31 15:27  5       12     0
```

Snapshots are plain tab-separated text, so you can always read one by hand:

```
grep '^pane' ~/.local/share/tmux/resurrect/last | tr '\t' '|'
```

Each `pane` line carries session, window index, pane index, pane title, cwd, the command that was running, and the restore command (the `:`-prefixed one at the end — that's what the whitelist above filters on). Don't hardcode `awk` field numbers against it: pane titles can shift the offsets, so a fixed `$10` reads the command on most lines and something else on others.

#### The Friday/Monday routine

Shut down whenever — continuum saved you within the last 15 minutes and continues doing so. Monday, run `tmux` and the session rebuilds itself.

If you want certainty before a deliberate shutdown, `prefix + Ctrl-s` (or `trs save`) first, so the snapshot is exactly the state you're leaving rather than up to 15 minutes stale.

Two gotchas:

- **Restore is additive, not replacing.** Restoring into a session that already has panes skips those panes (resurrect won't clobber a live pane). Restore into a fresh server, which is what continuum's auto-restore does.
- **Only tracked nvim projects get their buffers back.** If a window matters, press `<leader>us` in its nvim once — see [vim-obsession](#session-tracking-vim-obsession-plugin) in Part 2.

### Discoverability (tmux)

| Binding | Action |
|---------|--------|
| prefix + ? | List every active key binding |
| prefix + : | Open the tmux command prompt |

When in doubt, prefix + ? prints the live binding list straight from your running config, which always beats a stale cheat sheet.

---

## Part 4: Your superfile Config Cheat Sheet

This section reflects your own `superfile/` config (v1.6.0). The config lives in the dotfiles repo and is symlinked to `~/.config/superfile`, same pattern as `nvim/` and `eza/`. All hotkeys below are superfile defaults — `hotkeys.toml` hasn't been customized. Keys are vim-flavored out of the box (`h`/`j`/`k`/`l` move, so the muscle memory from Parts 1–3 carries over).

### Config choices

What was changed from the generated defaults (`superfile/config.toml`):

| Setting | Value | Why |
|---------|-------|-----|
| `editor` | `nvim` | `e` opens files in Neovim explicitly instead of relying on `$EDITOR` |
| `cd_on_quit` | `true` | Quitting with `Q` drops the shell into the directory you were browsing — needs the `spf()` wrapper below |
| `code_previewer` | `bat` | File previews use bat's syntax highlighting instead of the builtin chroma |
| `enable_md5_checksum` | `true` | MD5 checksum generation in the metadata panel (`md5sum` is installed) |
| `theme` | `catppuccin-mocha` | The generated default, kept deliberately |

The `cd_on_quit` half lives in `shell/functions.sh`: an `spf()` function wraps the real binary, and after superfile exits it sources the last-dir file superfile wrote (`~/.local/state/superfile/lastdir`) so your shell lands there. Without the wrapper, `Q` behaves like plain `q`.

Not enabled (missing dependencies): `zoxide_support` (no zoxide installed) and the exiftool `metadata` plugin. The `[open_with]` table at the bottom of `config.toml` is empty — add `ext = "command"` lines there to route specific file types to specific programs.

### Launching and quitting

| Key | Action |
|-----|--------|
| `spf` | Launch (the shell function, which wraps the binary) |
| `q` / `Esc` | Quit |
| `Q` | Quit **and cd the shell** to the directory you were browsing |

### Navigation (spf)

| Key | Action |
|-----|--------|
| `j` / `k` (or arrows) | Move down / up |
| `h` / `Left` / `Backspace` | Go to parent directory |
| `l` / `Right` / `Enter` | Enter directory / confirm |
| `PgUp` / `PgDn` | Page up / down |
| `/` | Search in the current panel |
| `.` | Toggle dotfiles |
| `o` | Sort options menu |
| `R` | Reverse sort order |

### Panels and focus

superfile is multi-panel: you can have several file panels side by side, plus a sidebar, a metadata panel, and a process bar.

| Key | Action |
|-----|--------|
| `n` | New file panel |
| `w` | Close current file panel |
| `Tab` / `L` | Next file panel |
| `Shift+Left` / `H` | Previous file panel |
| `N` | Split the current file panel |
| `f` | Toggle the file preview panel |
| `F` | Toggle the footer (metadata/processes/clipboard row) |
| `s` | Focus the sidebar (pinned dirs and disks) |
| `m` | Focus the metadata panel |
| `p` | Focus the process bar |
| `P` | Pin / unpin the current directory |

### File operations

| Key | Action |
|-----|--------|
| `Ctrl+n` | Create a new file or directory (end with `/` for a directory) |
| `Ctrl+r` | Rename |
| `Ctrl+c` | Copy selected item(s) |
| `Ctrl+x` | Cut |
| `Ctrl+v` | Paste |
| `Ctrl+d` / `Delete` | Delete (to trash) |
| `D` | Permanently delete |
| `Ctrl+a` | Compress into an archive |
| `Ctrl+e` | Extract an archive |
| `e` | Open file in nvim |
| `E` | Open the current directory in nvim |

### Select mode

Like Vim's visual mode: switch modes, mark multiple files, then run one operation on all of them.

| Key | Action |
|-----|--------|
| `v` | Toggle between browser mode and select mode |
| `Enter` / `l` | Select / deselect the item under the cursor |
| `Shift+Down` / `J` | Extend selection down |
| `Shift+Up` / `K` | Extend selection up |
| `A` | Select all items in the panel |

### Other actions

| Key | Action |
|-----|--------|
| `c` | Copy the working directory path to the clipboard |
| `Ctrl+p` | Copy the selected file's path |
| `:` | Open the command line (run a shell command from here) |
| `>` | Open the spf prompt |
| `z` | Zoxide jump (currently disabled — zoxide isn't installed) |

### Discoverability (spf)

| Key | Action |
|-----|--------|
| `?` | Built-in help menu listing every active hotkey |

Same principle as tmux's prefix + ?: the live help menu reads your actual `hotkeys.toml`, which always beats a stale cheat sheet.
