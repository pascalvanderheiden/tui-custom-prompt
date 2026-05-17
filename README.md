# TUI Custom Prompt

A reproducible setup for a **rainbow-flag Oh-My-Posh terminal prompt**. Use
this repo to spin up an identical terminal on a new laptop (macOS / Linux /
Windows), or to share the look-and-feel with others.

The prompt renders as a single powerline line. Each segment only appears when
it has something to show — **if a tool below is not installed, or the marker
it looks for is not in the current folder, the segment is silently hidden**.

## What's in this repo

| File                                              | Purpose                                  |
| ------------------------------------------------- | ---------------------------------------- |
| `rainbowflag.omp.json`                            | The Oh-My-Posh prompt theme              |
| `scripts/*.sh`                                    | Helpers for the contextual segments      |
| `install.sh`                                      | One-shot installer for macOS / Linux     |
| `install.ps1`                                     | One-shot installer for Windows           |

### Prompt segments

| Band       | Segments (left → right)                       | Source                                       |
| ---------- | --------------------------------------------- | -------------------------------------------- |
| 🔴 Red     | OS · `opt+spc to record`                      | static hint                                  |
| 🟠 Orange  | Azure (e.g. `microsoft.com`)                  | `az account show` — domain part of user      |
| 🟡 Amber   | Folder                                        | current path                                 |
| 🟡 Yellow  ` <gh-user>`                                  | active `gh auth status` account              |
| 🟢 Green   | `🪙 717.0K` (tokens, last 30 days)            | `ai-engineering-fluency usage`               |
| 🔷 Azure   | Git (branch + file counts)                    | git status                                   |
| 🔵 Blue    | `squad` · execution time                      | `.squad` marker + last-cmd duration > 500 ms |
| 🟣 Violet  | openspec · spec-kit                           | openspec / spec-kit project markers          |
| 🩷 Pink    | `🐳 1/2` (colima)                             | running / total Colima VMs                   |
| 🟪 Purple  | root cue                                      | shows only when running as root              |

Values only (no `key:` labels). Edit any helper in `scripts/` to change what
a segment shows.

---

## Prerequisites

The prompt itself only needs **Oh-My-Posh** and a **Nerd Font**. Everything
else is optional — install only the tools you care about; the corresponding
segment stays hidden when the tool (or its project marker) is missing.

### Required

