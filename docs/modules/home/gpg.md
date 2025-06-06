# GPG

This module sets some defaults for gpg, mainly to let your gpg-agent handle ssh keys.

View the [*nix-core* Home Manager module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/home/gpg).

## SSH Setup

### GPG

You need a GPG authentication subkey. Follow the steps below to create one. If you already have a GPG key, skip to step 2.

#### 1. Generate a new GPG key

```sh
gpg --full-gen-key --allow-freeform-uid
```

1. Select `1` as the type of key.
1. Select `4096` for the keysize.
1. Select `0` to choose 'Never expire'.
1. Enter your name, email address, and a comment (if you want). Select `0` for 'Okay'.

#### 2. Create an authentication subkey

```sh
gpg --expert --edit-key KEY-ID
```

1. At the new `gpg>` prompt, enter: `addkey`
1. When prompted, enter your passphrase.
1. When asked for the type of key you want, select: (8) RSA (set your own capabilities).
1. Enter `S` to toggle the ‘Sign’ action off.
1. Enter `E` to toggle the ‘Encrypt’ action off.
1. Enter `A` to toggle the ‘Authenticate’ action on. The output should now include Current allowed actions: Authenticate, with nothing else on that line.
1. Enter `Q` to continue.
1. When asked for a keysize, choose `4096`.
1. Select `0` to choose 'Never expire'.
1. Once the key is created, enter `quit` to leave the gpg prompt, and `y` at the prompt to save changes.

### HM config

```nix
imports = [
  inputs.core.homeModules.gpg
];

services.gpg-agent.sshKeys = [ "YOUR_AUTH_SUBKEY_KEYGRIP" ];
```

> Get the keygrip of your authentication subkey with: `gpg -K --with-keygrip`
