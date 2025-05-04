{ tags, geo, ... }:
{
  index = 102;
  tags = with tags; [
    exclude-bgp-mesh
    qemu
  ];
  cpuThreads = 4;
  city = geo.cities."US Seattle";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCuvMMZMBtnht1T7dYrfyI8HZibbPDXaJRcX0EDWgue8IB/z+Fhquqfp1LjUqYklR13Oyfh7I7EIz5z0V/QlklnJPsuht+LvW7lEpk3NzSwhFrXktOzqjn+bICHL+KxZDaEHxIXm+AaXh+cH+VrrdD2WKrgMtZAv+8gvLHW51t73W5oiyiefBJfMHba7EHvRNh9enXCzhWzp4pJdlWDd1Iu80P/dmpKWSjtFlSFzXl9Pv22IbdDSsHkdNbf9vucjL69LOzB49gIQIhvIxIMdtQZPzMR4iEn0BqvVDqyXjRz7l91/btduK2mFD/JECb9VTOlx+FrKPOk+cXZDSbfNcp6a3p62iaPEXNqh+y2vXJdVMxkVKwVZOSsNpw4SRwS0E/p8F3nUj6rEaqiikMW19tct5F2As0Yi2/7aW6JBiP1Wc118GztvQyQjtAy2w3142nK4N2O2IWTa5fvO4UHk4NqnYzNZT6aTZftcT/4Y47T7zPlSZdaix9Q1oQuXZolUPD8trGo1wVgiIhFeO4vMP7xDoQ/689bWPbb8HD4tA8JD238wAyYttlsr4sa62Lz0MyGwn1XASCmQ+7Y1uKZr5j2VBpjosDfoDq01ax5QDt8MdkBSfml8QtY9jBpq82t89PVXXoefkndZAFvuYfYyaG6g5pQ/3BUnWlfvPQ4ekZfIw==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHq9gnvAZdEt84vZf83s4+T+3AhPVY/xz2o5qbqR8ftx";
  };
  zerotier = "fb4c304816";
}
