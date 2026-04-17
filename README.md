# The RHCSA Field Manual

A hands-on guide to Red Hat Enterprise Linux 10 and the EX200 exam.

By [Alex Kraker](https://github.com/kraker). Built with [Quarto](https://quarto.org/).

## Repository Layout

- `book/` — Quarto book sources
- `vagrant/` — single-VM RHEL 10 dev environment

## Building the Book

Prerequisites: [Quarto](https://quarto.org/docs/get-started/) >= 1.9, R, and the `knitr` R package. (The `vagrant/` setup provisions all three on a RHEL 10 VM.)

```sh
cd book
quarto preview    # live preview
quarto render     # build to book/_book/
```

## Dev VM

```sh
cd vagrant
cp .rhel-credentials.template .rhel-credentials   # add your Red Hat dev creds
./up.sh
```

The VM uses the [`kraker/rhel-10`](https://app.vagrantup.com/kraker/boxes/rhel-10) box published by the sibling project at `~/git-repos/vagrant-rhel-boxes/`. See [CLAUDE.md](CLAUDE.md) for more detail on the layout and dev workflow.

## License

Copyright © 2026 Alex Kraker

This work is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/). See [LICENSE](LICENSE) for the full text.
