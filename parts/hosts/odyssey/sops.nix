{ config, ... }:

{
  sops = {
    defaultSopsFile = ../../secrets/secrets.env;
    defaultSopsFormat = "dotenv";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      home_wifi_1 = {
        sopsFile = ../../secrets/home_wifi_1.env;
        restartUnits = [ "NetworkManager.service" ];
      };
      home_wifi_2 = {
        sopsFile = ../../secrets/home_wifi_2.env;
        restartUnits = [ "NetworkManager.service" ];
      };
      user_creds = {
        neededForUsers = true;
      };
      ssh_private_key = {
        sopsFile = ../../secrets/ssh_private_key.enc;
        format = "binary";
        owner = "armand";
        path = "${config.users.users.armand.home}/.ssh/id_ed25519";
        mode = "0600";
      };
      anthropic_key = {
        sopsFile = ../../secrets/anthropic_key.enc;
        format = "binary";
        owner = "armand";
        mode = "0600";
        path = "${config.users.users.armand.home}/.secrets/anthropic_key";
      };
      cargo_registry_token = {
        sopsFile = ../../secrets/cargo_registry_token.enc;
        format = "binary";
        owner = "armand";
        mode = "0600";
        path = "${config.users.users.armand.home}/.cargo/credentials.toml";
      };
      speech_key = { };
      speech_region = { };
      azure_openai_key = { };
      azure_openai_endpoint = { };
    };
  };
}
