import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';

// Pi's bundled provider clients default the User-Agent to
// `pi (${os.platform()} ${os.release()}; ${os.arch()})`, which sends the
// running kernel release to every model provider. There is no setting for it,
// but before_provider_headers runs once per provider request and its output
// overrides that default. Strip everything down to the product name.
export default function sanitizeUserAgent(pi: ExtensionAPI): void {
  pi.on('before_provider_headers', (event) => {
    event.headers['User-Agent'] = 'pi';
  });
}
