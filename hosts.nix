{
  "50kvm" = rec {
    index = 1;
    ptrPrefix = "hong-kong.china";
    sshPubRSA = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCw1fEo3i7HViqekWReTW+jF7Nlw86ZYjez9zYq960PcuF9X/MaUjXCoUNuAs7km9AGc3RexPcX7sdth5qA2V7JH/KewARI2qiBZVCeX8DnSl27iVSkEeHFnoDQeSgrOnmQwd6N1ELpcJatGzWLA6FagobJm90HlbKW1uSwbh1TprDPtyFVLhaoyjIuTd+K3obCGZQiBY9Hmuiq0pTUM+PXgC4hRy5gsWnuLupDRSHDkPpAfXAND6decx6Xpx7GGtGQRbZ5xw0ZOPrphuVowagjMq7eQXivrc3S6LdqErdqnbVGUzV7EqJluRqWuH/j3XMUnrXxryJ/JpR7tMssc4xacRI0zD8J5jRGDDTvV+2RNarYC9bfHLVpdWHkELI1M2iNOehiYCzqO0ay5cVqEf3ynRe1HZIRp6Z7nI6dot/TjiQMx5+DGz1YTBvWL7NieZ9RjIKRus9qFZXDgK/8ZWylsVvRjemMv2Nno7l5js+7c5R9pfMO6NZiH4o8AJEus5Wx+M+A4hxXZAU7dGgcJPlhKCKZuIoVJTQnuctKN/ff+AeXNoZTM7MPdbNlzZ5ogrTXuCO9vXCohRlxXNBwGUYR4hUXF2nC+RBGCpYSUVypmpexRlbNpec6E6q+Q9BMltrQ/bRbGoNN4oateowFjiYS5uBqBUm6iXONWLNwUAdLpQ==";
    sshPubEd25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC/8Bj5bOf+14ZrrvUdQNxBWjl0ZZ64D4wnUw9T5rK9N";
    tincPub = ''
      -----BEGIN PUBLIC KEY-----
      MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvKTNcERyGg4/QH2c8S/K
      IkD5YT4MwMnDYs7m3M3OFWnMjlfoPoBUSDmaWdEmZuEHjyfy4fRplHAVrowzE3Ml
      3I2lCf3ZJy2tuXgaGVUbAyxPf5wy9dGH5Y9pQgdp3w1cJgHRfyeHL7gQ9mbXXrRT
      16oCjZKqENmbBIA64Cu2Owz/U4v5c+uhp1AH+mtbb1n1gV7U0kOo6yDS0QpeM8BL
      lo4J1UUP+z8SVp5Ed8nYaaNRvM1wW8qmqQvaqFCp7pKsIqnJZ/siO+xEwQxPVV3+
      pp64XH49xUTFB9cr3hZ5zBiPzUeCON3/aHpBU0vwgOCBD8LP1I7eshmeJZTPJaW5
      NVKL3I9c1av8vi2pEhFj+xZZLLbYdVo63Vx86znBK/y9dLO4Xr1D+4AwQFweAC57
      lGAv2lWIZDVAEb26ZhVN782S5y0EmUgoxMpf6wctYYE+sUhjf7vM3uiUanDrHmMY
      RtPTo1Sc/ipRvgPEpehE9/UZ5Ff57kOsphkxIjQmXoy9raEDpHUmE/jmXILKZR/d
      oyoH2IIbKqnwWWAb5C48i8YTipZbKskooV1VOKgivwQvozYvHR68pHyqfL5yEeTt
      Z47C+Plu0efNj9khuffRmjXwaCKLDPhd7xnyDKw6qV2SBvxWAB0zALjl305c2Qcj
      qN0qOnIJAZMNjCT5MQ3QWuECAwEAAQ==
      -----END PUBLIC KEY-----
    '';
    public = rec {
      IPv4 = "23.226.61.104";
      IPv6 = "2001:470:19:10bd::1";
      IPv6Alt = "2001:470:fa1d::1";
    };
    ltnet = rec {
      IPv4Prefix = "172.18.${builtins.toString index}";
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
    tincPub = ''
      -----BEGIN PUBLIC KEY-----
      MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqzMW4yWNvkRO2/OQ8xGR
      4kjFh5mue6H7HnpSZH+UppWYKZReQEAmRdYo2gFgA/yQDYpFOLtDzicC+dyMtvwX
      PgvIU3ZmvLwteS15qcICT7njLNBRf3SEaUE2gFJZhWokuGaW/FCiQqUqrCXJNoOs
      S7dIXj1WNffuDnk0ZD9AE1YikHpCRPWv02UNsedui7XRokUGZaTMA45qZizsbrLK
      qKcy4VMqEq3IPxHxJ5sRmSRLyjVwDzR0hW0MHVJOplI8AVqPzLVnuyIOw9nTv0lc
      EMOOxc4tJnSEmZnEZCLMZciSulIJdiIT+W2FYca0baaVa6Tx4Q+OxN5SJikHQuB9
      aB6jWlfWxBslML8tK1XZZmtq0wbfbqX5DvmE9uq0cppkt3JiWuorLcV3tINizqWU
      bEU7jSgAhD/XbCCwmYuTcTHmhuiSvOrfeEt1MCPNKJQuCwJWX/eH2fJ7dZSNa5X0
      sXcNo6ps4/3JlsBLYT2tEalWRtJabKq3aqB9iObTh1wJBmDSVDcsHUQkw+Z6swt/
      GuTPfWjkmoaSnx4Q9t7FoRYE9RRJm2ERsjBQbtrd4vbmG9hpTmTGTj9FCLMQukMM
      KsItbjTLNrLUepqaz9S2nroO6TUXL9B79KA2UcbRrnjsSJF9sQImVb6qsejRnE59
      hhcd5OwetisDTRt/jmomIncCAwEAAQ==
      -----END PUBLIC KEY-----
    '';
    public = rec {
      IPv4 = "185.186.147.110";
      IPv6 = "2607:fcd0:100:b100::198a:b7f6";
    };
    ltnet = rec {
      IPv4Prefix = "172.18.${builtins.toString index}";
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
    tincPub = ''
      -----BEGIN PUBLIC KEY-----
      MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvgJ/jOYyXfRZ757JRnUe
      JjDJndC8lLLdwcaP2IUUVFQ/euQHTRHkqDrfJ4gPMbUvAYzXioC9WvqR8MCt0UN2
      X69iAtZzumG4asvNyM+rCR5wo8CpQh9umqCJrZLWLD/9B67VsMOS7kjNgJA521ks
      JSkTMgnTYb8Yo4OslRLfDvPzJ5j9D6y3ChrEtmYPxg+wuH9Jt1tsyoR97uY+P9xR
      8cwaAnALvzritYxNWq6zMPt3BsWox6q4PtwABVqxEQkT6zVgzmJ0VhWiLzlptAwE
      haSmX71U7N794J2mwHtssM/mMxdmfl1Ry/1ZpWE6ofgVQgo8mE2od/xtdegi85RP
      9+pE49kYscqXMXii2hvOs8pfnYzCksXIVVZbs0wrxJ/tXFEVMTFD/9yeXBAJ09RY
      mc7MlKcrKeN8LuKLGMRnVjx4mqOWhgdGVCQvPAoJM2s3pic9FrfoqDelBVwVP6FJ
      k7PnL981Xlw9BwIa84qkIIjEPdL9M/idCccg3cOqYfcwV5TK42amOZV84lWS2LPt
      7X1l4R5dYrrcapEtZdtimLxv9YdwS3wiX5kfa4ApHC0sQ7SImy9OekOhX+zHoAGw
      MY5g7ynXfWIOzY3jGy8KmzQu5HgYp+89sngyFPD3uplXm5zf/BnJ/CHPCIhgeizo
      qQOir44AhPKGKoDHjWsSoaUCAwEAAQ==
      -----END PUBLIC KEY-----
    '';
    public = rec {
      IPv4 = "51.77.66.117";
      IPv6 = "2001:41d0:700:2475::1";
    };
    ltnet = rec {
      IPv4Prefix = "172.18.${builtins.toString index}";
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
    tincPub = ''
      -----BEGIN PUBLIC KEY-----
      MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAyAHmI1LsfYoZHOuhP7QI
      pU3UEyGgkmMhTH751b6/8GsPIxRAuI6sMFeKLNhpRWXyv/+mE/MuYutt7cgNrwpA
      PJAQ0zdKGKPbq3qaUdjv1mCH9tHl4+p+NHfPWP03pvvUuxIFE9q0xLA2bnKVbekp
      BAklQKZMT60Su3W4ZhLYr6ouKdZj9O3c+Olp/UFWvmS4+vhNnE4V8rdKNNcaGZXZ
      XmaKWOVWmICOhpMLOZPSB1GeSKW12AvSe4fwTmk5p0TvnKJlu4U/Al1AH4Se8rIq
      ug7nlFLLacCf1AxI9DXXkpX0ugbp8oNgvg8Ow4fM7hm4OISvcFtwthlkS0+3B1ib
      LtlKE+IOKg5btIhD8FZup2kmXfza/q0rclcI6QfarXaetjgXEZpnx4pmj3X5+pi5
      qLT4uhNVH58yMMZE5gc///yyz45fha1dvbNvmiFerYdVP2sfIv8OhcLEYp35fWmo
      rP9suyCMVbZ1PGomLWt+46/8J+Sxnq1GVz14NFEQIX9dvwaN3o5FHhhN0i9wtDLL
      pDQfR1LMrWpWxIkVREXEeAR00LQ1pyDRAqUNRFPYhcHyk5pybldl8AELdS557AqP
      4Oc3skdCXlIm7fPMddBasEM3k78FLAl1RQK2q3DaXyv+iriW+by0YehZqfzDdRpW
      P1EIN+0zuzQQoo1PeXmhPrMCAwEAAQ==
      -----END PUBLIC KEY-----
    '';
    public = rec {
      IPv4 = "107.172.134.89";
      IPv6 = "2001:470:1f07:54d::1";
      IPv6Alt = "2001:470:8a6d::1";
    };
    ltnet = rec {
      IPv4Prefix = "172.18.${builtins.toString index}";
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
    tincPub = ''
      -----BEGIN PUBLIC KEY-----
      MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA15U///0WfYk+VVKrBzyC
      FhIvcIZ/2aTbZGZ/Ne/L4uu1tGx5GRU0sIX6i/LuXeDrxWCqYRUk05nf2mGBwFiG
      R5A/zbGApypr/pM9OwaQSBL05fV7PCisIuJj4oSZvasn+choHrnWWmZ568ApE+tH
      WphtzLjPB8dd1tD8t6IkKWmjerGDh9EcJwAf+ocvwpqc0AAjgUNte4+GKa4ettyy
      vg1xY9NpVzoydSWCeMAYxqP+i2m5797OMyYRPV/4KbV/0NYy5tVj0VMUdTXj+2JU
      TDtBQWOqmUYRPDwYXOLBp8FFDNy9ftjQr7rRYXKQkLS/GWq8Pnp75UUHYSxQt6iI
      jP+YmEpAhOWZXxpaucH/F5DJHWKS7k6Sr8keT1iWUacHXc2IN7bbhDmzYvFaRZ1d
      ZoDNNnjJimzCyPIKYqy3l8BzSqpsSGQufsil26bbwr+7s4swq2pumgEWjS9n3K5M
      VGBpDQwMdkP1lgZR0W3eGVscWGFbHs1K4zz1YikExGgpg61Up/5ymS4/7BdYnZsr
      jNaEXf51vQeEvAEyzBtTaftKG+wKvjR4m2m4gcQ0+VNDQoUM7voi3OPd5Ja7l2tT
      q4rz6zrFkAaDZjiy1sTJ+c4w22gQZdY+wcToQDG6r3d/sw5DIm41xs7uXjnx2r92
      5VnT6fySR2XCoeSqezabpiECAwEAAQ==
      -----END PUBLIC KEY-----
    '';
    public = rec {
      IPv4 = "107.172.197.108";
      IPv6 = "2001:470:1f07:c6f::1";
      IPv6Alt = "2001:470:8d00::1";
    };
    ltnet = rec {
      IPv4Prefix = "172.18.${builtins.toString index}";
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
    ptrPrefix = "bissen.luxemborg";
    sshPubRSA = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0KX6XYiuX+fEvwVc4VN8i9VfKJgz3x806HMvHgNg2hnXOd0h+VYUP+TW6FwMcn6VsG/VJvPAHjB/9loKpcqZucbAHlrNUlumU/PhmvCtmQAMedfLnK2G5Nc6/reeGhLLWzFhvNJNNeUiR3BVbZgOJDtngTJCu/gx8cp4oo/2NaoUNZZgEVfUKPW6jWUD3Q0d6aIA4KBsIG/kSEEyI1UhYH34trY/CndD1L70MtW/+PmM0MeEs5F9cPONDqD5FYYW+hqBF8qqZmiYmeSMS0290/WmC9OEE+0ztEPEhlIoj232O7zOK1Bi7eoYBd7TWeHj4AsZKUSHBld+vc5r7Bq4LtvwlmM7QlCo3teK8E/S7EngjP8KuQ5LvJsf/W3W4dkfDW3eRgmDUxGWbIj+/Es4UNCW2otmv7S26aSvz3Y93TnBj+qtUD5N4A7m0LOvve5UXxS84jSlz6UE6AjGs6SFR3n0PDq5GJeQVej/x8ugz6l2N07Odju85NxhGxsVtOmrYToWZGts193DejIdLlmlkyLB4Lu1Ewj77PpI8EvLSnImOHX2cMRp9+56eYhzruQcsZvSXPtOF0LFcrVXm7h6cuy/G66kirlCcOCl28NctvMVoTJUj1A0OsuQjLILqCNKazyxNeXqFa0/HN0WcXS+YE5AddWwAnO/JdUx0/K2PHw==";
    sshPubEd25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKncnTrQSX37j2kODCMb/d6+qoDgMg5zJIVgPCOYolNK";
    tincPub = ''
      -----BEGIN PUBLIC KEY-----
      MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAmhn7UdH8fnkxQLWHynLt
      i4DhAQohFPFwypAKfxoX2HN3rEc4XNJPRRnegHdrrsW0JX9ybfe+NwhCK/ISCkJf
      ecxs4CsTLh8hQx932nXfMSjCWTMD0QhZ1b5cm/KbtFvV9pDi3wZhFMH1BFidyZjw
      RDpcQ49pwqLtcHjIeUFBsBXx1BSIGWPsbxOZniV4OwpJCPMlVW8zQOAct3Oy12W5
      qHnLtUXU20TYj550XEZUXZmruvSBIOd5iHGj4RwKtK1SNJw7ca6cg4dEsPASNQqF
      PzqSIQAJRiqWvFUiUUPGExqDatGfvjrcxZ9SgbNBuisdCl53vhya9X3dtkT92vGk
      ZJS7yrbaPjUAJU7L3u1sa9Jw747BhHf+H/gq0imnqO/zg/lI5UAGc46lajrhVK/r
      9eS3kZ7S1D0xD23wUELXpzoC7pNEDiolTGR5QOIx7YF1DDpcHbRRXylfjZOlbHwx
      vftuhvsSW5WQvhnay8BgiNYg4MBWJzXLjRaO1Y2t4ScvEGVdc7d2AW3RT3JfBVtU
      WzvkZqi2q4H7NPQSMpW+hqT1TUQZPdtc8xciikgVe9ociCmOQ+5VMP17owZIwRwO
      0wyIjlTCgj40YQwa7AmubbUJGfwzBHBvUHnJ83IAZvPuEzjCOSHRf5erldVJV/Nc
      kU8HaSI+zfm/TONHIcwuObsCAwEAAQ==
      -----END PUBLIC KEY-----
    '';
    public = rec {
      IPv4 = "107.189.12.254";
      IPv6 = "2605:6400:30:f22f::1";
      IPv6Alt = "2605:6400:cac6::1";
    };
    ltnet = rec {
      IPv4Prefix = "172.18.${builtins.toString index}";
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
    tincPub = ''
      -----BEGIN PUBLIC KEY-----
      MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEApOZu+B5IRsSMIyiZNveG
      YYiZz/M+Qvvr5BWMfcNWDH1TfgujrVLn0HIgf8QTKm1tkMkKcDBqqD6FfvX6LQsL
      pevkw4bNobTlugdA0U8c6t3p+dMSV34TeIUiEBGlN8uzdr+oHf7aQ0neNM+j5aab
      OQ3pTq1GADAjCpT3ZTL5bMxbaKvwJDaBzU22AR3zP2QGEMqY9t2TYd6wl2CCj3xT
      9OqYfEskgKlp0sGrnmutoJ1/PgLXAY6eZmVBYV/Cruu0m6wmos1p6HwzhSlHPf3t
      qiIp0K0TW2eYh95PsULBgMH7+xww+gdAo28uGxrILr/AK5/81uzXAChdzQQo/BIF
      q8gnSCkqK9/OJUXUOi1izywBFCMH/wY/BmkvAyes8evb53fhwAnKptd+KGjRr/R4
      ghgxSVo8DOuUUfC8pHJTYeqDfX5qxlf7BuaWjr0C8BSiohh9zPipUibuAeAtCJrK
      j2WaYaUS1v0p2RSc2UnXWPM1C4nfJm2emTkdW52/+hzBAO7I498YKGOAF0O4z4vt
      jUpWOe3PBWPpNm8Trim/L0EFnxBI5nFrp8m65wm2AQxbHDRXbT+zdJuLJWz0nzIt
      cfU0AwWpvgFllAxkGAbxQ8fHUeAO+mhnBjnMuH3e4FUAlJsJX8MQ48IVnute8oem
      URbKEVeifXR0banq3dVRM40CAwEAAQ==
      -----END PUBLIC KEY-----
    '';
    public = rec {
      IPv4 = "45.138.97.165";
      IPv6 = "2001:ac8:20:3::433a:a05d";
    };
    ltnet = rec {
      IPv4Prefix = "172.18.${builtins.toString index}";
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
    sshPubRSA = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJhp6nMcdanAyOcWGpxP4Kw/QYFm5pgPHYCMe82hNsWV77GoTFby9zEHCnJJ0e2h0EntcsbBbv+CcWvL8bT8BhFbSLTfJDyVsDNOSoe8WrRv2LnB6oyQmk3eXe+Rl0Vu73wScDIsGaUDVxXcsSdLkV2/8GW7yt0/uIRKUpddRn78s8hWUv95kK7pIKqy+tBc0vED7B0D7S/Nwp2dHcdNh+CWkQTAsPKV8vHLvVX7is1tLjpZgtv6wXYSh8oALXv9fe3JLn05iawtvYkIfxwrKAy7Pd4nvCQe+LSOmLjfN7uscKC3imtchJWX8jH4hsm8eXiT+1CeF6Am8OtlmkHsGIicy9f5hVyDec6WYeJBheIwxwvlNAZvXfHOnj9yBjMd9KQ6Qmv6YOcg/NAIWCWDaEWhflpDdkqmGJVqQRK1Bg3UhBBfyadiRJuCdJlFOl6i3DhmC3H1/Z5SdKRR0KPLIBrvgwvERpBKqkum0XFSCLO3/Y5f+48o4Dq2XA8V5WxLQCwVTNpdynX1YctnIlQVvpA24HDAg7i1ScuvpN9ILrgQ0rm0xXec3lHkrEObvgN4t1jiO86wfpsN+U0cjDMJnQrL6UhcHq01Kr6dDBjsxAIVJcuAWuQfd7kw/IwBjLixg0iF6UzhHIxzwawYYofzvZme2nZWqNJo2hHb74heLY6w==";
    sshPubEd25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA5J07sDCCcXavCT2M7daZFwQ3zdXkT6OJ94gszhWp/s";
    tincPub = ''
      -----BEGIN PUBLIC KEY-----
      MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAyVVbrmGrDOzpt8UbgCer
      +2XJAWOQjzy2mMrNTgG/gcKvzhPCLgjDXOEW5eUAAPHa8yalJKs/n7DaxeNzJSk5
      afckTABfCZt5F8f/J7F6AIjkD+TmUVpr1mNU+bdrR4ZSiv5sy68FE90OnS0rphfe
      AajCV2kDgsz73y4gtUGU6rlESTvACvFERfakTcP8RzRk43ZPjdnbxdTk3wEyto55
      dVlwjiapDHDpIzYJnrdreed3m10wTpBG+BMq1KsFAuZ2WsBownGhEA4PgMaVoT5k
      NQ3Tn3ymA0h6ocnfcwNyyMpg90k840ANZjb/y3HBoaPdKxaV3sWfp9kriHvvlKSl
      cSXGhep086MVtnmM/24PvW02Dql2inNmLejHSF9giKbD1zX4DY7unjLt2oPfVjdt
      Y1MEaZqTZ3baNICECo89w8LumPVk66PWLmCSu6fKE1kPB7eepd/7VuNT92B62ufd
      fIWxthKXbs9exbhUwuBRpClhqIBfh4bNmIXOmoc5Ly13VDwONn+WRkQT7hiFyuwW
      oNuCkW8yGwWZ5LuvpekDXBY51717FuT3x90VKaKQmtA5wIX8wsCAtiLFJVfgZkQ2
      kMmFHt28O9xuo2wxCiR4Mc/S+JgVo+KTXxP0QbcvworO+6DfmdDREUCMDu9g9riH
      BzVRZbvZNJc1omAUpZ5yLJsCAwEAAQ==
      -----END PUBLIC KEY-----
    '';
    public = rec {
      IPv4 = "172.245.52.105";
    };
    ltnet = rec {
      IPv4Prefix = "172.18.${builtins.toString index}";
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
    tincPub = ''
      -----BEGIN PUBLIC KEY-----
      MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv7l7ixKfO1VVfhfnKdVK
      Ww5hBoNUV2hmaafmYpsHfBoSKB+X7Rusf5cxeR3+trAwTt9j+AQLhA2tWldg7PPq
      9l1JX0lNynRtWk0fkgDTBX39az/yMaSVxjSmDl+ZCkTzUWgKTrbYu7sCSV8gzRCk
      HBQxOX6yUP0fkeSZ5Gu6el22bl2KaJChNxSRm7PemriKNjqMm6zLxZ3DARyHvZZs
      suJY0XNtZR7CU4x+Bk0xGk0XgF57hnpU4LirFuDIPCOym/OWF3/jvI0ghvklY+Pb
      bcM4DJowfoRNw1NpsI/4bsZRX4gn0cTCuA+E5X+2ccv6nbThDvJKuSNf+uzA8vwW
      5Qvzat6+rZllzHfm2+LfYJYOB2/6hjYyOFp9sArZU6vetcAc3cz/qbjEH8I1qiEE
      glKsOp82RinecJrSZOirADoQ8yYY7I0VcGhTk9dVhkyyUO7DY7wsOlrIdc1IDfVX
      sGM4poDMgPxivNXOzmePQT8/kEvtyWaqMTto8ULdGNKfrQGGMAI1ABZdujbD6bEh
      TUzkvNeSw8JX/2Lo7VK+G3IfkurWn/xV5I9+VFnV07VSRln2KX+vIapOr0EmGBiF
      WswvMnrpp9p7a7c4nua7v/JZ8Ig4Fget7lUGznIXEIZcP3G+WEzXMzzxZIALslXJ
      IeyZXPyoMMrygWbGZ4gxNvcCAwEAAQ==
      -----END PUBLIC KEY-----
    '';
    public = rec {
      IPv4 = "132.145.123.138";
      IPv6 = "2603:c021:8000:aaaa:2::1";
    };
    ltnet = rec {
      IPv4Prefix = "172.18.${builtins.toString index}";
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
    tincPub = ''
      -----BEGIN PUBLIC KEY-----
      MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqk2NiTWBhuWGF5bVp0VI
      lokejJWd+waPGjt2U619L2hNxTxnPNNUtc+0qOKYzyKMuN5QrQAjEgLVkTGZj2LN
      SQX74VR6cYCuMiIzkvk0J5JbEuk5ly3bCPiaR2sBgpAQkN1O/YMTnZPraCB6MXJb
      ol2G69+H0bBPpiND7uHm6+Nrsh/LlI+3FyIrWo5fFrNFkghRXwWa4sfphFob7RGO
      N3xBSmSwBnIajxKKwDCVpUVX+gDqXsV7K/TkeitIxYPkAaYymd57bxtiIvaIoZUJ
      /vfsXKKfOtojJtWa+y8GZ3KVkN0wFD2+Kt7wng9uiqJLzk7YwLVGTJsDoFzOtqXO
      kuafWtEJMC6v94cWpTNJVxryyGqH5Y4JAg8fs5NBGvznu5GppjW8Nhe1a5ivbhTN
      8Eg2bTc3+1aMrBOZRMaeP/8y4U0JXim03h4Gi5fAp4weQ6zfcN34fTLk4mvxrMXF
      ml4eEYPmNBN6PbQwp8qSMHUuFaJbv0qAw4QqLBmTIbi1lyRh7DXe27ANtojPrfhc
      z4mA0Qto6C41xHa0nJ/dHDdlXToOMnRzb2I4ScMka0M7jj/WUCKRbfGP4WIKP3ip
      i7cJ6nUU+6gayALcOkCPKoPF4vmkk1SXVgaMZ+52b639cRf3Eqi0JbbCo1KYnfg4
      +B/cDCcs26w3yY+Wwt4//9kCAwEAAQ==
      -----END PUBLIC KEY-----
    '';
    public = rec {
      IPv4 = "140.238.54.105";
      IPv6 = "2603:c021:8000:aaaa:3::1";
    };
    ltnet = rec {
      IPv4Prefix = "172.18.${builtins.toString index}";
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
    tincPub = ''
      -----BEGIN PUBLIC KEY-----
      MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEApe1NKoMICXysW1iUKzRB
      tLrNLxw8iQjwYstrIor4kruaxyx9Jr7syj2SOwALIq7IKU5esIPcPDOTRy1PQbXm
      xrNpEl9OJNGAB+oK5k/H7jiK2OvRlAbuJ1O8C+lFX0KbxPi7WWYfKEav53o2bfaR
      J7+asMQVZxfBVGhtyMfgGj9XwDFPKhH/CD7JDbhXCbVzKKwnwDvul5mOA321Yucv
      DfwaFYhHVs272IdyamuEL+5dBdz6SEjZKRf+25m+vQ7PZ7puGg0vWcbKZ+FTVUUf
      D6V0Y4H0lVx8KEFKZr9QtLbfJdcKuJQWBDZoEJZ25uid5WB9d66LNg/K/7cKsWee
      +31ILf8G7OlhwOrwQlKcFEQ3jvWPNsVSmVftObds0kgHS7/haYLCFqrQXel1b3sW
      9q0xPL6yzVB87CGDQ99A9jgz9YJVCjYKux15d3LSyxmbTYqSFgTBzpn9IV9PJGcD
      vA2Sb0KlSA4IdbedpqC2rUrl/eYB6e1QbGu8qM5f0uP1yLupUFAwiJVKdqsHz867
      fznh9ffnfyGE+vUI2sayweraACscRROk1D+QFTypEC03MezSl0RPwLNIRnwsJFBo
      TM0idS4qKIAWD6t4pPIG6XQwWBMCRvP/s+Hm7MmuicPT/c2OjPyQNt53VJApkrUa
      khQJgQgEEAsP0YoRJvVLcE8CAwEAAQ==
      -----END PUBLIC KEY-----
    '';
    public = rec {
      IPv4 = "158.101.128.102";
      IPv6 = "2603:c021:8000:aaaa:4::1";
    };
    ltnet = rec {
      IPv4Prefix = "172.18.${builtins.toString index}";
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
