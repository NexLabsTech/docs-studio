import hashlib
import json
import os
from pathlib import Path
from smoke import safe_output_path

sandbox = Path(os.environ["NDS_QUALIFICATION_SANDBOX"])
sentinel = Path(os.environ["NDS_TEST_EXTERNAL_SENTINEL"])
before = hashlib.sha256(sentinel.read_bytes()).hexdigest().upper()
checks = {}

def refused(name, value):
    try:
        safe_output_path(sandbox, value)
    except (ValueError, FileExistsError):
        checks[name] = True
    else:
        checks[name] = False

refused("traversal_rejected", "..\\" + sentinel.parent.name + "\\" + sentinel.name)
refused("absolute_destination_rejected", str(sentinel))
refused("unc_destination_rejected", "\\\\server\\share\\sentinel.bin")
existing = safe_output_path(sandbox, "existing-output.bin")
existing.write_bytes(b"preserve-existing-test-file")
existing_before = hashlib.sha256(existing.read_bytes()).hexdigest().upper()
refused("existing_destination_rejected", "existing-output.bin")
checks["existing_destination_unchanged"] = hashlib.sha256(existing.read_bytes()).hexdigest().upper() == existing_before
refused("junction_reparse_rejected", "junction\\new-output.bin")
after = hashlib.sha256(sentinel.read_bytes()).hexdigest().upper()
checks["external_sentinel_unchanged"] = before == after
if not all(checks.values()):
    raise SystemExit(json.dumps({"tests": checks, "passed": False}, sort_keys=True))
print(json.dumps({"tests": checks, "passed": True}, sort_keys=True))