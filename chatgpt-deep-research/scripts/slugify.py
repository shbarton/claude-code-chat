#!/usr/bin/env python3
import re, sys, unicodedata
s = sys.argv[1] if len(sys.argv) > 1 else "deep research"
s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode("ascii")
s = re.sub(r"[^a-zA-Z0-9]+", "-", s).strip("-").lower()
print(s or "deep-research")
