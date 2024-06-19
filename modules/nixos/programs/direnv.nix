{ ... }:
{
  # Configure direnv - This must be installed into global space, when put in home-manager it doesn't work
  programs.direnv = {
    enable = true;
  };
}
