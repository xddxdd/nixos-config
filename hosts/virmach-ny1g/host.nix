{ tags, geo, ... }@args:
{
  index = 8;
  tags = with tags; [
    dn42
    public-facing
    qemu
    server
  ];
  city = geo.cities."US New York City";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4deGLTDTGKNoWDo5IDEK6R5wHymwdNnxrdsrL13/ayPy2B2zi5FuS6FFz0EEgaEEzD+9U6NCxxEypUU6uLjVAGlH7ILqyy0ASyIY3enGHkdv65gNIjNDymzQosR4kt5M/VmfEHJFf22tKTuV/CR6/fiCDe9xGEHbCv5r/0vzNnV4A/wijs1xoqD9x9AsUkkoo3SAUpeJljZxMD3CHNn03ROmXhnADIeX2hGiASfzwPS7tSEO9Mh7BDNJu8uRqkH3nlDIOenBHAjsuFQGed9WF03JHElyxO94AhoZwNzgeqjYxktU6pCAh2CnPKjuYeXUBSSPz/GOWkGYbgpHKOcvF5Kmu1f5H5+R1g5V04BN4PVjGvRU+iXd4hZCCHi6XqZ8v6fo15ECJ8EexTF7RIvGkzCLY/m0dtgIcBAXhzphvmzveGh1X3iS/eOMXWHugmmXnKfSA5Rl/1rU+ZcPJ1/Ju0A/6SyYy2MAJ4ZTEZGJSA9CrmrIYflr1LpRPq0WlSjChoXaz8WzBx6DxdeVDzRWLvlVbYfUa8cOalb0MVAwjCuo1pzg0ejbWj8b76p4diTEGyI7CbdRG45f7F7aqoSq3iW0CzivqZofs+5GaJgS8X7S4RTMJQWzCw93MLwyd0iiHxTeFp5RcYxL/L9HM/jQGk6fTkZ5JbHGhKOieDKtUQw==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC5Oz+8RCV4amTUqd5BwLJ1gqkhyVhDItoevMwczN3Ry";
  };
  public = {
    IPv4 = "45.42.214.121";
    IPv6 = "2001:470:1f07:54d::1";
    IPv6Alt = "2001:470:8a6d::1";
    IPv6Subnet = "2001:470:8a6d:ffff::";
  };
  dn42 = {
    IPv4 = "172.22.76.190";
    region = 42;
  };
}
