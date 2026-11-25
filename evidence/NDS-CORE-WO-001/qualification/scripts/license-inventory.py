import json
import os
from importlib import metadata
from pathlib import Path

output = Path(__file__).resolve().parents[1] / "logs" / "python-license-inventory.json"
packages = []
for dist in metadata.distributions():
    name = dist.metadata.get("Name") or "unknown"
    version = dist.version
    expression = dist.metadata.get("License-Expression")
    classifiers = dist.metadata.get_all("Classifier") or []
    approved = [item.rsplit(" :: ", 1)[-1] for item in classifiers if item.startswith("License :: OSI Approved :: ")]
    license_text = dist.metadata.get("License") or ""
    license_summary = license_text.strip().splitlines()[0][:120] if license_text.strip() else ""
    license_value = expression or "; ".join(sorted(set(approved))) or license_summary or "UNDECLARED"
    packages.append({"name": name, "version": version, "license_metadata": license_value})

packages.sort(key=lambda item: (item["name"].lower(), item["version"]))
tally = {}
for item in packages:
    tally[item["license_metadata"]] = tally.get(item["license_metadata"], 0) + 1
result = {
    "method": "installed distribution License, License-Expression and OSI classifier metadata; not legal advice",
    "python_version": os.sys.version.split()[0],
    "distribution_count": len(packages),
    "license_tally": tally,
    "undeclared": [item for item in packages if item["license_metadata"] == "UNDECLARED"],
    "packages": packages,
}
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(json.dumps({"distribution_count": result["distribution_count"], "license_tally": tally, "undeclared_count": len(result["undeclared"])}))
