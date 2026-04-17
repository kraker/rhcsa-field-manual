# Persistent shell state across `{bash}` chunks

Research notes from 2026-04-17. Captures what we tried, what broke, and what
to try if we decide to revisit. Not currently implemented — the book uses
knitr's default stateless `{bash}` engine.

## Problem

By default, knitr spawns a fresh shell for each `{bash}` chunk. `cd`, exports,
shell functions, and `set -o` state don't persist across chunks:

````markdown
```{bash}
cd /etc
```

```{bash}
pwd   # prints the document directory, not /etc
```
````

This is fine for isolated one-liners but awkward for teaching where commands
naturally build on each other (e.g. `cd`, then `ls`, then `cat somefile`).

## Landscape

- **bash_kernel** (Jupyter) — last release Nov 2023, dormant.
- **calysto_bash** (Jupyter) — last release Oct 2017, dead.
- **xontrib-jupyter** — actively maintained, but xonsh ≠ bash; wrong shell
  for an RHCSA book.
- **knitractive** — purpose-built for this exact use case: runs each chunk
  inside a persistent tmux session via `tmuxr` + `rexpect`. The author
  (Jeroen Janssens) built it to publish *Data Science at the Command Line*
  online. Labeled "experimental"; last core commit 2021, docs-only update
  Apr 2024. GitHub-only, as are its two sibling packages.
- Quarto maintainers have explicitly said they will not add a native shell
  engine (quarto-dev discussion #4634). Use Jupyter or knitr.

## What we tried: knitractive

Install via renv:

```r
renv::install(c("jeroenjanssens/rexpect",
                "jeroenjanssens/tmuxr",
                "jeroenjanssens/knitractive",
                # declared deps in the three packages are incomplete;
                # these are needed transitively but not pulled in:
                "glue", "purrr", "stringr"))
```

Setup chunk at the top of a `.qmd` (after YAML):

````markdown
```{r setup, include=FALSE}
knitractive::start(name = "bash",
                   command = "bash",
                   prompt = rexpect::prompts$bash)
```

```{bash, include=FALSE}
PS1='$ '
```
````

Using `name = "bash"` overrides knitr's default `{bash}` engine, so existing
chunks need no syntax changes. The hidden chunk normalizes PS1 — the default
`rexpect::prompts$bash` regex (`^(.*(\$|#)|>)$`) matches RHEL's default
prompt, but an explicit PS1 makes tmux-pane output predictable in the
rendered book.

## Why we stopped

The tmux binary on RHEL 10 has a reproducible bug. Package is
`tmux-3.3a-13.20230918gitb202a2f.el10` (from baseos, also in EPEL 10) but
`tmux -V` reports `tmux next-3.4` — a pre-release snapshot. Any
`tmux capture-pane -p -t <target>` crashes the tmux server. `tmuxr` uses
this form on every interaction.

Minimal repro (no R, no knitractive):

```
$ tmux new-session -d -s t "sleep 60"
$ tmux capture-pane -p -t t
server exited unexpectedly
```

## Paths forward (if we revisit)

1. **Build tmux from source in `vagrant/provision.sh`.** ~15 lines:
   `libevent-devel`, `ncurses-devel`, fetch stable tmux tarball, configure/
   make/install. Keeps knitractive intact. Downside: three GitHub-only R
   packages + custom tmux build + a package labeled "experimental" =
   fragile stack.

2. **DIY custom knitr engine backed by `processx`.** ~40 lines of R:
   spawn a long-lived `bash` child with `processx::process$new()`, feed
   each chunk's code to stdin followed by a sentinel (`echo __END__$?`),
   read stdout until the sentinel. Register via `knitr::knit_engines$set()`.
   Pros: one dep (processx, already on CRAN), no tmux, total control.
   Cons: we own the edge cases (stderr interleaving, interactive prompts
   like `sudo`, timeouts). Loses knitractive's fancier features
   (Ctrl-C simulation, `top` screenshots) — probably fine for RHCSA.

3. **Wait for upstream.** If a future RHEL tmux ships stable 3.4+, the
   `capture-pane -p -t` bug should be gone and knitractive may just start
   working.

## Current approach

Stay with knitr's stateless `{bash}`. For multi-step examples, combine
commands into a single chunk:

````markdown
```{bash}
cd /etc
pwd
ls | head
```
````

Worse ergonomics than notebook-style cells, but zero infra to maintain
while we focus on writing the book.