| Tool         | macOS (Homebrew)                                | Linux                                                | Windows (winget)                          |
| ------------ | ----------------------------------------------- | ---------------------------------------------------- | ----------------------------------------- |
| Oh-My-Posh   | `brew install jandedobbeleer/oh-my-posh/oh-my-posh` | `curl -s https://ohmyposh.dev/install.sh \| bash -s` | `winget install JanDeDobbeleer.OhMyPosh -s winget` |
| Nerd Font    | `brew install --cask font-meslo-lg-nerd-font`   | see [Nerd Font](#nerd-font) section                  | `winget install DEVCOM.JetBrainsMonoNerdFont` |
| Git          | preinstalled / `brew install git`               | preinstalled / `apt install git`                     | `winget install Git.Git`                  |

After installing the font, point your terminal at it (`MesloLGM NF` or any
Nerd Font you prefer):

* **VS Code** — `Cmd/Ctrl+Shift+P` → *Preferences: Open User Settings (JSON)*:
  ```json
  { "terminal.integrated.fontFamily": "MesloLGM NF" }
  ```
* **Windows Terminal** (`settings.json`):
  ```json
  { "profiles": { "defaults": { "font": { "face": "MesloLGM NF" } } } }
  ```

### Optional — power the contextual segments

Each tool below powers a single segment. Install only what you need — missing
tools (or missing project markers) silently hide their segment.

| Segment             | Tool                                | macOS (Homebrew)                                                                                       | Windows                                                                                                |
| ------------------- | ----------------------------------- | ------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------ |
| 🟠 Azure            | **Azure CLI**                       | `brew install azure-cli`                                                                               | `winget install Microsoft.AzureCLI`                                                                    |
| 🟡 GitHub user      | **GitHub CLI** (`gh`)               | `brew install gh`                                                                                      | `winget install GitHub.cli`                                                                            |
| 🟢 Tokens (30 days) | **AI Engineering Fluency** *(internal)* | `npm i -g @microsoft/ai-engineering-fluency`                                                           | `npm i -g @microsoft/ai-engineering-fluency`                                                           |
| 🔵 Squad            | **Squad CLI**                       | `npm i -g @bradygaster/squad-cli`                                                                      | `npm i -g @bradygaster/squad-cli`                                                                      |
| 🟣 OpenSpec         | **OpenSpec CLI** + `jq`             | `brew install node jq` then `npm i -g @fission-codes/openspec`                                         | `winget install OpenJS.NodeJS jqlang.jq` then `npm i -g @fission-codes/openspec`                       |
| 🟣 Spec Kit         | **GitHub Spec Kit** (`specify`)     | `brew install uv` then `uv tool install specify-cli --from git+https://github.com/github/spec-kit.git` | `winget install astral-sh.uv` then `uv tool install specify-cli --from git+https://github.com/github/spec-kit.git` |

Notes:

* **Tokens** counts tokens used over the **last 30 days** via
  `ai-engineering-fluency usage`. The tool is internal to Microsoft; outside
  Microsoft this segment will simply stay hidden. Repurpose
  `scripts/tokens.sh` to show a different metric if you wish.
* **Squad** requires a `.squad` marker (file or folder) at or above the
  current directory — the segment only shows inside a "squad" project.
* **OpenSpec** segment requires an `openspec/` or `.openspec/` directory in
  the project (`jq` is used for nicer status output).
* **Spec Kit** segment requires a `.specify/` directory or `specs/*/spec.md`
  in the project.

### Colima (optional)

If you also want the 🩷 colima segment showing `<running>/<total>` VMs:

* **macOS**:
  ```bash
  brew install colima docker
  colima start
  ```
* **Linux**:
  ```bash
  curl -LO https://github.com/abiosoft/colima/releases/latest/download/colima-Linux-x86_64
  sudo install colima-Linux-x86_64 /usr/local/bin/colima
  colima start
  ```
* **Windows**: not supported — use Docker Desktop / WSL2 instead. The segment
  will stay hidden.

### Authenticate / activate

After install, sign in once so the relevant segments populate:

```bash
az login          # populates the 🟠 Azure segment
gh auth login     # populates the 🟡 gh segment
colima start      # populates the 🩷 colima segment
```

### Nerd Font

The prompt uses glyphs from a Nerd Font — without one you will see boxes.
[MesloLGM Nerd Font](https://www.nerdfonts.com/font-downloads) is recommended.

Linux manual install:
```bash
mkdir -p ~/.local/share/fonts
curl -fLo ~/.local/share/fonts/MesloLGM-Regular.ttf \
  https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M/Regular/MesloLGMNerdFont-Regular.ttf
fc-cache -f
```

---

## Install

Clone this repo, then run the installer for your platform.

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

The installers:

* install Oh-My-Posh if missing,
* install a MesloLGM Nerd Font (skippable),
* add a marked block to your shell rc / `$PROFILE` (safe to re-run; the block
  is updated in place, never duplicated),
* preview the prompt.

After it finishes, open a new terminal (or run `exec $SHELL` / `. $PROFILE`).

### Manual install

If you prefer to wire it up yourself, replace `$REPO` with the absolute path
where you cloned this repo.

**zsh** — append to `~/.zshrc`:
```bash
eval "$(oh-my-posh init zsh --config $REPO/rainbowflag.omp.json)"
```

**bash** — append to `~/.bashrc`:
```bash
eval "$(oh-my-posh init bash --config $REPO/rainbowflag.omp.json)"
```

**PowerShell** — `code $PROFILE` and add:
```powershell
oh-my-posh init pwsh --config "$env:USERPROFILE\GitHub\tui-custom-prompt\rainbowflag.omp.json" | Invoke-Expression
```

**fish** — `~/.config/fish/config.fish`:
```fish
oh-my-posh init fish --config $REPO/rainbowflag.omp.json | source
```

### Updating Oh-My-Posh

```bash
brew upgrade oh-my-posh                 # macOS
winget upgrade JanDeDobbeleer.OhMyPosh  # Windows
```

---

## Sanity check

Run any helper script directly to see what the corresponding segment will
print. Empty output means the segment will hide — exactly what you want when
the tool isn't relevant.

```bash
./scripts/gh-user.sh
./scripts/openspec.sh
./scripts/speckit.sh
./scripts/tokens.sh
./scripts/colima.sh
./scripts/squad.sh
```

---

## Troubleshooting

* **Boxes / garbled glyphs** — Nerd Font not installed *or* terminal not using
  it. Re-check the [Nerd Font](#nerd-font) step.
* **Prompt looks plain after install** — your shell rc was not reloaded; open
  a new terminal.
* **Azure segment missing** — sign in with `az login`.
* **🟡 gh segment missing** — run `gh auth login` (and `gh auth switch` if you
  have multiple accounts).
* **openspec / spec-kit segment missing** — you're not inside a project
  containing the relevant marker (`openspec/`, `.openspec/`, `.specify/`, or
  `specs/*/{spec,plan,tasks}.md`).
* **colima segment missing** — install Colima and run `colima start`.
* **tokens segment missing** — `ai-engineering-fluency` is not on `$PATH`
  (it's an internal Microsoft tool). Either install it or repurpose
  `scripts/tokens.sh`.
* **squad segment missing** — there's no `.squad` marker at or above the
  current directory.
* **Execution-time segment missing** — by design; it only appears for commands
  taking longer than 500 ms.
