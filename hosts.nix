{
  "50kvm" = rec {
    index = 1;
    tincPub = ''
      -----BEGIN RSA PUBLIC KEY-----
      MIICCgKCAgEA2sXb2Z+s5KmPgbBDPs3tr/SHyF11/Xev2lYFb+1Gcm/zmnbjY/sE
      nIxArZpKqHIgFEXQHkTSX21Oh/UNWEXCNdpFBnClhpqynQae7kqULFo9Rp5u6PXX
      +UaHR/jMaj1itBVb019c7G+q6uwAxp9S5Qb7I/QqL2bizhpUUvYsM2N9TGHwmdq0
      /Ju73q+bjlpS/SyD03podA7dsZMNKlgFhpesKR6qiyd2jHVJuO1no97Hw1lN8Nut
      w5fh+NTVagbyQOsMxKIu5TB6GW8+zKmC9FDxBL53rgPZWsUQomxKmj0Yg8GQLCS0
      JqM2+jKEYOycczWRmH13o4/RySW5cl4CNT4p5sRbNh4m04BjnFNypsF0gAKQ/249
      pa9ESWqrr8hCde6AUwCK5OTg6qFezlOCCcJB6kKQpT0uulkowsBsZrXavrFlLAbS
      828z7uFiUgAQFPg9SxOzyjNUkRs9tI1dNSv3RxlS7457vOfep7RU5WlxbF5IMRy0
      Et2Iy0IvhTxtDq8/69+ufpAvVgiIohS0iCHWVv/FPG+jN04b41J4KUALVLb+OisA
      6hGdWvR0pPhY6ZUM9LlEf1ZCPrhe7a8NP0QAM02qUhLX6DLckVQoj8/4cGXAyWLq
      GUnqGiaDoO4eoy3U+DARgoaXqQIThoVeiIWQ8c6SHF+/2cbzfd1hiG8CAwEAAQ==
      -----END RSA PUBLIC KEY-----
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
    tincPub = ''
      -----BEGIN RSA PUBLIC KEY-----
      MIICCgKCAgEA6HK94gg7Vu+Knt0Xmp3J34ZrTFt46pieaSYSVD7hxTxXx4KLnuWT
      NnKzQ+Xfjefi9e8CrCEDWRMhoHL280LQ6EiL8REMEd6ygd7cnAhyxw5tgiDau/rw
      7K+A0nqbYzowHWY4C8iO8itjNuvWuyDCQPn3/uIkmdq4WiT51pv6ogjkC8T14u/N
      uJGoK/F0VKntAC9bDRya7+1S66ewhurL5vYRKfkpHEIJntHEK+h2HiLYr/uB98al
      AKDO4Y+7HADmXoMbxnR/JLldwn/Ri8BAHB3HRdWA5RukeR7hDtJSuoXn0mJnK7IB
      1Qfrz58c1W1Ik9KOweGew97wgmBQbX2wpYNGGduKiXwylOdlcvhiMJC7CKUkwf61
      o48t3Qzgegb5UcqH37X7jYOZ6pHw5jTfBPR9jb2QvqpJ/KCixYeBnZp8be9MQsVr
      1zXYzatmvWsvy4qihJkDZMixyslo6VsAcqrPKLtfLmeHP+QTEUD2agcH8P2LiO5b
      UJshLS0uFHlX6B6K7hbAsj6DXnbIjk57gOQh+2m4k6fII75nPpPWLgX8LlFqPxK2
      vRFoMAG3PTnuWovElZAsu6X6svWgdujc8VN8ja7d5wNs00HaD71xc/X24yjVl6gv
      ehmcbEWLq/eFX122Ob33i9DOV1ZuxriKJ9pq0DibX/fel9qE7c/OPD8CAwEAAQ==
      -----END RSA PUBLIC KEY-----
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
    tincPub = ''
      -----BEGIN RSA PUBLIC KEY-----
      MIICCgKCAgEAuxzwE0eBifxI0qwdVmXEXdtL/wo2uECRTixbyetVm5YRe6lcXOIE
      Ov3RKJie/mSHlCSOOToAiWp4GnRE6i59VYW1x9HvTT6jMKhTsVVt1xJPTwZxwjsX
      spwChmifIqy7l7ENKFNsYRcwyNSZLPbCo/VuATE4PXNm5TRfMc+7ABr8g011Xngg
      1EjHWOLjlFR6pLXtk/C2AAK5gDqWjWQDwuo9bEW1njWpmX4WPGX8d29f+08LYgzO
      6LYm6BVU9/QeQHzQphB5ZiSTHIg//+mVQfXkujxnMdCpNury/sKY4rBNryjlLy4I
      BeuY4WbFiqx6smvAKZrCqTxAP55N2wyOEM53CcGZ+PCMDV/n60xNWQEC+jQ1cA3Q
      3ebE66cPPZrGHqe+kRzlIs7lbkrhGZIO67A6Y2AqCbN+bBkCaxPtX1XL0CS8e5w9
      3VdCaoS2VZAt9Ty1N0nAqbZvCU/OyEuJG2micF+s1PLxEUd3mVwXWmVFC0dqqSsc
      AOxbfxxN87sn3sNgThEbvT0w6r6AlgsMLNFErOJ6w466PLmrVXC8ku9W6cwsWfV2
      jyNKm8K+slaOjbY7/GGRf+eqenB0fIAek/AB03YRfEVnlKXt7W9+s/zw95uwItlP
      NFcZux4BZdomn6XNDYsYUB2I8iBI/mOT/EgeXDrhpvSix5KqemRWM+kCAwEAAQ==
      -----END RSA PUBLIC KEY-----
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
  "virtono" = rec {
    index = 2;
    tincPub = ''
      -----BEGIN RSA PUBLIC KEY-----
      MIICCgKCAgEAr1f3QBcRnwzSVK3VwE/o+MX8xNP++AvrYxOievSIG9DlNvtXx0FY
      lSB+u0bZRkVtaIPqfR8y6RpOnE5TxTX+cosKw9hxhSRVamb0xhDd0S/BtEVOSpQj
      1aTW1fDYIARXDUYG0JIPqLwclrji9c406uu+YGriUTK649RTB8XGS4xIYetrmYXP
      NdXPcKgsEploE+cq715266hT/6ZDLadkasuvyFihW6QArXb/UWMjyaTiiusaYCll
      VM5Qv/7+VijzxI+soE8h1d9O/afF8Pb8i+R0w1g+Aac+jI8ucs2+LBAnw/AC7WOS
      ZL9EGX/oMdUlU6Js8fA4/BwJkdOpaiqTOWyRwcDqWFsRwlwKBD26ls4q0EJQLWkf
      CbdHLhbdKqXw+KIbGkR8KFXh+MoIiKQRi+CSb2qYWwSyQwzq7gRDvsbzy1DJCUkB
      YiXBPsW/CSL2CdHtqaYCAB8BaFoB0+sFKMtBxk53QI2NXdXSKwl3q5DCBVoDJAUz
      j07hncoMjTQOHImGyKoRpR20GCAOp0muoiDSZ4q2wP97dF/OT45tqIif1Ms87SPN
      H0VAkrHURisLpYY2xHc8d42fgTTU7mdl0Xh89dr0eJ5Ihnsg/HZbG4Ur/RwboGR9
      PFK+7k/JehNXaph5eiXPQa6qEz6kUWSWnlogY0MGrMt8witwe4b+vYsCAwEAAQ==
      -----END RSA PUBLIC KEY-----
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
  "virmach-nl1g" = rec {
    index = 6;
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
    tincPub = ''
      -----BEGIN RSA PUBLIC KEY-----
      MIICCgKCAgEA1UoOx7GHS6vBxEnuLIBie/EikQHbgpS6DBtap2DJ7zmVFCWeC63t
      wiqzm/DCyV7fc95GgfbeEHxkQcYklTKNRK6I/FffIrHP4wd4DUeRxRFvU4R/SpAI
      /UEMhbhxGW2OEddFkNgeBEbrFF1HQHzvU8kwJ49DPcYWzs12lo3MWMVUGKdehpXS
      giewdNMlEZj1eykBNe2Xl2/X1v7GSO/2pLr2UWgQcm92APX4WD6NufI/mvs1lOjQ
      eTkNRIyb5vjEUlrsoyEyw+PEFGPlZzioirZ1C0w87VB7P7wuKOBUWE0yxTXvbriJ
      favq5ZMd4vc5XwELi2iu2nCzh6gk2V5viBxnN65SOkNck+Q964gJRW3kK8AI1vCI
      0QeQ4TeO1UTfIGBomoOOmOUGhwfpfLZ1FMS5Jo6He/FQZQQUpXzQAtjx4hMYb2gs
      03G8MSe1HIkIyP/BaAhZ4nlLGURaB3hv/hJut0aJiz6V/yDOn4OFy9j8JXNIiTd7
      RrzKUvasGXWKpIqNQFbs51Wjzh4dUAZRN7gsUTIbAp/dvCZPTjq90/8fV1PUQsOY
      NngtFZWp78RJI43Vj/q/5aGjclUk4OndIh/c/YDHifFYwpfzX/DfZZt9taI8O287
      BtFK5IjgGLQzj++GNhR6dN0hdtdKIGzpE4ZyPekgf2DI3zYtw077XH8CAwEAAQ==
      -----END RSA PUBLIC KEY-----
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
    tincPub = ''
      -----BEGIN RSA PUBLIC KEY-----
      MIICCgKCAgEAoKFyIdtRvNnPdi9s/cvpd32apQtf519AauXUiq+UPPAQHFqCWYCP
      l/eyY8iAqVMSBvOut7LTYSCHFaH/K2rcIz9IQpDFi31Ev2VWqzyX1bfa+Lk5LgFb
      azxhl/g4i3AU3+bksuHpC+4F9JihlLiM3VJUOnE6mmF050vGnzpFdg7vrs8avOKF
      +OuSt8tHvYzK/EUWHOUW/kSskIQ7Xxl+Mr8D6/EzvIlAOsCO6BuvTFdCMe3ghAe4
      LQKy6xa9dryDEbn7fKHmmJAK0uGpBvgpQPSORcwYfJijttf9sjwaKW+u3uUXGK5C
      p1GpWuKDV9yVSCwyll1/e1ADPo7yvqcvQDSFbBxkNj3dM4odLEqkq8dRYbxqJNVA
      R6ocjOgtMmYKiuRQ5tvPbAXpE0Dzaq9Az4hR7rhjbZv7hcDKAm0Q0BOMzAKER66E
      ZFPDOpJGJy6k5rZGA6qrqazF7MYTs03GDUp6wyX1w+vz5xb7f1CRGSzMzLGKo4ri
      3lWRiEtQt889sTtIVOw4AUO3b0sXTUDdDa3cs6aB81NnDOcjgRlF7QjHvab7MO6e
      RKGoC+0P6uCkhIP2MCTz9D61NP/bFBxQrpTCdovQ68XX0WhYr6MPn4bUZkbgIzaJ
      j7yN45MVrrisS5ZTiZhx7kq3KDQ9dhezZOOryDvvJy2bXsy4e8XX668CAwEAAQ==
      -----END RSA PUBLIC KEY-----
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
    tincPub = ''
      -----BEGIN RSA PUBLIC KEY-----
      MIICCgKCAgEAyDjdmYv6wOMnt/2X003oAuAsubuFVgRAjOJTTUy/Lt7KlPT8MPXS
      nFmBhu5BPfdNkDLj8SFuvEHWzHcruqcuTYa1S7FzpLy+8XXUb8GkI4kYG1KXMV2e
      jSLLTm7mgAaW86cghvaR6D3gHYpeS6RmcbMUmg1dQ2VtqRtzThlVkJCNs1OAXyVn
      WJwsM3lYuNG2SXSbNokN+ubYONy8bNOknl9DMZKG5cRkdeJgkXv1N0JgNEZ31bE9
      BCtz9eUmiGIPijxWsYZlBXF0vYEoWZCWjzSxxjqCQJTDjfu6jGr9s/8UwC31xjyz
      BwrQrwk8fWKihJZLYdh0EqBoJjlxRgyOIuyMmIIkzA+oajn1mT7biubPvGLvQZbQ
      NuFYURdM7I9Kigyl2zqtFbQp/FLSmstrT7Jq/rs3CEX1mOHwhrjOYGD9XK34GjlB
      oGttclCne6vZSbHzyFz4pnJm94TuDU7bruBIMQ4Nxot5mh1Bmm2YPh5GSaxpvrRp
      Cq2IPFqSQmfBjDMtJzU9YX5w7TPaOrg5PyFMlOKSbxiOGsVlHmgEP8ih+XiId90a
      wZt2o2ZsCmIu2w4wfPYpLHKEb8V9p7edTvmb7BmeXw6Cg5mikEKU67wxlSzKUHXG
      cYPGdqTApPp+W9Quvyz2DmnHqFinVcaLChhK6Jtzo2p9Eu/LB+qq5V8CAwEAAQ==
      -----END RSA PUBLIC KEY-----
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
