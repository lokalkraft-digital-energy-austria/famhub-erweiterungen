#!/usr/bin/env node
/**
 * Die Aufnahmeregeln des Gemeinschaftsregals — maschinell, damit die Lesezeit klein bleibt.
 *
 * `famhub-plugin prüfen` hat vorher schon geprüft, was **jeder** Server prüft (Manifest, API-Stand,
 * Speichergrenze, Bildschirme, Unterschrift des Autors). Hier steht nur, was zusätzlich gilt, weil
 * dieses Paket mit der App ausgeliefert wird und fremden Familien angeboten wird.
 *
 *     node .github/regeln.mjs erweiterungen/at.beispiel.garten
 */
import { readFile, readdir, stat } from 'node:fs/promises';
import path from 'node:path';

const dir = process.argv[2];
if (!dir) {
  console.error('Aufruf: regeln.mjs <ordner>');
  process.exit(2);
}

const fehler = [];
const hinweise = [];

const manifest = JSON.parse(await readFile(path.join(dir, 'famhub.plugin.json'), 'utf8').catch(() => 'null'));
if (!manifest) {
  console.error(`✗ ${dir}: kein famhub.plugin.json`);
  process.exit(1);
}

// 1 · Sandkasten. Ohne ihn kommt nichts in ein Regal, das mit der App ausgeliefert wird.
if ((manifest.runtime ?? 'wasm') !== 'wasm') fehler.push('runtime muss "wasm" sein – ohne Sandkasten nehmen wir nichts auf');

// 2 · Kein gebautes Artefakt. Gebaut wird aus dem Quelltext – nur so bedeutet die Unterschrift etwas.
const alle = [];
const walk = async (d) => {
  for (const e of await readdir(d, { withFileTypes: true })) {
    const p = path.join(d, e.name);
    if (e.isDirectory()) await walk(p);
    else alle.push(path.relative(dir, p));
  }
};
await walk(dir);
const gebaut = alle.filter((f) => /\.(wasm|zip|tgz|so|dylib|exe)$/i.test(f));
if (gebaut.length) fehler.push(`gebaute Dateien gehören nicht ins Repo: ${gebaut.join(', ')}`);

// 3 · Quelltext, aus dem sich das Artefakt bauen lässt
const quelle = alle.some((f) => /\.(wat|rs|go|ts|js)$/i.test(f));
if (!quelle) fehler.push('kein Quelltext gefunden (plugin.wat oder Rust-/Go-Quelle)');

// 4 · Wer es geschrieben hat
if (!(await stat(path.join(dir, 'autor.json')).catch(() => null))) fehler.push('autor.json fehlt (famhub-plugin einreichen …)');

// 5 · Lizenz
if (!alle.some((f) => /^LICENSE(\.md|\.txt)?$/i.test(f))) fehler.push('LICENSE fehlt');

// 6 · Zwei Sprachen – eine Familie in Wien und eine in Cork sollen dasselbe verstehen
const zweisprachig = (o, wo) => {
  if (!o) return;
  if (!o.de || !o.en) hinweise.push(`${wo} hat nur ${Object.keys(o).join(', ')} – deutsch und englisch bitte`);
};
zweisprachig(manifest.name, 'name');
zweisprachig(manifest.description, 'description');
for (const n of manifest.provides?.nav ?? []) zweisprachig(n.title, `nav.${n.key}.title`);

// 7 · Die Kennung gehört dem Autor (umgedrehte Domain) und passt zum Ordner
if (!/^[a-z0-9]+(\.[a-z0-9-]+){1,4}$/.test(manifest.id ?? '')) fehler.push('die Kennung ist keine umgedrehte Adresse (at.beispiel.garten)');
if (path.basename(dir) !== manifest.id) fehler.push(`der Ordner heißt ${path.basename(dir)}, die Kennung ${manifest.id}`);

// 8 · Was sie verlangt, steht im Pull Request – hier nur sichtbar machen, damit es niemand übersieht
const needs = manifest.needs ?? {};
if (needs.network?.length) hinweise.push(`will ins Netz: ${needs.network.join(', ')} – bitte im Pull Request begründen`);
if (needs.permissions?.length) hinweise.push(`will Kernrechte: ${needs.permissions.join(', ')} – bitte im Pull Request begründen`);
if (needs.jobs) hinweise.push('will regelmäßig etwas tun – bitte im Pull Request begründen');

for (const h of hinweise) console.log(`! ${dir}: ${h}`);
for (const f of fehler) console.error(`✗ ${dir}: ${f}`);
if (fehler.length) process.exit(1);
console.log(`✓ ${dir}: Aufnahmeregeln erfüllt`);
