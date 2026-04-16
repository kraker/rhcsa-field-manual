# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**The RHCSA Field Manual** — a Quarto book covering Red Hat Enterprise Linux 10 and the EX200 (RHCSA) exam. Licensed CC BY-NC-SA 4.0.

## Build Commands

```sh
quarto preview    # Live preview with hot reload
quarto render     # Build to _book/
```

Quarto >= 1.9 is required. The engine is `knitr`. There is no Python/uv dependency.

## Book Structure

Configuration lives in `_quarto.yml`. Chapters are `.qmd` (Quarto Markdown) files.

```
_quarto.yml          # Book config: chapter order, themes, metadata
index.qmd            # Landing page
preface.qmd          # Front matter
acknowledge.qmd      # Front matter
prereqs/             # Prerequisite chapters (CLI basics, lab setup)
chapters/            # Main content (01-17), mapped to RHCSA exam objectives
practice/            # Practice exams
appendices/          # Command reference, glossary, supplementary material
references.bib       # BibTeX bibliography
```

Chapters are numbered `01-17` in filenames. Most are stubs — only uncommented chapters in `_quarto.yml` are active in the build. Comment/uncomment chapter lines to include or exclude them.

## Content Conventions

- Each chapter maps to an RHCSA exam objective area
- Executable bash code blocks use `{bash}` (knitr-evaluated); static examples use plain `bash`
- The command reference appendix is the most substantial file (~1100 lines)
- A companion study repo at `../rhcsa/` contains source synthesis modules that chapters are based on
