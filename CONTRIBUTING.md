# Contributing to nix-core

Please read the following guidelines to make the contribution process smooth and effective for everyone involved.

## Branches

### **Main Branches:**
   - **`master`**: This is the production-ready branch. Only stable and tested code should be merged here.
   - **`develop`**: This is the integration branch for features. All new features should be merged here before they are considered stable enough for the `master` branch.

### **Feature Branches:**
   - **`feature/<feature-name>`**: Create these branches from the `develop` branch. These branches are used to develop new features. Once the feature is complete and tested, it should be merged back into `develop`.

### **Documentation Branches:**
   - **`docs/<topic-name>`**: Create these branches from the `master` branch (for direct documentation updates) or `develop` branch (if documentation changes are tied to upcoming features). These branches are exclusively for contributions to the documentation (`docs/` directory).
   - **`gh-deploy`**: **Do not touch this branch.** It is automatically managed and used by `mkdocs` to deploy the documentation to GitHub Pages.

### **Hotfix Branches:**
   - **`hotfix/<hotfix-name>`**: Create these branches from the `master` branch. These branches are used for urgent fixes that need to go directly into production. Once a hotfix is complete, it should be merged back into both `master` and `develop`.

## Getting Started

1. Fork the repository.

Click on the `Fork` button in the top right corner on the repository page. Then, click on the `Fork Repository` button.

2. Clone your forked repository to your local machine.

```sh
git clone https://github.com/<your-username>/nix-core.git
cd nix-core
```

3. Create a new branch for your feature or bug fix.

```sh
git checkout develop
git pull origin develop
git checkout -b feature/<feature-name>
```

> [!NOTE]
> Use `docs/<topic-name>` for documentation contributions

4. Make your changes and commit them to your branch.

```sh
git add .
git commit -m "feature/<feature-name>: A brief description of your feature"
```

5. Push your branch to your forked repository.

```sh
git push origin feature/<feature-name>
```

6. Create a pull request (PR) from your feature branch to the `develop` branch.

- Select the `Pull Request` tab in the top on the repository page.
- Click on the `New Pull Request` button.
- From the two dropdowns, select the branch to merge into (`sid115:develop`) and the branch to pull from (`<your-username>:feature/<feature-name>`).
- Click on the `New Pull Request` button.
- Please provide a title and description for the pull request.
- Click on the `Create Pull Request` button.

7. Wait for the pull request to be merged.

Please keep in touch with me in the conversation tab of your pull request.

## Hotfixes

If you need to submit a hotfix, follow these steps:

1. Create a new branch from the `master` branch.

```sh
git checkout master
git pull origin master
git checkout -b hotfix/<hotfix-name>
```

2. Make your changes and commit them to your branch.

```sh
git add .
git commit -m "hotfix/<hotfix-name>: A brief description of the hotfix"
```

3. Push your branch to your forked repository.

```sh
git push origin hotfix/<hotfix-name>
```

4. Create a pull request (PR) from your hotfix branch to both the `master` and `develop` branches.

## Documentation contributions

Documentation page using [mkdocs](https://www.mkdocs.org/) hosted on [GitHub pages](https://sid115.github.io/nix-core/).

### Prerequisites

* **direnv**: Use [`direnv`](https://direnv.net/) to automate and streamline dependency management. It should be available on most distros.
* **Nix Package Manager**: Install the [Nix package manager](https://nixos.org/download/).

    Add the following to `~/.config/nix/nix.conf` (or `/etc/nix/nix.conf` for system-wide):
    ```ini
    experimental-features = nix-command flakes
    ```

### Setup

1.  Clone this repository:
    ```bash
    git clone https://github.com/sid115/nix-core.git
    ```
2.  Navigate into the cloned directory:
    ```bash
    cd nix-core
    ```
3.  Allow `direnv` to install dependencies from `shell.nix`:
    ```bash
    direnv allow
    ```

### Conventions

Learn about the file layout, configuration settings and markdown syntax [here](https://www.mkdocs.org/user-guide/writing-your-docs/).

Please use the following file naming scheme:

* use lower case only
* use dashes (-) instead of spaces, no underscores (_)
* use the page names as file names in `mkdocs.yml`, e.g.:

```yaml
- Foo:
  - Bar: 'foo/bar.md'
```

### Deployment

To test your changes, run `mkdocs serve` in the root directory. This will generate the site locally which can be reached by visiting `http://127.0.0.1:8000`.

To open a Pull Request, please follow the Getting Stated guide. For documentation contributions, you can fork from `master` for direct documentation updates or `develop` if documentation changes are tied to upcoming features. Please name your forks using this convention: `docs/<topic-name>`

Your changes will automatically be deployed once they are merged with the `master` branch.

## Code style

Please use the following style guidelines when writing your Nix code.

### Best Practices

#### Value priorities

Use `mkDefault` to allow values to be easily overwritten by users. When specific values are crucial for configuration, use `mkOverride` or `mkForce` to enforce them. If users attempt to override these enforced values, ensure that clear [error messages](https://nix.dev/manual/nix/2.24/language/builtins.html#builtins-throw) are provided to inform them of the issue.

#### Function Aliasing

Define aliases for library functions within a *let-in* block instead of using `with lib;` at the top of each file. For example:

```nix
{ lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  foo = mkDefault "bar";
}
```

### Formatting

Use [`nixfmt`](https://github.com/NixOS/nixfmt) to format your code.

#### Installation

```nix
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.nixfmt-rfc-style ];
}
```

#### Usage

```bash
nixfmt path/to/your/file.nix
```

### Naming conventions

Use [`camelCase`](https://en.wikipedia.org/wiki/Letter_case#Camel_case) or [`kebab-case`](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) to name your variables and functions.

## Communication

Feel free to open an issue if you encounter a bug or have a feature request.

Thank you for contributing!   
-Sid
