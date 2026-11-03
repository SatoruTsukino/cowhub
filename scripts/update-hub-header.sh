#!/bin/bash
# Automatically update CowHub header and Window Name with latest commit short hash
set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HASH="$(git -C "$REPO_ROOT" rev-parse --short HEAD 2>/dev/null || echo "dev")"

if [ -z "$HASH" ]; then
    exit 0
fi

python3 -c "
import re

repo_root = '$REPO_ROOT'
hash_val = '$HASH'

for file in [f'{repo_root}/luascripts/cowhub.lua', f'{repo_root}/luascripts/preview.lua']:
    try:
        with open(file, 'r', encoding='utf-8') as f:
            content = f.read()
        new_content = re.sub(r'Name = \"Cow Hub( \[[a-f0-9]+\])?\"', f'Name = \"Cow Hub [{hash_val}]\"', content)
        new_content = re.sub(r'^-- (Cow Hub( \[[a-f0-9]+\])? \| )?', f'-- Cow Hub [{hash_val}] | ', new_content, count=1)
        if new_content != content:
            with open(file, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f'Updated header in {file} to [{hash_val}]')
    except Exception as e:
        pass
"

