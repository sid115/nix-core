# Derivations

At its core, Nix is about building software. Nix doesn't install software directly from a global repository; instead, it builds *derivations*. A derivation is a description of how to build a package. It's a pure function `inputs -> output`, meaning given the same inputs, it will always produce the same output.

## Your first Derivation

Let's build a simple "hello world" program.

First, create a C source file `hello.c`:

```c
// hello.c
#include <stdio.h>

int main() {
    printf("Hello from C!\n");
    return 0;
}
```

Then, create a `default.nix` file that imports Nixpkgs and then calls the package definition below.

```nix
# default.nix
{ pkgs ? import <nixpkgs> {} }: # Fetch Nixpkgs
# Nixpkgs is a collection of Nix expressions.
# We need some functions (like `callPackage`) that are defined there.
# Nixpkgs will be covered later in this guide.

pkgs.callPackage ./my-hello.nix { }
# `callPackage` is a helper function for Package derivations.
# It automatically resolves all needed input arguments the derivation needs from Nixpkgs.
```

> Hint: `default.nix` will get replaced by Nix Flakes later. You do not need to know what Flakes are at the moment, but keep this relationship in mind.

Now, define how to build the C source file a Nix file, `my-hello`.nix:

```nix
# my-hello.nix
{ stdenv }: # Inputs

stdenv.mkDerivation {
  pname = "my-hello"; # Package name
  version = "0.1.0";  # Package version

  src = ./.; # The source code for the package is in the current directory

  # Phases of the build process
  # mkDerivation defines standard phases like unpackPhase, patchPhase, configurePhase, buildPhase, installPhase
  # For simple builds, we just need build and install.

  buildPhase = ''
    # Compile command
    ${stdenv.cc}/bin/gcc hello.c -o hello
  '';

  installPhase = ''
    # Install the compiled program into the output directory ($out)
    mkdir -p $out/bin
    cp hello $out/bin/hello
  '';
}
```

Let's break this down:

- `stdenv`: This derivation is a function that expects `stdenv` (standard environment, providing common build tools and phases) as an argument. It will be automatically resolved from Nixpkgs.
- `stdenv.mkDerivation`: This is the core function to create a derivation. It sets up a standard build environment and provides a set of common build phases.
- `pname`, `version`: Standard metadata for the package.
- `src = ./.;`: This tells Nix to copy all files from the current directory into the build sandbox.
- `buildPhase`: This is where you put commands to compile your software. Here, `gcc` is used from the standard C compiler provided by `stdenv.cc` to compile `hello.c` into an executable `hello`.
- `installPhase`: This is where you put commands to install the build artifacts into the `$out` directory, which is the final location in the Nix store. Here, a `bin` directory is created to move the `hello` executable into.

## Building and Running a Derivation

To build this derivation, use `nix build`:

```bash
nix build --file default.nix
```

You'll see output from the build process. If successful, Nix creates a `result` symlink in your current directory. This `result` symlink points to the package in the Nix store.

Now, run your compiled program:

```bash
./result/bin/hello
```
```
Hello from C!
```
