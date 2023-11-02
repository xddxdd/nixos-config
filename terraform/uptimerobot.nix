{
  config,
  lib,
  LT,
  packages,
  ...
}: {
  terraform.required_providers = {
    uptimerobot = {
      source = "private.lantian.pub/xddxdd/uptimerobot";
      version = packages.xddxdd-uptimerobot.version;
    };
  };

  variable = {
    "uptimerobot_api_key" = {
      description = "UptimeRobot API Key";
      type = "string";
      sensitive = true;
    };
    "uptimerobot_telegram_target" = {
      description = "UptimeRobot Telegram Target";
      type = "string";
      sensitive = false;
    };
  };

  provider.uptimerobot.api_key = "\${var.uptimerobot_api_key}";
  provider.uptimerobot.cache_ttl = 86400;

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

  resource.uptimerobot_monitor =
    {
      blog = {
        friendly_name = "Blog";
        type = "http";
        url = "https://lantian.pub";
        interval = 300;
        alert_contact = [
          {id = "\${uptimerobot_alert_contact.email.id}";}
          {id = "\${uptimerobot_alert_contact.telegram.id}";}
        ];
      };

      utils_oracle_lb = {
        friendly_name = "Utils/Oracle LB";
        type = "port";
        sub_type = "https";
        url = "oracle-lb.lantian.pub";
        interval = 300;
        alert_contact = [
          {id = "\${uptimerobot_alert_contact.telegram.id}";}
        ];
      };

      utils_oracle_nlb = {
        friendly_name = "Utils/Oracle NLB";
        type = "port";
        sub_type = "https";
        url = "oracle-nlb.lantian.pub";
        interval = 300;
        alert_contact = [
          {id = "\${uptimerobot_alert_contact.telegram.id}";}
        ];
      };
    }
    // (lib.mapAttrs' (n: v:
      lib.nameValuePair "blog_${LT.sanitizeName n}" {
        friendly_name = "Blog/${n}";
        type = "http";
        url = "https://${n}.lantian.pub";
        interval = 300;
        alert_contact = [
          # {id = "\${uptimerobot_alert_contact.email.id}";}
          {id = "\${uptimerobot_alert_contact.telegram.id}";}
        ];
      })
    LT.serverHosts);
}
