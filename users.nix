{ ... } : {
  users.users.simcra = {
    isNormalUser = true;
    description = "simcra";
    extraGroups = [ 
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [];
  };
}