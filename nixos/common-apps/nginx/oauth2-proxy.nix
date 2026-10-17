# Disabled: common/dex.yaml + common/oauth2-proxy.yaml (oauth2-proxy client
# secret + cookie secret) were removed from the nixos-secrets repo
# (7bcc13f), and the dex issuer (login.lantian.pub) was on a vhost fed by
# the same module. Restore this file from git history once both secrets
# are re-provisioned. Vhosts that set enableOAuth keep their location
# directives but the backing socket and upstream login no longer exist.
{ }