_: final: prev:
let
  sources = final.callPackage ../helpers/_sources/generated.nix { };
  vibrancy = sources.vscode-vibrancy-continued.src;

  appOut = "resources/app/out";
  runtimeDir = "vscode-vibrancy-runtime-v6";
  runtimeEntry = "$out/lib/vscode/${appOut}/${runtimeDir}/index.cjs";

  # Mirrors global.vscode_vibrancy_plugin as built by the extension's installJS()
  # for vscode-vibrancy-continued v1.1.93 on Linux with all-default settings.
  injectData = {
    os = "linux";
    win11 = false;
    config = {
      type = "auto";
      opacity = 0;
      backgroundOverride = "";
      theme = "Default Dark";
      enableAutoTheme = false;
      preferredDarkTheme = "Default Dark";
      preferredLightTheme = "Default Light";
      preferedDarkTheme = "Default Dark";
      preferedLightTheme = "Default Light";
      imports = [ "/path/to/file" ];
      refreshInterval = 10;
      preventFlash = true;
      windowMode = "auto";
      windowControlsStyle = "auto";
      forceFramelessWindow = false;
      disableFramelessWindow = false;
      disableThemeFixes = false;
      disableColorCustomizations = false;
    };
    theme = builtins.fromJSON (builtins.readFile (vibrancy + "/themes/Default Dark.json"));
    themeCSS = builtins.readFile (vibrancy + "/themes/Default Dark.css");
    imports = {
      css = "";
      js = "";
    };
  };

  # Appended to out/main.js exactly like the extension's generateNewJS().
  bootstrapJs = final.writeText "vscode-vibrancy-bootstrap.js" ''

    /* !! VSCODE-VIBRANCY-START !! */
    ;(function(){
    if (!import('fs').then(fs => fs.existsSync("@vibrancyBase@"))) return;
    global.vscode_vibrancy_plugin = ${builtins.toJSON injectData}; try{ import("@vibrancyRuntimeUrl@"); } catch (err) {console.error(err)}
    })()
    /* !! VSCODE-VIBRANCY-END */
  '';
in
{
  vscode = prev.vscode.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      chmod u+w resources/app "${appOut}" \
        "${appOut}/main.js" \
        "${appOut}/vs/code/electron-browser/workbench" \
        "${appOut}/vs/code/electron-browser/workbench/workbench.html"

      # installRuntime(): copy the CJS runtime into out/vscode-vibrancy-runtime-v6/
      cp -r "${vibrancy}/runtime-pre-esm" "${appOut}/${runtimeDir}"

      # modifyElectronJSFile(): frameless + transparent BrowserWindow (Linux auto)
      sed -i 's/experimentalDarkMode/frame:false,transparent:true,experimentalDarkMode/g' "${appOut}/main.js"
      grep -q 'frame:false,transparent:true,experimentalDarkMode' "${appOut}/main.js"

      # installJS(): append the runtime bootstrap
      substitute ${bootstrapJs} vscode-vibrancy-bootstrap.js \
        --replace-fail "@vibrancyBase@" "${runtimeEntry}" \
        --replace-fail "@vibrancyRuntimeUrl@" "file://${runtimeEntry}"
      cat vscode-vibrancy-bootstrap.js >> "${appOut}/main.js"
      rm vscode-vibrancy-bootstrap.js

      # installHTML(): allow the runtime's Trusted Types policy
      sed -i 's/^[[:space:]]*trusted-types$/& VscodeVibrancyContinued/' "${appOut}/vs/code/electron-browser/workbench/workbench.html"
      grep -q 'trusted-types VscodeVibrancyContinued' "${appOut}/vs/code/electron-browser/workbench/workbench.html"

      # workbench.html is checksum-verified; update product.json so VS Code
      # does not flag the installation as corrupt
      htmlChecksum=$(sha256sum "${appOut}/vs/code/electron-browser/workbench/workbench.html" | cut -d' ' -f1)
      htmlChecksumB64=$(printf "$(echo "$htmlChecksum" | sed 's/../\\x&/g')" | base64 | tr -d '=')
      tmpProductJson="$(mktemp)"
      jq --arg key "vs/code/electron-browser/workbench/workbench.html" --arg value "$htmlChecksumB64" \
        '.checksums[$key] = $value' resources/app/product.json > "$tmpProductJson"
      mv "$tmpProductJson" resources/app/product.json
    '';
  });
}
