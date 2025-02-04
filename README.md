![Build workflow](https://github.com/IONOS-WordPress/ionos-wordpress/actions/workflows/release.yaml/badge.svg)

This monorepo contains all the code for the ionos-wordpress project.

It enables developers to maintain all of our IONOS WordPress hosting related plugin at a single place.

## Philosophy

- Self contained

  Repository contains all the code, configuration and tool needed to maintain our IONOS WordPress Hosting specific plugins.

  Event the tooling and it's configuration is integrated in the repository. Tools are either declared as dependencies or using a containerized approach.

  Once you've checked out the repository everything is in it's place and you can immediately start working. There is just a mininmal set of [Requirements](#requirements) to be installed on your machine.

- Cross platform

  The repository is designed to work on major operating systems. It uses a containerized approach to run native tools and services.

- Mono structure

  The repository is organized as [Monorepo](https://en.wikipedia.org/wiki/Monorepo) to maintain various sub projects in a single place.

  This allows to share code and configuration between the sub projects and to maintain a single version for all of them.

- Local first

  The repository is designed to work [locally first](https://dev.to/alexanderop/what-is-local-first-web-development-3mnd). It uses a containerized approach to run native tools and services.

  This allows to work on the code and configuration locally and to test it in a local environment before pushing it to a remote repository.

# Development

The repository contains all the code, configuration and tools needed to maintain our IONOS WordPress Hosting specific artifacts.

The repository provides

- automatic [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) provisioning and configuration for WordPress autocompletion and PHP debugging

- `vscode` configuration and settings so that all required plugins and settings are automatically installed and configured

## Directory layout

- The top level directory contains configuration files

  - `pnpm-workspace.yaml` is used to configure where [pnpm](https://pnpm.io/) will find sub packages like WordPress plugins

  - `.npmrc` ist used to configure [pnpm](https://pnpm.io/) behaviour like the automatically provided NodeJS version and the package cache location.

  - `pnpm-lock.yaml` is the lock file generated by [pnpm](https://pnpm.io/).

  - `.wp-env.json` and `.wp-env-afterStart.sh` are configuration files for the [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/)

  - `.editorconfig` is used to configure the code style for the repository. _This file is used by various editors and IDEs to enforce the code style._

  - see [Customization](#customization) for details to `.env`, `.secrets` and `.env.local` files.

- Directory `packages/` contains all the sub projects sorted by category.

  - `packages/wp-plugin/` contains WordPress plugin sub projects

  - `packages/npm/` contains npm package sub projects

  - `packages/docker/` contains docker image sub projects

  - `packages/docs/` contains documentation sub projects

  Not all of the package categories are required to be present in the repository. You can remove or create category directories as needed (i.e. if the first docker sub project is required, create `packages/docker` and place the docker sub project inside).

> [!IMPORTANT]
> Why are the sub projects sorted into category directories ?
> Different types of artifacts have different requirements and require a different build/release workflow. By sorting the sub projects into category directories we can provide a unified build/release workflow for all sub projects of the same category automatically.

## Requirements

- [`vscode`](https://code.visualstudio.com/)

  Actually vscode is _not really_ required but it makes working with the repository much easier.

  _You can use [DevContainer](https://containers.dev/) even on other IDEs like PHPStorm but this repository takes only care for `vscode` for now._

  - Install the [`ms-vscode-remote.remote-containers` extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) to use the [DevContainer](https://containers.dev/) feature.

- a modern `docker` version (including `docker compose` sub command)

All other tools are located in a [DevContainer](https://containers.dev/) providing a unified development experience across all platforms.

> [!TIP]
> The [DevContainer](https://containers.dev/) is automatically started when you open the repository in vscode. Our [DevContainer](https://containers.dev/) provides tools like `pnpm`, `bash` and all other native tools required for maintaing the software artifacts located in this repository.

## Toolchain

Software detailed here will be automatically provided in the project specfic [DevContainer](https://containers.dev/).

- [pnpm](https://pnpm.io/) is used as package manager in favor of npm because of it's excellent monorepo support plus

  - it's much faster than npm and yarn

  - it caches once downloaded packages and reuses them across projects

  - it uses hard links to save disk space

  - it computes sub project dependencies for free

  - manages NodeJS provisioning automatically

- `bash`, `jq` and friends

  We need shell and some shell commands to implement workflows and scripts.

## Setup

- checkout the repository

  - switch to branch `develop` if you want to work on the latest development version : `git switch develop`

- open the repository in `vscode`

`vscode` will now install the extensions and automatically start the [DevContainer](https://containers.dev/) providing the whole toolchain.

- call `pnpm install` to install dependencies

## Commands

All commands are declared in the `scripts` section of the root `package.json` file.

Each command is a script that can be executed by running `pnpm run <command>` or shorter using `pnpm <command>`.

To get a list of commands you can run `pnpm run`.

The commands are organized as shell scripts located in `./scripts/` directory.

The command scripts in `./scripts/` contain even some advanced example usages.

> [!TIP]
> Some commands require other commands to be executed before. Due to the limits of package scripts we can't declare dependencies between scripts. So we have to rely on the developer to execute the commands in the correct order. _Dependency aware tools like `make` would solve this issue butare skipped for now to keep the toolchain simple to understand._

- `pnpm start` : starts the [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) environment

  Command will generate

  - the [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) configuration file `.wp-env.json` registering all WordPress plugins and themes declared in the repository

  - `vscode` related `settings.json` to enable PHP autocompletion and hyperlinking support

  - `vscode` related `launch.json` to support PHP debugging

  > [!TIP]
  > You need to call the start command using `pnpm start --xdebug` to let [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) start with xdebug enabled. You can persist this setting by adding `WP_ENV_START_OPTS='--xdebug'` to your individual `.env.local` file (see `.env.local.example`).

  You can override (even parts of) the generated default configuration by providing a `.wp-env.override.json` file in the root directory of the repository (see https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/#wp-env-override-json).

  You can execute `pnpm start` repeatedly. Change the configuration files and restart the environment to see the changes taking effect.

- `pnpm stop` : stops the [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) environment.

- `pnpm build` : builds all sub projects of the monorepo.

  Builds all WorPress plugins, themes etc.

- `pnpm watch` : builds all sub projects of the monorepo and rebuild it again whenever a sub project file changes.

- `pnpm changeset` : provides access to the [changeset](https://www.npmjs.com/package/@changesets/cli) tool.

  The command is a wrapper around the `changeset` tool to provide a unified interface to [manage changesets](https://github.com/changesets/changesets/blob/main/docs/intro-to-using-changesets.md).

  [Changesets](https://github.com/changesets/changesets/blob/main/docs/intro-to-using-changesets.md) are a way to version and release multiple software artifacts in a monorepo and providing a changelog for end users.

  See [Changeset](#changeset) for more details of the changeset workflow.

- `pnpm wp-env` : provides an entrypoint to access the [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) environment.

  The command is a wrapper around the `wp-env` tool.

  Example usage : `pnpm wp-env logs --no-watch` to show the logs of the [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) environment.

### Advanced commands

- `pnpm clean` : will clean up generated resources by the build process.

  The command is configured to be interactive (see `.env`) so you can selectively decide which resources to clean up.

- `pnpm distclean` : will clean up **ANY** generated Monorepo resources (like `./node_modules` and so on).

  This command will revert the project repository to a clean state like you've just checked out the repository. The only thing it keeps are

  - files that are under version control
  - `.code-workspace` file
  - `.wp-env.override.json` file
  - `.env.local` file
  - `.secrets` file

  The command is configured to be interactive (see `.env`) so you can selectively decide which resources to clean up.

  **After deletion of all dependencies using `pnpm distclean` you need to execute `pnpm install` manually before calling any of the other commands.**

  > [!TIP]
  > You can add more files to be automatically preserved by adding them to the `GIT_CLEAN_OPTS` variable in the `.env` or `.env.local` file.

- `pnpm update-dependencies` : will allow you to update the dependencies of the monorepo.

  The command will show you all dependencies that can be updated and let you decide which to update.

  Example usage :
  `pnpm update-dependencies` updates all dependencies, adhering to ranges specified in package.json,
  `pnpm update-dependencies --latest` updates all dependencies to their latest versions

### Configuration

The project supports various ways of configuring project settings.

#### Environment

- `.env` : contains the global configuration for the project.

  This file is under version control and contains the default configuration for the project.

  This file should not contain sensitive data like credentials or security tokens.

  `.env` will sourced by bash which means you can even declare and export bash functions here.

- `.env.local` : an optional environment configuration file for individual developer settings.

  This file can be used to override settings from `.env` and/or to provide individual settings.

  `.env.local` will sourced by bash which means you can even declare and export bash functions here.

  This file should not contain sensitive data like credentials or security tokens.

  **It is not under version control.**

  You can use `.env.local.example` as a template.

- `.secrets` an optional file which can be used to provide secret settings like security tokens and credentials.

  **It is not under version control.**

  You can use `.env.local.example` as a template.

  `.env.local` will sourced by bash which means you can even declare and export bash functions here.

  > [!CAUTION]
  > environment variables are **NOT** reflected by the docker containers created by the [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) environment. You need to provide the secrets and environment to the [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) environment using a `.wp-env.overriode.json` file.

#### wp-env

- `.wp-env.json` : will be **generated on every start** of the [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) environment.

  **The file is not under version control.**

  It acts as the default configuration for the [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) environment containing all WordPress plugins and themes.

- `.wp-env.override.json` : is an optional file which can be used to override settings for the [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) environment.

  Use this file to override the default configuration which individual settings.

  **The file is not under version control.**

#### `vscode`

- `./vscode/launch.json` contains PHP debug configuration for `vscode`

  It will be generated **on every start** of the [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) environment.

  **The file is not under version control.**

- `./vscode/settings.json` contain settings for `vscode` and vscode extensions.

  It will be generated **on every start** of the [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) environment.

  **The file is not under version control.**

- `./vscode/extensions.json` contains recommended extensions for `vscode` used by this project.

- `*.code-workspace` files are optional configuration files for `vscode`.

  A [workspace](https://code.visualstudio.com/docs/editor/workspaces) file may contain settings, launch configuration and recommended plugins to install for the workspace. When used it will extend/override the `vscode` settings provided by default for the Monorepo.

  Create a [workspace file](https://code.visualstudio.com/docs/editor/workspaces) to configure vscode to your individual needs.

  **Workspace files will not version controlled.**

## Workflows

### Changeset

Changesets are a way to version and release multiple software artifacts in a monorepo and providing a changelog for end users **automatically**.

Changesets will not harm your ways to work with GIT. It's more or less independent from GIT workflow.

#### Create a feature

Whenever you start working on a new feature (or breaking change or something worth to be noted in the changelog) you should create a new changeset entry :

```bash
pnpm changeset add
```

This command will create a new changeset markdown file in `./changeset/` directory.

This file contains the human readable description about the changeset in markdown format. this description will be taken over in the changelog when you create a new release using `changeset`

In the `frontmatter` section of this file will be noted which sub projects the the monorepo are affected by this changeset. And furthermore, which type of change this changeset represents (major, minor, patch).

The changets file will be taken under version control as long as it takes to create a new release. After the release is created the changeset file will be merged into the affected changelog files and removed from the changeset directory.

#### Create a release manually

Using `changeset` to create a release

- frees you from maintaining a changelogs manually

- automates the semantic version for you based on the changeset files

```bash
  # so you've developed some features, bugfixes and so on.
  # for every "change" that should be reflected into the changelog and/or the new version number you've created a  changeset file using `pnpm changeset add`
  ...
  # now you want to create a new release :
  # - update semver versions
  # - generate changelogs using changeset for all sub projects
  pnpm changeset version

  # review changes made by changeset

  # all changeset markdown are now merged into the referenced monorepo packages and will be removed from the changeset directory
  # version numbers are increased according to the proposed changes in the changeset files

  # commit updated files
  git add .
  git commit -am "chore(release) : $(jq -r '.version | values' package.json) [skip release]"

  # tag release
  pnpm changeset tag

  # push changes and tags
  git push && git push --tags

  # merge develop into main
  git push origin develop:main
```

### Git

The project uses git hooks at various stages.

For example the `pre-commit` hook will automatically lint-fix the code before committing and will abort the commit process if lint-fix was not successful.

Git hooks are located in the `./.githooks` directory.

The hooks are automatically installed by the `pnpm install` command.

> [!TIP]
> If you want to disable git hooks for some reason you can disable the git hooks by adding `--no-verify` to the git command.
> Example : `git commit --no-verify`

#### Workflows

## CI/CD

The [DevContainer](https://containers.dev/) of this repository will also be used by the CI/CD pipeline to ensure exactly the same development environment for both local development, CI/CD and release.
