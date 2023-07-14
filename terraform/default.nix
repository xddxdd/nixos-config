{
  config,
  lib,
  ...
}: let
  stringVars = {
    "email" = false;
    "uptimerobot_api_key" = true;
    "uptimerobot_telegram_target" = false;
  };
in {
  terraform.required_providers = {
    uptimerobot = {
      source = "private.lantian.pub/xddxdd/uptimerobot";
      version = "1.0.0";
    };
  };

  variable =
    lib.mapAttrs (name: value: {
      description = name;
      type = "string";
      sensitive = value;
    })
    stringVars;

  provider.uptimerobot.api_key = "\${var.uptimerobot_api_key}";

  resource.uptimerobot_alert_contact.email = {
    friendly_name = "\${var.email}";
    type = "e-mail";
    value = "\${var.email}";
  };

  resource.uptimerobot_alert_contact.telegram = {
    friendly_name = "Telegram";
    type = "telegram";
    value = "\${var.uptimerobot_telegram_target}";
  };

  resource.uptimerobot_monitor.blog = {
    friendly_name = "Blog";
    type = "http";
    url = "https://lantian.pub";
    interval = 300;
    alert_contact = [
      {id = "\${uptimerobot_alert_contact.email.id}";}
      {id = "\${uptimerobot_alert_contact.telegram.id}";}
    ];
  };
}
