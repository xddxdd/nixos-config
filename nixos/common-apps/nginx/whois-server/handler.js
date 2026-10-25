import fs from 'fs';
import delegations from '@delegations@';

const objectTypes = [
    'aut-num', 'inetnum', 'inet6num', 'person', 'mntner', 'schema',
    'organisation', 'tinc-keyset', 'tinc-key', 'route-set', 'as-block', 'as-set', 'dns',
];
const ipDelegations = [
    delegations.ipv4.map(([network, prefix, server]) => [BigInt(network), BigInt(32 - prefix), server]),
    delegations.ipv6.map(([network, prefix, server]) => [BigInt(network), BigInt(128 - prefix), server]),
];

function addressValue(address) {
    if (!address.includes(':')) {
        const parts = address.split('.');
        if (parts.length !== 4 || parts.some(p => !/^(0|[1-9][0-9]{0,2})$/.test(p) || Number(p) > 255)) {
            return null;
        }
        return { bits: 32, value: parts.reduce((v, p) => (v << 8n) | BigInt(p), 0n) };
    }

    if (!/^[0-9a-f:]+$/i.test(address)) return null;
    const halves = address.split('::');
    if (halves.length > 2) return null;
    const left = halves[0] ? halves[0].split(':') : [];
    const right = halves.length === 2 && halves[1] ? halves[1].split(':') : [];
    if (left.concat(right).some(p => !/^[0-9a-f]{1,4}$/i.test(p))) return null;
    if (halves.length === 1 ? left.length !== 8 : left.length + right.length >= 8) return null;
    const parts = halves.length === 1 ? left : left.concat(Array(8 - left.length - right.length).fill('0'), right);
    return { bits: 128, value: parts.reduce((v, p) => (v << 16n) | BigInt('0x' + p), 0n) };
}

function addressText(value, bits) {
    if (bits === 32) {
        return [24n, 16n, 8n, 0n].map(shift => String((value >> shift) & 255n)).join('.');
    }
    const parts = Array.from({ length: 8 }, (_, i) => Number((value >> BigInt(112 - i * 16)) & 65535n));
    let start = -1;
    let length = 1;
    for (let i = 0; i < parts.length;) {
        if (parts[i] !== 0) {
            i++;
            continue;
        }
        let end = i;
        while (end < parts.length && parts[end] === 0) end++;
        if (end - i > length) {
            start = i;
            length = end - i;
        }
        i = end;
    }
    const hex = parts.map(p => p.toString(16));
    return start === -1 ? hex.join(':') : hex.slice(0, start).join(':') + '::' + hex.slice(start + length).join(':');
}

function readObject(root, type, name) {
    try {
        const path = fs.realpathSync(root + '/' + type + '/' + name);
        if (!path.startsWith(root + '/')) return null;
        return fs.readFileSync(path, 'utf8');
    } catch (e) {
        if (['ENOENT', 'ENOTDIR', 'EISDIR', 'ELOOP', 'ENAMETOOLONG'].includes(e.code)) return null;
        throw e;
    }
}

function allocation(root, type, address, prefix) {
    for (let mask = prefix; mask > 0; mask--) {
        const shift = BigInt(address.bits - mask);
        const network = (address.value >> shift) << shift;
        const content = readObject(root, type, addressText(network, address.bits) + '_' + mask);
        if (content !== null) return content;
    }
    return null;
}

function banner(r) {
    // nginx may reject a malformed URI before setting request_uri.
    return '% Lan Tian Nginx-based WHOIS Server\n% GET ' + (r.variables.request_uri || '') + ':\n\n';
}

function respond(r, status, text) {
    r.headersOut['Content-Type'] = 'text/plain; charset=utf-8';
    r.return(status, banner(r) + text);
}

