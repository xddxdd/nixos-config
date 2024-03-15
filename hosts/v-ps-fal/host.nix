{ tags, geo, ... }@args:
{
  index = 6;
  tags = with tags; [
    dn42
    public-facing
    qemu
    server
  ];
  city = geo.cities."DE Falkenstein";
  hostname = "185.254.74.105";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFrjUTDuR4qNJLjbQdSBUeZnzI7kTj8aqBchxL1IqpBz52KPhb12+5FptZj4OiRnNHIOXE05CMJnZzAeMKCy/Xdey4Vx7arM6uFYDN1dL7v0w5sLz6JzZLR1OmGjm4rCGhvqZmEtCI1fYIYm+XN7CQellZCluaZZ39MMFy87mSTa9Da2iZTRV20wp+ScGKAO4DsywosGUtS4l99TSwXYUidDYlPT6eddffMzjfSNgVLVWcafprfSm/kSnMfYOUgt11GilFfip1Yv2ZlVCm/3Ry0tjc4J398gpZY2iJBMP0pG+XBhYv3UHmsiFixpzOALQ4xj752+Zx6sJ63nbj2+hcQRxIJQToYsPUuxLeK0PKsp15xnXhkeS+nCudOxtk6bcXYSWre+be65dF5+rHHxQbGo0sYvtd6v0fvJx+HND3/bCDduUsu2/R4qcm1hNRYhF7zUwq3P3tslPW9zK1hsw/7yUXJU2CRqdpDxrTDV8ac+l9dRm+JkmzlcEMHNVgNzV2Nkj4HoMXuksyxOmKXkV5FMd/idaOvjcHzyFlwsTzctl6qxmOkvf7VB+KR6nM4bWDoEcd9y/U0cV7xgaziZCN+RC9yeh2H1one1/aMAX+kl63ET7CLbzN6xgCgWCGFeu2rcc4M7WloHUsSIB3OxnzLyucEo1jApfrFU1vpJT+2w==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINpY+uauSxVKTs2LtBBbdwX5LYZcXdfpesbB7O5y34y0";
  };
  public = {
    IPv4 = "185.254.74.105";
    IPv6 = "2a03:d9c0:2000::72";
  };
  dn42 = {
    IPv4 = "172.22.76.119";
    region = 41;
  };
}
