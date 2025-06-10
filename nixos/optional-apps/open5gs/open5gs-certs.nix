{
  pkgs,
  LT,
  ...
}:
{
  systemd.services.open5gs-certs = {
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ openssl ];
    script = ''
      mkdir -p demoCA
      if [ ! -f "demoCA/serial" ]; then
        echo 01 > demoCA/serial
      fi
      touch demoCA/index.txt

      # CA self certificate
      if [ ! -f "ca.crt" ]; then
        openssl req -new -x509 -days 3650 -newkey rsa:2048 -nodes -keyout ca.key -out ca.crt \
          -subj /CN=ca.epc.mnc010.mcc315.3gppnetwork.org/C=KO/ST=Seoul/O=NeoPlane
      fi

      for i in amf ausf bsf hss mme nrf scp sepp1 sepp2 sepp3 nssf pcf pcrf smf udm udr
      do
        if [ ! -f "$i.crt" ]; then
          openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:2048 \
              -out $i.key
          openssl req -new -key $i.key -out $i.csr \
              -subj /CN=$i.epc.mnc010.mcc315.3gppnetwork.org/C=KO/ST=Seoul/O=NeoPlane
          openssl ca -batch -notext -days 3650 \
              -keyfile ca.key -cert ca.crt \
              -in $i.csr -out $i.crt -outdir .
        fi
      done
    '';
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      User = "open5gs";
      Group = "open5gs";
      StateDirectory = "open5gs-certs";
      WorkingDirectory = "/var/lib/open5gs-certs";
    };
  };
}
