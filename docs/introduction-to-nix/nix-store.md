# Nix Store

You've built a package, and it landed in the `/nix/store`. The Nix store is the heart of Nix's reproducibility, atomicity, and rollback capabilities.

## Unique Paths (Hashing)

Every piece of software, configuration, or data managed by Nix lives in the Nix store under a unique, cryptographically hashed path. For example, `nix build` might produce something like:

```
/nix/store/zx9qxw749wmla1fad93al7yw2mg1jvzf-my-hello-0.1.0
```

A Nix store path consists of its hash and a human readable name with a version, which are defined in the corresponding derivation. The hash ensures:

1.  **Immutability:** Entries in the Nix Store are read only. Once something is in the Nix store, it never changes. If you modify a source file or a build instruction, it creates a *new* derivation with a *new* hash, and thus a *new* path in the store. The old version remains untouched.
2.  **Reproducibility:** If two different systems build the exact same derivation, they will produce the exact same hash and thus the exact same path. This guarantees that "it works on my machine" translates to "it works on *any* Nix machine."
3.  **Collision Avoidance:** Because the path includes a hash of all its inputs (source code, build script, compiler, libraries, etc.), different versions or configurations of the same package can coexist peacefully in the store without conflicting.

You can inspect the contents of a store path directly:

```bash
ls -l /nix/store/zx9qxw749wmla1fad93al7yw2mg1jvzf-my-hello-0.1.0/bin
```

Replace the hash with the actual hash from your previous `nix build` command or `ls -l result`.

## Dependency Resolution

The Nix store is also a giant, explicit dependency graph.
When you define a derivation for `my-hello` that uses `stdenv` and `gcc`, Nix doesn't just build `my-hello`. It first ensures that `stdenv` and `gcc` (and their own dependencies, recursively) are also present in the Nix store.

Let's look at the dependencies of your `my-hello` derivation:

```bash
nix path-info --recursive ./result
```

This command will list all the Nix store paths that `my-hello` directly or indirectly depends on. You'll see things like `glibc`, `gcc`, and many other low-level system libraries. Each of these is itself a derivation built and stored in the Nix store under its own unique hash.

This means that conflicts are impossible because different versions of the same library (e.g., `libssl-1.0` and `libssl-3.0`) can coexist peacefully in `/nix/store` under their distinct hashes.
