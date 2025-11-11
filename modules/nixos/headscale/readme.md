# NixOS Headscale Module

## Usage
Server
```nix
{
  imports = [ ./modules/headscale.nix ];

  # Your main domain
  networking.domain = "steffen.fail";

  # Enable Headscale
  services.headscale = {
    enable = true;
    # Results in the URL https://headscale.steffen.fail
    subdomain = "headscale";
  };
}
```

Client
```
services.tailscale.enable = true;
```

## Post-Installation

1.  **On the server**, create a user:
    ```bash
    sudo headscale users create <your_username>
    ```

2.  **On a client**, connect:
    ```bash
    tailscale login --login-server https://headscale.steffen.fail
    ```
    Then, run the displayed `headscale nodes register ...` command on the **server** to register the device.
