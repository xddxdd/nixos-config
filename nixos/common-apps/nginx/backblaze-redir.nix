_: {
  lantian.nginxVhosts."backblaze.lantian.pub" = {
    locations."/".return = "307 https://backblaze-b2.lantian.workers.dev$request_uri";
    enableCommonLocationOptions = false;
    sslCertificate = "lets-encrypt-lantian.pub";
  };
}
