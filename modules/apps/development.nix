{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.apps.development;
in
{
  options.modules.apps.development = {
    enable = mkEnableOption "development applications";
    
    android = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Android development tools";
    };
    
    web = mkOption {
      type = types.bool;
      default = true;
      description = "Enable web development tools";
    };
  };
  
  config = mkIf cfg.enable {
    home.packages = with pkgs; 
      (optionals cfg.android [
        # Android development packages
      ]) ++
      (optionals cfg.web [
        # Web development packages
        nodePackages.pnpm
        nodePackages.yarn
      ]);
  };
}