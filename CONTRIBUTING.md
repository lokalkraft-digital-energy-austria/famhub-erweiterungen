# Aufnahmeregeln

## Was geprüft wird — und was nicht

> Wir lesen Manifest und Quelltext und bauen das Paket selbst aus dem Quelltext. Wir suchen **nicht**
> nach versteckten Denkfehlern und geben keine Sicherheitsgarantie für fremden Code — dafür ist der
> Sandkasten da: kein Dateisystem, kein Netz außer den genannten Adressen, keine fremde Tabelle,
> Zeit- und Speichergrenze, und jedes Recht muss der Betreiber selbst bestätigen.

Das ist ehrlich gemeint. Wer mehr braucht, betreibt seine eigene Quelle und steht selbst dafür ein.

## Die Regeln

Maschinell geprüft (die Prüfung im Pull Request macht genau das):

* **`runtime: "wasm"`** — ohne Sandkasten kommt nichts in ein Regal, das mit der App ausgeliefert
  wird. `runtime: "node"` ist für den eigenen Server gedacht, nicht für fremde.
* **Kein gebautes Artefakt im Repo.** Kein `plugin.wasm`, keine `.zip`, keine Binärdateien. Gebaut
  wird aus deinem Quelltext — nur so kann die Unterschrift über dem Verzeichnis etwas bedeuten.
* **`autor.json`** mit gültiger Unterschrift über dem Quelltext.
* **`LICENSE`** im Ordner.
* **Texte deutsch und englisch** in `name`, `description` und in den Bildschirmen.
* **`needs.network`** nur zu benannten Adressen **und mit Begründung** im Pull Request.
* **`needs.permissions`**: jedes Kernrecht wird im Pull Request begründet.
* **Die Kennung** ist die umgedrehte Schreibweise einer Domain, die dir gehört
  (`at.mueller.gartenplan`), und sie ist im Regal noch frei.
* `famhub-plugin prüfen` ohne Fehler.

Von Hand gelesen: das Manifest (*was will es, und passt das zu dem, was es zu sein behauptet*) und
ein Blick in den Quelltext auf offensichtliche Unehrlichkeit.

## Was dich danach erwartet

* **Du bleibst der Autor.** Dein Name und dein Kontakt stehen in der Verwaltung jedes Servers, der
  deine Erweiterung installiert — „geschrieben von … · Unterschrift geprüft".
* **Du pflegst sie.** Melden sich zwölf Monate lang weder du noch eine neue Fassung, wandert sie ins
  Archiv: installiert bleibt sie, aus dem Regal verschwindet sie.
* **Sicherheitsmeldungen** bitte an den Kontakt in der README — wir ziehen eine Fassung zurück, wenn
  es sein muss.

## Nach der Aufnahme etwas ändern

Neue Fassungsnummer im Manifest, `einreichen` noch einmal laufen lassen (die Unterschrift hängt am
Quelltext), Pull Request. Alte Fassungen bleiben im Regal — ein Server auf älterem Kern-Stand findet
so noch etwas, das zu ihm passt.
