{ tags, geo, ... }:
{
  index = 15;
  tags = with tags; [
    low-disk
    qemu
    server
  ];
  hostname = "2001:bc8:1640:4f1f::1";
  city = geo.cities."NL Amsterdam";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqKLXq0jtyL0D0akD7vFtTiXmAAboTFFHAR6Qx9j0IluyxXzxJ5iSqnF8nhBcT8QptlY+gRGIRhkuRhNO0/3VTsL/8jorw7srUq7TBvw6WKsXJnR0ANRj2bxK+r+jfM55UXC47oKah+rzi7b2QuRCqOjR5BKhxqtCtb+PbgtccxsGlopobc99bxBgK9NyIuMBIJ7+CIdev7nYOI7ASalGz3QtPL9bfwVz9xwYSfbhXILr/bNLAGlQf39mQVveCSieYhZoIozqHrm4trgpSDz8IHBM6OQ66y0lOI45PVOTa0l8c+XP6QX8m4jVBz4xBP//LD/IZym7hAbF8GxCCNiNQv8+BpYaeTBOQlsuhJL00IFPXbRcFjw2P98fmY7ko3OcELOsz6Wy04ZvboPN2EtCUdkJUoSVYYsE7F5zQtiVYiFSI1OovTqMgr24m2boIkqNLkD8Q6Nu7/QNteGlT93dyIuMBNHo3nBzrQGePm9YJLZtmVdgALu6hQv2rLs1WsYR0UNxrgQ5il+ifNS9loXYKhtAO2G0zIRad08DIV9Yp4GLBsfg/TFyyeVBfQjgbHhKzym7W6ex8yiSrebKvVvQaF2DznCs30bUNQa6pO2Gp+WQ7wo5qDYrFwv5Qxh9a8IeLZeBsQkDHhWELweUTNU/zDffYFdCP1awGlX4h4EWtZw==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWSI6klO/G6LkGeZqAd8iR7f43S5bTo4RrwTnP8RRyY";
  };
  zerotier = "6dc4324888";
  public = {
    IPv6 = "2001:bc8:1640:4f1f::1";
  };
  dn42 = {
    region = 41;
  };
}
