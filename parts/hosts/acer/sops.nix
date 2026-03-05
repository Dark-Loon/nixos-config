{ ... }:

{
  # Configure sops
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
      speech_key = { };
      speech_region = { };
      azure_openai_key = { };
      azure_openai_endpoint = { };
    };
  };
}
