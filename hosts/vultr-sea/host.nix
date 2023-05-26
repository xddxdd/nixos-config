{
  tags,
  geo,
  ...
} @ args: {
  index = 12;
  tags = with tags; [low-ram public-facing server];
  city = geo.cities."US Seattle";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKMO3tpAqks8VEPC98dzyuAW6OEevjb5nL6oH0guwLgfK6Yhjf2mqdqpodKJXXgYLxbHIXI/ntCiUeUhqCHKF3GWyj3v83AqQTTIAXxVwbGMm4OMdyL/qZugI+H6dxp088uaU5lS5rsb6qTEhcdWrVyqedwYZonrYjdaShGaAtItoEdemHMSWIIbWcINCvo7zemTDQPrOrPkzy7BJSYvBtlqEzjWafBGF1OGxAunV6o1ix8Gl6gm18qLhXRMjc642luUGGc6ODsOif6VFn8QQiUtcj/4nIhZeEJj6XuobBcEsMnPC/YDprp4wAlmjvhhXJCGPl7WqFAdQZTpFQfcnZ0safgbNOEui4HQqIZNu5iU7dRWNjboAGk/BDxgSaGwZbgiPpx9J0+241enHlhJqjcjQ5a0jVL2W1CwprOnZGcX0ahfQt8oZcn4Y/lpJmt6VCv12js33MX9N6eQCCPLmF5hu6BTs1fnqRJoAujTnHXF+mZXuh9gMJ/wlQ7T3Y6hIsF3GWquuM1pRD3JqVjrHv38oqKRwCmLfc3XIsBSpabrrt+nf25qQ9KEOrJX4oLZ4881F3wX6NNsNcuHqXZQDDB1KO08w+51e/dbWMxx1goTsBK9xWuv/Eq0XiPUpxsRis+nxXGEkPpRPGAOsgGYcKL2oYB6+DIhQ/q1LzY6uhuQ==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDLulOXVexsbZft2dg5dt5uY/6ZFLHLJFfu9TS397Msu";
  };
  public = {
    IPv4 = "144.202.83.81";
    IPv6 = "2001:19f0:8001:5b2:5400:04ff:fe57:2a89";
  };
  dn42 = {
    IPv4 = "172.22.76.121";
    region = 44;
  };
}
