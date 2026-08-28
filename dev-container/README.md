# One dev container for every project

This is a single dev container I open in VS Code and do all my work inside, mostly for isolation. Extensions, terminals, and any CLI coding agents run in the box, not on my Mac. The twist is that I did not want a `.devcontainer` committed into every project. There is just one config, and it lives at the root of my workspace directory (`~/Workspace` by default). I open that directory once, let VS Code build the container, and from then on every project I keep under it opens inside the same warm box. Third-party projects I do not want touched still open normally on the host, because nothing here is automatic.

If you want the reasoning behind all of this, the security posture, the trade-offs, and the options I did not take, that is all in the [deep dive](./docs/deep-dive.md).

## Index

- [Before you start](#before-you-start)
- [Install](#install)
- [How I use it day to day](#how-i-use-it-day-to-day)
- [Configuring](#configuring)
- [The files](#the-files)
- [Deep dive](#deep-dive)

****

## Before you start

Two things need to be in place:

- VS Code with the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension.
- A local container runtime. Docker Desktop works, and so do OrbStack, colima, Podman, and Rancher Desktop. The config does not care which one you run.

## Install

One line. It creates your workspace directory (default `~/Workspace`) and drops the `.devcontainer/` into it, pulling the files straight from this repo without cloning anything. If there is already a `.devcontainer` there, it gets backed up first.

```
curl -fsSL https://raw.githubusercontent.com/dsapab/wizardly-snippets/main/dev-container/install.sh | sh
```

Want the container somewhere other than `~/Workspace`? Set `WORKSPACE_DIR`.

```
curl -fsSL https://raw.githubusercontent.com/dsapab/wizardly-snippets/main/dev-container/install.sh | WORKSPACE_DIR=~/code sh
```

And fair enough, piping someone's script into `sh` is exactly the kind of thing this repo is wary of. If you would rather look before you leap, save it, read it, and run it once you are happy.

```
curl -fsSL https://raw.githubusercontent.com/dsapab/wizardly-snippets/main/dev-container/install.sh -o /tmp/devbox-install.sh
less /tmp/devbox-install.sh
sh /tmp/devbox-install.sh && rm /tmp/devbox-install.sh
```

## How I use it day to day

First time, I open the workspace directory itself and build the box.

1. Open `~/Workspace` in VS Code.
2. Run **Dev Containers: Reopen in Container** from the Command Palette. VS Code builds the image once. This is slow the first time and quick after that.

That container mounts the whole `~/Workspace` tree, so every project under it is already reachable from inside. To work on one project, I open just that folder from within the connected window (**File, Open Folder**, then pick the project under `/workspaces`). It swaps the editor root to that project and stays in the same container, so I get a normal single-project window that happens to be isolated.

After I have opened a project once, it shows up in **File, Open Recent** tagged `[Dev Container]`. Clicking it reconnects to the box and opens straight into that project, restarting the container if it had stopped. That is the everyday path, no rebuild, no manual attach.

Adding a new project is nothing special. Drop it under `~/Workspace` and it is immediately openable inside the box.

If you want a terminal shortcut instead of clicking Open Recent, a small shell function does it. The box has a fixed name (`devbox`), so you can start it if needed and open a project by its container path:

```
workon () {
  docker start devbox >/dev/null 2>&1 || true
  local hex=$(printf '{"containerName":"/devbox"}' | xxd -p | tr -d '\n')
  code --folder-uri "vscode-remote://attached-container+${hex}/workspaces/$1"
}
# usage:  workon my-project
```

The exact URI encoding can shift between VS Code versions, so the safe move is to open a project once through Open Recent and copy the real URI it uses.

## Configuring

- **`WORKSPACE_DIR`** picks where the container lives and which tree it mounts. Default `~/Workspace`. Set it on the install command.
- **Tools and languages** go in [`.devcontainer/devcontainer.json`](./.devcontainer/devcontainer.json) under `features`, or baked into [`.devcontainer/Dockerfile`](./.devcontainer/Dockerfile) for anything a Feature does not cover. Both files are commented so you can see what is a real setting and what is just a default written out.
- **Extensions you want everywhere** are better set once as a global VS Code user setting, `dev.containers.defaultExtensions`, rather than listed per config. Same idea for `dotfiles.repository`, which clones your dotfiles into the box on creation. More on both in the deep dive.

## The files

- `install.sh` creates the workspace directory and fetches `.devcontainer/` into it. POSIX sh, backs up an existing config, no clone.
- `.devcontainer/devcontainer.json` is the container definition: the Features, the mount, the fixed name, and a security block that is commented out and ready for you to turn on.
- `.devcontainer/Dockerfile` is the base image, kept thin on purpose. It is where you bake tools that Features do not provide.
- `docs/deep-dive.md` is the long version: why I built it this way and every knob I skipped.

## Deep dive

Everything else lives in [docs/deep-dive.md](./docs/deep-dive.md), including the security model on macOS, the resource and network controls, why there is no automatic "Reopen in Container?" prompt, and the alternatives worth knowing about if this shape ever stops fitting.
