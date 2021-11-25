{
  "50kvm" = rec {
    index = 1;
    ptrPrefix = "hong-kong.china";
    sshPubRSA = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCw1fEo3i7HViqekWReTW+jF7Nlw86ZYjez9zYq960PcuF9X/MaUjXCoUNuAs7km9AGc3RexPcX7sdth5qA2V7JH/KewARI2qiBZVCeX8DnSl27iVSkEeHFnoDQeSgrOnmQwd6N1ELpcJatGzWLA6FagobJm90HlbKW1uSwbh1TprDPtyFVLhaoyjIuTd+K3obCGZQiBY9Hmuiq0pTUM+PXgC4hRy5gsWnuLupDRSHDkPpAfXAND6decx6Xpx7GGtGQRbZ5xw0ZOPrphuVowagjMq7eQXivrc3S6LdqErdqnbVGUzV7EqJluRqWuH/j3XMUnrXxryJ/JpR7tMssc4xacRI0zD8J5jRGDDTvV+2RNarYC9bfHLVpdWHkELI1M2iNOehiYCzqO0ay5cVqEf3ynRe1HZIRp6Z7nI6dot/TjiQMx5+DGz1YTBvWL7NieZ9RjIKRus9qFZXDgK/8ZWylsVvRjemMv2Nno7l5js+7c5R9pfMO6NZiH4o8AJEus5Wx+M+A4hxXZAU7dGgcJPlhKCKZuIoVJTQnuctKN/ff+AeXNoZTM7MPdbNlzZ5ogrTXuCO9vXCohRlxXNBwGUYR4hUXF2nC+RBGCpYSUVypmpexRlbNpec6E6q+Q9BMltrQ/bRbGoNN4oateowFjiYS5uBqBUm6iXONWLNwUAdLpQ==";
    sshPubEd25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC/8Bj5bOf+14ZrrvUdQNxBWjl0ZZ64D4wnUw9T5rK9N";
    tincPubRSA = ''
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
    tincPubEd25519 = "bb5Ld0HJaC9Jzkf8ad/labkOaEAnGc8XeclpWYNZeYL";
    public = rec {
      IPv4 = "23.226.61.104";
      IPv6 = "2001:470:19:10bd::1";
      IPv6Alt = "2001:470:fa1d::1";
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
    sshPubRSA = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCfK8gSS4EXf1yGprWEMYMbEuUkQ3ngITHgTfgbx98qONTm/loSMhNqN2VM1haCjCV8h4PUAd11mPjzzci08wQD/5aSbQnrx+ku8vkT8D+hNTzdxSGTTbvOIGsfTB26JPH0cFklJTz1hQSD9mOPl6IkdP9qKtlTmTf/NrER3ClEaKRfgjgrpkJ+IvlNLIO4Lgm47xoh3Jj8TUZd+qowcHjvilE+XY9tTIYypaRp1vA6D8sgNp9aIObpYO/XzuMGabaGHJO5bPWjIw/Fw+mDctNVtWLxczis/qTGYWMUUVbmMGpmvfZQ955xnXoY4hCgbOe2gTVHJuRboGE0qTNr7WxxPfEHJdIfsSs64OeBX2QwbAs1126PAQABKYorJGsjOo+sbymVxYa6gklJXZsr7fwCcOzWzcYQvqgplipFdrwzol/KyyhHASg6mVoTdzudbBYpqYwc/a/vQpLxeDw905fq6tp8OPYTHJvW2X5ad6ld8dK0IOjbYR9YD3ls0tRCYiD+cgwdY5OVecLRdeuKfX3MyWwH1ObBqA9Ge3NrGvxirqO6Dgd0rhdc6VepHEVKCIZ86ugcJXAu5Yyr7z9IEBT7W2uCeLnl9Fb6jwHh2sd67oYt+uO/UDL2yibZWuzFxCpfPxXAnULhtF4zjQXg6hhQinaisfnVFz7mccJY1sx/xw==";
    sshPubEd25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2BWqVqhSvJFLTomqBfntFfZBE6u5jFwwK167PNf+ia";
    tincPubRSA = ''
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
    tincPubEd25519 = "YDKx1u/2OP1jf6mou65URPaVBLPLbZY1ClwYK+257tF";
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
    sshPubRSA = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5a2K6h3RbZpNnRMCHdd2wH1H3MJtiSUe0UhhE/6MnE6GJEgP1Kbt0JBVwMn/UEaKfcdHdUhSQGg95q8Z87gbuyvmXiAj1xFyqdOTrZwqyLDPj9gCe/krA/02z6O9hxaqF2FMJwudcqq0Um/ppxbHGkFH+KURzbdIH/CSBuyrqGl6v/lWbmyI4H4NpZZCo37y8NVicfTsljDxcQpQzy7iEXvwAdjqQI8HSxM+8Kx5BIuV5rAmJzF1Pb+GaZXodvVRIULa3zvfUfaEhYbKTukgvwdwMSB5eigO6WRjqJWgz9/6VCy/JRZ3UQVNRh98FZVBktj3qN4WsR/NpcmS7eFv7p1WWnWj/YjxtPTlB7jUnA8wthqCqyCOQi8ABbt/hmSqmTVbpDm/IWefsgdJIjarkreEToeEne3BSwJ/crhLejitpMjM5RvcOurpUY14kZTBwbcE8gB0TS7j73+GvXLHs7FSkeVpdDC6gW4RZkYmMcT0+H/mybASET0bgMwCakIZ8QSVGJ49JWmvXRYRNlBjoHu44HITa5R8ya2OjxLunPXbk7d9EUyyejLwq33+zRucJD7NiokKyLxfgS9zqlr1kV44ehP04mg+mHKKDxdKoY1bYlYbBXDNi/RSP65MlGBcznAECOyQAoxWLtdK0mW+tJpGkCGt2iplDoF5dJHhG5w==";
    sshPubEd25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFZz8i4n3uwXrVFyKn/QxHst3FpbYKB8uoR2YZzI4U6";
    tincPubRSA = ''
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
    tincPubEd25519 = "MsUVokv6xh1tg9SXd/rMGF6iI+7FsDCrshiYU7Ro/lG";
    public = rec {
      IPv4 = "51.77.66.117";
      IPv6 = "2001:41d0:700:2475::1";
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
    sshPubRSA = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4deGLTDTGKNoWDo5IDEK6R5wHymwdNnxrdsrL13/ayPy2B2zi5FuS6FFz0EEgaEEzD+9U6NCxxEypUU6uLjVAGlH7ILqyy0ASyIY3enGHkdv65gNIjNDymzQosR4kt5M/VmfEHJFf22tKTuV/CR6/fiCDe9xGEHbCv5r/0vzNnV4A/wijs1xoqD9x9AsUkkoo3SAUpeJljZxMD3CHNn03ROmXhnADIeX2hGiASfzwPS7tSEO9Mh7BDNJu8uRqkH3nlDIOenBHAjsuFQGed9WF03JHElyxO94AhoZwNzgeqjYxktU6pCAh2CnPKjuYeXUBSSPz/GOWkGYbgpHKOcvF5Kmu1f5H5+R1g5V04BN4PVjGvRU+iXd4hZCCHi6XqZ8v6fo15ECJ8EexTF7RIvGkzCLY/m0dtgIcBAXhzphvmzveGh1X3iS/eOMXWHugmmXnKfSA5Rl/1rU+ZcPJ1/Ju0A/6SyYy2MAJ4ZTEZGJSA9CrmrIYflr1LpRPq0WlSjChoXaz8WzBx6DxdeVDzRWLvlVbYfUa8cOalb0MVAwjCuo1pzg0ejbWj8b76p4diTEGyI7CbdRG45f7F7aqoSq3iW0CzivqZofs+5GaJgS8X7S4RTMJQWzCw93MLwyd0iiHxTeFp5RcYxL/L9HM/jQGk6fTkZ5JbHGhKOieDKtUQw==";
    sshPubEd25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC5Oz+8RCV4amTUqd5BwLJ1gqkhyVhDItoevMwczN3Ry";
    tincPubRSA = ''
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
    tincPubEd25519 = "qEvOIJwbeExJCAy4FIGpXRJdKw2Ep5Q0VAA6FkuGA+O";
    public = rec {
      IPv4 = "107.172.134.89";
      IPv6 = "2001:470:1f07:54d::1";
      IPv6Alt = "2001:470:8a6d::1";
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
    sshPubRSA = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDnpgMzepBss2c522NQot++GUiQ/TLBRwfXD8zfD2XTgnsZwAgRp6A7kCbVAu/CJ5O7UqaFYK6UhiQvPwHdkpLluy7a5ifZrI74dvkRgMg84P5YZXPxNiWWOQH8peiJFZJxG0wKC2ZVP1PmNp/OJJD22dtEXrDlu7lVzIHoIoSoT8qiqIx4VP3jJSM+t4ruuTi44Vvw0S4TjvPfENUcOKrU3nvbpliVkNpuPQROKi26Oz7o2jAVE8QME6Yvh8NVxUQTgqR5lHxBhuP2PTfnKtv6WIJf1xL5EF4WywL1uObc4w3qIAHrRj6ioZD/nFqgaQJpKO3+lmkRhz5iwXPfU19xPq5j0sDRPvoeE8F/P5QgMXJFnDR40YxBtvxUqAbNE9WR4pd0AdX0QwTrWQecAkDXpaY/L524JO5eJacbi/VCLvc3+QLNJDgOeXmIHv2oSF6Rpm2Q+/Tze9YdyjDvdhOmC59kRXx70Vs4SAArU7iF0mVbM8vTCV13DfQCUrf5XoJCX5lekhdIFnj/dju3lJr29POfThquzT6PndL9aRD0mA1ZNR1dk9wwvvv12bVoTgoEiVdSVLY934aMxO7wXSDhsivXXUrexk/lrC6nIF5y4PiORQK/5qtxFwn1tdFMNYb3j8PZcWkfOXErf+ZTarDYTXr6tciEB49WMadeJniOBQ==";
    sshPubEd25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjmwZpgsCSqgs4kTRqLbkS1uRnNTLGweRqK+YrXs7Qf";
    tincPubRSA = ''
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
    tincPubEd25519 = "Z06vhOqNMAzbUPew2sGNzFwM72HrV6gXjmNYfBU2afC";
    public = rec {
      IPv4 = "107.172.197.108";
      IPv6 = "2001:470:1f07:c6f::1";
      IPv6Alt = "2001:470:8d00::1";
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
    sshPubRSA = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0KX6XYiuX+fEvwVc4VN8i9VfKJgz3x806HMvHgNg2hnXOd0h+VYUP+TW6FwMcn6VsG/VJvPAHjB/9loKpcqZucbAHlrNUlumU/PhmvCtmQAMedfLnK2G5Nc6/reeGhLLWzFhvNJNNeUiR3BVbZgOJDtngTJCu/gx8cp4oo/2NaoUNZZgEVfUKPW6jWUD3Q0d6aIA4KBsIG/kSEEyI1UhYH34trY/CndD1L70MtW/+PmM0MeEs5F9cPONDqD5FYYW+hqBF8qqZmiYmeSMS0290/WmC9OEE+0ztEPEhlIoj232O7zOK1Bi7eoYBd7TWeHj4AsZKUSHBld+vc5r7Bq4LtvwlmM7QlCo3teK8E/S7EngjP8KuQ5LvJsf/W3W4dkfDW3eRgmDUxGWbIj+/Es4UNCW2otmv7S26aSvz3Y93TnBj+qtUD5N4A7m0LOvve5UXxS84jSlz6UE6AjGs6SFR3n0PDq5GJeQVej/x8ugz6l2N07Odju85NxhGxsVtOmrYToWZGts193DejIdLlmlkyLB4Lu1Ewj77PpI8EvLSnImOHX2cMRp9+56eYhzruQcsZvSXPtOF0LFcrVXm7h6cuy/G66kirlCcOCl28NctvMVoTJUj1A0OsuQjLILqCNKazyxNeXqFa0/HN0WcXS+YE5AddWwAnO/JdUx0/K2PHw==";
    sshPubEd25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKncnTrQSX37j2kODCMb/d6+qoDgMg5zJIVgPCOYolNK";
    tincPubRSA = ''
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
    tincPubEd25519 = "XoA62mYaC8/AV0AsyHy0b1UoDkDXjT/TZG2pSENlj8F";
    public = rec {
      IPv4 = "107.189.12.254";
      IPv6 = "2605:6400:30:f22f::1";
      IPv6Alt = "2605:6400:cac6::1";
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
      pingfinderUUID = "***REMOVED***";
    };
    neonetwork = rec {
      IPv4 = "10.127.10.${builtins.toString index}";
      IPv6 = "fd10:127:10:${builtins.toString index}::1";
    };
  };
  "virtono-old" = rec {
    index = 9;
    ptrPrefix = "frankfurt.germany";
    sshPubRSA = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDtj23Lfs8ab1zBkUmz0e0mdIWvDmWXam/wdX0r7H1hKtsjU2xLqRdGs30IrFQQw2pAdp9GEgDD+VDIXS6Ze5wv8TahpI4wPm4rjhf1LnNl7MRyOXePEGz+cM+Nyd8WRn/uKNdOVbprtr9TSbgA62XpAlaRMNKVuHFOZ5TTX/bix81tvIRu6Wb9s3ZyyiSbvz58sy2DpkQmFlv8nhWgnLhOIbTWrcSQ+dBiPgcLT+zzV/S7s+Opfr1PjRDEgBBIYgujsJzuRwBRGdOCSFU/B7KaCgvX7QO292emGPB/OlYk0cgBz2nQKzYSBC1zZ1UduHmnn7G1wTVDybaQUPGvip7mPF8rIx241fC4SSe7o7z9Gh1tLNM0d5HgJsaVTxqnuzfnTnn6AwHHB58thvuNZFIH17odXVc1Lcjmm+GzHVWjuWsTgaT1BQY9lpFDzvxIaT0MTT1ySx2/k2cc7SUBcwbUr0/MX+VXRG4zNQNgCmLkXQOhS0CBtwfGbdSkTnHT6hVpA29LlrFSufy4QcquYUPmCDTCLPloDHsZ8/6wnUCV0N5GB3UA8DfxdWbLYrwwiNeLr84i5zTOVGGGe3htZCT43JzeRVeLnTHBi+IL6lo9PlI45zpX3hr5FRzxpMgEIpaykSaEwST4VDRfIyLWc8iUrvuOQ35QrgbFzmS0uULoxw==";
    sshPubEd25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGkP3giLGDrua7AIx/REFEjfHJBhFeFo6nPVwJK4mSQ";
    tincPubRSA = ''
      -----BEGIN RSA PUBLIC KEY-----
      MIICCgKCAgEApOZu+B5IRsSMIyiZNveGYYiZz/M+Qvvr5BWMfcNWDH1TfgujrVLn
      0HIgf8QTKm1tkMkKcDBqqD6FfvX6LQsLpevkw4bNobTlugdA0U8c6t3p+dMSV34T
      eIUiEBGlN8uzdr+oHf7aQ0neNM+j5aabOQ3pTq1GADAjCpT3ZTL5bMxbaKvwJDaB
      zU22AR3zP2QGEMqY9t2TYd6wl2CCj3xT9OqYfEskgKlp0sGrnmutoJ1/PgLXAY6e
      ZmVBYV/Cruu0m6wmos1p6HwzhSlHPf3tqiIp0K0TW2eYh95PsULBgMH7+xww+gdA
      o28uGxrILr/AK5/81uzXAChdzQQo/BIFq8gnSCkqK9/OJUXUOi1izywBFCMH/wY/
      BmkvAyes8evb53fhwAnKptd+KGjRr/R4ghgxSVo8DOuUUfC8pHJTYeqDfX5qxlf7
      BuaWjr0C8BSiohh9zPipUibuAeAtCJrKj2WaYaUS1v0p2RSc2UnXWPM1C4nfJm2e
      mTkdW52/+hzBAO7I498YKGOAF0O4z4vtjUpWOe3PBWPpNm8Trim/L0EFnxBI5nFr
      p8m65wm2AQxbHDRXbT+zdJuLJWz0nzItcfU0AwWpvgFllAxkGAbxQ8fHUeAO+mhn
      BjnMuH3e4FUAlJsJX8MQ48IVnute8oemURbKEVeifXR0banq3dVRM40CAwEAAQ==
      -----END RSA PUBLIC KEY-----
    '';
    tincPubEd25519 = "LM76jAmSI3/Yav+KxG+kR+wsys5IPOLWLoYzksSD60E";
    public = rec {
      IPv4 = "45.138.97.165";
      IPv6 = "2001:ac8:20:3::433a:a05d";
    };
    ltnet = rec {
      IPv4 = "${IPv4Prefix}.1";
      IPv4Prefix = "172.18.${builtins.toString index}";
      IPv6 = "${IPv6Prefix}::1";
      IPv6Prefix = "fdbc:f9dc:67ad:${builtins.toString index}";
    };
    dn42 = rec {
      IPv4 = "172.22.76.189";
      IPv6 = "fdbc:f9dc:67ad:${builtins.toString index}::1";
      region = 41;
    };
    neonetwork = rec {
      IPv4 = "10.127.10.${builtins.toString index}";
      IPv6 = "fd10:127:10:${builtins.toString index}::1";
    };
  };
  "virmach-nl1g" = rec {
    index = 6;
    ptrPrefix = "amsterdam.netherlands";
    sshPubRSA = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCfDXWrr5hWPxEclnCSh4KwNIuiFTiO2gFSv1NU/uFgalc9Vv/HDEgECpK96OjyubzuFk2XpnAX789TdTIA51lgCpOExuectMgv1kOiyZ5MXgQQfNqhTUkWaXaUshMdn9wFdQvfX9bLCybfN2QnlpEoh5lts4wDJGeY0qmUThEt1tVgtLYk7AHaNc+TjNnmCBqVOApcgmJDIxE5GCma3fWyThFKRbSKqckNHPfGH1qkWK2REVmhlr5bAumVstmW0fdk71UhRYj5YRI1/9TwZAUFCgq27Frgv0s3VM6jXB7yAj923wm9ig2MnkouLdsCa2KoaTW20BTDokpZ7IUrI2lFOUglVQ7H1Oi/tzF8Hjfm1j7PuM1OjFtzXOke0bOFUB81mN8nLFQauS9bCK/q4Tn+ld8k5kiL+Pe3vpTdFpjBQ0zeRTyM986l3p89ckhditT/+H0hGJ2W0IOhP0oEdBoNkG6YDbO7JAEJlJTDJ6FlgkpM0MEiywFZj6EIzF5wMhHUkZABkpQf2WcnyACUb+N2T1d19XoGM9F7rV0gNJViR8BDkyjkK2R1Ss6AOCoy9FFUVo7mp8k7/x8vAYDU/BUZjIef4cZIJ/qa8jxj8zPcH8K7I2hTMNmX4Ijp8S75fvr9vzFLo5C2es0RZoVrRFZq+Ujnh2cojZHpwKl5ZTvzOQ==";
    sshPubEd25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVJfiWHLJ8pP96XuGq5plTFj5gcY7gIAqxPQHxVuJLx";
    tincPubRSA = ''
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
    tincPubEd25519 = "EGsgw69soQZI1sLY+s2BvN3FtbtTg+zUzJxuKP9fdsD";
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
    sshPubRSA = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDSLlxqrHoMNLNrh3OXpUenCfeoAnZWFGN9dY5jWEjJ7bND7xUhmSGVibqEwiSg4cLjvoA6vYCmw4N/4HpN6R2wZyuLTFTxpANuAPS083s3IVGImOxQW9Nbokyz3Zpi9wWoSaROkvpaHBZuIhZgCLVHw+q/GOxd/PTwNdxbJr0OkVub80q87pcze+h4s0NFQcZWhCweoS2FdOooPmqCYlWemFzDnefSzBYwpmj2jid7BrTWXWS5SG+vlEtilASYjaz8FRaQQemQDdNHFRfz5LWzDPRMB/SLQSuPy7eC0H93sKTpnpQjZ4zbcMzgHiM+LCK+ZgcCys6FlL/a1r4xuus4t+REJUHk5/VppeIaCvzqh4xDdhiUQApWPsF00L4Ql/UYNWr6NAaAVFxogYJoObMFDZLu9kg6cD9oazTiZ7jXozW+/Q+a8ZjswQ0P3mUNSujVYQ6t4QdasnVqzeJh1M61J+RGeJRSpF4RTIGRjV8NySXDb3t3+jjs6ftgtgOuhVh0D0bq5/JuzKL0dfLGlwZxAgmAitrO4eAfDsA/4il2JFszscVb2wau6HJojgcJNyBe0Zhm5+QJEnewftn8M0KAIS7aReVeQDqq2yRu7p27JTCfxYJm+K4FC+MGOjnAvpelVJf1BYF7bw3ZCVIaQTm9UIeLRs3G1zJ4hITAo5MztQ==";
    sshPubEd25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErp+D8ITlOFi946F3/GEq+QWsDX9myFeVAwaFBLfqfJ";
    tincPubRSA = ''
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
    tincPubEd25519 = "iRqfc3gAra3anWFbZ9NHAayZccoqcFNIdUWhXYCnqpC";
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
    sshPubRSA = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMDWloT27dXqxzdR7simTpNVcdb/ygfkkvUDtSR37aaDFNjRGHEO6HQ/wV831ISwZlSRZUiLkvFD9uelquHvFxwnRzDNz/Rqxc8LJMgdhYUPvJL6kA7kn7RcZe/raEVyWpRhYBHNKTcc/WL5/xuJUmJvGCTuIblXog0dtmeLn4MtrMAC+SpxkuUYLDKqhNKk9I4gdpLkr/OuceAIxiCwvJOq6gOl0wJJtFOOsHU2rTW4XNn8uTjhF/KuYEC17DGx4QQik0Vq7LXNhfjQutdLoS82OX1cCci/0ybB2p0785wK9+6QkJIDqmohb3D4Anw5P8ZCSrxKl+XCAd6hGl+QVAXdy+JYchfsS/ldxS/BS/+JHNjqjeQizuqYUiEP4CVk8yMoh7eMr/ldFCxOb78/hZSYvtPybw+tkkLqXBreMle4v/V8unkrfWFnxelmn3duHsPE/yjDPLGwJSIQzNvxKldKgj86UnxRCuRQCurcxRWNIWa/ttFnLfKY0VrKi/3uKXR0BOhVQUZdeRQ0DhOhsqFUMN+8WLQmaj3WfABV1eTFWEzmul9zQUapCVGePFsDiyCidr2UgeT/RgCmomkxndkLl/2ROwjkw7hUYqy0vRHdq5nd8i4tczdZYzVGrRsVd7qQ4VMEn/x1GnCwsa7qNsi6y2EygKU6LtxySDYhTwAQ==";
    sshPubEd25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzrBeumtGvE+EZ0qlHMs43DMQ+jBXawKa4ztYFS2cTb";
    tincPubRSA = ''
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
    tincPubEd25519 = "cKbtwcdG42qZMAt5LVfhucWbnekseHRaEuDAUIbyRpB";
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
    sshPubRSA = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2ucVGO1YiyCVqwk1A5D4BoISdgPpHjx8HmjfTQ/F3A50aYwKg6fvN6qHtWq7RDg3IICKii8EgXEhVSrG8LXxkZZW8zory4y2zwGl0XMFlhCFWo19zjLsIDBV57YoIBIGlwcyhbg9gQEnVcOrJbM/5ZpVqsyXryQ+NsPBHagtYgsPk0b8if5i/0kuqu+Y1K4rhN47toGcgwK5O8iYRYmlkPvgUQHQFaaQlvii64a9Tzwct6HhRsDYzoxGl9J/yMUiom7Qbhey9E4+qHp6kAIscQirMRmevKUikdIl8vdt7c81ms4+6QA4E8lWUujqTbXAceQ3cZxzUIWfoOoMBxs2rr1OIWEhvyzGVzfcIQCdSI4qJEksDOP8dg4ulhDISqxzHTZSKkh1D/glpd0yU045dwnQrBI/9dpYjjhmuEcIlZNllQdIv383ZdgGnyQoNetNP955abVJcxteiTQTHTQBVimQNuoyHhJ31RDqEMOgbUpuVp3ucU+Vml0p0NvQ4mP4YxRrzZzFEzyw6BTYA2aWDBm8AAMUwKfFak97CeHvQ+arFRzuCRApUUDzO7Wh5w1F5GihaBNlRIGYW9j5ss01QqPZsYIb9+mJpjukFiKKL5ZKxb1pgzQIh5t3Nmq9AE2Oh1rjSmZdqcN3RYA3WUK9squaJyHUcpahJjPTjeBQu5Q==";
    sshPubEd25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINaMb598DMCrl3knaRaLzF5XVGCnjZSQQ5WKeYcZh88m";
    tincPubRSA = ''
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
    tincPubEd25519 = "qrL/DMKf4YmnN3K8Co/kKqX+BUY/16O9YMeI81kr4DK";
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
}
