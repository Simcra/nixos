{
  isNormalUser = true;
  description = "Simcra";
  extraGroups = [
    "networkmanager"
    "wheel"
  ];
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILOvefL7G4P4GUsW+zU6E3h5A2k0fqiE5XB/fICRAVik"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMboS93ic/vd9Fn8Ebpz/IGcK9LahJmCzg+2p7tRXWKI simcra@monadrecon"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICJC93Hq9ShvSpZaEcK7yV8iAS+xoSdoGREEcpU5ldKl simcra@streambox"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMzU9dSeAoavZcjmhqiWi4nHbh4pcL4eyTeUOMBVUN9 simcra@voidhawk"
  ];
}
