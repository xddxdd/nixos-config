{
  pkgs,
  config,
  inputs,
  ...
}:
let
  glauthUsers = import (inputs.secrets + "/glauth-users.nix");
in
{
  systemd.services.asterisk-fax-monitor = {
    description = "Asterisk Fax Monitor";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.inotify-tools
      pkgs.msmtp
      pkgs.coreutils
    ];
    script = ''
      FAX_DIR="/var/lib/asterisk/fax"
      MAILTO="${glauthUsers.lantian.mail}"
      FROM="${config.programs.msmtp.accounts.default.from}"

      mkdir -p "$FAX_DIR"

      # Watch for new files
      inotifywait -m -e close_write -e moved_to "$FAX_DIR" --format '%w%f' | while read -r FILE; do
        [ -f "$FILE" ] || continue
        FILENAME="$(basename "$FILE")"
        BOUNDARY="$(cat /proc/sys/kernel/random/uuid | tr -d '-')"
        FILEDATA="$(base64 "$FILE")"
        {
          printf -- "To: %s\r\n" "$MAILTO"
          printf -- "From: %s\r\n" "$FROM"
          printf -- "Subject: New Fax Received: %s\r\n" "$FILENAME"
          printf -- "MIME-Version: 1.0\r\n"
          printf -- "Content-Type: multipart/mixed; boundary=\"%s\"\r\n" "$BOUNDARY"
          printf -- "\r\n"
          printf -- "--%s\r\n" "$BOUNDARY"
          printf -- "Content-Type: text/plain; charset=utf-8\r\n"
          printf -- "\r\n"
          printf -- "A new fax has been received: %s\r\n" "$FILENAME"
          printf -- "\r\n"
          printf -- "--%s\r\n" "$BOUNDARY"
          printf -- "Content-Type: application/octet-stream\r\n"
          printf -- "Content-Transfer-Encoding: base64\r\n"
          printf -- "Content-Disposition: attachment; filename=\"%s\"\r\n" "$FILENAME"
          printf -- "\r\n"
          printf -- "%s\r\n" "$FILEDATA"
          printf -- "--%s--\r\n" "$BOUNDARY"
        } | sendmail -t
        echo "Emailed $FILE"
      done
    '';
    serviceConfig = {
      User = "asterisk";
      Group = "asterisk";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
