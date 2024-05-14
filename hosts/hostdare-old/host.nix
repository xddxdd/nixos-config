{ tags, geo, ... }:
{
  index = 13;
  tags = with tags; [
    qemu
    server
    x86_64-v1
  ];
  city = geo.cities."US Los Angeles";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCfK8gSS4EXf1yGprWEMYMbEuUkQ3ngITHgTfgbx98qONTm/loSMhNqN2VM1haCjCV8h4PUAd11mPjzzci08wQD/5aSbQnrx+ku8vkT8D+hNTzdxSGTTbvOIGsfTB26JPH0cFklJTz1hQSD9mOPl6IkdP9qKtlTmTf/NrER3ClEaKRfgjgrpkJ+IvlNLIO4Lgm47xoh3Jj8TUZd+qowcHjvilE+XY9tTIYypaRp1vA6D8sgNp9aIObpYO/XzuMGabaGHJO5bPWjIw/Fw+mDctNVtWLxczis/qTGYWMUUVbmMGpmvfZQ955xnXoY4hCgbOe2gTVHJuRboGE0qTNr7WxxPfEHJdIfsSs64OeBX2QwbAs1126PAQABKYorJGsjOo+sbymVxYa6gklJXZsr7fwCcOzWzcYQvqgplipFdrwzol/KyyhHASg6mVoTdzudbBYpqYwc/a/vQpLxeDw905fq6tp8OPYTHJvW2X5ad6ld8dK0IOjbYR9YD3ls0tRCYiD+cgwdY5OVecLRdeuKfX3MyWwH1ObBqA9Ge3NrGvxirqO6Dgd0rhdc6VepHEVKCIZ86ugcJXAu5Yyr7z9IEBT7W2uCeLnl9Fb6jwHh2sd67oYt+uO/UDL2yibZWuzFxCpfPxXAnULhtF4zjQXg6hhQinaisfnVFz7mccJY1sx/xw==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2BWqVqhSvJFLTomqBfntFfZBE6u5jFwwK167PNf+ia";
  };
  public = {
    IPv4 = "185.186.147.110";
    IPv6 = "2607:fcd0:100:b100::198a:b7f6";
  };
  dn42 = {
    IPv4 = "172.22.76.117";
    region = 44;
  };
}
