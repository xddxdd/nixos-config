# Index 1-99: Servers
# Index 100-199: Clients
#
# IPv6Subnet must be at least /96
{
  geo,
  tags,
  ...
}: {
  "50kvm-old" = {
    index = 9;
    tags = with tags; [server x86_64-v1];
    city = geo.cities."CN Hong Kong";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCw1fEo3i7HViqekWReTW+jF7Nlw86ZYjez9zYq960PcuF9X/MaUjXCoUNuAs7km9AGc3RexPcX7sdth5qA2V7JH/KewARI2qiBZVCeX8DnSl27iVSkEeHFnoDQeSgrOnmQwd6N1ELpcJatGzWLA6FagobJm90HlbKW1uSwbh1TprDPtyFVLhaoyjIuTd+K3obCGZQiBY9Hmuiq0pTUM+PXgC4hRy5gsWnuLupDRSHDkPpAfXAND6decx6Xpx7GGtGQRbZ5xw0ZOPrphuVowagjMq7eQXivrc3S6LdqErdqnbVGUzV7EqJluRqWuH/j3XMUnrXxryJ/JpR7tMssc4xacRI0zD8J5jRGDDTvV+2RNarYC9bfHLVpdWHkELI1M2iNOehiYCzqO0ay5cVqEf3ynRe1HZIRp6Z7nI6dot/TjiQMx5+DGz1YTBvWL7NieZ9RjIKRus9qFZXDgK/8ZWylsVvRjemMv2Nno7l5js+7c5R9pfMO6NZiH4o8AJEus5Wx+M+A4hxXZAU7dGgcJPlhKCKZuIoVJTQnuctKN/ff+AeXNoZTM7MPdbNlzZ5ogrTXuCO9vXCohRlxXNBwGUYR4hUXF2nC+RBGCpYSUVypmpexRlbNpec6E6q+Q9BMltrQ/bRbGoNN4oateowFjiYS5uBqBUm6iXONWLNwUAdLpQ==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC/8Bj5bOf+14ZrrvUdQNxBWjl0ZZ64D4wnUw9T5rK9N";
    };
    public = {
      IPv4 = "23.226.61.104";
    };
    dn42 = {
      IPv4 = "172.22.76.189";
      region = 52;
    };
  };
  "v-ps-hkg" = {
    index = 1;
    tags = with tags; [public-facing server];
    hostname = "95.214.164.82";
    city = geo.cities."CN Hong Kong";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQChQcbvCQd/LwHhTC44LsjMBdR6Kv8RVXWWQN363niVrZiPjFkkNNH7eqzgzUjrlhZh/gkWEoAUoJUJ/YJFJVB6HfoubS3wFA54qzY3hkcHBCLEQXiW9rG8p41WJxdjduJrOboNWKsxsuhkwaP1xCK9SBJOII6/tEZGXg6Ajvi19qR6OqKC9n7Q0+fT16QNKUn8AOCinTYaKug8Zxlgw9cKHVmAuI9+g5gpEpBkbGZnflGnHDp9p7ZbAWHInek+9HgUd0Vc2fzLKDbteTz7uTL4tQyxatgdYSOQK5yFvHhVShCxOJNBk4W6cTjhrMHvz8AuG3O0jGdQNIhS0KMzI/d37w6n/S5hXCRQoHi1X48pc0z8Kqf6ej/aAoh8rejUz1SoZJR+y2KailFAYGX4dAYPolcIBVYt+RfLeclnmybapXrv+PcslZbBUkBncPm7rK+u0b5IV1o9PPBZHklsJlA7LVtOMAGvaH1j4ZQCrnRQo+IYL/4jSqC1vnM7XjARQDAKAxnoT7FwzKPUU3Or121Vw+WaI4kCZgzJZfrQHQU2BkKYeYn7nuWTkhn0qEdHomCIeoiPiuQnF+NNH/oN+pI53Uyflv+19DcTv4jV2gq0L5+ifXonYf0e9Eujql4Fai5Cltd71ee6wa/DagcpXMd1QDCmQCVuMkB/tFp7q45OJQ==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDOr1Sq4OSSjirG3kVybjypj0s7nEtx4F23ISgxSRQvV";
    };
    public = {
      IPv4 = "95.214.164.82";
      IPv6 = "2403:2c80:b::12cc";
    };
    dn42 = {
      IPv4 = "172.22.76.186";
      region = 52;
    };
  };
  "hostdare-old" = {
    index = 13;
    tags = with tags; [server x86_64-v1];
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
  };
  "v-ps-sjc" = {
    index = 3;
    tags = with tags; [public-facing server];
    city = geo.cities."US San Jose";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4aYURWnQGEkxYueAnGgZQbrQA+SHNLRgpJZd+2J9DyKdtoqXRhSjGEAGJkqBg8alWadaYJ15wvKj5BHoTQCao6XXzuxsP35Y+xtaWJ0wJ5ZJ3/J8l4z0V/85EdYqxPInQe0cpfqTEt+lnqlOOeq4f9522OMErSzefAk/MHp+OxDWr2ZdrZVggGVFpujFdCU3ckM8NMCZUufOXX2+wXQfkMXd3umGaM3oMJl6bIEyqtLwlCWnSuMEXS5JwnZ3lhKg73PO5tRaq2FcL8RXaph9uiHWmP/ch2RTnJ4xjmbhiGQuaebtCUnfW6sDZPfOv5KOx5T4V8yBOtnyDPoS2mYKva1I9HztW4JgzWzTRonFqbaH61jFalyWPTPMt/W1gQWZEnWbCewt+jBGUApBTaxDnKXywGxyjpb7MOfdLAuDkr19p9PR04G5BOw940CXeU3K0KvLjwsQN3ptHL4t6GesNWcZ3x8cxZbvi3n58GUgGjjxTro+TXgzqPU9U7JYeFPwdgoytBSPucA4DheYCkV6/V30tX8UETpGuSzWUplyVCbbXbZYGh6ulce3X4xXn0Nir3F4bzTCQlvzTWz8zkmHW1QERmStVhMJD2K7JWpe0h97zzi+jFv9QLLnfBBKjia02s7if3sZTjk4jI59B3X9Fmf3faeNXIoDMRBJcIwFtyw==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH7jqK5IsCqMJqJUhAk2oQBQHhvxEb2q39BKNi1VsyOg";
    };
    public = {
      IPv4 = "80.66.196.80";
      IPv6 = "2604:a840:2::ed";
    };
    dn42 = {
      IPv4 = "172.22.76.185";
      region = 44;
    };
  };
  "oneprovider" = {
    index = 10;
    tags = with tags; [nix-builder public-facing server];
    cpuThreads = 8;
    city = geo.cities."FR Paris";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5a2K6h3RbZpNnRMCHdd2wH1H3MJtiSUe0UhhE/6MnE6GJEgP1Kbt0JBVwMn/UEaKfcdHdUhSQGg95q8Z87gbuyvmXiAj1xFyqdOTrZwqyLDPj9gCe/krA/02z6O9hxaqF2FMJwudcqq0Um/ppxbHGkFH+KURzbdIH/CSBuyrqGl6v/lWbmyI4H4NpZZCo37y8NVicfTsljDxcQpQzy7iEXvwAdjqQI8HSxM+8Kx5BIuV5rAmJzF1Pb+GaZXodvVRIULa3zvfUfaEhYbKTukgvwdwMSB5eigO6WRjqJWgz9/6VCy/JRZ3UQVNRh98FZVBktj3qN4WsR/NpcmS7eFv7p1WWnWj/YjxtPTlB7jUnA8wthqCqyCOQi8ABbt/hmSqmTVbpDm/IWefsgdJIjarkreEToeEne3BSwJ/crhLejitpMjM5RvcOurpUY14kZTBwbcE8gB0TS7j73+GvXLHs7FSkeVpdDC6gW4RZkYmMcT0+H/mybASET0bgMwCakIZ8QSVGJ49JWmvXRYRNlBjoHu44HITa5R8ya2OjxLunPXbk7d9EUyyejLwq33+zRucJD7NiokKyLxfgS9zqlr1kV44ehP04mg+mHKKDxdKoY1bYlYbBXDNi/RSP65MlGBcznAECOyQAoxWLtdK0mW+tJpGkCGt2iplDoF5dJHhG5w==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFZz8i4n3uwXrVFyKn/QxHst3FpbYKB8uoR2YZzI4U6";
    };
    public = {
      IPv4 = "51.159.15.98";
      IPv6 = "2001:470:1f13:3b1::1";
      IPv6Alt = "2001:470:cab6::1";
      IPv6Subnet = "2001:470:cab6:ffff::";
    };
    dn42 = {
      IPv4 = "172.22.76.113";
      region = 41;
    };
  };
  "virmach-ny1g" = {
    index = 8;
    tags = with tags; [public-facing server];
    city = geo.cities."US New York City";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4deGLTDTGKNoWDo5IDEK6R5wHymwdNnxrdsrL13/ayPy2B2zi5FuS6FFz0EEgaEEzD+9U6NCxxEypUU6uLjVAGlH7ILqyy0ASyIY3enGHkdv65gNIjNDymzQosR4kt5M/VmfEHJFf22tKTuV/CR6/fiCDe9xGEHbCv5r/0vzNnV4A/wijs1xoqD9x9AsUkkoo3SAUpeJljZxMD3CHNn03ROmXhnADIeX2hGiASfzwPS7tSEO9Mh7BDNJu8uRqkH3nlDIOenBHAjsuFQGed9WF03JHElyxO94AhoZwNzgeqjYxktU6pCAh2CnPKjuYeXUBSSPz/GOWkGYbgpHKOcvF5Kmu1f5H5+R1g5V04BN4PVjGvRU+iXd4hZCCHi6XqZ8v6fo15ECJ8EexTF7RIvGkzCLY/m0dtgIcBAXhzphvmzveGh1X3iS/eOMXWHugmmXnKfSA5Rl/1rU+ZcPJ1/Ju0A/6SyYy2MAJ4ZTEZGJSA9CrmrIYflr1LpRPq0WlSjChoXaz8WzBx6DxdeVDzRWLvlVbYfUa8cOalb0MVAwjCuo1pzg0ejbWj8b76p4diTEGyI7CbdRG45f7F7aqoSq3iW0CzivqZofs+5GaJgS8X7S4RTMJQWzCw93MLwyd0iiHxTeFp5RcYxL/L9HM/jQGk6fTkZ5JbHGhKOieDKtUQw==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC5Oz+8RCV4amTUqd5BwLJ1gqkhyVhDItoevMwczN3Ry";
    };
    public = {
      IPv4 = "216.52.57.200";
      IPv6 = "2001:470:1f07:54d::1";
      IPv6Alt = "2001:470:8a6d::1";
      IPv6Subnet = "2001:470:8a6d:ffff::";
    };
    dn42 = {
      IPv4 = "172.22.76.190";
      region = 42;
    };
  };
  "virmach-ny6g" = {
    index = 4;
    tags = with tags; [public-facing server];
    city = geo.cities."US New York City";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDnpgMzepBss2c522NQot++GUiQ/TLBRwfXD8zfD2XTgnsZwAgRp6A7kCbVAu/CJ5O7UqaFYK6UhiQvPwHdkpLluy7a5ifZrI74dvkRgMg84P5YZXPxNiWWOQH8peiJFZJxG0wKC2ZVP1PmNp/OJJD22dtEXrDlu7lVzIHoIoSoT8qiqIx4VP3jJSM+t4ruuTi44Vvw0S4TjvPfENUcOKrU3nvbpliVkNpuPQROKi26Oz7o2jAVE8QME6Yvh8NVxUQTgqR5lHxBhuP2PTfnKtv6WIJf1xL5EF4WywL1uObc4w3qIAHrRj6ioZD/nFqgaQJpKO3+lmkRhz5iwXPfU19xPq5j0sDRPvoeE8F/P5QgMXJFnDR40YxBtvxUqAbNE9WR4pd0AdX0QwTrWQecAkDXpaY/L524JO5eJacbi/VCLvc3+QLNJDgOeXmIHv2oSF6Rpm2Q+/Tze9YdyjDvdhOmC59kRXx70Vs4SAArU7iF0mVbM8vTCV13DfQCUrf5XoJCX5lekhdIFnj/dju3lJr29POfThquzT6PndL9aRD0mA1ZNR1dk9wwvvv12bVoTgoEiVdSVLY934aMxO7wXSDhsivXXUrexk/lrC6nIF5y4PiORQK/5qtxFwn1tdFMNYb3j8PZcWkfOXErf+ZTarDYTXr6tciEB49WMadeJniOBQ==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjmwZpgsCSqgs4kTRqLbkS1uRnNTLGweRqK+YrXs7Qf";
    };
    public = {
      IPv4 = "216.52.57.20";
      IPv6 = "2001:470:1f07:c6f::1";
      IPv6Alt = "2001:470:8d00::1";
      IPv6Subnet = "2001:470:8d00:ffff::";
    };
    dn42 = {
      IPv4 = "172.22.76.126";
      region = 42;
    };
  };
  "buyvm" = {
    index = 2;
    tags = with tags; [low-ram server];
    city = geo.cities."LU Bissen";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0KX6XYiuX+fEvwVc4VN8i9VfKJgz3x806HMvHgNg2hnXOd0h+VYUP+TW6FwMcn6VsG/VJvPAHjB/9loKpcqZucbAHlrNUlumU/PhmvCtmQAMedfLnK2G5Nc6/reeGhLLWzFhvNJNNeUiR3BVbZgOJDtngTJCu/gx8cp4oo/2NaoUNZZgEVfUKPW6jWUD3Q0d6aIA4KBsIG/kSEEyI1UhYH34trY/CndD1L70MtW/+PmM0MeEs5F9cPONDqD5FYYW+hqBF8qqZmiYmeSMS0290/WmC9OEE+0ztEPEhlIoj232O7zOK1Bi7eoYBd7TWeHj4AsZKUSHBld+vc5r7Bq4LtvwlmM7QlCo3teK8E/S7EngjP8KuQ5LvJsf/W3W4dkfDW3eRgmDUxGWbIj+/Es4UNCW2otmv7S26aSvz3Y93TnBj+qtUD5N4A7m0LOvve5UXxS84jSlz6UE6AjGs6SFR3n0PDq5GJeQVej/x8ugz6l2N07Odju85NxhGxsVtOmrYToWZGts193DejIdLlmlkyLB4Lu1Ewj77PpI8EvLSnImOHX2cMRp9+56eYhzruQcsZvSXPtOF0LFcrVXm7h6cuy/G66kirlCcOCl28NctvMVoTJUj1A0OsuQjLILqCNKazyxNeXqFa0/HN0WcXS+YE5AddWwAnO/JdUx0/K2PHw==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKncnTrQSX37j2kODCMb/d6+qoDgMg5zJIVgPCOYolNK";
    };
    public = {
      IPv4 = "107.189.12.254";
      IPv6 = "2605:6400:30:f22f::1";
      IPv6Alt = "2605:6400:cac6::1";
      IPv6Subnet = "2605:6400:cac6:ffff::";
    };
    dn42 = {
      IPv4 = "172.22.76.187";
      region = 41;
    };
  };
  "oracle-vm1" = {
    index = 5;
    tags = with tags; [public-facing server];
    city = geo.cities."JP Tokyo";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDSLlxqrHoMNLNrh3OXpUenCfeoAnZWFGN9dY5jWEjJ7bND7xUhmSGVibqEwiSg4cLjvoA6vYCmw4N/4HpN6R2wZyuLTFTxpANuAPS083s3IVGImOxQW9Nbokyz3Zpi9wWoSaROkvpaHBZuIhZgCLVHw+q/GOxd/PTwNdxbJr0OkVub80q87pcze+h4s0NFQcZWhCweoS2FdOooPmqCYlWemFzDnefSzBYwpmj2jid7BrTWXWS5SG+vlEtilASYjaz8FRaQQemQDdNHFRfz5LWzDPRMB/SLQSuPy7eC0H93sKTpnpQjZ4zbcMzgHiM+LCK+ZgcCys6FlL/a1r4xuus4t+REJUHk5/VppeIaCvzqh4xDdhiUQApWPsF00L4Ql/UYNWr6NAaAVFxogYJoObMFDZLu9kg6cD9oazTiZ7jXozW+/Q+a8ZjswQ0P3mUNSujVYQ6t4QdasnVqzeJh1M61J+RGeJRSpF4RTIGRjV8NySXDb3t3+jjs6ftgtgOuhVh0D0bq5/JuzKL0dfLGlwZxAgmAitrO4eAfDsA/4il2JFszscVb2wau6HJojgcJNyBe0Zhm5+QJEnewftn8M0KAIS7aReVeQDqq2yRu7p27JTCfxYJm+K4FC+MGOjnAvpelVJf1BYF7bw3ZCVIaQTm9UIeLRs3G1zJ4hITAo5MztQ==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErp+D8ITlOFi946F3/GEq+QWsDX9myFeVAwaFBLfqfJ";
    };
    public = {
      IPv4 = "132.145.123.138";
      IPv6 = "2603:c021:8000:aaaa:2::1";
    };
    dn42 = {
      IPv4 = "172.22.76.123";
      region = 52;
    };
  };
  "oracle-vm2" = {
    index = 7;
    tags = with tags; [public-facing server];
    city = geo.cities."JP Tokyo";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMDWloT27dXqxzdR7simTpNVcdb/ygfkkvUDtSR37aaDFNjRGHEO6HQ/wV831ISwZlSRZUiLkvFD9uelquHvFxwnRzDNz/Rqxc8LJMgdhYUPvJL6kA7kn7RcZe/raEVyWpRhYBHNKTcc/WL5/xuJUmJvGCTuIblXog0dtmeLn4MtrMAC+SpxkuUYLDKqhNKk9I4gdpLkr/OuceAIxiCwvJOq6gOl0wJJtFOOsHU2rTW4XNn8uTjhF/KuYEC17DGx4QQik0Vq7LXNhfjQutdLoS82OX1cCci/0ybB2p0785wK9+6QkJIDqmohb3D4Anw5P8ZCSrxKl+XCAd6hGl+QVAXdy+JYchfsS/ldxS/BS/+JHNjqjeQizuqYUiEP4CVk8yMoh7eMr/ldFCxOb78/hZSYvtPybw+tkkLqXBreMle4v/V8unkrfWFnxelmn3duHsPE/yjDPLGwJSIQzNvxKldKgj86UnxRCuRQCurcxRWNIWa/ttFnLfKY0VrKi/3uKXR0BOhVQUZdeRQ0DhOhsqFUMN+8WLQmaj3WfABV1eTFWEzmul9zQUapCVGePFsDiyCidr2UgeT/RgCmomkxndkLl/2ROwjkw7hUYqy0vRHdq5nd8i4tczdZYzVGrRsVd7qQ4VMEn/x1GnCwsa7qNsi6y2EygKU6LtxySDYhTwAQ==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzrBeumtGvE+EZ0qlHMs43DMQ+jBXawKa4ztYFS2cTb";
    };
    public = {
      IPv4 = "140.238.54.105";
      IPv6 = "2603:c021:8000:aaaa:3::1";
    };
    dn42 = {
      IPv4 = "172.22.76.124";
      region = 52;
    };
  };
  "oracle-vm-arm" = {
    index = 12;
    tags = with tags; [nix-builder public-facing server];
    cpuThreads = 4;
    city = geo.cities."JP Tokyo";
    system = "aarch64-linux";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2ucVGO1YiyCVqwk1A5D4BoISdgPpHjx8HmjfTQ/F3A50aYwKg6fvN6qHtWq7RDg3IICKii8EgXEhVSrG8LXxkZZW8zory4y2zwGl0XMFlhCFWo19zjLsIDBV57YoIBIGlwcyhbg9gQEnVcOrJbM/5ZpVqsyXryQ+NsPBHagtYgsPk0b8if5i/0kuqu+Y1K4rhN47toGcgwK5O8iYRYmlkPvgUQHQFaaQlvii64a9Tzwct6HhRsDYzoxGl9J/yMUiom7Qbhey9E4+qHp6kAIscQirMRmevKUikdIl8vdt7c81ms4+6QA4E8lWUujqTbXAceQ3cZxzUIWfoOoMBxs2rr1OIWEhvyzGVzfcIQCdSI4qJEksDOP8dg4ulhDISqxzHTZSKkh1D/glpd0yU045dwnQrBI/9dpYjjhmuEcIlZNllQdIv383ZdgGnyQoNetNP955abVJcxteiTQTHTQBVimQNuoyHhJ31RDqEMOgbUpuVp3ucU+Vml0p0NvQ4mP4YxRrzZzFEzyw6BTYA2aWDBm8AAMUwKfFak97CeHvQ+arFRzuCRApUUDzO7Wh5w1F5GihaBNlRIGYW9j5ss01QqPZsYIb9+mJpjukFiKKL5ZKxb1pgzQIh5t3Nmq9AE2Oh1rjSmZdqcN3RYA3WUK9squaJyHUcpahJjPTjeBQu5Q==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINaMb598DMCrl3knaRaLzF5XVGCnjZSQQ5WKeYcZh88m";
    };
    public = {
      IPv4 = "158.101.128.102";
      IPv6 = "2603:c021:8000:aaaa:4::1";
    };
    dn42 = {
      IPv4 = "172.22.76.125";
      region = 52;
    };
  };
  "terrahost" = {
    index = 11;
    tags = with tags; [public-facing server];
    city = geo.cities."NO Sandefjord";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDL4OQIUTdyZynG4B+/1GFjMoQKX9xq1BVyOF8spXWNcUDqPUfetgA0H5CLILvUZTyR5thM7zS5gQdn01m1qznMXoGtOQqVBTLGS6ZV8J2rO3/vwKseJYh6rNiaImWu6mEu/G6k3v3xrtan9j+Y9X+vLPGHY90uASzYv45VaU/xW/4ChDLfQZitLW3lyGz3DZqXDTZZDzLeHCMwFFYw7GcIG67E30IoDd8300wqRg3sCeTb8XwqqhA2YDn/UuTJNQTHaRCFEt5x92FILmzbT1WxFYh3UXZ6VTGZQ+OLRbqhTq1IiyaV9B4reiglyAC6P8IMjpl3yqhF+pvJodSzIi6cEutbVZ7nP61nu2InsjvHfHumh5dPSJcpYmiOFcUtyLx/YKPHbw92B1yMWai5t+Y359xgJpJvIX8Tuoeu4S/zheAD1q2/8zf/ueCBZfniTU7xrdL3KJFcyLwqEWvUr+/ZtmjodGUj6jij0cqXCaDuqqy0/+HYmvVfBSZ11aQIM1liEa4w5y2gJyNW7fz613OvHd6JXglz9FSYlSmQudNYYaLGy7ltBQfInJXwzdcO+jmZjif9pjQBPXXVXUx9SErM30Dg8//gK4OR/YxhMyReIStQkVN1OPILyOGWFSo2ryCNpjwNHzHba18jZaS7HPt8ebL4KsULZEEVKozUK8ARcw==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3gI3Xp4vuhLA7syB110Dt46tAZQvBm+TEQ7Pg25HY7";
    };
    public = {
      IPv4 = "194.32.107.228";
      IPv6 = "2a03:94e0:ffff:194:32:107::228";
    };
    dn42 = {
      IPv4 = "172.22.76.122";
      region = 41;
    };
  };
  "servarica" = {
    index = 6;
    tags = with tags; [server x86_64-v1];
    city = geo.cities."CA Montréal";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClxxprXEYNHdbrxA6P0vIzWqSaZ3/sbVacLdTolj5epwc/aklqXbBI5zDH4tac3RmEOBIVNW3PHMZcOAnwD0eo+WbCFw6qkckZBQFAAmroqI5RExonnXgTbuCqQld/kjVtmU/Wnf72yk/BQm8cWfmhPi0I9siERqkzV9lV0vow3jYPgUtA0u5kBU76iBU2X5VYv75Gim7/xC3Fe7c8Oo8LQQdMwSVfAJzC6tPMYQWo/BaDRQfHGyJqfVYq/BSCUhYev361P9gA+L0EMq3b+ohb2v2FqSwQnvbnAkWq4EVL4JpqJ8kboxGVCQTayz6kTu6BYwgvGmSKZo1/mlVEUrlbFK7hPlTH2THfR0ZLiNjJ1Ael1cjOdIRPG0EHhhafRAAYfaDRxO8UZqPg1XjzQCqmliQPBhxnr18VibRph3b+s8Xbi2prPvdPbIy4etZA3RJFbU9HyGoJxtFKWylJ/zeDoVIvdYC/6dtqTd22Aw8VNHein77RmVMInqZwVjvy7PFsnyFX2OnQk7hxghxMY7MkD1eg+Y5CuChkrV1y0pXUhczes44qMjYGkM5Zz5yRP1qLX3pyf1Sash7JDfeU9CoM2RUe1q36knNSwufia2tSUh2C1YxG9yTTxbB53NhcP4wukkmt4NG4XJWTTaX3typf0+ooNQUAB06Tal4vl0dBGw==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICD/HKWrYGo0Ip5ktr4KOWLRg+FHkRkhEi8rfFf3RifQ";
    };
    public = {
      IPv4 = "104.152.209.126";
      IPv6 = "2602:ffd5:1:160::1";
    };
    dn42 = {
      IPv4 = "172.22.76.119";
      region = 44;
    };
  };
  "lt-hp-omen" = {
    index = 100;
    tags = with tags; [client i915-sriov nix-builder];
    cpuThreads = 16;
    city = geo.cities."US Chicago";
    hostname = "127.0.0.1";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDE4CLCfkSGU7NMz4n5yp8AEdds7br0Ehe0e/RFCBz7wmqC6JeFgwapZefDwdI5av5UnBP1dqmi602OBF9yTCQ0yL1FLYTgkfWjGZSpRWOW69rQGsSGHMF/BExNQnVzmIrlMHlWtyQvDsI6tycMAiPBh2e2jcCzjGQSsHIE2d8TNN3XaA1Mht9dC7pAQqT3QUeYbUud2xWh0jCLLX+fLe9F41O9//TLLX/Lergf8Nxlu9BBM8l3t7JQBFq0QmzFSL+ODnlMCq/yEkXTOTNUNo9hzuLIr3qTX3jmYb4iF+WmeAfTcA1i0JWeMo/TilWhKsoBkYanIBCz9tctpqB2xFOWlC8UKXlgRwDRftDXTIrHMu2RvshB6bKxfV54yYAkMp7p/Alfq+4aYDjE10e0IRxB3AGsyVDH7eGWxbdDJSblu2zNaZfFmIARVU7Kc1bJHe05NmAOSwIparSh/ge4Nv3+i+ZQr6GPUv8ILHJEyn1kladwX0tubqXyR8caETe0FL0=";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKZp2mN9BALoEjCyvAK27k5AZwOmQqU6ZWi+SXvYezBe";
    };
    dn42 = {
      IPv4 = "172.22.76.114";
      region = 42;
    };
  };
  "lt-lenovo" = {
    index = 101;
    tags = with tags; [client nix-builder];
    # CPU for lt-lenovo is throttled to 50%
    # cpuThreads = 8;
    cpuThreads = 4;
    city = geo.cities."US Chicago";
    hostname = "192.168.0.6";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZcTivKNdS8+var7e60bl8JZPJhhbfHuOhmVwVt3zsoi6vOeMKjOLT+HKgvjGL6ctRB4bafdf24FdGlyWsbA7WC6Dmt7IcKVkPkMXzRfMF9KqngyYHnC5gwyraEkJ9BXZBYnAQeLKs7YQBb7LwQNXwaKsSRewyWSu//6EVqd/1NrzgOP8AXL446jjzoUizFN5f0xM/9b7wllH70VnvKVIGa2djU87QtX0XHda2yyx+GmCy9ic2qtn3Tpu0h6ex89p/ppymq4WxF5GizPF3neqp6K2EEAOfD667c+B/C8EYD8ltt3kBcOxNj7udk5ZwAmpDIf6U8gZxyaxaZ1vUWdrfw/AsQehQDi9wRr/Z77Bc57WnNI3Ib3TpcbAc+UE313Pg557WO8msyIgG2fovCrgj1Ez8eM54y/JDD6ekez8zSBNggm4D8m9MufDd9EohCP02t6rIKLrQmHAYOeKIVqwc49pF0yNk1ddJZSgMJszYY1km82V9zUtX6Kr2CoRyrJ+tWOxb8K95V/RqYC9Ll/r3hqc7uMFvgg8B0N1hIUpQDnqNQIhfz8ysjVeHrS/S3+w/Kg80TPSQhv9nXhXQ255UC2OCX5Eu9f9DYFewxBcDxKTEU52/yxkigmiYRsSOAVMdfkpGgDYPdrO8hIS++qclbeTLiW9a7PIO350fwLYX3w==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+dRFR7ZEU/XyPl4EyAsWD/cSDdWkoa2OL9A2WAMllG";
    };
    dn42 = {
      IPv4 = "172.22.76.115";
      region = 42;
    };
  };
  "lt-hp-z220-sff" = {
    index = 102;
    tags = with tags; [nix-builder x86_64-v1];
    cpuThreads = 4;
    city = geo.cities."US Chicago";
    hostname = "192.168.0.2";
    ssh = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCuvMMZMBtnht1T7dYrfyI8HZibbPDXaJRcX0EDWgue8IB/z+Fhquqfp1LjUqYklR13Oyfh7I7EIz5z0V/QlklnJPsuht+LvW7lEpk3NzSwhFrXktOzqjn+bICHL+KxZDaEHxIXm+AaXh+cH+VrrdD2WKrgMtZAv+8gvLHW51t73W5oiyiefBJfMHba7EHvRNh9enXCzhWzp4pJdlWDd1Iu80P/dmpKWSjtFlSFzXl9Pv22IbdDSsHkdNbf9vucjL69LOzB49gIQIhvIxIMdtQZPzMR4iEn0BqvVDqyXjRz7l91/btduK2mFD/JECb9VTOlx+FrKPOk+cXZDSbfNcp6a3p62iaPEXNqh+y2vXJdVMxkVKwVZOSsNpw4SRwS0E/p8F3nUj6rEaqiikMW19tct5F2As0Yi2/7aW6JBiP1Wc118GztvQyQjtAy2w3142nK4N2O2IWTa5fvO4UHk4NqnYzNZT6aTZftcT/4Y47T7zPlSZdaix9Q1oQuXZolUPD8trGo1wVgiIhFeO4vMP7xDoQ/689bWPbb8HD4tA8JD238wAyYttlsr4sa62Lz0MyGwn1XASCmQ+7Y1uKZr5j2VBpjosDfoDq01ax5QDt8MdkBSfml8QtY9jBpq82t89PVXXoefkndZAFvuYfYyaG6g5pQ/3BUnWlfvPQ4ekZfIw==";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHq9gnvAZdEt84vZf83s4+T+3AhPVY/xz2o5qbqR8ftx";
    };
    dn42 = {
      IPv4 = "172.22.76.116";
      region = 42;
    };
  };
}
