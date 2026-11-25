const fs = require('node:fs');
const path = require('node:path');

const qualification = path.resolve(__dirname, '..');
const remotionRoot = path.join(qualification, 'remotion');
const lock = JSON.parse(fs.readFileSync(path.join(remotionRoot, 'package-lock.json'), 'utf8'));
const packages = [];
const notInstalled = [];

for (const [relative, locked] of Object.entries(lock.packages ?? {})) {
  if (!relative.startsWith('node_modules/')) continue;
  const packagePath = path.join(remotionRoot, relative, 'package.json');
  let metadata;
  try { metadata = JSON.parse(fs.readFileSync(packagePath, 'utf8')); }
  catch {
    notInstalled.push({ name: locked.name ?? relative.slice('node_modules/'.length), version: locked.version ?? 'unknown', optional: locked.optional === true });
    continue;
  }
  let licenseFile = null;
  const pointer = /^SEE LICENSE IN\s+(.+)$/i.exec(metadata.license ?? '');
  if (pointer) {
    const packageDirectory = path.dirname(packagePath);
    const candidate = path.resolve(packageDirectory, pointer[1].trim());
    if (candidate.startsWith(`${packageDirectory}${path.sep}`) && fs.existsSync(candidate)) {
      const firstLine = fs.readFileSync(candidate, 'utf8').split(/\r?\n/).map(line => line.trim()).find(Boolean) ?? '';
      licenseFile = { file: pointer[1].trim(), first_line: firstLine.slice(0, 120) };
    } else {
      licenseFile = { file: pointer[1].trim(), missing: true };
    }
  }
  packages.push({
    name: metadata.name ?? relative.slice('node_modules/'.length),
    version: metadata.version ?? locked.version ?? 'unknown',
    license: /^SEE LICENSE IN\b/i.test(metadata.license ?? '')
      ? 'LICENSE_FILE_POINTER'
      : (metadata.license ?? 'UNDECLARED'),
    license_file: licenseFile,
  });
}

packages.sort((a, b) => a.name.localeCompare(b.name) || a.version.localeCompare(b.version));
const tally = {};
for (const item of packages) tally[item.license] = (tally[item.license] ?? 0) + 1;
const result = {
  method: 'package-lock package paths matched against installed package.json license metadata; not legal advice',
  lock_entry_count: Object.keys(lock.packages ?? {}).filter(key => key.startsWith('node_modules/')).length,
  package_count: packages.length,
  not_installed_count: notInstalled.length,
  license_tally: tally,
  undeclared: packages.filter(item => item.license === 'UNDECLARED').map(({ name, version }) => ({ name, version })),
  license_files_missing: packages.filter(item => item.license_file?.missing).map(({ name, version, license_file }) => ({ name, version, ...license_file })),
  not_installed: notInstalled,
  packages,
};
const output = path.join(qualification, 'logs', 'npm-license-inventory.json');
fs.mkdirSync(path.dirname(output), { recursive: true });
fs.writeFileSync(output, `${JSON.stringify(result, null, 2)}\n`);
process.stdout.write(JSON.stringify({ lock_entry_count: result.lock_entry_count, package_count: result.package_count, not_installed_count: notInstalled.length, license_tally: tally, undeclared_count: result.undeclared.length, license_files_missing_count: result.license_files_missing.length }));
