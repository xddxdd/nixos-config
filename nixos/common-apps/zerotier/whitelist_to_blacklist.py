import sys

ALLOWED_CHARACTERS = '1234567890abcdefghijklmnopqrstuvwxyz'

def whitelist_to_blacklist(prefix = ''):
    result = []
    for ch in ALLOWED_CHARACTERS:
        if any([v == prefix + ch for v in sys.argv[1:]]):
            pass
        elif any([v.startswith(prefix + ch) for v in sys.argv[1:]]):
            result.extend(whitelist_to_blacklist(prefix + ch))
        else:
            result.append(prefix + ch)
    return result

print('\n'.join(whitelist_to_blacklist()), end='')
