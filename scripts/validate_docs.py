"""Dependency-free documentation baseline checks; not runtime qualification."""
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
DOCS = [
    "01-overview", "02-requirements", "03-scope", "04-architecture",
    "05-security", "06-test-benchmark", "07-deployment", "08-editorial",
    "09-backlog", "10-definition-of-done", "11-decisions", "12-checkpoint",
    "13-data-contracts", "14-ui-ux", "15-recovery", "16-sources-licenses",
    "17-release-plan", "18-youtube-integration-proposal", "19-governance",
]
WOS = [
    "NDS-CORE-WO-001", "NDS-MEDIA-WO-002", "NDS-MOTION-WO-003",
    "NDS-PIPE-WO-004", "NDS-UI-WO-005", "NDS-PILOT-WO-006",
    "NDS-QA-WO-007",
]
SECTIONS = [
    "OBJECTIVE", "CONTEXT", "SCOPE", "OUT OF SCOPE", "FILES/SOURCES TO READ",
    "REQUIREMENTS", "ARCHITECTURE RULES", "CONSTRAINTS", "ACCEPTANCE CRITERIA",
    "TESTS", "DELIVERABLES", "REVIEW FORMAT", "STOP CONDITION",
]
REQUIRED = {
    "README.md", "AGENTS.md", "PROMPT-CODEX.md", "CHANGELOG.md",
    ".gitignore", ".github/workflows/docs-validation.yml",
    ".github/governance/main-ruleset.json", "scripts/validate_docs.py",
    "templates/context-lock.md", "templates/evidence-bundle.md",
    "templates/checkpoint-delta.md",
} | {f"docs/{name}.md" for name in DOCS} | {
    f"work-orders/{name}.md" for name in WOS
}

def validate(root, tracked):
    errors = []
    texts = {}
    for name in sorted(REQUIRED):
        path = root / name
        if name not in tracked or not path.is_file() or path.is_symlink() or not path.resolve().is_relative_to(root.resolve()):
            errors.append(f"missing or unsafe tracked file: {name}")
            continue
        try:
            content = path.read_text(encoding="utf-8")
        except (UnicodeError, OSError):
            errors.append(f"unreadable UTF-8 file: {name}")
            continue
        if not content.strip():
            errors.append(f"empty file: {name}")
        texts[name] = content
    for name in WOS:
        path = f"work-orders/{name}.md"
        lines = texts.get(path, "").splitlines()
        for section in SECTIONS:
            if f"## {section}" not in lines:
                errors.append(f"{path}: missing section {section}")
    req = texts.get("docs/02-requirements.md", "")
    for i in range(1, 20):
        if not re.search(r"^\| R%02d \|" % i, req, re.M):
            errors.append(f"missing requirement R{i:02}")
    dod = texts.get("docs/10-definition-of-done.md", "")
    for i in range(1, 12):
        if not re.search(r"\bD%02d\b" % i, dod):
            errors.append(f"missing DoD D{i:02}")
    decisions = texts.get("docs/11-decisions.md", "")
    for i in range(1, 9):
        if not re.search(r"^\| D%03d \|" % i, decisions, re.M):
            errors.append(f"missing decision D{i:03}")
    for target in re.findall(r"\]\(([^)]+)\)", texts.get("README.md", "")):
        if target.startswith(("https://", "http://", "#", "mailto:")):
            continue
        name = target.split("#", 1)[0].rstrip("/")
        if name and name not in tracked and not any(x.startswith(name + "/") for x in tracked):
            errors.append(f"README link missing from Git: {target}")
    return errors

class ValidationTests(unittest.TestCase):
    def test_fixture_and_missing_requirements(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for name in REQUIRED:
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("fixture\n", encoding="utf-8")
            for wo in WOS:
                (root / f"work-orders/{wo}.md").write_text("\n".join("## " + s for s in SECTIONS), encoding="utf-8")
            req = root / "docs/02-requirements.md"
            req.write_text("\n".join(f"| R{i:02} |" for i in range(1, 20)), encoding="utf-8")
            (root / "docs/10-definition-of-done.md").write_text(" ".join(f"D{i:02}" for i in range(1, 12)), encoding="utf-8")
            (root / "docs/11-decisions.md").write_text("\n".join(f"| D{i:03} |" for i in range(1, 9)), encoding="utf-8")
            self.assertEqual(validate(root, REQUIRED), [])
            req.write_text("| R01 |", encoding="utf-8")
            self.assertIn("missing requirement R19", validate(root, REQUIRED))
            (root / "README.md").write_text("[broken](absent.md)", encoding="utf-8")
            self.assertIn("README link missing from Git: absent.md", validate(root, REQUIRED))
            self.assertIn("missing or unsafe tracked file: AGENTS.md", validate(root, REQUIRED - {"AGENTS.md"}))
            (root / f"work-orders/{WOS[0]}.md").write_text("# empty WO", encoding="utf-8")
            self.assertIn(f"work-orders/{WOS[0]}.md: missing section TESTS", validate(root, REQUIRED))

if __name__ == "__main__":
    if sys.argv[1:] == ["--self-test"]:
        unittest.main(argv=[sys.argv[0]], verbosity=2)
    elif not sys.argv[1:]:
        tracked = {p.decode("utf-8") for p in subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT).split(b"\0") if p}
        errors = validate(ROOT, tracked)
        for error in errors:
            print(error, file=sys.stderr)
        print(f"docs-validation: {'FAIL' if errors else 'PASS'}; {len(REQUIRED)} required paths; {len(errors)} errors")
        sys.exit(bool(errors))
    else:
        sys.exit("usage: validate_docs.py [--self-test]")
