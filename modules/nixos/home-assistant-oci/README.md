# Home Assistant OCI 

Open source home automation that puts local control and privacy first. Powered by a worldwide community of tinkerers and DIY enthusiasts

- [homepage](https://www.home-assistant.io/)
- [docs](https://www.home-assistant.io/docs/)

## Setup

Import `inputs.core.nixosModule.home-assistant-oci`, set `services.home-assistant-oci.enable = true` in your config and access the webUI with `http://<ip-of-your-device>:8123` locally. There should be an option for creating an account.

## Auto-discovery

In case you cannot get your home devices discovered in your network, you might need to open TCP ports on your server that are required by your services via `networking.firewall.allowedTCPPorts` and add the services via `Settings >> Devices & Services >> Integrations >> Add Integration` manually in home-assistant.

## TODO

- [ ] let docker image update automatically
