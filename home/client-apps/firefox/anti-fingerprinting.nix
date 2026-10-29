{
  lib,
  pkgs,
  osConfig,
  LT,
  ...
}:
let
  # Baseline: the complete prefs dict invisible_core (nvfetcher-pinned
  # release) hands the patched engine through translate_profile_to_prefs. The
  # engine's declaration gate refuses to launch unless the persona is declared
  # whole, so the baseline stays complete; the overrides below touch only
  # host-specific or user-choice values. Timezone and language follow the
  # host system (i18n.defaultLocale "zh_CN.UTF-8" -> BCP-47 "zh-CN").
  generateBaseline = pkgs.writeText "generate-baseline-prefs.py" ''
    import json
    from invisible_core import prefs
    from invisible_core._fpforge import generate_profile

    profile = generate_profile(2547)
    gen = prefs.translate_profile_to_prefs(
        profile,
        locale="${builtins.replaceStrings [ ".UTF-8" "_" ] [ "" "-" ] osConfig.i18n.defaultLocale}",
        timezone="${osConfig.time.timeZone}",
    )
    # The branding archive URI is NOT emitted here: its value embeds a store
    # path, and builtins.readFile scans file contents for store references -
    # with the URI present the prefs.json string would carry a Nix string
    # context, which builtins.fromJSON refuses (forceStringNoCtx). The value
    # is declared with proper context in the overrides instead.
    gen.pop("zoom.stealth.branding.archive", None)
    with open("prefs.json", "w") as f:
        json.dump(gen, f)
  '';
  baselinePrefs =
    pkgs.runCommand "invisible-firefox-prefs-${LT.sources.invisible-core.version}"
      {
        nativeBuildInputs = [
          (pkgs.python3.withPackages (
            ps: with ps; [
              maxminddb
              platformdirs
              psutil
              pysocks
              requests
              tzdata
            ]
          ))
        ];
      }
      ''
        export PYTHONPATH=${LT.sources.invisible-core.src}/src
        python3 ${generateBaseline}
        mkdir -p $out
        mv prefs.json $out/
      '';
  baseline = builtins.fromJSON (builtins.readFile "${baselinePrefs}/prefs.json");

  # The branding archive a page reaches through chrome://branding/content/ and
  # resource://usercontext-content/branding/; it only exists in the
  # invisible_core source tree (the engine binary ships no zip). Declared here
  # as a proper context-carrying string instead of inside the generated JSON
  # (see the comment in generateBaseline).
  brandingArchive = "file://${LT.sources.invisible-core.src}/src/invisible_core/branding/official/branding.zip";

  # Real display geometry per host, measured on the machine itself
  # (kscreen-doctor: panel mode, logical geometry under its scale, and the
  # configured lantian.hidpi). Hosts without an entry keep the sampled
  # persona values untouched.
  panels = {
    "lt-hp-omen" = {
      width = 2560;
      height = 1440;
      refresh = 165;
    };
  };
  panel = panels.${osConfig.networking.hostName} or null;
  screenOverrides =
    if panel == null then
      { }
    else
      {
        # Engine semantics (dom/base/nsScreen.cpp): screen.width/height are
        # handed back directly as a CSSIntRect, i.e. CSS pixels - matching
        # real Firefox on X11/XWayland (X screen at native size, DPR from
        # Xft.dpi). KWin rounds logical size up: 2560/1.5 -> 1707.
        "zoom.stealth.screen.width" = builtins.ceil (panel.width / osConfig.lantian.hidpi);
        "zoom.stealth.screen.height" = builtins.ceil (panel.height / osConfig.lantian.hidpi);
        # The device-pixel counterpart used for the maximized-window
        # geometry (StealthDeclaredMaximizedWindow): full device res minus
        # the taskbar (declared in CSS px in the baseline) in device px, so
        # the device rect matches GetAvailRect's CSS rect (912 * 1.5 = 1368).
        "zoom.stealth.screen.avail_device_width" = panel.width;
        "zoom.stealth.screen.avail_device_height" = builtins.ceil (
          panel.height - baseline."zoom.stealth.screen.taskbar_px" * osConfig.lantian.hidpi
        );
        # Window scale: the real compositor scale (matches Xft.dpi/96).
        "layout.css.devPixelsPerPx" = builtins.toString osConfig.lantian.hidpi;
        # Refresh rate: the active panel mode.
        "layout.frame_rate" = panel.refresh;
      };
in
{
  programs.firefox.profiles.lantian.settings =
    baseline
    // screenOverrides
    // {
      # UA tracks the latest Firefox version in nixpkgs (what a current real
      # Firefox reports), not the engine package's own base version.
      "general.useragent.override" =
        let
          firefoxVersion = pkgs.firefox.version;
        in
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:${lib.versions.major firefoxVersion}) Gecko/20100101 Firefox/${firefoxVersion}";

      # Synthetic host ICE candidate, injected by the C++ patch when no real
      # host candidates can be gathered; pinned to the real LAN subnet instead
      # of the seed-derived one in the baseline.
      "zoom.stealth.webrtc.host_ip" = "192.168.0.${builtins.toString LT.this.index}";

      # No upstream usage ping.
      "invisible_firefox.usage_ping.enabled" = false;

      # Font manifest: the engine binary's own fonts/bundle-fonts.list
      # (byte-exact with the font set it ships; the engine package installs its
      # tree under lib/<libName>/). No fallback: a package without the file
      # fails the evaluation completely. The branding archive only exists in
      # the invisible_core source tree and stays as the baseline's file: URI.
      "zoom.stealth.fonts.manifest" =
        let
          engine = osConfig.programs.firefox.package.unwrapped;
        in
        builtins.readFile "${engine}/lib/${engine.libName}/fonts/bundle-fonts.list";

      # Stylix also picks host font NAMES that are absent from the engine's
      # Windows font bundle (the lookup would fall back to the host's
      # fontconfig - a leak). Force the retail Windows defaults instead, all
      # shipped by the bundle.
      "font.name.monospace.x-western" = lib.mkForce "Consolas";
      "font.name.sans-serif.x-western" = lib.mkForce "Arial";
      "font.name.serif.x-western" = lib.mkForce "Times New Roman";

      # Branding as above (with proper store context, unlike the JSON values).
      "zoom.stealth.branding.archive" = brandingArchive;
    };
}
