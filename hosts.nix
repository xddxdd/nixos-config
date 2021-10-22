{
  "50kvm" = rec {
    index = 1;
    sshPub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC/8Bj5bOf+14ZrrvUdQNxBWjl0ZZ64D4wnUw9T5rK9N";
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
    sshPub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2BWqVqhSvJFLTomqBfntFfZBE6u5jFwwK167PNf+ia";
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
    sshPub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFZz8i4n3uwXrVFyKn/QxHst3FpbYKB8uoR2YZzI4U6";
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
    sshPub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC5Oz+8RCV4amTUqd5BwLJ1gqkhyVhDItoevMwczN3Ry";
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
    sshPub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjmwZpgsCSqgs4kTRqLbkS1uRnNTLGweRqK+YrXs7Qf";
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
    sshPub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKncnTrQSX37j2kODCMb/d6+qoDgMg5zJIVgPCOYolNK";
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
    sshPub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGkP3giLGDrua7AIx/REFEjfHJBhFeFo6nPVwJK4mSQ";
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
    sshPub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA5J07sDCCcXavCT2M7daZFwQ3zdXkT6OJ94gszhWp/s";
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
    sshPub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErp+D8ITlOFi946F3/GEq+QWsDX9myFeVAwaFBLfqfJ";
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
    sshPub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzrBeumtGvE+EZ0qlHMs43DMQ+jBXawKa4ztYFS2cTb";
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
    system = "aarch64-linux";
    sshPub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINaMb598DMCrl3knaRaLzF5XVGCnjZSQQ5WKeYcZh88m";
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
