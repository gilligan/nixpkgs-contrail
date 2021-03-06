{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let

  cfg = config.contrail.control;
  confFile = import (./configuration + "/R${contrailPkgs.contrailVersion}/control.nix") { inherit pkgs cfg; };

in {
  options = {
    contrail.control = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      configFile = mkOption {
        type = types.path;
        description = "contrail control configuration file";
        default = confFile;
      };
      autoStart = mkOption {
        type = types.bool;
        default = true;
      };
      logLevel = mkOption {
        type = types.enum [ "SYS_DEBUG" "SYS_INFO" "SYS_WARN" "SYS_ERROR" ];
        default = "SYS_INFO";
      };
      debug = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Make debug symbols available for debugging with gdb
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    users.users.root.packages = mkIf cfg.debug [ contrailPkgs.control.debug ];

    systemd.services.contrail-control = mkMerge [
      {
        after = [ "network.target" "contrail-api.service" "contrail-collector.service" ];
        preStart = "mkdir -p /var/log/contrail/";
        serviceConfig.ExecStart = "${contrailPkgs.control}/bin/contrail-control --conf_file ${cfg.configFile}";
        postStart = ''
          ${contrailPkgs.configUtils}/bin/provision_control.py --api_server_ip 127.0.0.1 \
            --api_server_port 8082 --oper add --host_name $HOSTNAME --host_ip 192.168.1.1 --router_asn 64512
        '';
      }
      (mkIf cfg.autoStart { wantedBy = [ "multi-user.target" ]; })
    ];

  };

}
