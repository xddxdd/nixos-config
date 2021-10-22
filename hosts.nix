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
