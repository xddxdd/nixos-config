{ pkgs, lib, ... }:
let
  kamailioInstances = [
    "icscf"
    "pcscf"
    "scscf"
    "smsc"
  ];

  kamailioPkg = pkgs.kamailio.overrideAttrs (old: {
    modules = [
      "cdp_avp"
      "cdp"
      "db_mysql"
      "dialplan"
      "enum"
      "http_async_client"
      "http_client"
      "ims_auth"
      "ims_charging"
      "ims_dialog"
      "ims_diameter_server"
      "ims_icscf"
      "ims_ipsec_pcscf"
      "ims_isc"
      "ims_ocs"
      "ims_qos"
      "ims_registrar_pcscf"
      "ims_registrar_scscf"
      "ims_usrloc_pcscf"
      "ims_usrloc_scscf"
      "jansson"
      "json"
      "nghttp2"
      "outbound"
      "presence_conference"
      "presence_dialoginfo"
      "presence_mwi"
      "presence_profile"
      "presence_reginfo"
      "presence_xml"
      "presence"
      "pua_bla"
      "pua_dialoginfo"
      "pua_reginfo"
      "pua_rpc"
      "pua_usrloc"
      "pua_xmpp"
      "pua"
      "sctp"
      "tls"
      "utils"
      "uuid"
      "xcap_client"
      "xcap_server"
      "xmlops"
      "xmlrpc"
    ];

    buildInputs = (old.buildInputs or [ ]) ++ [
      pkgs.jansson
      pkgs.libmnl
      pkgs.libuuid
      pkgs.lksctp-tools
    ];
  });
in
{
  imports = [ ../mysql.nix ];

  # https://github.com/herlesupreeth/Kamailio_IMS_Config
  environment.etc.kamailio_icscf.source = ./kamailio_icscf;
  environment.etc.kamailio_pcscf.source = ./kamailio_pcscf;
  environment.etc.kamailio_scscf.source = ./kamailio_scscf;
  environment.etc.kamailio_smsc.source = ./kamailio_smsc;
  environment.etc.kamailio-pkg.source = kamailioPkg;

  services.mysql = {
    ensureDatabases = builtins.map (i: "kamailio-${i}") kamailioInstances;
    ensureUsers = [
      {
        name = "kamailio";
        ensurePermissions = builtins.listToAttrs (
          builtins.map (i: lib.nameValuePair "\\`kamailio-${i}\\`.*" "ALL PRIVILEGES") kamailioInstances
        );
      }
    ];
  };

  systemd.services = builtins.listToAttrs (
    builtins.map (i: {
      name = "kamailio-${i}";
      value = {
        description = "Kamailio SIP Server - ${i}";
        requires = [ "network.target" ];
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        environment = {
          CFGFILE = "/etc/kamailio_${i}/kamailio_${i}.cfg";
          SHM_MEMORY = "64";
          PKG_MEMORY = "8";
        };

        serviceConfig = {
          Type = "forking";
          User = "kamailio";
          Group = "kamailio";

          PIDFile = "/run/kamailio_${i}/kamailio_${i}.pid";
          ExecStart = "${kamailioPkg}/bin/kamailio -P /run/kamailio_${i}/kamailio_${i}.pid -f $CFGFILE -m $SHM_MEMORY -M $PKG_MEMORY --atexit=no";

          Restart = "always";
          RestartSec = "5";

          RuntimeDirectory = "kamailio_${i}";
          RuntimeDirectoryMode = "0770";
          AmbientCapabilities = [ "CAP_CHOWN" ];
        };
      };
    }) kamailioInstances
  );
  systemd.tmpfiles.rules = [
    "d /var/run/kamailio 755 kamailio kamailio"
  ];

  users.users.kamailio = {
    group = "kamailio";
    isSystemUser = true;
  };
  users.groups.kamailio = { };
}
