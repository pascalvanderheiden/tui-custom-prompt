# TUI Custom Prompt

A reproducible setup for a **rainbow-flag Oh-My-Posh terminal prompt** that is
visually aligned with the **GitHub Copilot CLI status line**. Use this repo to
spin up an identical terminal on a new laptop (macOS / Linux / Windows), or to
share the look-and-feel with others.

The Oh-My-Posh theme (`rainbowflag.omp.json`) uses the same rainbow palette as
the GitHub Copilot CLI status line in this setup, so the terminal feels
consistent whether you are at the shell prompt or inside `copilot`.

## What's in this repo

| File                                              | Purpose                                  |
| ------------------------------------------------- | ---------------------------------------- |
| `rainbowflag.omp.json`                            | The Oh-My-Posh prompt theme              |
| `scripts/*.sh`                                    | Helpers for line-2 context segments      |
| `install.sh`                                      | One-shot installer for macOS / Linux     |
| `install.ps1`                                     | One-shot installer for Windows           |

### Prompt segments — one rainbow line

All segments render in a single line, styled as powerline chunks. Each band's
background color is the segment color; foreground is white/black for max
contrast. Segments only appear when relevant (e.g. `colima` only when Colima
VMs exist), so the line stays compact.

| Band       | Segments (left → right)                       | Source                                      |
| ---------- | ---------------------------------------------- | ------------------------------------------- |
| 🔴 Red       | OS · `opt+spc to record`                     | static hint mirrors Copilot CLI footer      |
| 🟠 Orange    | Azure (e.g. `@microsoft.com`)                | `az account show` — domain part of user     |
| 🟡 Yellow    | Path · `🐙 <gh-user>`                         | folder + active `gh auth status` account    |
| 🟢 Green     | Git · tokens (e.g. `717.0K`)                 | git status + `ai-engineering-fluency usage` |
| 🔵 Blue      | squad · execution time                       | `.squad` marker + last-cmd duration > 500 ms |
| 🟣 Purple    | openspec · spec-kit · colima · root          | openspec/spec-kit/colima helpers + root cue |

Values only (no `key:` labels) for a tight prompt. Helpers live in `scripts/`
— edit any of them to change what a segment shows.

> No Kubernetes segment — toggle `kubectl` contexts at the shell or status-line
> level instead.

---

## 1. Install a Nerd Font

