# Dev container deep dive

This is the long version of the [README](../README.md): why I set up one shared dev container the way I did, what it actually buys me for isolation, and the handful of options I looked at and skipped. If you just want to install it and go, the README has everything you need. This file is for when you want to change something and would rather understand the knob before you turn it.

## Index

- [What I was actually after](#what-i-was-actually-after)
- [Why one shared box instead of per-project containers](#why-one-shared-box-instead-of-per-project-containers)
- [Isolation on macOS, honestly](#isolation-on-macos-honestly)
- [Security knobs](#security-knobs)
- [Resource limits](#resource-limits)
- [Networking](#networking)
- [How opening a project works](#how-opening-a-project-works)
- [Why there is no "Reopen in Container?" prompt](#why-there-is-no-reopen-in-container-prompt)
- [Global settings worth setting once](#global-settings-worth-setting-once)
- [Future options I left on the table](#future-options-i-left-on-the-table)
- [References](#references)

****

## What I was actually after

I wanted a development machine that is not my laptop. Somewhere extensions, language servers, build tools, and CLI coding agents run without touching my host filesystem, my SSH keys, or my AWS credentials unless I explicitly hand them over. VS Code's Dev Containers feature does exactly this: when you connect to a container, the editor's server half and everything it spawns run inside the container. The integrated terminal is a shell in the box, so an agent I launch there is boxed in too.

The one thing I did not want was a `.devcontainer` committed into every repo I touch. My machine hosts a lot of projects, some mine and some other people's, and littering all of them with the same config (and remembering to gitignore it) is exactly the kind of chore that made me want isolation in the first place.

## Why one shared box instead of per-project containers

The default Dev Containers model is one container per project folder, defined by a `.devcontainer` in that folder. That is great for reproducibility and for teams, and it is the wrong shape for "my personal dev machine for everything."

So I inverted it. One config lives at the root of my workspace directory. VS Code's default behavior when you open that directory is to bind-mount the whole thing into the container, which means every project underneath is already present. I open the workspace once to build the box, then open individual projects from inside it. One environment, shared across everything, no per-project files anywhere.

The cost is real and worth stating plainly. All my projects share one toolchain now. If two projects need conflicting versions of something, they will fight. When that happens I can still drop a normal `.devcontainer` into the one project that needs it and let it run its own container, separate from the shared box. For everything else, one box is simpler than twenty.

## Isolation on macOS, honestly

Containers on macOS do not run on the Mac kernel. Docker Desktop, OrbStack, and colima all run a Linux VM, and your containers live inside that VM. This matters for how you think about isolation.

The strong boundary is the VM. Code in the container is a couple of layers away from macOS: it is a process in a container, inside a Linux VM, on your Mac. A container escape would still land inside the VM, not on your host. That is a meaningful gap that a plain process on your laptop does not have.

The per-container settings (dropped capabilities, CPU and memory caps, a non-root user) partition things inside that VM. They limit what a compromised or runaway process can do to the VM and to your other containers. They are worth setting, but the VM is the wall doing most of the work.

One practical consequence: the VM has its own overall CPU and memory ceiling, set in your runtime's settings. That ceiling caps the blast radius of anything you run, no matter what a single container's limits say. Set it somewhere sane and you have a backstop.

## Security knobs

The reassuring part of going with a managed `devcontainer.json` is that you give up no control. `runArgs` passes arguments straight to `docker run`, so anything you would do by hand on the command line, you can declare in the config. On top of that there are typed properties for the common cases. Between them you reach every knob a hand-rolled `docker run` would.

What is in the config, commented and ready to turn on:

- **Non-root user.** `remoteUser` and `containerUser` are set to `vscode`, the non-root user the base image ships. `remoteUser` is who the editor, terminal, tasks, and agents run as. Running as root inside a container is a common and avoidable footgun.
- **Dropped capabilities and no new privileges.** `--cap-drop=ALL` and `--security-opt no-new-privileges` in `runArgs` strip the container down to the capabilities it actually needs and stop processes from gaining more through setuid binaries.
- **Read-only root filesystem.** `--read-only` plus a writable `--tmpfs` for `/tmp` means a process cannot scribble on the image at runtime. Worth it once you know which paths your tools need to write.
- **Explicit mounts only.** The container sees your workspace tree and nothing else. Your `~/.aws`, your `~/.ssh`, your host home directory are not mounted unless you add them. That absence is the isolation. Mount credentials in deliberately when a project needs them, and know you have done it.

One honest gotcha. The Dev Containers tooling leans toward debugging-friendly defaults and may add `SYS_PTRACE` and `seccomp=unconfined` so native debuggers work out of the box. Those loosen isolation. If you want the container locked down, set your own capabilities and `securityOpt` and do not rely on the defaults being tight. This is the one place a managed container can be looser than one you built yourself, and it is a two-line fix.

The biggest hole to avoid is sharing the host Docker socket into the container, which the `docker-outside-of-docker` Feature does. It is convenient when you need to build or run images from inside the box, but it hands the container control of your host's Docker daemon, which is close to handing over the host. I left it commented out. Turn it on only when you truly need it, and know what it costs.

## Resource limits

`runArgs` carries the standard docker limits:

```
"runArgs": [
  "--name", "devbox",
  "--cpus", "4",
  "--memory", "8g",
  "--memory-swap", "8g",
  "--pids-limit", "512"
]
```

On macOS these are enforced by cgroups inside the Linux VM, so they cap the container within whatever the VM itself is allowed. There is also a `hostRequirements` property (`cpus`, `memory`, `storage`) in the spec, but that declares minimums rather than enforcing ceilings, so for actual limits use `runArgs`.

## Networking

By default the container gets a normal bridge network with outbound access. To tighten it, `runArgs` again:

- `--network none` cuts the container off from the network entirely.
- `--network <name>` attaches it to a custom docker network you control, which is where you would put egress rules.
- `--dns <ip>` pins resolvers.

For exposing app ports back to the host, `forwardPorts` and `appPort` in the config handle it. `--network host` is a Linux-only thing and does nothing useful on a Mac, since the "host" from the container's view is the Linux VM, not macOS.

## How opening a project works

The mechanic that makes the shared box practical is that a VS Code remote connection is to the container, not to a folder. The connection and the workspace root are separate. Once you are connected, changing the open folder swaps the editor root and keeps the same connection, the same way opening a different directory over SSH does not log you out of the server.

So the flow is:

1. Open the workspace directory, **Reopen in Container**. This builds or starts `devbox` and connects.
2. From that connected window, **Open Folder** to a project under `/workspaces`. Same container, new root.
3. That project now lives in **Open Recent** as `[Dev Container]`. Next time, click it and you reconnect straight into the project, restarting the box if it had stopped.

The `workon` shell function in the README is the terminal version of step 3. It leans on the box having a fixed name (`devbox`) and on the container's URI being derivable from that name.

Keeping the box warm is one setting: `"shutdownAction": "none"`. The default stops the container when you close the VS Code window, which would mean a cold start every time. With `none` the box keeps running, so Open Recent and `workon` reconnect instantly.

## Why there is no "Reopen in Container?" prompt

With a committed local `.devcontainer`, opening the folder pops a prompt offering to reopen in the container, because VS Code sees the config sitting in the folder. This setup has no config in the project folders, so that prompt never appears. Open Recent and `workon` are what replace it.

I looked at getting the prompt back without committing anything, and there is a genuine tension. The prompt fires on config-in-the-folder, and config-in-the-folder is also what makes VS Code build a separate container keyed to that folder. You cannot have both the automatic prompt and a single shared box through that mechanism, because the mechanism is per-folder by definition. Given the choice, I kept the shared box.

If you ever decide the prompt matters more than the single box, here are the ways to get it:

- **Repository configuration paths.** The `dev.containers.repositoryConfigurationPaths` user setting points VS Code at a local folder of configs, matched to a repo by its git remote. You get the prompt with nothing committed, but it is keyed per remote and does nothing for local-only folders.
- **A symlinked, globally gitignored `.devcontainer`.** Keep one real config in your home, symlink `.devcontainer` into each project, and add `.devcontainer/` to your global gitignore (`git config --global core.excludesfile`). VS Code sees a config in the folder and prompts, and nothing is ever committed. The catch is that this is back to per-folder containers, not the shared box.
- **A pinned Docker Compose service.** Point multiple folders' configs at one long-lived compose service so they attach to the same running container. This can share a single box across folders, but you have to pin the compose project name or each folder spins its own stack, and it is fiddlier than it sounds. I would not reach for it first.

## Global settings worth setting once

Two VS Code user settings do more for consistency than anything in the container config, because they apply to every container you ever open:

- **`dev.containers.defaultExtensions`** installs a list of extensions into every container automatically. This is the right home for your always-on toolkit, better than listing extensions in each config. It even applies when you attach to a container you started yourself.
- **`dotfiles.repository`** clones a dotfiles repo into the container when it is created and runs your install script. Your shell config, aliases, and any agent bootstrap ride along into every box. Pair it with `dotfiles.targetPath` and `dotfiles.installCommand`.

One caveat on the Features side: `dev.containers.defaultFeatures` only applies when VS Code builds a container. If you attach to an already-running container, Features are not injected, because Features are a build-time concept. For the shared box that is fine, since it gets built from the config. If you lean on attaching to hand-started containers, bake tools into the Dockerfile instead.

## Future options I left on the table

- **Named configs.** A `.devcontainer/` folder can hold several configs in subfolders, like `.devcontainer/full/devcontainer.json` and `.devcontainer/minimal/devcontainer.json`, and VS Code lets you pick which to open. Handy if you ever want a heavy box and a light box off the same setup. Not needed for one shared environment, but the folder layout already supports it.
- **Per-project override.** Nothing stops you from dropping a real `.devcontainer` into a single project that needs a different or conflicting toolchain. It runs its own container, separate from the shared box, and the two coexist fine.
- **Codespaces.** The same `devcontainer.json` spec runs in GitHub Codespaces. If I ever want this environment in the cloud rather than local, the config largely carries over.

## References

- [Create a dev container](https://code.visualstudio.com/docs/devcontainers/create-dev-container)
- [Developing inside a container (overview)](https://code.visualstudio.com/docs/devcontainers/containers)
- [Attach to a running container](https://code.visualstudio.com/docs/devcontainers/attach-container)
- [Advanced container configuration](https://code.visualstudio.com/docs/devcontainers/containers-advanced)
- [devcontainer.json reference](https://containers.dev/implementors/json_reference/)
- [Dev Container Features](https://containers.dev/features)
- [Dotfiles repositories in VS Code](https://code.visualstudio.com/docs/devcontainers/containers#_personalizing-with-dotfile-repositories)
