# Disabled: common/smtp.yaml was removed from the nixos-secrets repo
# (treewide: remove all secrets, 7bcc13f), so msmtp has no credentials and
# cannot send mail. Restore file contents from git history, re-provision
# common/smtp.yaml, then revert this change.
{ }