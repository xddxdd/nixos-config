_: {
  # Rule priorities are local to each chain; equal priorities retain definition order.
  firewallPriorities = {
    early = 100;
    preService = 200;
    service = 300;
    terminal = 400;
  };
}
