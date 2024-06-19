{
  isNormalUser = true;
  description = "Simcra";
  extraGroups = [ "networkmanager" "wheel" ];
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMzU9dSeAoavZcjmhqiWi4nHbh4pcL4eyTeUOMBVUN9"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILOvefL7G4P4GUsW+zU6E3h5A2k0fqiE5XB/fICRAVik"
  ];
}
