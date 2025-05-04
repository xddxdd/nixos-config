{ config, lib, ... }:
let
  mcc_mnc = [
    [
      "001"
      "001"
    ]
    [
      "315"
      "010"
    ]
    [
      "999"
      "999"
    ]
  ];

  volteServices = {
    "pcscf" = 5060;
    "icscf" = 4060;
    "scscf" = 6060;
    "smsc" = 7090;
  };
in
{
  domains = builtins.map (
    mcc_mnc:
    let
      mcc = builtins.elemAt mcc_mnc 0;
      mnc = builtins.elemAt mcc_mnc 1;

      volteRecords = lib.mapAttrsToList (svc: port: [
        {
          recordType = "A";
          name = "${svc}.ims";
          address = "192.168.0.9";
        }
        {
          recordType = "SRV";
          name = "_sip._udp.${svc}.ims";
          priority = 0;
          weight = 0;
          inherit port;
          target = "${svc}.ims.mnc${mnc}.mcc${mcc}.3gppnetwork.org.";
        }
        {
          recordType = "SRV";
          name = "_sip._tcp.${svc}.ims";
          priority = 0;
          weight = 0;
          inherit port;
          target = "${svc}.ims.mnc${mnc}.mcc${mcc}.3gppnetwork.org.";
        }
      ]) volteServices;
    in
    {
      domain = "mnc${mnc}.mcc${mcc}.3gppnetwork.org";
      providers = [ "bind" ];
      records = lib.flatten [
        config.common.nameservers.Public
        volteRecords
        {
          recordType = "A";
          name = "hss.ims";
          address = "127.0.0.47";
        }
        {
          recordType = "A";
          name = "pcrf.epc";
          address = "127.0.0.9";
        }
        {
          recordType = "SRV";
          name = "_sip._udp";
          priority = 0;
          weight = 0;
          port = 5060;
          target = "icscf.ims.mnc${mnc}.mcc${mcc}.3gppnetwork.org.";
        }
        {
          recordType = "SRV";
          name = "_sip._tcp";
          priority = 0;
          weight = 0;
          port = 5060;
          target = "icscf.ims.mnc${mnc}.mcc${mcc}.3gppnetwork.org.";
        }
      ];
    }
  ) mcc_mnc;
}
