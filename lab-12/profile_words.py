#!/usr/bin/env python3
"""Small targeted dictionary made ONLY from a fixed fictional profile."""
from pathlib import Path

words = [name + year + suffix
         for name in ('mira', 'Mira', 'Example')
         for year in ('1999', '9912')
         for suffix in ('', '!')]
Path('/tmp/lab12/profile-passwords.txt').write_text('\n'.join(words) + '\n')
Path('/tmp/lab12/profile-usernames.txt').write_text('demo\n')
print('Fictional profile: Mira Example, birth year 1999.')
print(f'Generated {len(words)} candidates.')
