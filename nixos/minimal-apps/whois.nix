_: {
  programs.whois = {
    enable = true;
    settings = [
      {
        pattern = "\\.dn42$";
        server = "172.22.76.108";
      }
      {
        pattern = "\\-DN42$";
        server = "172.22.76.108";
      }
      {
        pattern = "^[0-9]{4}$";
        server = "172.22.76.108";
      }
      {
        pattern = "^as424242[0-9]{4}$";
        server = "172.22.76.108";
      }
      {
        pattern = "^172\\.2[0-3]\\..*$";
        server = "172.22.76.108";
      }
      {
        pattern = "^fd.*$";
        server = "172.22.76.108";
      }
    ];
  };
}
