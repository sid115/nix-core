# Instaloader

Instaloader is a tool to download pictures (or videos) along with their captions and other metadata from Instagram. This module wraps instaloader in a systemd service for periodic downloads.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/instaloader).

## References

- [GitHub](https://github.com/instaloader/instaloader)
- [docs](https://instaloader.github.io/)

## Troubleshooting

### Password authentication does not work

This is a known issue in version 4.14.x. You should provide a session file containing a browser cookie:

1. Install [instaloader](https://search.nixos.org/packages?channel=unstable&show=instaloader&from=0&size=50&sort=relevance&type=packages&query=instaloader) (the package is sufficient) on your client machine.
1. Log into Instagram in any Firefox based browser. Here, LibreWolf is used.
1. Load cookies: `instaloader --load-cookies LibreWolf`
1. Copy your session file to your server running the nix-core instaloader module:
    - From: `~/.config/instaloader/session-<your_ig_user>`
    - To: `/var/lib/instaloader/.config/session-<your_ig_user>`

See [this issue](https://github.com/instaloader/instaloader/issues/2585) for more information.
