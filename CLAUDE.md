# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**The RHCSA Field Manual** — a Quarto book covering Red Hat Enterprise Linux 10 and the EX200 (RHCSA) exam. Licensed CC BY-NC-SA 4.0.

## Repository Layout

```
book/        # Quarto book sources (chapters, _quarto.yml, references.bib, ...)
vagrant/     # Single-VM RHEL 10 dev environment (Vagrantfile + provisioner)
LICENSE
README.md
```

The Quarto book lives entirely under `book/`. The `vagrant/` directory provisions the RHEL 10 VM that serves as the runtime for the book's executable shell snippets.

## Build Commands

All Quarto commands run from inside `book/`:

```sh
cd book
quarto preview    # Live preview with hot reload
quarto render     # Build to book/_book/
```

Quarto >= 1.9 is required. The engine is `knitr` (so R + the `knitr` package must be installed wherever you render). There is no Python/uv dependency.

## Book Structure

Configuration lives in `book/_quarto.yml`. Chapters are `.qmd` (Quarto Markdown) files.

```
book/
├── _quarto.yml          # Book config: chapter order, themes, metadata
├── index.qmd            # Landing page
├── preface.qmd          # Front matter
├── acknowledge.qmd      # Front matter
├── prereqs/             # Prerequisite chapters (CLI basics, lab setup)
├── chapters/            # Main content (01-17), mapped to RHCSA exam objectives
├── practice/            # Practice exams
├── appendices/          # Command reference, glossary, supplementary material
└── references.bib       # BibTeX bibliography
```

Chapters are numbered `01-17` in filenames. Most are stubs — only uncommented chapters in `_quarto.yml` are active in the build. Comment/uncomment chapter lines to include or exclude them.

## Dev VM (vagrant/)

A single RHEL 10 VM (`rhcsa-dev`, 192.168.56.20) provisioned with Quarto, R, and knitr. Intended workflow is VS Code Remote SSH into the VM, with the project root synced to `/home/vagrant/rhcsa-field-manual`.

```sh
cd vagrant
cp .rhel-credentials.template .rhel-credentials   # add Red Hat dev creds
./up.sh
vagrant ssh-config >> ~/.ssh/config               # for VS Code Remote SSH
```

The VM uses [`kraker/rhel-10`](https://app.vagrantup.com/kraker/boxes/rhel-10) — the box published by the sibling project at `~/git-repos/vagrant-rhel-boxes/`. This is deliberate dogfooding: the book's RHEL 10 dev VM is built from the same blueprint we publish to the community. The box ships unregistered; the `vagrant-registration` plugin attaches it to the user's RHSM subscription at first boot using the credentials in `.rhel-credentials`.

`provision.sh` enables CRB via `subscription-manager`, installs EPEL, R + git + Quarto, and installs `knitr` via dnf (`R-knitr`) with a CRAN fallback. As of 2026-04 EPEL 10 doesn't ship `R-knitr`, so the CRAN fallback is the working path; the dnf attempt activates if/when EPEL adds it.

## Content Conventions

- Each chapter maps to an RHCSA exam objective area
- Executable bash code blocks use `{bash}` (knitr-evaluated); static examples use plain `bash`
- The command reference appendix is the most substantial file (~1100 lines)
- A companion study repo at `../rhcsa/` contains source synthesis modules that chapters are based on
