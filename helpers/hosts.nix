# Index 1-99: Servers
# Index 100-199: Clients
#
# IPv6Subnet must be at least /96

let
  roles = import ./roles.nix;
in
{
  "50kvm-old" = rec {
    index = 9;
    ptrPrefix = "hong-kong.china";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCw1fEo3i7HViqekWReTW+jF7Nlw86ZYjez9zYq960PcuF9X/MaUjXCoUNuAs7km9AGc3RexPcX7sdth5qA2V7JH/KewARI2qiBZVCeX8DnSl27iVSkEeHFnoDQeSgrOnmQwd6N1ELpcJatGzWLA6FagobJm90HlbKW1uSwbh1TprDPtyFVLhaoyjIuTd+K3obCGZQiBY9Hmuiq0pTUM+PXgC4hRy5gsWnuLupDRSHDkPpAfXAND6decx6Xpx7GGtGQRbZ5xw0ZOPrphuVowagjMq7eQXivrc3S6LdqErdqnbVGUzV7EqJluRqWuH/j3XMUnrXxryJ/JpR7tMssc4xacRI0zD8J5jRGDDTvV+2RNarYC9bfHLVpdWHkELI1M2iNOehiYCzqO0ay5cVqEf3ynRe1HZIRp6Z7nI6dot/TjiQMx5+DGz1YTBvWL7NieZ9RjIKRus9qFZXDgK/8ZWylsVvRjemMv2Nno7l5js+7c5R9pfMO6NZiH4o8AJEus5Wx+M+A4hxXZAU7dGgcJPlhKCKZuIoVJTQnuctKN/ff+AeXNoZTM7MPdbNlzZ5ogrTXuCO9vXCohRlxXNBwGUYR4hUXF2nC+RBGCpYSUVypmpexRlbNpec6E6q+Q9BMltrQ/bRbGoNN4oateowFjiYS5uBqBUm6iXONWLNwUAdLpQ==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC/8Bj5bOf+14ZrrvUdQNxBWjl0ZZ64D4wnUw9T5rK9N";
    };
    syncthing = "PSIRDZ7-CFOIASN-QPS7X74-SRZQ44B-NS6R36H-DCXC6OK-T6PTBDF-7R6C5QU";
    public = rec {
      IPv4 = "23.226.61.104";
    };
    dn42 = rec {
      IPv4 = "172.22.76.189";
      region = 52;
    };
    yggdrasil.IPv6 = "200:3fa5:78e8:f74f:d078:6477:246e:bd0f";
  };
  "linkin" = rec {
    index = 1;
    ptrPrefix = "hong-kong.china";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCkL37ZQV3RAmiM+TFOagMvmld8NRJcgQ37soAD13EcK9vJVA37vnzI/fKEYkP+oubBIQZBTnddLl8mSZlx0vC9alekpWFu2Y+HX7nm6qUef2O3pctZD0Br5AhNoye4k+Ly+FaVBddpUu9Z7H/yVlZarrA1XBQynyaIfcv5DOi5Jc6U5MVhs4qhBY8sElmYEV/Z103VbYpW4rZ+yw2sKmXFNAR5yL7jAiJQS+T3HWqEiicyT6ppLpy9nGkbbzHYQMxJqSdQ1TsRUK7TJepVEXGnuVCBOFKs74jXjzl3enABNmL2BiO9iiVo/rxWbLmV9k031sQMwCIsj/YYulDG3rFmbWiN5Wnm66X+201nDATJr0vzafojcLK2Pgxym1zVbKL6+bZOxES6WTqktFzj4eGa0ekoHKzgz0bXbSf3TNOHbt+WvXK+sgV8YVs9NUyA6X7JNCX1kooWoGS74nspdNZRa5ZAxTLmB62WwJefqdRotuE5sw1tzAjPXuyw8JOtrBZeYHDS26yJKlHV19EfWllbC1xFPXWcdJHCxgo2UiKC/ESP+xCJt/9zgsN8NboXvZp20lGVrel47c4MD63Ann6Wp/KV81xlV/URmPauJCDDDGXzhZBrc+5/is7EXY/3KqOvKfRJXcjjk8/kW2rmgul/fmdXfjaQ8wM3xUnwbFBc9Q==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDw/OsayZlH0vM33lenT7xU7YaCzZI/+buXBzI+zib8W";
    };
    syncthing = "QPG2K6W-7JVQ3E4-AN637A6-FLLIVOI-MGWNLHE-5XGPJYE-JWUHZQX-GLPFYQ4";
    public = rec {
      IPv4 = "103.172.81.11";
      IPv6 = "2001:470:19:10bd::1";
      IPv6Alt = "2001:470:fa1d::1";
      IPv6Subnet = "2001:470:fa1d:ffff::";
    };
    dn42 = rec {
      IPv4 = "172.22.76.186";
      region = 52;
    };
    yggdrasil.IPv6 = "202:afa9:dd3c:34eb:22a5:851a:11b9:356";
  };
  "hostdare" = rec {
    index = 3;
    ptrPrefix = "los-angeles.united-states";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCfK8gSS4EXf1yGprWEMYMbEuUkQ3ngITHgTfgbx98qONTm/loSMhNqN2VM1haCjCV8h4PUAd11mPjzzci08wQD/5aSbQnrx+ku8vkT8D+hNTzdxSGTTbvOIGsfTB26JPH0cFklJTz1hQSD9mOPl6IkdP9qKtlTmTf/NrER3ClEaKRfgjgrpkJ+IvlNLIO4Lgm47xoh3Jj8TUZd+qowcHjvilE+XY9tTIYypaRp1vA6D8sgNp9aIObpYO/XzuMGabaGHJO5bPWjIw/Fw+mDctNVtWLxczis/qTGYWMUUVbmMGpmvfZQ955xnXoY4hCgbOe2gTVHJuRboGE0qTNr7WxxPfEHJdIfsSs64OeBX2QwbAs1126PAQABKYorJGsjOo+sbymVxYa6gklJXZsr7fwCcOzWzcYQvqgplipFdrwzol/KyyhHASg6mVoTdzudbBYpqYwc/a/vQpLxeDw905fq6tp8OPYTHJvW2X5ad6ld8dK0IOjbYR9YD3ls0tRCYiD+cgwdY5OVecLRdeuKfX3MyWwH1ObBqA9Ge3NrGvxirqO6Dgd0rhdc6VepHEVKCIZ86ugcJXAu5Yyr7z9IEBT7W2uCeLnl9Fb6jwHh2sd67oYt+uO/UDL2yibZWuzFxCpfPxXAnULhtF4zjQXg6hhQinaisfnVFz7mccJY1sx/xw==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2BWqVqhSvJFLTomqBfntFfZBE6u5jFwwK167PNf+ia";
    };
    syncthing = "Z6JHQ7G-P4WURZH-OPIK33T-UHHFTVU-2CGFEAE-CT7QEOO-LB2HC4D-YNJ72QZ";
    public = rec {
      IPv4 = "185.186.147.110";
      IPv6 = "2607:fcd0:100:b100::198a:b7f6";
    };
    dn42 = rec {
      IPv4 = "172.22.76.185";
      region = 44;
    };
    yggdrasil.IPv6 = "200:425d:96c:e84b:3520:1db4:b6ca:ed91";
  };
  "oneprovider" = rec {
    index = 10;
    ptrPrefix = "paris.france";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5a2K6h3RbZpNnRMCHdd2wH1H3MJtiSUe0UhhE/6MnE6GJEgP1Kbt0JBVwMn/UEaKfcdHdUhSQGg95q8Z87gbuyvmXiAj1xFyqdOTrZwqyLDPj9gCe/krA/02z6O9hxaqF2FMJwudcqq0Um/ppxbHGkFH+KURzbdIH/CSBuyrqGl6v/lWbmyI4H4NpZZCo37y8NVicfTsljDxcQpQzy7iEXvwAdjqQI8HSxM+8Kx5BIuV5rAmJzF1Pb+GaZXodvVRIULa3zvfUfaEhYbKTukgvwdwMSB5eigO6WRjqJWgz9/6VCy/JRZ3UQVNRh98FZVBktj3qN4WsR/NpcmS7eFv7p1WWnWj/YjxtPTlB7jUnA8wthqCqyCOQi8ABbt/hmSqmTVbpDm/IWefsgdJIjarkreEToeEne3BSwJ/crhLejitpMjM5RvcOurpUY14kZTBwbcE8gB0TS7j73+GvXLHs7FSkeVpdDC6gW4RZkYmMcT0+H/mybASET0bgMwCakIZ8QSVGJ49JWmvXRYRNlBjoHu44HITa5R8ya2OjxLunPXbk7d9EUyyejLwq33+zRucJD7NiokKyLxfgS9zqlr1kV44ehP04mg+mHKKDxdKoY1bYlYbBXDNi/RSP65MlGBcznAECOyQAoxWLtdK0mW+tJpGkCGt2iplDoF5dJHhG5w==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFZz8i4n3uwXrVFyKn/QxHst3FpbYKB8uoR2YZzI4U6";
    };
    syncthing = "ZAURUE3-SQTDORN-WIMV6TB-HLO4KGS-V4DKCQR-4FR42KL-COMW4JD-NQDSTQ7";
    public = rec {
      IPv4 = "51.159.15.98";
      IPv6 = "2001:0bc8:1201:0706:8634:97ff:fe11:7b94";
    };
    dn42 = rec {
      IPv4 = "172.22.76.113";
      region = 41;
    };
    yggdrasil.IPv6 = "201:8a4:ea18:3575:7450:92af:a4a6:2ec";
  };
  "virmach-ny1g" = rec {
    index = 8;
    ptrPrefix = "new-york.united-states";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4deGLTDTGKNoWDo5IDEK6R5wHymwdNnxrdsrL13/ayPy2B2zi5FuS6FFz0EEgaEEzD+9U6NCxxEypUU6uLjVAGlH7ILqyy0ASyIY3enGHkdv65gNIjNDymzQosR4kt5M/VmfEHJFf22tKTuV/CR6/fiCDe9xGEHbCv5r/0vzNnV4A/wijs1xoqD9x9AsUkkoo3SAUpeJljZxMD3CHNn03ROmXhnADIeX2hGiASfzwPS7tSEO9Mh7BDNJu8uRqkH3nlDIOenBHAjsuFQGed9WF03JHElyxO94AhoZwNzgeqjYxktU6pCAh2CnPKjuYeXUBSSPz/GOWkGYbgpHKOcvF5Kmu1f5H5+R1g5V04BN4PVjGvRU+iXd4hZCCHi6XqZ8v6fo15ECJ8EexTF7RIvGkzCLY/m0dtgIcBAXhzphvmzveGh1X3iS/eOMXWHugmmXnKfSA5Rl/1rU+ZcPJ1/Ju0A/6SyYy2MAJ4ZTEZGJSA9CrmrIYflr1LpRPq0WlSjChoXaz8WzBx6DxdeVDzRWLvlVbYfUa8cOalb0MVAwjCuo1pzg0ejbWj8b76p4diTEGyI7CbdRG45f7F7aqoSq3iW0CzivqZofs+5GaJgS8X7S4RTMJQWzCw93MLwyd0iiHxTeFp5RcYxL/L9HM/jQGk6fTkZ5JbHGhKOieDKtUQw==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC5Oz+8RCV4amTUqd5BwLJ1gqkhyVhDItoevMwczN3Ry";
    };
    syncthing = "OJOXTFG-UTGO6DK-O3HNZ5G-UOKDPJL-IH7IO3R-IYX4L3B-4QOFZUT-PWCHJQV";
    public = rec {
      IPv4 = "216.52.57.200";
      IPv6 = "2001:470:1f07:54d::1";
      IPv6Alt = "2001:470:8a6d::1";
      IPv6Subnet = "2001:470:8a6d:ffff::";
    };
    dn42 = rec {
      IPv4 = "172.22.76.190";
      region = 42;
    };
    yggdrasil.IPv6 = "201:724e:e8fa:b4fd:8674:916c:44bf:54a2";
  };
  "virmach-ny6g" = rec {
    index = 4;
    ptrPrefix = "new-york.united-states";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDnpgMzepBss2c522NQot++GUiQ/TLBRwfXD8zfD2XTgnsZwAgRp6A7kCbVAu/CJ5O7UqaFYK6UhiQvPwHdkpLluy7a5ifZrI74dvkRgMg84P5YZXPxNiWWOQH8peiJFZJxG0wKC2ZVP1PmNp/OJJD22dtEXrDlu7lVzIHoIoSoT8qiqIx4VP3jJSM+t4ruuTi44Vvw0S4TjvPfENUcOKrU3nvbpliVkNpuPQROKi26Oz7o2jAVE8QME6Yvh8NVxUQTgqR5lHxBhuP2PTfnKtv6WIJf1xL5EF4WywL1uObc4w3qIAHrRj6ioZD/nFqgaQJpKO3+lmkRhz5iwXPfU19xPq5j0sDRPvoeE8F/P5QgMXJFnDR40YxBtvxUqAbNE9WR4pd0AdX0QwTrWQecAkDXpaY/L524JO5eJacbi/VCLvc3+QLNJDgOeXmIHv2oSF6Rpm2Q+/Tze9YdyjDvdhOmC59kRXx70Vs4SAArU7iF0mVbM8vTCV13DfQCUrf5XoJCX5lekhdIFnj/dju3lJr29POfThquzT6PndL9aRD0mA1ZNR1dk9wwvvv12bVoTgoEiVdSVLY934aMxO7wXSDhsivXXUrexk/lrC6nIF5y4PiORQK/5qtxFwn1tdFMNYb3j8PZcWkfOXErf+ZTarDYTXr6tciEB49WMadeJniOBQ==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjmwZpgsCSqgs4kTRqLbkS1uRnNTLGweRqK+YrXs7Qf";
    };
    syncthing = "POPMWR2-GAW4K5V-S3G6YTI-6KI6ZYN-KYUPVOF-LYWVMKL-M2IAYQM-TIRVEQT";
    public = rec {
      IPv4 = "216.52.57.20";
      IPv6 = "2001:470:1f07:c6f::1";
      IPv6Alt = "2001:470:8d00::1";
      IPv6Subnet = "2001:470:8d00:ffff::";
    };
    dn42 = rec {
      IPv4 = "172.22.76.126";
      region = 42;
    };
    yggdrasil.IPv6 = "200:3dc6:b526:4907:14ab:cb02:c5e9:2306";
  };
  "buyvm" = rec {
    index = 2;
    ptrPrefix = "bissen.luxembourg";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0KX6XYiuX+fEvwVc4VN8i9VfKJgz3x806HMvHgNg2hnXOd0h+VYUP+TW6FwMcn6VsG/VJvPAHjB/9loKpcqZucbAHlrNUlumU/PhmvCtmQAMedfLnK2G5Nc6/reeGhLLWzFhvNJNNeUiR3BVbZgOJDtngTJCu/gx8cp4oo/2NaoUNZZgEVfUKPW6jWUD3Q0d6aIA4KBsIG/kSEEyI1UhYH34trY/CndD1L70MtW/+PmM0MeEs5F9cPONDqD5FYYW+hqBF8qqZmiYmeSMS0290/WmC9OEE+0ztEPEhlIoj232O7zOK1Bi7eoYBd7TWeHj4AsZKUSHBld+vc5r7Bq4LtvwlmM7QlCo3teK8E/S7EngjP8KuQ5LvJsf/W3W4dkfDW3eRgmDUxGWbIj+/Es4UNCW2otmv7S26aSvz3Y93TnBj+qtUD5N4A7m0LOvve5UXxS84jSlz6UE6AjGs6SFR3n0PDq5GJeQVej/x8ugz6l2N07Odju85NxhGxsVtOmrYToWZGts193DejIdLlmlkyLB4Lu1Ewj77PpI8EvLSnImOHX2cMRp9+56eYhzruQcsZvSXPtOF0LFcrVXm7h6cuy/G66kirlCcOCl28NctvMVoTJUj1A0OsuQjLILqCNKazyxNeXqFa0/HN0WcXS+YE5AddWwAnO/JdUx0/K2PHw==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKncnTrQSX37j2kODCMb/d6+qoDgMg5zJIVgPCOYolNK";
    };
    syncthing = "OSZPE2T-ABQZTBH-4IA5HUU-W7PGHCV-ZULYGXO-57TN7GM-B7UVQD5-O5EXTQ7";
    public = rec {
      IPv4 = "107.189.12.254";
      IPv6 = "2605:6400:30:f22f::1";
      IPv6Alt = "2605:6400:cac6::1";
      IPv6Subnet = "2605:6400:cac6:ffff::";
    };
    dn42 = rec {
      IPv4 = "172.22.76.187";
      region = 41;
    };
    yggdrasil.IPv6 = "200:f71e:b96e:90fa:2f29:d816:e104:ab92";
  };
  "oracle-vm1" = rec {
    index = 5;
    ptrPrefix = "tokyo.japan";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDSLlxqrHoMNLNrh3OXpUenCfeoAnZWFGN9dY5jWEjJ7bND7xUhmSGVibqEwiSg4cLjvoA6vYCmw4N/4HpN6R2wZyuLTFTxpANuAPS083s3IVGImOxQW9Nbokyz3Zpi9wWoSaROkvpaHBZuIhZgCLVHw+q/GOxd/PTwNdxbJr0OkVub80q87pcze+h4s0NFQcZWhCweoS2FdOooPmqCYlWemFzDnefSzBYwpmj2jid7BrTWXWS5SG+vlEtilASYjaz8FRaQQemQDdNHFRfz5LWzDPRMB/SLQSuPy7eC0H93sKTpnpQjZ4zbcMzgHiM+LCK+ZgcCys6FlL/a1r4xuus4t+REJUHk5/VppeIaCvzqh4xDdhiUQApWPsF00L4Ql/UYNWr6NAaAVFxogYJoObMFDZLu9kg6cD9oazTiZ7jXozW+/Q+a8ZjswQ0P3mUNSujVYQ6t4QdasnVqzeJh1M61J+RGeJRSpF4RTIGRjV8NySXDb3t3+jjs6ftgtgOuhVh0D0bq5/JuzKL0dfLGlwZxAgmAitrO4eAfDsA/4il2JFszscVb2wau6HJojgcJNyBe0Zhm5+QJEnewftn8M0KAIS7aReVeQDqq2yRu7p27JTCfxYJm+K4FC+MGOjnAvpelVJf1BYF7bw3ZCVIaQTm9UIeLRs3G1zJ4hITAo5MztQ==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErp+D8ITlOFi946F3/GEq+QWsDX9myFeVAwaFBLfqfJ";
    };
    syncthing = "KLUWWHQ-3FKFDU4-6RSS4FT-INZAP3G-4V4PZ5X-Z3XHH2I-GIN7NNS-GDREIQP";
    public = rec {
      IPv4 = "132.145.123.138";
      IPv6 = "2603:c021:8000:aaaa:2::1";
    };
    dn42 = rec {
      IPv4 = "172.22.76.123";
      region = 52;
    };
    yggdrasil.IPv6 = "203:ad5c:7556:91f:e61c:774b:7f2:9162";
  };
  "oracle-vm2" = rec {
    index = 7;
    ptrPrefix = "tokyo.japan";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMDWloT27dXqxzdR7simTpNVcdb/ygfkkvUDtSR37aaDFNjRGHEO6HQ/wV831ISwZlSRZUiLkvFD9uelquHvFxwnRzDNz/Rqxc8LJMgdhYUPvJL6kA7kn7RcZe/raEVyWpRhYBHNKTcc/WL5/xuJUmJvGCTuIblXog0dtmeLn4MtrMAC+SpxkuUYLDKqhNKk9I4gdpLkr/OuceAIxiCwvJOq6gOl0wJJtFOOsHU2rTW4XNn8uTjhF/KuYEC17DGx4QQik0Vq7LXNhfjQutdLoS82OX1cCci/0ybB2p0785wK9+6QkJIDqmohb3D4Anw5P8ZCSrxKl+XCAd6hGl+QVAXdy+JYchfsS/ldxS/BS/+JHNjqjeQizuqYUiEP4CVk8yMoh7eMr/ldFCxOb78/hZSYvtPybw+tkkLqXBreMle4v/V8unkrfWFnxelmn3duHsPE/yjDPLGwJSIQzNvxKldKgj86UnxRCuRQCurcxRWNIWa/ttFnLfKY0VrKi/3uKXR0BOhVQUZdeRQ0DhOhsqFUMN+8WLQmaj3WfABV1eTFWEzmul9zQUapCVGePFsDiyCidr2UgeT/RgCmomkxndkLl/2ROwjkw7hUYqy0vRHdq5nd8i4tczdZYzVGrRsVd7qQ4VMEn/x1GnCwsa7qNsi6y2EygKU6LtxySDYhTwAQ==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzrBeumtGvE+EZ0qlHMs43DMQ+jBXawKa4ztYFS2cTb";
    };
    syncthing = "4PFMHUL-336XMHJ-WPIQPIX-MGKMDXS-5UFQNVF-IIC6ERE-2YNMCOF-5DFEWAU";
    public = rec {
      IPv4 = "140.238.54.105";
      IPv6 = "2603:c021:8000:aaaa:3::1";
    };
    dn42 = rec {
      IPv4 = "172.22.76.124";
      region = 52;
    };
    yggdrasil.IPv6 = "200:66b2:e1fb:e4e6:301c:8fbc:950c:7cf0";
  };
  "oracle-vm-arm" = rec {
    index = 12;
    ptrPrefix = "tokyo.japan";
    system = "aarch64-linux";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2ucVGO1YiyCVqwk1A5D4BoISdgPpHjx8HmjfTQ/F3A50aYwKg6fvN6qHtWq7RDg3IICKii8EgXEhVSrG8LXxkZZW8zory4y2zwGl0XMFlhCFWo19zjLsIDBV57YoIBIGlwcyhbg9gQEnVcOrJbM/5ZpVqsyXryQ+NsPBHagtYgsPk0b8if5i/0kuqu+Y1K4rhN47toGcgwK5O8iYRYmlkPvgUQHQFaaQlvii64a9Tzwct6HhRsDYzoxGl9J/yMUiom7Qbhey9E4+qHp6kAIscQirMRmevKUikdIl8vdt7c81ms4+6QA4E8lWUujqTbXAceQ3cZxzUIWfoOoMBxs2rr1OIWEhvyzGVzfcIQCdSI4qJEksDOP8dg4ulhDISqxzHTZSKkh1D/glpd0yU045dwnQrBI/9dpYjjhmuEcIlZNllQdIv383ZdgGnyQoNetNP955abVJcxteiTQTHTQBVimQNuoyHhJ31RDqEMOgbUpuVp3ucU+Vml0p0NvQ4mP4YxRrzZzFEzyw6BTYA2aWDBm8AAMUwKfFak97CeHvQ+arFRzuCRApUUDzO7Wh5w1F5GihaBNlRIGYW9j5ss01QqPZsYIb9+mJpjukFiKKL5ZKxb1pgzQIh5t3Nmq9AE2Oh1rjSmZdqcN3RYA3WUK9squaJyHUcpahJjPTjeBQu5Q==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINaMb598DMCrl3knaRaLzF5XVGCnjZSQQ5WKeYcZh88m";
    };
    syncthing = "PFMSOOM-APX676H-CKYGFUC-SNESC4K-SU3V4PK-BX7BCXH-MDNRTT2-RVO6XAJ";
    public = rec {
      IPv4 = "158.101.128.102";
      IPv6 = "2603:c021:8000:aaaa:4::1";
    };
    dn42 = rec {
      IPv4 = "172.22.76.125";
      region = 52;
    };
    yggdrasil.IPv6 = "203:1160:3010:f27:1872:3a30:590f:ec8";
  };
  "terrahost" = rec {
    index = 11;
    ptrPrefix = "sandefjord.norway";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDL4OQIUTdyZynG4B+/1GFjMoQKX9xq1BVyOF8spXWNcUDqPUfetgA0H5CLILvUZTyR5thM7zS5gQdn01m1qznMXoGtOQqVBTLGS6ZV8J2rO3/vwKseJYh6rNiaImWu6mEu/G6k3v3xrtan9j+Y9X+vLPGHY90uASzYv45VaU/xW/4ChDLfQZitLW3lyGz3DZqXDTZZDzLeHCMwFFYw7GcIG67E30IoDd8300wqRg3sCeTb8XwqqhA2YDn/UuTJNQTHaRCFEt5x92FILmzbT1WxFYh3UXZ6VTGZQ+OLRbqhTq1IiyaV9B4reiglyAC6P8IMjpl3yqhF+pvJodSzIi6cEutbVZ7nP61nu2InsjvHfHumh5dPSJcpYmiOFcUtyLx/YKPHbw92B1yMWai5t+Y359xgJpJvIX8Tuoeu4S/zheAD1q2/8zf/ueCBZfniTU7xrdL3KJFcyLwqEWvUr+/ZtmjodGUj6jij0cqXCaDuqqy0/+HYmvVfBSZ11aQIM1liEa4w5y2gJyNW7fz613OvHd6JXglz9FSYlSmQudNYYaLGy7ltBQfInJXwzdcO+jmZjif9pjQBPXXVXUx9SErM30Dg8//gK4OR/YxhMyReIStQkVN1OPILyOGWFSo2ryCNpjwNHzHba18jZaS7HPt8ebL4KsULZEEVKozUK8ARcw==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3gI3Xp4vuhLA7syB110Dt46tAZQvBm+TEQ7Pg25HY7";
    };
    syncthing = "6J6CMZP-2PATCDC-434O6MM-QULLX2U-EWVH2JE-J2UBCE6-Y54M27G-VCFHGAQ";
    public = rec {
      IPv4 = "194.32.107.228";
      IPv6 = "2a03:94e0:ffff:194:32:107::228";
    };
    dn42 = rec {
      IPv4 = "172.22.76.122";
      region = 41;
    };
    yggdrasil.IPv6 = "200:e0f6:8e20:ea3c:df88:3357:f0f6:ee1f";
  };
  "scaleway-fr-par" = rec {
    index = 13;
    ptrPrefix = "paris.france";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3/nmvMyf4amfWc1VEPW1JU6OTRtujri335Y0kbpO+rACDbISwrT4eCrxiYEpx9LuRirRMaVRaYNJB13QrvAz2OXjuvtbv/uIdXtvqkCkVZ1svnC0i9+7DtCJFwe2A6kINROAwvnwcFKOcn0vzj4w0nO2gAKYLhRhKbq2LvecBM6szhhhpvjoQk+TuAYGqq9f0HHFU4j0gPmL3EZrk41aHyNZeysgmFHI/OslFNXEg+BebqmEpMS0OZvluDU+BFgt7mdiioyTO167S2n5GTJ8NXpO03jOwC17n+ATTakTJ4On8MB66np8A9Qgd2MieO7m8728NZG7HJCP2A+QPTvTwabe84Y21YePuC2z5Z0t7+Z5YnrRouCZSMzHKrfLvzLll+HMT59eynEP3gN91W5SMr0wfJnCMl8II8LakVAEgKMXOGq3lEDGUryPJPPB5sR9ECz28YWE+b/TuwgPugGoP/GE9/4ZqGzNsaCO/J8o1DqVrGdmEUKwcYAHI7E9gZ5my4lUZc2qFKJCCBKnrfWyIcKrEpIUWI6wNFULRAUKozBueKs8eZsmbc3SKyoeri0WffpQALatBtTIjPzR+EP8oxPNog6tegLWZQ8DGYJ4eTcHowQ5rsYALADySwRPoi0l2wjzx2nVqXZ2zxaSMiCC/VaPTpiIs3HRxmTWQ0u1LNQ==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAnuzYD0V6YVpkVpjWLW8Ds+ZL5TKTjcIpnd/Rzqz5Rz";
    };
    syncthing = "WLPTB6F-Q2JP4AG-WNVCEDC-GFKL7B3-Z5CUNLF-VRO7X5W-JBYCES2-GKBFQAY";
    public = rec {
      IPv6 = "2001:bc8:47a0:66b::1";
    };
    dn42 = rec {
      IPv4 = "172.22.76.121";
      region = 41;
    };
    yggdrasil.IPv6 = "201:c38c:4884:b853:6041:2d3c:bec4:c97c";
  };
  "scaleway-nl-ams" = rec {
    index = 14;
    ptrPrefix = "amsterdam.netherlands";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDT31X4dXf1P4ZB+/wkoPPuGOtK5rEbtqivVEIDKcIjhV2QgyZALVcD8D4vKKMsGPg7doxfmktCd9EI6taXzxVm2AMAc6FTeCPJT5wQhxmyNW4q+6uzcDIOM4R2lBY1w2JmbGub/BlQ5hbHi6mubPrgyV90QMSES1v325+g0ADADBKjWPX+040XechcAHdBGHLkdRg845ZKLjq9eXSrfeS8MnkABr1x1ArpSoU62ayb2jocNxxyzHx9Mq7Hnh00m3iU22Ep/K328d86KqjjjziijkSCeY4ajwfnDE49Art7UQP+WqS/mOCA1bfSB9a9zIueRcPcpsyG+5g/+pgTzYtf8ph7Hb+LrX/jHdQavxJmTGqpBl5ShqiwctyjAtnKQV21NYZ/1UyEvCHYa6SJuoFCdiPQsNv+qBnE0/ToiaD6rLCvVzu3RPT3NWCWQruUiaRpYndGvjuoGlvqnZJG5P65r/bVnIC4N+FNvoZMBas7yc3YkB/orQB7q9CptYYqIFis6t5eikdnBmwYTW07VoiixNBvKnGCBFYz6PKrrsGDyGGHPgeUxhz5BDCsp4TSvAyYoALfgtOsrbho6Q7yn84R9NbronCtA1SggBlheaqQeEVT3Ngy6eGdwUmJN6C4Z0LekUw+OK+Zo2h5hZWjWFwT5qYTU5e9lFH0mYg3M87h+Q==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAbD6JvBPs6NkUJe95OMSppNacVzpizA5/rpNqVtXwdM";
    };
    syncthing = "GRHOOWC-KP6A3UM-SWZPHBW-6TVVZBH-O6VDDIC-X2CP63R-H37KHIE-L5AUIQN";
    public = rec {
      IPv6 = "2001:bc8:1828:292::1";
    };
    dn42 = rec {
      IPv4 = "172.22.76.120";
      region = 41;
    };
    yggdrasil.IPv6 = "202:935c:d5de:9015:9060:7c25:39d3:f3c3";
  };
  "lantian-hp-omen" = rec {
    index = 100;
    role = roles.client;
    hostname = "127.0.0.1";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDE4CLCfkSGU7NMz4n5yp8AEdds7br0Ehe0e/RFCBz7wmqC6JeFgwapZefDwdI5av5UnBP1dqmi602OBF9yTCQ0yL1FLYTgkfWjGZSpRWOW69rQGsSGHMF/BExNQnVzmIrlMHlWtyQvDsI6tycMAiPBh2e2jcCzjGQSsHIE2d8TNN3XaA1Mht9dC7pAQqT3QUeYbUud2xWh0jCLLX+fLe9F41O9//TLLX/Lergf8Nxlu9BBM8l3t7JQBFq0QmzFSL+ODnlMCq/yEkXTOTNUNo9hzuLIr3qTX3jmYb4iF+WmeAfTcA1i0JWeMo/TilWhKsoBkYanIBCz9tctpqB2xFOWlC8UKXlgRwDRftDXTIrHMu2RvshB6bKxfV54yYAkMp7p/Alfq+4aYDjE10e0IRxB3AGsyVDH7eGWxbdDJSblu2zNaZfFmIARVU7Kc1bJHe05NmAOSwIparSh/ge4Nv3+i+ZQr6GPUv8ILHJEyn1kladwX0tubqXyR8caETe0FL0=";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKZp2mN9BALoEjCyvAK27k5AZwOmQqU6ZWi+SXvYezBe";
    };
    syncthing = "SJS5Z6B-L2PH7PV-LHSOTQP-BX22TJ6-GVMWYKW-C54EU3S-4NAQ6EO-YIZE6AI";
    dn42 = rec {
      IPv4 = "172.22.76.114";
      region = 42;
    };
    yggdrasil.IPv6 = "200:89bd:cf68:6583:f5a7:1ce2:bf8c:a11";
  };
  "lantian-lenovo" = rec {
    index = 101;
    role = roles.client;
    hostname = "192.168.0.186";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZcTivKNdS8+var7e60bl8JZPJhhbfHuOhmVwVt3zsoi6vOeMKjOLT+HKgvjGL6ctRB4bafdf24FdGlyWsbA7WC6Dmt7IcKVkPkMXzRfMF9KqngyYHnC5gwyraEkJ9BXZBYnAQeLKs7YQBb7LwQNXwaKsSRewyWSu//6EVqd/1NrzgOP8AXL446jjzoUizFN5f0xM/9b7wllH70VnvKVIGa2djU87QtX0XHda2yyx+GmCy9ic2qtn3Tpu0h6ex89p/ppymq4WxF5GizPF3neqp6K2EEAOfD667c+B/C8EYD8ltt3kBcOxNj7udk5ZwAmpDIf6U8gZxyaxaZ1vUWdrfw/AsQehQDi9wRr/Z77Bc57WnNI3Ib3TpcbAc+UE313Pg557WO8msyIgG2fovCrgj1Ez8eM54y/JDD6ekez8zSBNggm4D8m9MufDd9EohCP02t6rIKLrQmHAYOeKIVqwc49pF0yNk1ddJZSgMJszYY1km82V9zUtX6Kr2CoRyrJ+tWOxb8K95V/RqYC9Ll/r3hqc7uMFvgg8B0N1hIUpQDnqNQIhfz8ysjVeHrS/S3+w/Kg80TPSQhv9nXhXQ255UC2OCX5Eu9f9DYFewxBcDxKTEU52/yxkigmiYRsSOAVMdfkpGgDYPdrO8hIS++qclbeTLiW9a7PIO350fwLYX3w==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+dRFR7ZEU/XyPl4EyAsWD/cSDdWkoa2OL9A2WAMllG";
    };
    syncthing = "KQLTC6O-CULFZ6S-ACXMI2D-PCJYAPU-UHGMONS-BLHO4K2-D5GANFG-CQXMDQ2";
    dn42 = rec {
      IPv4 = "172.22.76.115";
      region = 42;
    };
    yggdrasil.IPv6 = "200:ed7f:781c:28ae:a150:5774:869:3c36";
  };
  "lt-hp-z220-sff" = rec {
    index = 102;
    role = roles.none;
    hostname = "192.168.0.168";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCuvMMZMBtnht1T7dYrfyI8HZibbPDXaJRcX0EDWgue8IB/z+Fhquqfp1LjUqYklR13Oyfh7I7EIz5z0V/QlklnJPsuht+LvW7lEpk3NzSwhFrXktOzqjn+bICHL+KxZDaEHxIXm+AaXh+cH+VrrdD2WKrgMtZAv+8gvLHW51t73W5oiyiefBJfMHba7EHvRNh9enXCzhWzp4pJdlWDd1Iu80P/dmpKWSjtFlSFzXl9Pv22IbdDSsHkdNbf9vucjL69LOzB49gIQIhvIxIMdtQZPzMR4iEn0BqvVDqyXjRz7l91/btduK2mFD/JECb9VTOlx+FrKPOk+cXZDSbfNcp6a3p62iaPEXNqh+y2vXJdVMxkVKwVZOSsNpw4SRwS0E/p8F3nUj6rEaqiikMW19tct5F2As0Yi2/7aW6JBiP1Wc118GztvQyQjtAy2w3142nK4N2O2IWTa5fvO4UHk4NqnYzNZT6aTZftcT/4Y47T7zPlSZdaix9Q1oQuXZolUPD8trGo1wVgiIhFeO4vMP7xDoQ/689bWPbb8HD4tA8JD238wAyYttlsr4sa62Lz0MyGwn1XASCmQ+7Y1uKZr5j2VBpjosDfoDq01ax5QDt8MdkBSfml8QtY9jBpq82t89PVXXoefkndZAFvuYfYyaG6g5pQ/3BUnWlfvPQ4ekZfIw==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHq9gnvAZdEt84vZf83s4+T+3AhPVY/xz2o5qbqR8ftx";
    };
    syncthing = "6BR2PXQ-TQAKVAA-EBLNUXB-YZUSZ54-HCLWQBR-QRCGNQU-LKRCDHR-ZUH3YQZ";
    dn42 = rec {
      IPv4 = "172.22.76.116";
      region = 42;
    };
    yggdrasil.IPv6 = "200:8f67:1a55:411a:94e7:8c34:e012:32c1";
  };
}
