// Disables pi's startup extension/package update check by hooking the
// package-manager method the interactive startup check calls.
//
// Why hook internals: pi exposes no event or setting to disable only the
// startup "Package Updates Available" check. The only supported lever is
// PI_OFFLINE, which also disables model catalog refresh, the pi.dev version
// check, and telemetry. DefaultPackageManager.prototype.checkForAvailableUpdates
// is surgical: it is the sole method the interactive startup check calls, while
// `pi update --extensions` uses updateConfiguredSources (a different method), so
// explicit updates keep working. Package commands (update/install/remove) run in
// a separate process that does not load extensions, so this patch never affects them.
export default async function () {
  try {
    const mod: any = await import("@earendil-works/pi-coding-agent");
    const PM = mod.DefaultPackageManager;
    if (!PM?.prototype) return;
    const proto = PM.prototype;
    if (proto.__noUpdateCheckPatched) return;
    proto.__noUpdateCheckPatched = true;
    proto.checkForAvailableUpdates = async () => [];
  } catch {
    // Export unavailable in this pi version; fail harmlessly.
  }
}
