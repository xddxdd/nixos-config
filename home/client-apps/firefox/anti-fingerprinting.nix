{ lib, osConfig, ... }:
{
  programs.firefox.profiles.lantian.settings = {
    # Anti fingerprint
    # https://github.com/feder-cr/invisible_playwright/blob/main/src/invisible_playwright/prefs.py
    # Turn off Firefox's own resistFingerprinting; we do our own via patches.
    "privacy.resistFingerprinting" = false;
    "privacy.resistFingerprinting.letterboxing" = false;

    # FF150 fingerprintingProtection — enabled by default (or remotely via
    # Mozilla webcompat overrides). FP Pro detects the side-effects and
    # flips `privacy_settings: true`. On FF146 these were all off → false.
    # Force off so FP Pro reports privacy_settings:false (matches FF146).
    "privacy.fingerprintingProtection" = false;
    "privacy.fingerprintingProtection.pbmode" = false;
    "privacy.fingerprintingProtection.remoteOverrides.enabled" = false;

    # WebRTC: enabled, no public IP leak.
    # obfuscate_host_addresses=false: our C++ injection handles candidate
    # selection; mDNS causes mDNS-IPC to hang in sandboxed content processes.
    # disableIPv6=true keeps IPv6 out of gathering (less entropy, no IPv6 leak).
    "media.peerconnection.enabled" = true;
    "media.peerconnection.ice.no_host" = false;
    "media.peerconnection.ice.default_address_only" = false;
    "media.peerconnection.ice.obfuscate_host_addresses" = false;
    "media.peerconnection.ice.disableIPv6" = true;
    "media.peerconnection.ice.proxy_only" = false;
    "media.peerconnection.ice.relay_only" = false;
    "media.peerconnection.use_document_iceservers" = true;

    # Proxy — route DNS through SOCKS proxies to avoid local DNS leaks.
    "network.proxy.socks_remote_dns" = true;
    "network.proxy.failover_direct" = false;

    # Safebrowsing — chatty and fingerprintable.
    "browser.safebrowsing.malware.enabled" = false;
    "browser.safebrowsing.phishing.enabled" = false;
    "browser.safebrowsing.downloads.enabled" = false;
    "browser.safebrowsing.downloads.remote.enabled" = false;

    # First-run / welcome UI noise.
    "browser.startup.page" = 0;
    "browser.shell.checkDefaultBrowser" = false;
    "browser.aboutwelcome.enabled" = false;
    "browser.startup.upgradeDialog.enabled" = false;
    "termsofuse.acceptedVersion" = 999;

    # Disable about:newtab auto-load — TopSitesFeed.sys.mjs auto-fetches when
    # a tab opens, triggering a cross-process BC swap that hijacks the first
    # page.goto() (NS_BINDING_ABORTED on creepjs/peet/sannysoft/fppro).
    "browser.newtabpage.enabled" = false;
    "browser.newtab.preload" = false;
    "browser.newtabpage.activity-stream.feeds.topsites" = false;
    "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
    "browser.newtabpage.activity-stream.enabled" = false;

    # Speech synth: enabled (the C++ patch fabricates voices from the
    # comma list above) regardless of the host OS.
    "media.webspeech.synth.enabled" = true;
    "zoom.stealth.voices.list" = lib.join "," [
      "Microsoft David - English (United States)|en-US|1|1"
      "Microsoft Zira - English (United States)|en-US|0|1"
      "Microsoft Mark - English (United States)|en-US|0|1"
      "Microsoft David Desktop - English (United States)|en-US|0|1"
      "Microsoft Zira Desktop - English (United States)|en-US|0|1"
    ];

    # WebGL extensions whitelist — non-empty pre-empts native enumeration.
    "zoom.stealth.webgl.extensions" = lib.join "," [
      "ANGLE_instanced_arrays"
      "EXT_blend_minmax"
      "EXT_color_buffer_half_float"
      "EXT_float_blend"
      "EXT_frag_depth"
      "EXT_sRGB"
      "EXT_shader_texture_lod"
      "EXT_texture_compression_bptc"
      "EXT_texture_compression_rgtc"
      "EXT_texture_filter_anisotropic"
      "OES_element_index_uint"
      "OES_fbo_render_mipmap"
      "OES_standard_derivatives"
      "OES_texture_float"
      "OES_texture_float_linear"
      "OES_texture_half_float"
      "OES_texture_half_float_linear"
      "OES_vertex_array_object"
      "WEBGL_color_buffer_float"
      "WEBGL_compressed_texture_s3tc"
      "WEBGL_compressed_texture_s3tc_srgb"
      "WEBGL_debug_renderer_info"
      "WEBGL_debug_shaders"
      "WEBGL_depth_texture"
      "WEBGL_draw_buffers"
      "WEBGL_lose_context"
      "WEBGL_provoking_vertex"
    ];
    "zoom.stealth.webgl2.extensions" = lib.join "," [
      "EXT_color_buffer_float"
      "EXT_color_buffer_half_float"
      "EXT_float_blend"
      "EXT_texture_compression_bptc"
      "EXT_texture_compression_rgtc"
      "EXT_texture_filter_anisotropic"
      "OES_draw_buffers_indexed"
      "OES_texture_float_linear"
      "OES_texture_half_float_linear"
      "OVR_multiview2"
      "WEBGL_compressed_texture_s3tc"
      "WEBGL_compressed_texture_s3tc_srgb"
      "WEBGL_debug_renderer_info"
      "WEBGL_debug_shaders"
      "WEBGL_lose_context"
      "WEBGL_provoking_vertex"
    ];
    # WebGL numeric param overrides — kept empty (A/B test 2026-04-22 showed
    # mismatches between the values we shipped and ANGLE's real envelope
    # raised FP Pro's ML tampering score). Slot kept for future experiments.
    "zoom.stealth.webgl.int_params" = "";
    "zoom.stealth.webgl.int2_params" = "";
    "zoom.stealth.webgl.shader_precisions" = "";
    "zoom.stealth.webgl.float_params" = "";

    # DevTools anti-detection.
    "zoom.stealth.debugger.force_detach" = true;

    # Canvas substitution — additive ±1 noise over the OS base pattern;
    # set to True to replace pixels with hash(seed, idx) instead.
    "zoom.stealth.canvas.substitute_pixels" = false;

    # Navigator identity (locked to Windows Firefox 150).
    "general.useragent.override" =
      let
        firefoxVersion = osConfig.programs.firefox.package.version;
      in
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:${lib.versions.majorMinor firefoxVersion}) Gecko/20100101 Firefox/${firefoxVersion}";
    "general.platform.override" = "Win32";
    "general.oscpu.override" = "Windows NT 10.0; Win64; x64";
    "general.appversion.override" = "5.0 (Windows)";

    # WebGL Renderer
    "zoom.stealth.webgl.renderer" =
      "ANGLE (Intel, Intel(R) UHD Graphics 770 (0x00004690) Direct3D11 vs_5_0 ps_5_0, D3D11)";
    "zoom.stealth.webgl.vendor" = "Google Inc. (Intel)";
    "zoom.stealth.canvas.noise_skip_mask" = 15;

    # MSAA
    "zoom.stealth.webgl.msaa" = 4;
    "webgl.msaa-samples" = 4;
    "webgl.msaa-force" = true;

    # Fonts, not enabled since it break UI fonts
    "zoom.stealth.font.whitelist" = "";
    "zoom.stealth.font.metrics" = "";
  };
}
