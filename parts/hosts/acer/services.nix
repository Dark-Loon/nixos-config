{ ... }:

{
  # services.nextcloud = {
  #  enable = true;
  #  hostName = "nextcloud.tld";
  #  database.createLocally = true;
  #  config = {
  #    dbtype = "pgsql";
  #    adminpassFile = "/path/to/admin-pass-file";
  #  };
  # };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.KbdInteractiveAuthentication = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
  };
}