The prompt uses glyphs from a Nerd Font — without one you will see boxes.
[MesloLGM Nerd Font](https://www.nerdfonts.com/font-downloads) is recommended.

* **macOS** (Homebrew):
  ```bash
  brew install --cask font-meslo-lg-nerd-font
  ```
* **Linux**:
  ```bash
  mkdir -p ~/.local/share/fonts
  curl -fLo ~/.local/share/fonts/MesloLGM-Regular.ttf \
    https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M/Regular/MesloLGMNerdFont-Regular.ttf
  fc-cache -f
  ```
* **Windows** (winget):
  ```powershell
  winget install --id DEVCOM.JetBrainsMonoNerdFont   # or any Nerd Font you like
  ```

Point your terminal at the font:

**VS Code** — `Cmd/Ctrl+Shift+P` → *Preferences: Open User Settings (JSON)*:
```json
{ "terminal.integrated.fontFamily": "MesloLGM NF" }
```

**Windows Terminal** (`settings.json`):
```json
{ "profiles": { "defaults": { "font": { "face": "MesloLGM NF" } } } }
```

---

## 2. Install Oh-My-Posh

* **macOS** (Homebrew):
  ```bash
  brew install jandedobbeleer/oh-my-posh/oh-my-posh
  ```
* **Linux**:
  ```bash
  curl -s https://ohmyposh.dev/install.sh | bash -s
  ```
* **Windows** (winget):
  ```powershell
  winget install JanDeDobbeleer.OhMyPosh -s winget
  ```

Verify: `oh-my-posh --version`

---

## 3. Clone this repo & enable the theme

```bash
git clone https://github.com/pascalvanderheiden/tui-custom-prompt.git
cd tui-custom-prompt
```

### Quick install (recommended)

**macOS / Linux** (zsh, bash, or fish — auto-detected from `$SHELL`):
```bash
./install.sh                  # install + wire up current shell
./install.sh bash             # force a specific shell
SKIP_FONT=1 ./install.sh      # skip Nerd Font install
```

**Windows (PowerShell)**:
```powershell
.\install.ps1                 # install + wire up $PROFILE
.\install.ps1 -SkipFont       # skip Nerd Font install
```

The scripts:
* install Oh-My-Posh if missing (Homebrew / `ohmyposh.dev/install.sh` / winget),
* install a MesloLGM Nerd Font (skippable),
* add a marked block to your shell rc / `$PROFILE` (safe to re-run; the block
  is updated in place, never duplicated),
* preview the prompt.

After it finishes, open a new terminal (or run `exec $SHELL` / `. $PROFILE`).

### Manual install

If you prefer to wire it up yourself, replace `$REPO` with the absolute path
where you cloned this repo:

### zsh (macOS default)
Append to `~/.zshrc`:
```bash
eval "$(oh-my-posh init zsh --config $REPO/rainbowflag.omp.json)"
```
Reload: `exec zsh`.

### bash (Linux)
Append to `~/.bashrc`:
```bash
eval "$(oh-my-posh init bash --config $REPO/rainbowflag.omp.json)"
```
Reload: `source ~/.bashrc`.

### PowerShell (Windows / cross-platform)
Open profile with `code $PROFILE` and add:
```powershell
oh-my-posh init pwsh --config "$env:USERPROFILE\GitHub\tui-custom-prompt\rainbowflag.omp.json" | Invoke-Expression
```
Reload: `. $PROFILE`.

### fish
Add to `~/.config/fish/config.fish`:
```fish
oh-my-posh init fish --config $REPO/rainbowflag.omp.json | source
```

### Updating Oh-My-Posh
```bash
brew upgrade oh-my-posh                 # macOS
winget upgrade JanDeDobbeleer.OhMyPosh  # Windows
```

---

## 4. (Optional) GitHub Copilot CLI status line

If you use the [GitHub Copilot CLI](https://docs.github.com/en/copilot/github-copilot-in-the-cli),
its status line uses the same rainbow palette as this prompt, so the look stays
consistent.

Configure in `~/.copilot/settings.json`:
```json
{
  "statusLine": {
    "type": "command",
    "command": "/absolute/path/to/your/statusline.sh"
  },
  "footer": {
    "showDirectory": true,
    "showBranch": true,
    "showContextWindow": true,
    "showAgent": true
  }
}
```

---

## 5. Optional CLIs powering the prompt segments

Each line-2 segment is **opt-in** — install only the tools you care about; the
rest stay silently hidden. All commands below run inside your terminal.

### Line 1 (rainbow flag)

| Tool         | macOS (Homebrew)               | Windows (winget)                          | Used for                |
| ------------ | ------------------------------ | ----------------------------------------- | ----------------------- |
| Azure CLI    | `brew install azure-cli`       | `winget install Microsoft.AzureCLI`       | 🟠 `az` subscription    |
| Git          | preinstalled / `brew install git` | `winget install Git.Git`               | 🟢 git status segment   |

### Line 2 (Copilot CLI–style status bar)

| Tool                                                          | macOS (Homebrew)                                                   | Windows (winget / pwsh)                                                                  | Segment              |
| ------------------------------------------------------------- | ------------------------------------------------------------------ | ---------------------------------------------------------------------------------------- | -------------------- |
| **GitHub CLI** (`gh`)                                         | `brew install gh`                                                  | `winget install GitHub.cli`                                                              | 🟡 `gh: <user>`      |
| **`jq`** (used by openspec helper)                            | `brew install jq`                                                  | `winget install jqlang.jq`                                                               | 🟪 `openspec` (nice output) |
| **OpenSpec CLI**                                              | `brew install node` then `npm i -g @fission-codes/openspec`        | `winget install OpenJS.NodeJS` then `npm i -g @fission-codes/openspec`                   | 🟪 `openspec: …`     |
| **GitHub Spec Kit** (`specify`)                               | `brew install uv` then `uv tool install specify-cli --from git+https://github.com/github/spec-kit.git` | `winget install astral-sh.uv` then `uv tool install specify-cli --from git+https://github.com/github/spec-kit.git` | 🟣 `spec-kit: …`     |
| **AI Engineering Fluency** (`ai-engineering-fluency`) *(internal)* | `npm i -g @microsoft/ai-engineering-fluency` *(if you have access)* | `npm i -g @microsoft/ai-engineering-fluency`                                             | 🟢 `tokens<30d`      |
| **Colima** (Docker VM)                                        | `brew install colima docker`                                       | *not supported on Windows — use Docker Desktop / WSL2*                                   | 🩷 `colima: r/t`     |
| **Squad** (squad-of-agents)                                   | just create a `.squad` directory at your project root              | same                                                                                     | 🔵 `squad`           |

> The `ai-engineering-fluency` tool is an internal Microsoft package; outside
> Microsoft the green `tokens<30d` segment will simply stay hidden.
> Replace it with your own usage script in `scripts/tokens.sh` if you want a
> different metric there.

### Quick sanity check

After installing any of the above, run:
```bash
~/GitHub/tui-custom-prompt/scripts/gh-user.sh
~/GitHub/tui-custom-prompt/scripts/openspec.sh
~/GitHub/tui-custom-prompt/scripts/speckit.sh
~/GitHub/tui-custom-prompt/scripts/tokens.sh
~/GitHub/tui-custom-prompt/scripts/colima.sh
```
A populated line of output means the corresponding prompt segment will appear.
Empty output means the segment will hide — exactly what you want when the tool
isn't relevant.

### Authenticate / activate

```bash
az login          # populates the 🟠 Azure segment
gh auth login     # populates the 🟡 gh segment
colima start      # populates the 🩷 colima segment (when running)
```

---

## Troubleshooting

* **Boxes / garbled glyphs** — Nerd Font not installed *or* terminal not using
  it. Re-check step 1.
* **Prompt looks plain after install** — your shell rc was not reloaded; open a
  new terminal.
* **Azure segment missing** — sign in with `az login`. The segment is hidden
  when no subscription is active.
* **`gh:` segment missing** — run `gh auth login` (and ensure one of the
  accounts is the active one: `gh auth switch`).
* **`openspec:` / `spec-kit:` segment missing** — you're not inside (or under)
  a project containing the relevant marker (`openspec/`, `.openspec/`,
  `.specify/`, or `specs/*/{spec,plan,tasks}.md`).
* **`colima:` segment missing** — install Colima and run `colima start`.
* **`tokens<30d:` segment missing** — `ai-engineering-fluency` is not on
  `$PATH`; this is an internal Microsoft tool. Either install it or repurpose
  `scripts/tokens.sh`.
* **Execution-time segment missing** — by design; it only appears for commands
  taking longer than 500 ms.
