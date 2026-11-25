import hashlib
import json
from importlib.metadata import distributions
from pathlib import Path
from urllib.parse import urldefrag

from packaging.requirements import Requirement
from packaging.utils import canonicalize_name


lock = Path(__file__).with_name("requirements-lock.txt")
requirements = [
    Requirement(line.strip())
    for line in lock.read_text(encoding="utf-8").splitlines()
    if line.strip() and not line.lstrip().startswith("#")
]
installed = {
    canonicalize_name(dist.metadata["Name"]): dist
    for dist in distributions()
    if dist.metadata.get("Name")
}
expected_names = {canonicalize_name(requirement.name) for requirement in requirements}
missing = sorted(expected_names - installed.keys())
extra = sorted(installed.keys() - expected_names)
version_mismatch = []
direct_url_mismatch = []

for requirement in requirements:
    name = canonicalize_name(requirement.name)
    distribution = installed.get(name)
    if distribution is None:
        continue
    if requirement.specifier and not requirement.specifier.contains(distribution.version, prereleases=True):
        version_mismatch.append({"name": name, "expected": str(requirement.specifier), "actual": distribution.version})
    if requirement.url:
        direct_url = distribution.read_text("direct_url.json")
        metadata = json.loads(direct_url) if direct_url else {}
        expected_url, fragment = urldefrag(requirement.url)
        archive = metadata.get("archive_info", {})
        expected_hash = fragment.removeprefix("sha256=")
        actual_hash = archive.get("hashes", {}).get("sha256") or str(archive.get("hash", "")).removeprefix("sha256=")
        if metadata.get("url") != expected_url or not expected_hash or actual_hash != expected_hash:
            direct_url_mismatch.append(name)

result = {
    "passed": not (missing or extra or version_mismatch or direct_url_mismatch),
    "lock_file": lock.name,
    "lock_sha256": hashlib.sha256(lock.read_bytes()).hexdigest().upper(),
    "locked_distribution_count": len(expected_names),
    "installed_distribution_count": len(installed),
    "missing": missing,
    "extra": extra,
    "version_mismatch": version_mismatch,
    "direct_url_hash_mismatch": direct_url_mismatch,
}
print(json.dumps(result, sort_keys=True))
if not result["passed"]:
    raise SystemExit(1)