function lookup(r) {
    if (r.method !== 'GET' && r.method !== 'HEAD') {
        r.headersOut.Allow = 'GET, HEAD';
        respond(r, 405, '% Unsupported method\n');
        return;
    }
    let query = r.uri.slice(1);
    // The plain listener accepts spaces; retain the original first-token query behavior.
    if (query.length > 512 || /[^\x20-\x7e]|\\/.test(query)
        || /(?:^|\/)(?:\.|%2e){1,2}(?:\/|%2f|$)/i.test(r.variables.request_uri.split('?')[0])) {
        respond(r, 400, '% Invalid query\n');
        return;
    }
    query = query.split(' ')[0];
    if (!query) {
        respond(r, 200, '% 404 Not Found\n');
        return;
    }
    if (!/^[a-z0-9_.:\/-]+$/i.test(query) || query.includes('..')) {
        respond(r, 400, '% Invalid query\n');
        return;
    }
    if (/^[0-9]+$/.test(query)) {
        query = 'AS' + (query.length <= 4 ? '424242' + query.padStart(4, '0') : query);
    }

    try {
        const root = fs.realpathSync(r.variables.document_root);
        const fields = query.split('/');
        const address = fields[0];
        let parsed = null;
        let prefix;
        let backend = 'whois.arin.net';
        if (/^[0-9a-f]{0,4}:/i.test(address) || /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/.test(address)) {
            parsed = addressValue(address);
            prefix = fields.length === 1 && parsed ? parsed.bits : Number(fields[1]);
            if (!parsed || fields.length > 2 || (fields.length === 2 && !/^[0-9]+$/.test(fields[1]))
                || !Number.isInteger(prefix) || prefix < 0 || prefix > parsed.bits) {
                respond(r, 400, '% Invalid address or prefix\n');
                return;
            }
            const content = allocation(root, parsed.bits === 32 ? 'inetnum' : 'inet6num', parsed, prefix);
            if (content !== null) {
                const route = allocation(root, parsed.bits === 32 ? 'route' : 'route6', parsed, prefix);
                respond(r, 200, content + '\n% Relevant route object:\n' + (route === null ? '% 404\n' : route));
                return;
            }
            const entry = ipDelegations[parsed.bits === 32 ? 0 : 1]
                .find(([network, shift]) => (parsed.value >> shift) === (network >> shift));
            if (entry) backend = entry[2];
            query = address;
        } else {
            if (fields.length > 1) {
                if (fields.length !== 2 || !objectTypes.concat(['route', 'route6', 'key-cert', 'registry', 'role', 'telephony'])
                    .includes(fields[0]) || !fields[1]) {
                    respond(r, 400, '% Invalid object path\n');
                    return;
                }
                const content = readObject(root, fields[0], fields[1]);
                respond(r, 200, content === null ? '% 404 Not Found\n' : content);
                return;
            }
            for (const type of objectTypes) {
                const content = readObject(root, type, type === 'dns' ? query.toLowerCase() : query.toUpperCase());
                if (content !== null) {
                    respond(r, 200, content);
                    return;
                }
            }
            let entry;
            if (/^AS[0-9]+$/i.test(query)) {
                const asn = Number(query.slice(2));
                if (!Number.isSafeInteger(asn) || asn > 4294967295) {
                    respond(r, 400, '% Invalid ASN\n');
                    return;
                }
                query = 'AS' + asn;
                entry = delegations.asn.find(([first, last]) => asn >= first && asn <= last);
                if (entry) backend = entry[2];
            } else if (/-[a-z0-9]+$/i.test(query)) {
                query = query.toUpperCase();
                entry = delegations.handle.find(([suffix]) => query.toLowerCase().endsWith(suffix));
                if (entry) backend = entry[1];
            } else if (/^(?:\.[a-z0-9]+|(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]+)$/i.test(query)) {
                query = query.toLowerCase();
                entry = delegations.domain.find(([suffix]) => query.endsWith(suffix) || '.' + query === suffix);
                if (entry) backend = entry[1];
            } else {
                respond(r, 200, '% 404 Not Found\n');
                return;
            }
        }
        // Backends come only from the vendored tables; UNKNOWN is not a hostname.
        if (!backend) {
            respond(r, 200, '% 404 Not Found\n');
            return;
        }
        r.variables.whois_backend = backend;
        r.variables.whois_query = query;
        r.internalRedirect('@whois-remote');
    } catch (e) {
        r.error('WHOIS registry lookup failed: ' + e.message);
        respond(r, 500, '% Registry lookup failed\n');
    }
}

function remoteHeaders(r) {
    r.headersOut['Content-Type'] = 'text/plain; charset=utf-8';
    delete r.headersOut['Content-Length'];
}

function prepend(r, data, flags) {
    if (!r.variables.whois_prefix_sent) {
        r.variables.whois_prefix_sent = '1';
        r.sendBuffer(banner(r));
    }
    r.sendBuffer(data, flags);
}

function invalid(r) {
    respond(r, 400, '% Invalid query\n');
}

function limited(r) {
    respond(r, 429, '% Rate limit exceeded\n');
}

export default { lookup, remoteHeaders, prepend, invalid, limited };
