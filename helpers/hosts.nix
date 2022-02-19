# Index 1-99: Servers
# Index 100-199: Clients
#
# IPv6Subnet must be at least /96

let
  roles = import ./roles.nix;
in
{
  "50kvm" = rec {
    index = 1;
    ptrPrefix = "hong-kong.china";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCw1fEo3i7HViqekWReTW+jF7Nlw86ZYjez9zYq960PcuF9X/MaUjXCoUNuAs7km9AGc3RexPcX7sdth5qA2V7JH/KewARI2qiBZVCeX8DnSl27iVSkEeHFnoDQeSgrOnmQwd6N1ELpcJatGzWLA6FagobJm90HlbKW1uSwbh1TprDPtyFVLhaoyjIuTd+K3obCGZQiBY9Hmuiq0pTUM+PXgC4hRy5gsWnuLupDRSHDkPpAfXAND6decx6Xpx7GGtGQRbZ5xw0ZOPrphuVowagjMq7eQXivrc3S6LdqErdqnbVGUzV7EqJluRqWuH/j3XMUnrXxryJ/JpR7tMssc4xacRI0zD8J5jRGDDTvV+2RNarYC9bfHLVpdWHkELI1M2iNOehiYCzqO0ay5cVqEf3ynRe1HZIRp6Z7nI6dot/TjiQMx5+DGz1YTBvWL7NieZ9RjIKRus9qFZXDgK/8ZWylsVvRjemMv2Nno7l5js+7c5R9pfMO6NZiH4o8AJEus5Wx+M+A4hxXZAU7dGgcJPlhKCKZuIoVJTQnuctKN/ff+AeXNoZTM7MPdbNlzZ5ogrTXuCO9vXCohRlxXNBwGUYR4hUXF2nC+RBGCpYSUVypmpexRlbNpec6E6q+Q9BMltrQ/bRbGoNN4oateowFjiYS5uBqBUm6iXONWLNwUAdLpQ==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC/8Bj5bOf+14ZrrvUdQNxBWjl0ZZ64D4wnUw9T5rK9N";
    };
    tinc = {
      rsa = ''
        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEAvKTNcERyGg4/QH2c8S/KIkD5YT4MwMnDYs7m3M3OFWnMjlfoPoBU
        SDmaWdEmZuEHjyfy4fRplHAVrowzE3Ml3I2lCf3ZJy2tuXgaGVUbAyxPf5wy9dGH
        5Y9pQgdp3w1cJgHRfyeHL7gQ9mbXXrRT16oCjZKqENmbBIA64Cu2Owz/U4v5c+uh
        p1AH+mtbb1n1gV7U0kOo6yDS0QpeM8BLlo4J1UUP+z8SVp5Ed8nYaaNRvM1wW8qm
        qQvaqFCp7pKsIqnJZ/siO+xEwQxPVV3+pp64XH49xUTFB9cr3hZ5zBiPzUeCON3/
        aHpBU0vwgOCBD8LP1I7eshmeJZTPJaW5NVKL3I9c1av8vi2pEhFj+xZZLLbYdVo6
        3Vx86znBK/y9dLO4Xr1D+4AwQFweAC57lGAv2lWIZDVAEb26ZhVN782S5y0EmUgo
        xMpf6wctYYE+sUhjf7vM3uiUanDrHmMYRtPTo1Sc/ipRvgPEpehE9/UZ5Ff57kOs
        phkxIjQmXoy9raEDpHUmE/jmXILKZR/doyoH2IIbKqnwWWAb5C48i8YTipZbKsko
        oV1VOKgivwQvozYvHR68pHyqfL5yEeTtZ47C+Plu0efNj9khuffRmjXwaCKLDPhd
        7xnyDKw6qV2SBvxWAB0zALjl305c2QcjqN0qOnIJAZMNjCT5MQ3QWuECAwEAAQ==
        -----END RSA PUBLIC KEY-----
      '';
      ed25519 = "bb5Ld0HJaC9Jzkf8ad/labkOaEAnGc8XeclpWYNZeYL";
    };
    public = rec {
      IPv4 = "23.226.61.104";
      IPv6 = "2001:470:19:10bd::1";
      IPv6Alt = "2001:470:fa1d::1";
      IPv6Subnet = "2001:470:fa1d:ffff::";
    };
    ltnet = rec {
      IPv4 = "${IPv4Prefix}.1";
      IPv4Prefix = "172.18.${builtins.toString index}";
      IPv6 = "${IPv6Prefix}::1";
      IPv6Prefix = "fdbc:f9dc:67ad:${builtins.toString index}";
    };
    dn42 = rec {
      IPv4 = "172.22.76.186";
      IPv6 = "fdbc:f9dc:67ad:${builtins.toString index}::1";
      region = 52;
      peerWithGRC = true;
      pingfinderUUID = "***REMOVED***";
    };
    neonetwork = rec {
      IPv4 = "10.127.10.${builtins.toString index}";
      IPv6 = "fd10:127:10:${builtins.toString index}::1";
    };
  };
  "hostdare" = rec {
    index = 3;
    ptrPrefix = "los-angeles.united-states";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCfK8gSS4EXf1yGprWEMYMbEuUkQ3ngITHgTfgbx98qONTm/loSMhNqN2VM1haCjCV8h4PUAd11mPjzzci08wQD/5aSbQnrx+ku8vkT8D+hNTzdxSGTTbvOIGsfTB26JPH0cFklJTz1hQSD9mOPl6IkdP9qKtlTmTf/NrER3ClEaKRfgjgrpkJ+IvlNLIO4Lgm47xoh3Jj8TUZd+qowcHjvilE+XY9tTIYypaRp1vA6D8sgNp9aIObpYO/XzuMGabaGHJO5bPWjIw/Fw+mDctNVtWLxczis/qTGYWMUUVbmMGpmvfZQ955xnXoY4hCgbOe2gTVHJuRboGE0qTNr7WxxPfEHJdIfsSs64OeBX2QwbAs1126PAQABKYorJGsjOo+sbymVxYa6gklJXZsr7fwCcOzWzcYQvqgplipFdrwzol/KyyhHASg6mVoTdzudbBYpqYwc/a/vQpLxeDw905fq6tp8OPYTHJvW2X5ad6ld8dK0IOjbYR9YD3ls0tRCYiD+cgwdY5OVecLRdeuKfX3MyWwH1ObBqA9Ge3NrGvxirqO6Dgd0rhdc6VepHEVKCIZ86ugcJXAu5Yyr7z9IEBT7W2uCeLnl9Fb6jwHh2sd67oYt+uO/UDL2yibZWuzFxCpfPxXAnULhtF4zjQXg6hhQinaisfnVFz7mccJY1sx/xw==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2BWqVqhSvJFLTomqBfntFfZBE6u5jFwwK167PNf+ia";
    };
    tinc = {
      rsa = ''
        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEAqzMW4yWNvkRO2/OQ8xGR4kjFh5mue6H7HnpSZH+UppWYKZReQEAm
        RdYo2gFgA/yQDYpFOLtDzicC+dyMtvwXPgvIU3ZmvLwteS15qcICT7njLNBRf3SE
        aUE2gFJZhWokuGaW/FCiQqUqrCXJNoOsS7dIXj1WNffuDnk0ZD9AE1YikHpCRPWv
        02UNsedui7XRokUGZaTMA45qZizsbrLKqKcy4VMqEq3IPxHxJ5sRmSRLyjVwDzR0
        hW0MHVJOplI8AVqPzLVnuyIOw9nTv0lcEMOOxc4tJnSEmZnEZCLMZciSulIJdiIT
        +W2FYca0baaVa6Tx4Q+OxN5SJikHQuB9aB6jWlfWxBslML8tK1XZZmtq0wbfbqX5
        DvmE9uq0cppkt3JiWuorLcV3tINizqWUbEU7jSgAhD/XbCCwmYuTcTHmhuiSvOrf
        eEt1MCPNKJQuCwJWX/eH2fJ7dZSNa5X0sXcNo6ps4/3JlsBLYT2tEalWRtJabKq3
        aqB9iObTh1wJBmDSVDcsHUQkw+Z6swt/GuTPfWjkmoaSnx4Q9t7FoRYE9RRJm2ER
        sjBQbtrd4vbmG9hpTmTGTj9FCLMQukMMKsItbjTLNrLUepqaz9S2nroO6TUXL9B7
        9KA2UcbRrnjsSJF9sQImVb6qsejRnE59hhcd5OwetisDTRt/jmomIncCAwEAAQ==
        -----END RSA PUBLIC KEY-----
      '';
      ed25519 = "YDKx1u/2OP1jf6mou65URPaVBLPLbZY1ClwYK+257tF";
    };
    public = rec {
      IPv4 = "185.186.147.110";
      IPv6 = "2607:fcd0:100:b100::198a:b7f6";
    };
    ltnet = rec {
      IPv4 = "${IPv4Prefix}.1";
      IPv4Prefix = "172.18.${builtins.toString index}";
      IPv6 = "${IPv6Prefix}::1";
      IPv6Prefix = "fdbc:f9dc:67ad:${builtins.toString index}";
    };
    dn42 = rec {
      IPv4 = "172.22.76.185";
      IPv6 = "fdbc:f9dc:67ad:${builtins.toString index}::1";
      region = 44;
      peerWithGRC = true;
      pingfinderUUID = "***REMOVED***";
    };
    neonetwork = rec {
      IPv4 = "10.127.10.${builtins.toString index}";
      IPv6 = "fd10:127:10:${builtins.toString index}::1";
    };
  };
  "soyoustart" = rec {
    index = 10;
    ptrPrefix = "paris.france";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5a2K6h3RbZpNnRMCHdd2wH1H3MJtiSUe0UhhE/6MnE6GJEgP1Kbt0JBVwMn/UEaKfcdHdUhSQGg95q8Z87gbuyvmXiAj1xFyqdOTrZwqyLDPj9gCe/krA/02z6O9hxaqF2FMJwudcqq0Um/ppxbHGkFH+KURzbdIH/CSBuyrqGl6v/lWbmyI4H4NpZZCo37y8NVicfTsljDxcQpQzy7iEXvwAdjqQI8HSxM+8Kx5BIuV5rAmJzF1Pb+GaZXodvVRIULa3zvfUfaEhYbKTukgvwdwMSB5eigO6WRjqJWgz9/6VCy/JRZ3UQVNRh98FZVBktj3qN4WsR/NpcmS7eFv7p1WWnWj/YjxtPTlB7jUnA8wthqCqyCOQi8ABbt/hmSqmTVbpDm/IWefsgdJIjarkreEToeEne3BSwJ/crhLejitpMjM5RvcOurpUY14kZTBwbcE8gB0TS7j73+GvXLHs7FSkeVpdDC6gW4RZkYmMcT0+H/mybASET0bgMwCakIZ8QSVGJ49JWmvXRYRNlBjoHu44HITa5R8ya2OjxLunPXbk7d9EUyyejLwq33+zRucJD7NiokKyLxfgS9zqlr1kV44ehP04mg+mHKKDxdKoY1bYlYbBXDNi/RSP65MlGBcznAECOyQAoxWLtdK0mW+tJpGkCGt2iplDoF5dJHhG5w==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFZz8i4n3uwXrVFyKn/QxHst3FpbYKB8uoR2YZzI4U6";
    };
    tinc = {
      rsa = ''
        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEAvgJ/jOYyXfRZ757JRnUeJjDJndC8lLLdwcaP2IUUVFQ/euQHTRHk
        qDrfJ4gPMbUvAYzXioC9WvqR8MCt0UN2X69iAtZzumG4asvNyM+rCR5wo8CpQh9u
        mqCJrZLWLD/9B67VsMOS7kjNgJA521ksJSkTMgnTYb8Yo4OslRLfDvPzJ5j9D6y3
        ChrEtmYPxg+wuH9Jt1tsyoR97uY+P9xR8cwaAnALvzritYxNWq6zMPt3BsWox6q4
        PtwABVqxEQkT6zVgzmJ0VhWiLzlptAwEhaSmX71U7N794J2mwHtssM/mMxdmfl1R
        y/1ZpWE6ofgVQgo8mE2od/xtdegi85RP9+pE49kYscqXMXii2hvOs8pfnYzCksXI
        VVZbs0wrxJ/tXFEVMTFD/9yeXBAJ09RYmc7MlKcrKeN8LuKLGMRnVjx4mqOWhgdG
        VCQvPAoJM2s3pic9FrfoqDelBVwVP6FJk7PnL981Xlw9BwIa84qkIIjEPdL9M/id
        Cccg3cOqYfcwV5TK42amOZV84lWS2LPt7X1l4R5dYrrcapEtZdtimLxv9YdwS3wi
        X5kfa4ApHC0sQ7SImy9OekOhX+zHoAGwMY5g7ynXfWIOzY3jGy8KmzQu5HgYp+89
        sngyFPD3uplXm5zf/BnJ/CHPCIhgeizoqQOir44AhPKGKoDHjWsSoaUCAwEAAQ==
        -----END RSA PUBLIC KEY-----
      '';
      ed25519 = "MsUVokv6xh1tg9SXd/rMGF6iI+7FsDCrshiYU7Ro/lG";
    };
    public = rec {
      IPv4 = "51.77.66.117";
      IPv6 = "2001:41d0:700:2475::1";
      IPv6Subnet = "2001:41d0:700:2475::";
    };
    ltnet = rec {
      IPv4 = "${IPv4Prefix}.1";
      IPv4Prefix = "172.18.${builtins.toString index}";
      IPv6 = "${IPv6Prefix}::1";
      IPv6Prefix = "fdbc:f9dc:67ad:${builtins.toString index}";
    };
    dn42 = rec {
      IPv4 = "172.22.76.113";
      IPv6 = "fdbc:f9dc:67ad:${builtins.toString index}::1";
      region = 41;
    };
    neonetwork = rec {
      IPv4 = "10.127.10.${builtins.toString index}";
      IPv6 = "fd10:127:10:${builtins.toString index}::1";
    };
  };
  "virmach-ny1g" = rec {
    index = 8;
    ptrPrefix = "new-york.united-states";
    hostname = "107.172.197.23";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4deGLTDTGKNoWDo5IDEK6R5wHymwdNnxrdsrL13/ayPy2B2zi5FuS6FFz0EEgaEEzD+9U6NCxxEypUU6uLjVAGlH7ILqyy0ASyIY3enGHkdv65gNIjNDymzQosR4kt5M/VmfEHJFf22tKTuV/CR6/fiCDe9xGEHbCv5r/0vzNnV4A/wijs1xoqD9x9AsUkkoo3SAUpeJljZxMD3CHNn03ROmXhnADIeX2hGiASfzwPS7tSEO9Mh7BDNJu8uRqkH3nlDIOenBHAjsuFQGed9WF03JHElyxO94AhoZwNzgeqjYxktU6pCAh2CnPKjuYeXUBSSPz/GOWkGYbgpHKOcvF5Kmu1f5H5+R1g5V04BN4PVjGvRU+iXd4hZCCHi6XqZ8v6fo15ECJ8EexTF7RIvGkzCLY/m0dtgIcBAXhzphvmzveGh1X3iS/eOMXWHugmmXnKfSA5Rl/1rU+ZcPJ1/Ju0A/6SyYy2MAJ4ZTEZGJSA9CrmrIYflr1LpRPq0WlSjChoXaz8WzBx6DxdeVDzRWLvlVbYfUa8cOalb0MVAwjCuo1pzg0ejbWj8b76p4diTEGyI7CbdRG45f7F7aqoSq3iW0CzivqZofs+5GaJgS8X7S4RTMJQWzCw93MLwyd0iiHxTeFp5RcYxL/L9HM/jQGk6fTkZ5JbHGhKOieDKtUQw==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC5Oz+8RCV4amTUqd5BwLJ1gqkhyVhDItoevMwczN3Ry";
    };
    tinc = {
      rsa = ''
        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEAyAHmI1LsfYoZHOuhP7QIpU3UEyGgkmMhTH751b6/8GsPIxRAuI6s
        MFeKLNhpRWXyv/+mE/MuYutt7cgNrwpAPJAQ0zdKGKPbq3qaUdjv1mCH9tHl4+p+
        NHfPWP03pvvUuxIFE9q0xLA2bnKVbekpBAklQKZMT60Su3W4ZhLYr6ouKdZj9O3c
        +Olp/UFWvmS4+vhNnE4V8rdKNNcaGZXZXmaKWOVWmICOhpMLOZPSB1GeSKW12AvS
        e4fwTmk5p0TvnKJlu4U/Al1AH4Se8rIqug7nlFLLacCf1AxI9DXXkpX0ugbp8oNg
        vg8Ow4fM7hm4OISvcFtwthlkS0+3B1ibLtlKE+IOKg5btIhD8FZup2kmXfza/q0r
        clcI6QfarXaetjgXEZpnx4pmj3X5+pi5qLT4uhNVH58yMMZE5gc///yyz45fha1d
        vbNvmiFerYdVP2sfIv8OhcLEYp35fWmorP9suyCMVbZ1PGomLWt+46/8J+Sxnq1G
        Vz14NFEQIX9dvwaN3o5FHhhN0i9wtDLLpDQfR1LMrWpWxIkVREXEeAR00LQ1pyDR
        AqUNRFPYhcHyk5pybldl8AELdS557AqP4Oc3skdCXlIm7fPMddBasEM3k78FLAl1
        RQK2q3DaXyv+iriW+by0YehZqfzDdRpWP1EIN+0zuzQQoo1PeXmhPrMCAwEAAQ==
        -----END RSA PUBLIC KEY-----
      '';
      ed25519 = "qEvOIJwbeExJCAy4FIGpXRJdKw2Ep5Q0VAA6FkuGA+O";
    };
    public = rec {
      IPv4 = "107.172.197.23";
      IPv6 = "2001:470:1f07:54d::1";
      IPv6Alt = "2001:470:8a6d::1";
      IPv6Subnet = "2001:470:8a6d:ffff::";
    };
    ltnet = rec {
      IPv4 = "${IPv4Prefix}.1";
      IPv4Prefix = "172.18.${builtins.toString index}";
      IPv6 = "${IPv6Prefix}::1";
      IPv6Prefix = "fdbc:f9dc:67ad:${builtins.toString index}";
    };
    dn42 = rec {
      IPv4 = "172.22.76.190";
      IPv6 = "fdbc:f9dc:67ad:${builtins.toString index}::1";
      region = 42;
      peerWithGRC = true;
      pingfinderUUID = "***REMOVED***";
    };
    neonetwork = rec {
      IPv4 = "10.127.10.${builtins.toString index}";
      IPv6 = "fd10:127:10:${builtins.toString index}::1";
    };
  };
  "virmach-ny6g" = rec {
    index = 4;
    ptrPrefix = "new-york.united-states";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDnpgMzepBss2c522NQot++GUiQ/TLBRwfXD8zfD2XTgnsZwAgRp6A7kCbVAu/CJ5O7UqaFYK6UhiQvPwHdkpLluy7a5ifZrI74dvkRgMg84P5YZXPxNiWWOQH8peiJFZJxG0wKC2ZVP1PmNp/OJJD22dtEXrDlu7lVzIHoIoSoT8qiqIx4VP3jJSM+t4ruuTi44Vvw0S4TjvPfENUcOKrU3nvbpliVkNpuPQROKi26Oz7o2jAVE8QME6Yvh8NVxUQTgqR5lHxBhuP2PTfnKtv6WIJf1xL5EF4WywL1uObc4w3qIAHrRj6ioZD/nFqgaQJpKO3+lmkRhz5iwXPfU19xPq5j0sDRPvoeE8F/P5QgMXJFnDR40YxBtvxUqAbNE9WR4pd0AdX0QwTrWQecAkDXpaY/L524JO5eJacbi/VCLvc3+QLNJDgOeXmIHv2oSF6Rpm2Q+/Tze9YdyjDvdhOmC59kRXx70Vs4SAArU7iF0mVbM8vTCV13DfQCUrf5XoJCX5lekhdIFnj/dju3lJr29POfThquzT6PndL9aRD0mA1ZNR1dk9wwvvv12bVoTgoEiVdSVLY934aMxO7wXSDhsivXXUrexk/lrC6nIF5y4PiORQK/5qtxFwn1tdFMNYb3j8PZcWkfOXErf+ZTarDYTXr6tciEB49WMadeJniOBQ==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjmwZpgsCSqgs4kTRqLbkS1uRnNTLGweRqK+YrXs7Qf";
    };
    tinc = {
      rsa = ''
        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEA15U///0WfYk+VVKrBzyCFhIvcIZ/2aTbZGZ/Ne/L4uu1tGx5GRU0
        sIX6i/LuXeDrxWCqYRUk05nf2mGBwFiGR5A/zbGApypr/pM9OwaQSBL05fV7PCis
        IuJj4oSZvasn+choHrnWWmZ568ApE+tHWphtzLjPB8dd1tD8t6IkKWmjerGDh9Ec
        JwAf+ocvwpqc0AAjgUNte4+GKa4ettyyvg1xY9NpVzoydSWCeMAYxqP+i2m5797O
        MyYRPV/4KbV/0NYy5tVj0VMUdTXj+2JUTDtBQWOqmUYRPDwYXOLBp8FFDNy9ftjQ
        r7rRYXKQkLS/GWq8Pnp75UUHYSxQt6iIjP+YmEpAhOWZXxpaucH/F5DJHWKS7k6S
        r8keT1iWUacHXc2IN7bbhDmzYvFaRZ1dZoDNNnjJimzCyPIKYqy3l8BzSqpsSGQu
        fsil26bbwr+7s4swq2pumgEWjS9n3K5MVGBpDQwMdkP1lgZR0W3eGVscWGFbHs1K
        4zz1YikExGgpg61Up/5ymS4/7BdYnZsrjNaEXf51vQeEvAEyzBtTaftKG+wKvjR4
        m2m4gcQ0+VNDQoUM7voi3OPd5Ja7l2tTq4rz6zrFkAaDZjiy1sTJ+c4w22gQZdY+
        wcToQDG6r3d/sw5DIm41xs7uXjnx2r925VnT6fySR2XCoeSqezabpiECAwEAAQ==
        -----END RSA PUBLIC KEY-----
      '';
      ed25519 = "Z06vhOqNMAzbUPew2sGNzFwM72HrV6gXjmNYfBU2afC";
    };
    public = rec {
      IPv4 = "107.172.197.108";
      IPv6 = "2001:470:1f07:c6f::1";
      IPv6Alt = "2001:470:8d00::1";
      IPv6Subnet = "2001:470:8d00:ffff::";
    };
    ltnet = rec {
      IPv4 = "${IPv4Prefix}.1";
      IPv4Prefix = "172.18.${builtins.toString index}";
      IPv6 = "${IPv6Prefix}::1";
      IPv6Prefix = "fdbc:f9dc:67ad:${builtins.toString index}";
    };
    dn42 = rec {
      IPv4 = "172.22.76.126";
      IPv6 = "fdbc:f9dc:67ad:${builtins.toString index}::1";
      region = 42;
      pingfinderUUID = "***REMOVED***";
    };
    neonetwork = rec {
      IPv4 = "10.127.10.${builtins.toString index}";
      IPv6 = "fd10:127:10:${builtins.toString index}::1";
    };
  };
  "buyvm" = rec {
    index = 2;
    ptrPrefix = "bissen.luxembourg";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0KX6XYiuX+fEvwVc4VN8i9VfKJgz3x806HMvHgNg2hnXOd0h+VYUP+TW6FwMcn6VsG/VJvPAHjB/9loKpcqZucbAHlrNUlumU/PhmvCtmQAMedfLnK2G5Nc6/reeGhLLWzFhvNJNNeUiR3BVbZgOJDtngTJCu/gx8cp4oo/2NaoUNZZgEVfUKPW6jWUD3Q0d6aIA4KBsIG/kSEEyI1UhYH34trY/CndD1L70MtW/+PmM0MeEs5F9cPONDqD5FYYW+hqBF8qqZmiYmeSMS0290/WmC9OEE+0ztEPEhlIoj232O7zOK1Bi7eoYBd7TWeHj4AsZKUSHBld+vc5r7Bq4LtvwlmM7QlCo3teK8E/S7EngjP8KuQ5LvJsf/W3W4dkfDW3eRgmDUxGWbIj+/Es4UNCW2otmv7S26aSvz3Y93TnBj+qtUD5N4A7m0LOvve5UXxS84jSlz6UE6AjGs6SFR3n0PDq5GJeQVej/x8ugz6l2N07Odju85NxhGxsVtOmrYToWZGts193DejIdLlmlkyLB4Lu1Ewj77PpI8EvLSnImOHX2cMRp9+56eYhzruQcsZvSXPtOF0LFcrVXm7h6cuy/G66kirlCcOCl28NctvMVoTJUj1A0OsuQjLILqCNKazyxNeXqFa0/HN0WcXS+YE5AddWwAnO/JdUx0/K2PHw==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKncnTrQSX37j2kODCMb/d6+qoDgMg5zJIVgPCOYolNK";
    };
    tinc = {
      rsa = ''
        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEAmhn7UdH8fnkxQLWHynLti4DhAQohFPFwypAKfxoX2HN3rEc4XNJP
        RRnegHdrrsW0JX9ybfe+NwhCK/ISCkJfecxs4CsTLh8hQx932nXfMSjCWTMD0QhZ
        1b5cm/KbtFvV9pDi3wZhFMH1BFidyZjwRDpcQ49pwqLtcHjIeUFBsBXx1BSIGWPs
        bxOZniV4OwpJCPMlVW8zQOAct3Oy12W5qHnLtUXU20TYj550XEZUXZmruvSBIOd5
        iHGj4RwKtK1SNJw7ca6cg4dEsPASNQqFPzqSIQAJRiqWvFUiUUPGExqDatGfvjrc
        xZ9SgbNBuisdCl53vhya9X3dtkT92vGkZJS7yrbaPjUAJU7L3u1sa9Jw747BhHf+
        H/gq0imnqO/zg/lI5UAGc46lajrhVK/r9eS3kZ7S1D0xD23wUELXpzoC7pNEDiol
        TGR5QOIx7YF1DDpcHbRRXylfjZOlbHwxvftuhvsSW5WQvhnay8BgiNYg4MBWJzXL
        jRaO1Y2t4ScvEGVdc7d2AW3RT3JfBVtUWzvkZqi2q4H7NPQSMpW+hqT1TUQZPdtc
        8xciikgVe9ociCmOQ+5VMP17owZIwRwO0wyIjlTCgj40YQwa7AmubbUJGfwzBHBv
        UHnJ83IAZvPuEzjCOSHRf5erldVJV/NckU8HaSI+zfm/TONHIcwuObsCAwEAAQ==
        -----END RSA PUBLIC KEY-----
      '';
      ed25519 = "XoA62mYaC8/AV0AsyHy0b1UoDkDXjT/TZG2pSENlj8F";
    };
    public = rec {
      IPv4 = "107.189.12.254";
      IPv6 = "2605:6400:30:f22f::1";
      IPv6Alt = "2605:6400:cac6::1";
      IPv6Subnet = "2605:6400:cac6:ffff::";
    };
    ltnet = rec {
      IPv4 = "${IPv4Prefix}.1";
      IPv4Prefix = "172.18.${builtins.toString index}";
      IPv6 = "${IPv6Prefix}::1";
      IPv6Prefix = "fdbc:f9dc:67ad:${builtins.toString index}";
    };
    dn42 = rec {
      IPv4 = "172.22.76.187";
      IPv6 = "fdbc:f9dc:67ad:${builtins.toString index}::1";
      region = 41;
      peerWithGRC = true;
      pingfinderUUID = "***REMOVED***";
    };
    neonetwork = rec {
      IPv4 = "10.127.10.${builtins.toString index}";
      IPv6 = "fd10:127:10:${builtins.toString index}::1";
    };
  };
  "virmach-nl1g" = rec {
    index = 6;
    ptrPrefix = "amsterdam.netherlands";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCfDXWrr5hWPxEclnCSh4KwNIuiFTiO2gFSv1NU/uFgalc9Vv/HDEgECpK96OjyubzuFk2XpnAX789TdTIA51lgCpOExuectMgv1kOiyZ5MXgQQfNqhTUkWaXaUshMdn9wFdQvfX9bLCybfN2QnlpEoh5lts4wDJGeY0qmUThEt1tVgtLYk7AHaNc+TjNnmCBqVOApcgmJDIxE5GCma3fWyThFKRbSKqckNHPfGH1qkWK2REVmhlr5bAumVstmW0fdk71UhRYj5YRI1/9TwZAUFCgq27Frgv0s3VM6jXB7yAj923wm9ig2MnkouLdsCa2KoaTW20BTDokpZ7IUrI2lFOUglVQ7H1Oi/tzF8Hjfm1j7PuM1OjFtzXOke0bOFUB81mN8nLFQauS9bCK/q4Tn+ld8k5kiL+Pe3vpTdFpjBQ0zeRTyM986l3p89ckhditT/+H0hGJ2W0IOhP0oEdBoNkG6YDbO7JAEJlJTDJ6FlgkpM0MEiywFZj6EIzF5wMhHUkZABkpQf2WcnyACUb+N2T1d19XoGM9F7rV0gNJViR8BDkyjkK2R1Ss6AOCoy9FFUVo7mp8k7/x8vAYDU/BUZjIef4cZIJ/qa8jxj8zPcH8K7I2hTMNmX4Ijp8S75fvr9vzFLo5C2es0RZoVrRFZq+Ujnh2cojZHpwKl5ZTvzOQ==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVJfiWHLJ8pP96XuGq5plTFj5gcY7gIAqxPQHxVuJLx";
    };
    tinc = {
      rsa = ''
        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEAub9DXIxVpEnh8EuvOzy1/IMWkt0sGDlJxj7C7IBMu18JhDA25W6B
        TTUiz/n5I/DzBSxoMGUDA2Kj3Q3Afr2e7mZvtYj621m2ctscX3/J0pbKwhK8q/C2
        V4ZeNPxMkCra5luuhV6ZmUyJ1VibL4rz1QeRu72TwSuNifdohGSINcrdGmSNYw69
        fMDjWTpjmqHt3gdad8J4/Tv1lOKKhpNf0pFqzhDOVSpiATYXHOBqRn1V8iFJ41W5
        qhZmHmIuVL/H9NCr95d2pcneQ6VGdPyx3HIsJwMk7+p737715uvxZiUXk44//twr
        Xdjzcr5YmXSQAcycQ985M+3aKzbRoTfZpA4XoDpqEgkdERLnrvxPDoFeRq+jvoP8
        NW8w1ozBA0cw9Y9jlyXhXG5ug4wLsJ6sEpH03XPQeSsSGoy8tBVit8EwZpd3ALy0
        2QbWCQaJ+PpX9+V5UI5mOv54ZaIGv2aSDRN8Uh30RytBEHVdTdLfTbgT3BNooSSf
        kr5D1TrEeG8bHQ24Cq6Dw9zTc9rDj7vXQXOnKUhTK9+1JEuQ62mJXdjX2YTIP3o/
        B34twYcS819kvPCGmrupMasTn7BLwrLwpaiKfd80CmvbYs+xWM/nSQ8fdkjVmXDk
        uPgTSMToDUHQIXC7jojYQ7glhXcoLlaH3mJq6/cbbinEapvAZLyGotUCAwEAAQ==
        -----END RSA PUBLIC KEY-----
      '';
      ed25519 = "EGsgw69soQZI1sLY+s2BvN3FtbtTg+zUzJxuKP9fdsD";
    };
    public = rec {
      IPv4 = "172.245.52.105";
    };
    ltnet = rec {
      IPv4 = "${IPv4Prefix}.1";
      IPv4Prefix = "172.18.${builtins.toString index}";
      IPv6 = "${IPv6Prefix}::1";
      IPv6Prefix = "fdbc:f9dc:67ad:${builtins.toString index}";
    };
    dn42 = rec {
      IPv4 = "172.22.76.188";
      IPv6 = "fdbc:f9dc:67ad:${builtins.toString index}::1";
      region = 41;
    };
    neonetwork = rec {
      IPv4 = "10.127.10.${builtins.toString index}";
      IPv6 = "fd10:127:10:${builtins.toString index}::1";
    };
  };
  "oracle-vm1" = rec {
    index = 5;
    ptrPrefix = "tokyo.japan";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDSLlxqrHoMNLNrh3OXpUenCfeoAnZWFGN9dY5jWEjJ7bND7xUhmSGVibqEwiSg4cLjvoA6vYCmw4N/4HpN6R2wZyuLTFTxpANuAPS083s3IVGImOxQW9Nbokyz3Zpi9wWoSaROkvpaHBZuIhZgCLVHw+q/GOxd/PTwNdxbJr0OkVub80q87pcze+h4s0NFQcZWhCweoS2FdOooPmqCYlWemFzDnefSzBYwpmj2jid7BrTWXWS5SG+vlEtilASYjaz8FRaQQemQDdNHFRfz5LWzDPRMB/SLQSuPy7eC0H93sKTpnpQjZ4zbcMzgHiM+LCK+ZgcCys6FlL/a1r4xuus4t+REJUHk5/VppeIaCvzqh4xDdhiUQApWPsF00L4Ql/UYNWr6NAaAVFxogYJoObMFDZLu9kg6cD9oazTiZ7jXozW+/Q+a8ZjswQ0P3mUNSujVYQ6t4QdasnVqzeJh1M61J+RGeJRSpF4RTIGRjV8NySXDb3t3+jjs6ftgtgOuhVh0D0bq5/JuzKL0dfLGlwZxAgmAitrO4eAfDsA/4il2JFszscVb2wau6HJojgcJNyBe0Zhm5+QJEnewftn8M0KAIS7aReVeQDqq2yRu7p27JTCfxYJm+K4FC+MGOjnAvpelVJf1BYF7bw3ZCVIaQTm9UIeLRs3G1zJ4hITAo5MztQ==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErp+D8ITlOFi946F3/GEq+QWsDX9myFeVAwaFBLfqfJ";
    };
    tinc = {
      rsa = ''
        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEAv7l7ixKfO1VVfhfnKdVKWw5hBoNUV2hmaafmYpsHfBoSKB+X7Rus
        f5cxeR3+trAwTt9j+AQLhA2tWldg7PPq9l1JX0lNynRtWk0fkgDTBX39az/yMaSV
        xjSmDl+ZCkTzUWgKTrbYu7sCSV8gzRCkHBQxOX6yUP0fkeSZ5Gu6el22bl2KaJCh
        NxSRm7PemriKNjqMm6zLxZ3DARyHvZZssuJY0XNtZR7CU4x+Bk0xGk0XgF57hnpU
        4LirFuDIPCOym/OWF3/jvI0ghvklY+PbbcM4DJowfoRNw1NpsI/4bsZRX4gn0cTC
        uA+E5X+2ccv6nbThDvJKuSNf+uzA8vwW5Qvzat6+rZllzHfm2+LfYJYOB2/6hjYy
        OFp9sArZU6vetcAc3cz/qbjEH8I1qiEEglKsOp82RinecJrSZOirADoQ8yYY7I0V
        cGhTk9dVhkyyUO7DY7wsOlrIdc1IDfVXsGM4poDMgPxivNXOzmePQT8/kEvtyWaq
        MTto8ULdGNKfrQGGMAI1ABZdujbD6bEhTUzkvNeSw8JX/2Lo7VK+G3IfkurWn/xV
        5I9+VFnV07VSRln2KX+vIapOr0EmGBiFWswvMnrpp9p7a7c4nua7v/JZ8Ig4Fget
        7lUGznIXEIZcP3G+WEzXMzzxZIALslXJIeyZXPyoMMrygWbGZ4gxNvcCAwEAAQ==
        -----END RSA PUBLIC KEY-----
      '';
      ed25519 = "iRqfc3gAra3anWFbZ9NHAayZccoqcFNIdUWhXYCnqpC";
    };
    public = rec {
      IPv4 = "132.145.123.138";
      IPv6 = "2603:c021:8000:aaaa:2::1";
    };
    ltnet = rec {
      IPv4 = "${IPv4Prefix}.1";
      IPv4Prefix = "172.18.${builtins.toString index}";
      IPv6 = "${IPv6Prefix}::1";
      IPv6Prefix = "fdbc:f9dc:67ad:${builtins.toString index}";
    };
    dn42 = rec {
      IPv4 = "172.22.76.123";
      IPv6 = "fdbc:f9dc:67ad:${builtins.toString index}::1";
      region = 52;
    };
    neonetwork = rec {
      IPv4 = "10.127.10.${builtins.toString index}";
      IPv6 = "fd10:127:10:${builtins.toString index}::1";
    };
  };
  "oracle-vm2" = rec {
    index = 7;
    ptrPrefix = "tokyo.japan";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMDWloT27dXqxzdR7simTpNVcdb/ygfkkvUDtSR37aaDFNjRGHEO6HQ/wV831ISwZlSRZUiLkvFD9uelquHvFxwnRzDNz/Rqxc8LJMgdhYUPvJL6kA7kn7RcZe/raEVyWpRhYBHNKTcc/WL5/xuJUmJvGCTuIblXog0dtmeLn4MtrMAC+SpxkuUYLDKqhNKk9I4gdpLkr/OuceAIxiCwvJOq6gOl0wJJtFOOsHU2rTW4XNn8uTjhF/KuYEC17DGx4QQik0Vq7LXNhfjQutdLoS82OX1cCci/0ybB2p0785wK9+6QkJIDqmohb3D4Anw5P8ZCSrxKl+XCAd6hGl+QVAXdy+JYchfsS/ldxS/BS/+JHNjqjeQizuqYUiEP4CVk8yMoh7eMr/ldFCxOb78/hZSYvtPybw+tkkLqXBreMle4v/V8unkrfWFnxelmn3duHsPE/yjDPLGwJSIQzNvxKldKgj86UnxRCuRQCurcxRWNIWa/ttFnLfKY0VrKi/3uKXR0BOhVQUZdeRQ0DhOhsqFUMN+8WLQmaj3WfABV1eTFWEzmul9zQUapCVGePFsDiyCidr2UgeT/RgCmomkxndkLl/2ROwjkw7hUYqy0vRHdq5nd8i4tczdZYzVGrRsVd7qQ4VMEn/x1GnCwsa7qNsi6y2EygKU6LtxySDYhTwAQ==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzrBeumtGvE+EZ0qlHMs43DMQ+jBXawKa4ztYFS2cTb";
    };
    tinc = {
      rsa = ''
        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEAqk2NiTWBhuWGF5bVp0VIlokejJWd+waPGjt2U619L2hNxTxnPNNU
        tc+0qOKYzyKMuN5QrQAjEgLVkTGZj2LNSQX74VR6cYCuMiIzkvk0J5JbEuk5ly3b
        CPiaR2sBgpAQkN1O/YMTnZPraCB6MXJbol2G69+H0bBPpiND7uHm6+Nrsh/LlI+3
        FyIrWo5fFrNFkghRXwWa4sfphFob7RGON3xBSmSwBnIajxKKwDCVpUVX+gDqXsV7
        K/TkeitIxYPkAaYymd57bxtiIvaIoZUJ/vfsXKKfOtojJtWa+y8GZ3KVkN0wFD2+
        Kt7wng9uiqJLzk7YwLVGTJsDoFzOtqXOkuafWtEJMC6v94cWpTNJVxryyGqH5Y4J
        Ag8fs5NBGvznu5GppjW8Nhe1a5ivbhTN8Eg2bTc3+1aMrBOZRMaeP/8y4U0JXim0
        3h4Gi5fAp4weQ6zfcN34fTLk4mvxrMXFml4eEYPmNBN6PbQwp8qSMHUuFaJbv0qA
        w4QqLBmTIbi1lyRh7DXe27ANtojPrfhcz4mA0Qto6C41xHa0nJ/dHDdlXToOMnRz
        b2I4ScMka0M7jj/WUCKRbfGP4WIKP3ipi7cJ6nUU+6gayALcOkCPKoPF4vmkk1SX
        VgaMZ+52b639cRf3Eqi0JbbCo1KYnfg4+B/cDCcs26w3yY+Wwt4//9kCAwEAAQ==
        -----END RSA PUBLIC KEY-----
      '';
      ed25519 = "cKbtwcdG42qZMAt5LVfhucWbnekseHRaEuDAUIbyRpB";
    };
    public = rec {
      IPv4 = "140.238.54.105";
      IPv6 = "2603:c021:8000:aaaa:3::1";
    };
    ltnet = rec {
      IPv4 = "${IPv4Prefix}.1";
      IPv4Prefix = "172.18.${builtins.toString index}";
      IPv6 = "${IPv6Prefix}::1";
      IPv6Prefix = "fdbc:f9dc:67ad:${builtins.toString index}";
    };
    dn42 = rec {
      IPv4 = "172.22.76.124";
      IPv6 = "fdbc:f9dc:67ad:${builtins.toString index}::1";
      region = 52;
    };
    neonetwork = rec {
      IPv4 = "10.127.10.${builtins.toString index}";
      IPv6 = "fd10:127:10:${builtins.toString index}::1";
    };
  };
  "oracle-vm-arm" = rec {
    index = 12;
    ptrPrefix = "tokyo.japan";
    system = "aarch64-linux";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2ucVGO1YiyCVqwk1A5D4BoISdgPpHjx8HmjfTQ/F3A50aYwKg6fvN6qHtWq7RDg3IICKii8EgXEhVSrG8LXxkZZW8zory4y2zwGl0XMFlhCFWo19zjLsIDBV57YoIBIGlwcyhbg9gQEnVcOrJbM/5ZpVqsyXryQ+NsPBHagtYgsPk0b8if5i/0kuqu+Y1K4rhN47toGcgwK5O8iYRYmlkPvgUQHQFaaQlvii64a9Tzwct6HhRsDYzoxGl9J/yMUiom7Qbhey9E4+qHp6kAIscQirMRmevKUikdIl8vdt7c81ms4+6QA4E8lWUujqTbXAceQ3cZxzUIWfoOoMBxs2rr1OIWEhvyzGVzfcIQCdSI4qJEksDOP8dg4ulhDISqxzHTZSKkh1D/glpd0yU045dwnQrBI/9dpYjjhmuEcIlZNllQdIv383ZdgGnyQoNetNP955abVJcxteiTQTHTQBVimQNuoyHhJ31RDqEMOgbUpuVp3ucU+Vml0p0NvQ4mP4YxRrzZzFEzyw6BTYA2aWDBm8AAMUwKfFak97CeHvQ+arFRzuCRApUUDzO7Wh5w1F5GihaBNlRIGYW9j5ss01QqPZsYIb9+mJpjukFiKKL5ZKxb1pgzQIh5t3Nmq9AE2Oh1rjSmZdqcN3RYA3WUK9squaJyHUcpahJjPTjeBQu5Q==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINaMb598DMCrl3knaRaLzF5XVGCnjZSQQ5WKeYcZh88m";
    };
    tinc = {
      rsa = ''
        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEApe1NKoMICXysW1iUKzRBtLrNLxw8iQjwYstrIor4kruaxyx9Jr7s
        yj2SOwALIq7IKU5esIPcPDOTRy1PQbXmxrNpEl9OJNGAB+oK5k/H7jiK2OvRlAbu
        J1O8C+lFX0KbxPi7WWYfKEav53o2bfaRJ7+asMQVZxfBVGhtyMfgGj9XwDFPKhH/
        CD7JDbhXCbVzKKwnwDvul5mOA321YucvDfwaFYhHVs272IdyamuEL+5dBdz6SEjZ
        KRf+25m+vQ7PZ7puGg0vWcbKZ+FTVUUfD6V0Y4H0lVx8KEFKZr9QtLbfJdcKuJQW
        BDZoEJZ25uid5WB9d66LNg/K/7cKsWee+31ILf8G7OlhwOrwQlKcFEQ3jvWPNsVS
        mVftObds0kgHS7/haYLCFqrQXel1b3sW9q0xPL6yzVB87CGDQ99A9jgz9YJVCjYK
        ux15d3LSyxmbTYqSFgTBzpn9IV9PJGcDvA2Sb0KlSA4IdbedpqC2rUrl/eYB6e1Q
        bGu8qM5f0uP1yLupUFAwiJVKdqsHz867fznh9ffnfyGE+vUI2sayweraACscRROk
        1D+QFTypEC03MezSl0RPwLNIRnwsJFBoTM0idS4qKIAWD6t4pPIG6XQwWBMCRvP/
        s+Hm7MmuicPT/c2OjPyQNt53VJApkrUakhQJgQgEEAsP0YoRJvVLcE8CAwEAAQ==
        -----END RSA PUBLIC KEY-----
      '';
      ed25519 = "qrL/DMKf4YmnN3K8Co/kKqX+BUY/16O9YMeI81kr4DK";
    };
    public = rec {
      IPv4 = "158.101.128.102";
      IPv6 = "2603:c021:8000:aaaa:4::1";
    };
    ltnet = rec {
      IPv4 = "${IPv4Prefix}.1";
      IPv4Prefix = "172.18.${builtins.toString index}";
      IPv6 = "${IPv6Prefix}::1";
      IPv6Prefix = "fdbc:f9dc:67ad:${builtins.toString index}";
    };
    dn42 = rec {
      IPv4 = "172.22.76.125";
      IPv6 = "fdbc:f9dc:67ad:${builtins.toString index}::1";
      region = 52;
    };
    neonetwork = rec {
      IPv4 = "10.127.10.${builtins.toString index}";
      IPv6 = "fd10:127:10:${builtins.toString index}::1";
    };
  };
  "terrahost" = rec {
    index = 11;
    ptrPrefix = "sandefjord.norway";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDL4OQIUTdyZynG4B+/1GFjMoQKX9xq1BVyOF8spXWNcUDqPUfetgA0H5CLILvUZTyR5thM7zS5gQdn01m1qznMXoGtOQqVBTLGS6ZV8J2rO3/vwKseJYh6rNiaImWu6mEu/G6k3v3xrtan9j+Y9X+vLPGHY90uASzYv45VaU/xW/4ChDLfQZitLW3lyGz3DZqXDTZZDzLeHCMwFFYw7GcIG67E30IoDd8300wqRg3sCeTb8XwqqhA2YDn/UuTJNQTHaRCFEt5x92FILmzbT1WxFYh3UXZ6VTGZQ+OLRbqhTq1IiyaV9B4reiglyAC6P8IMjpl3yqhF+pvJodSzIi6cEutbVZ7nP61nu2InsjvHfHumh5dPSJcpYmiOFcUtyLx/YKPHbw92B1yMWai5t+Y359xgJpJvIX8Tuoeu4S/zheAD1q2/8zf/ueCBZfniTU7xrdL3KJFcyLwqEWvUr+/ZtmjodGUj6jij0cqXCaDuqqy0/+HYmvVfBSZ11aQIM1liEa4w5y2gJyNW7fz613OvHd6JXglz9FSYlSmQudNYYaLGy7ltBQfInJXwzdcO+jmZjif9pjQBPXXVXUx9SErM30Dg8//gK4OR/YxhMyReIStQkVN1OPILyOGWFSo2ryCNpjwNHzHba18jZaS7HPt8ebL4KsULZEEVKozUK8ARcw==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3gI3Xp4vuhLA7syB110Dt46tAZQvBm+TEQ7Pg25HY7";
    };
    tinc = {
      rsa = ''
        -----BEGIN PUBLIC KEY-----
        MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAoBe5yTNcbpG8RJBGJ/Kb
        w033UyMLAQ1ii3XoWkhLLwgp9frqDz2gFL0ZgkVSOE7X2KlAa11S536RL2XchMjU
        VeCYRqTbpuPAFfEr7hXrbGL5u3hjpKp3huLgXh3bHhQXfWVICRkBH399ILzTp+GI
        tVPV1WLAT0vjPqvsgIxP/3VDr5sv160hDFYX4etT50oXHHBupvzIgwfVAHPlGZ+Y
        dPBczqR5qxkwUBIPEdlsjKeu4wJAQmy/R+TAwzMFYYzmqfiSMqh2HBCR5y7hEXRo
        mU+zIcQEKOZle0Ptj12QcVfXgjiiCjQFbbmok40fhVGxmKN04lWlKn5d3euyuICq
        /MT3DmPq/VT3gT5YKTvN0ZyG4+8VBLbRy2vFfIJq/Fwfh48ukQSXzatvmt+SVUq9
        WcguMMjh+LW4zHVaACG8x7VIF4GsocguG43/2MIw08UKWhHW5VP6RPkUhxljejaR
        +9nyPdsNbdz8EB3vj52WXvNyBAGS999Yi2scZcka4e5A5+6Fz+B0q+m2wTGGYnAY
        7OA8Pw9o9vSJtHCZx+Yc/kjLjdCahABZZKanCUm8ELVLHCrY3iAv7qatrnWHj9F5
        +yMouTz7RmrZF26sSCMADmTUj2IsInWaOtgSaaml75sg1Y3BifRb7cUmDYvzoPXj
        CtJ/gWS6wt3dSlv4dLiF+5cCAwEAAQ==
        -----END PUBLIC KEY-----
      '';
      ed25519 = "3mzD95izLNxVDFoUPgl6dA7a5HYAsAglJuT3xgTxnkI";
    };
    public = rec {
      IPv4 = "194.32.107.228";
      IPv6 = "2a03:94e0:ffff:194:32:107::228";
    };
    ltnet = rec {
      IPv4 = "${IPv4Prefix}.1";
      IPv4Prefix = "172.18.${builtins.toString index}";
      IPv6 = "${IPv6Prefix}::1";
      IPv6Prefix = "fdbc:f9dc:67ad:${builtins.toString index}";
    };
    dn42 = rec {
      IPv4 = "172.22.76.122";
      IPv6 = "fdbc:f9dc:67ad:${builtins.toString index}::1";
      region = 41;
    };
    neonetwork = rec {
      IPv4 = "10.127.10.${builtins.toString index}";
      IPv6 = "fd10:127:10:${builtins.toString index}::1";
    };
  };
  "lantian-hp-omen" = rec {
    index = 100;
    role = roles.non-nixos;
    tinc = {
      rsa = ''
        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEAxOB+wflX3yAs2tl0Otr/UktPI3atUwqmTeZ4Od3t1lf9wdvs2o+L
        t0bIbwXmjtIjyVkz8M99Ls1YLOUYH4o3O7xc6GaUVaRpqd3xbWtYPQ3ifzH1EbSk
        yImFxAHZL4YHYdh0/IF3gjlmXyxCgpe79EtJyiaHJxoQdJRqICsKiRSgQVU6Uh6n
        FxqFfbQCih2xJkRfk9HhjncvnSdGmftVu/ul+NYwe6PaJwtrwAdvVovfJQSATy9Q
        XW08x2YpL2kX85ZtpiRbDnsNV/a8lRdflmtrMBuROfwUVlxfvUtBjPl0WLFxyGKL
        C7xFaLplxmgFD38HTxFGbWxXLGMfjQvgeQPYQg9KRfy754SsaFmyInkXsQYfHpPV
        PGcRBUvWWvG3JBnF+rwbcLldUlfUm8qubmsHQpG8+/gE0wTHI5jX0kw1ypo8x+6O
        VjmsCZ7EkEbZ9hvCvnluWZ7b4yWkoiS/Au8K+jbtXYkPN5l4y5ZlcVDBHrZ8uFag
        f18jXf7JAjNulJqUTs3uES7u2c2LB3F23X869Dzxri5DZGo3c8PyxTDf8IYcmbQu
        zGbS3TrywQLC4Vvsdw2zOS71OclXYUrMg7M3Vpa42FfBmhzPgLhnRZAERqQCYoPq
        WSohEWQ7COfi18pRBxFQSmcYnJF+VzDalEklQURGWzgo64Q0ABYDPIsCAwEAAQ==
        -----END RSA PUBLIC KEY-----
      '';
      ed25519 = "xjJv/DrAB/OgucjkxQ9wCtO7crW1GUXKBfJ19dXFWjB";
    };
    ltnet = rec {
      IPv4 = "${IPv4Prefix}.1";
      IPv4Prefix = "172.18.${builtins.toString index}";
      IPv6 = "${IPv6Prefix}::1";
      IPv6Prefix = "fdbc:f9dc:67ad:${builtins.toString index}";
    };
    dn42 = rec {
      IPv4 = "172.22.76.114";
      IPv6 = "fdbc:f9dc:67ad:${builtins.toString index}::1";
      region = 42;
    };
    neonetwork = rec {
      IPv4 = "10.127.10.${builtins.toString index}";
      IPv6 = "fd10:127:10:${builtins.toString index}::1";
    };
  };
  "lantian-lenovo" = rec {
    index = 101;
    role = roles.client;
    hostname = "192.168.0.141";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZcTivKNdS8+var7e60bl8JZPJhhbfHuOhmVwVt3zsoi6vOeMKjOLT+HKgvjGL6ctRB4bafdf24FdGlyWsbA7WC6Dmt7IcKVkPkMXzRfMF9KqngyYHnC5gwyraEkJ9BXZBYnAQeLKs7YQBb7LwQNXwaKsSRewyWSu//6EVqd/1NrzgOP8AXL446jjzoUizFN5f0xM/9b7wllH70VnvKVIGa2djU87QtX0XHda2yyx+GmCy9ic2qtn3Tpu0h6ex89p/ppymq4WxF5GizPF3neqp6K2EEAOfD667c+B/C8EYD8ltt3kBcOxNj7udk5ZwAmpDIf6U8gZxyaxaZ1vUWdrfw/AsQehQDi9wRr/Z77Bc57WnNI3Ib3TpcbAc+UE313Pg557WO8msyIgG2fovCrgj1Ez8eM54y/JDD6ekez8zSBNggm4D8m9MufDd9EohCP02t6rIKLrQmHAYOeKIVqwc49pF0yNk1ddJZSgMJszYY1km82V9zUtX6Kr2CoRyrJ+tWOxb8K95V/RqYC9Ll/r3hqc7uMFvgg8B0N1hIUpQDnqNQIhfz8ysjVeHrS/S3+w/Kg80TPSQhv9nXhXQ255UC2OCX5Eu9f9DYFewxBcDxKTEU52/yxkigmiYRsSOAVMdfkpGgDYPdrO8hIS++qclbeTLiW9a7PIO350fwLYX3w==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+dRFR7ZEU/XyPl4EyAsWD/cSDdWkoa2OL9A2WAMllG";
    };
    tinc = {
      rsa = ''
        -----BEGIN PUBLIC KEY-----
        MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA6PxXArlWPgPRiFSPid9r
        TUkVGtUafLw7oYyjmrio2eKY8IzNVlw3CW+4x4KnkvE1gM4mRQWX4I4IY/m5rJUk
        hbqG/1lNm3zAYUhN/H9GueeG1alob7v03DDM2qoTTMER0JbmfqVB/sniRZVH4pqi
        L23AHeO2v8ByqHcQ/f3h5+zzldlc0+hDHVXUxVp4nw3xD+2HHdEtMq+/BjekYDII
        Zoj5+dgDfFvGo9WQFSlAh6vCMxBmZayuH3zG+KxWFAqpUKX+8n3RPqKrESSg2WBH
        2shuBtn0SC86EvZV7hfSRBACswFgCC5EdRoE+GJiB2kYFtpr+o2uVA7Rra9YR5zh
        86VsYhAuFxDkXq6Vk6EBDegE72bTlm9VYGq8khiduAzJwcCOMIGK0vMy/ND1ccnq
        n1bt9UBBZbZjGYmKJa7AuJxX/dzLV8UCT0/xJG5jy72R8UNcDsO6VVK26rMrgO1H
        kgamKb6abc7QIzhzUtxmdRNGVYCBjB3B7n5XMjHyEPQBELgzRSHd/S58NJFbl30A
        2LvBHd1OtrbJAxN9DKk0BHvnJudILwDi8ttV2xNB+S6f9PysK0Yx21ot/r4SiJU7
        94y4q25+99RNuvsBNoqvCSspKpLbynkrwmEf2jPhFaGFy8UwFYn3PRHKhkhtBO+S
        3yFPl8R6cRN0C2NMqAdQqesCAwEAAQ==
        -----END PUBLIC KEY-----
      '';
      ed25519 = "3IO17i8Kr82h+aSBRjozwbL27eGoO5A+2gBI3iZ1SKE";
    };
    ltnet = rec {
      IPv4 = "${IPv4Prefix}.1";
      IPv4Prefix = "172.18.${builtins.toString index}";
      IPv6 = "${IPv6Prefix}::1";
      IPv6Prefix = "fdbc:f9dc:67ad:${builtins.toString index}";
    };
    dn42 = rec {
      IPv4 = "172.22.76.115";
      IPv6 = "fdbc:f9dc:67ad:${builtins.toString index}::1";
      region = 42;
    };
    neonetwork = rec {
      IPv4 = "10.127.10.${builtins.toString index}";
      IPv6 = "fd10:127:10:${builtins.toString index}::1";
    };
  };
}
