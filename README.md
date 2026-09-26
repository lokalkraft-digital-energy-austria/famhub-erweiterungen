# FamHub-Erweiterungen

Hier wird eingereicht, was ins **Gemeinschaftsregal** von
[FamHub](https://git.lokalkraft.at/madh/famapp) soll — `plugins.lokalkraft.at/community`.

Eine Erweiterung läuft **auf dem Server**, im WebAssembly-Sandkasten: kein Dateisystem, kein Netz
außer den Adressen aus ihrem Manifest, keine fremde Tabelle, Zeit- und Speichergrenze je Aufruf.
Ihre Oberfläche wird **beschrieben**, nicht programmiert, und von der App mit deren eigenen
Bausteinen gebaut.

## In fünf Minuten

```sh
npm create famhub-plugin at.beispiel.garten
cd at.beispiel.garten
npx famhub-plugin bauen  .          # plugin.wat wird plugin.wasm
npx famhub-plugin prüfen .          # dieselben Prüfungen wie im Server
```

Ausprobieren: Ordner nach `DATA_DIR/plugins/<kennung>` auf deinem eigenen FamHub, dann
*Systemverwaltung › Erweiterungen › Auf der Platte* → einschalten. Dafür braucht es dieses Repo
nicht — nur, wenn du deine Erweiterung **anderen Familien** anbieten willst.

## Einreichen

1. **Unterschreiben** (einmal einen Schlüssel erzeugen, er bleibt bei dir):

   ```sh
   npx famhub-plugin schlüssel --out ~/.config/famhub/autor.pem
   npx famhub-plugin einreichen . --key ~/.config/famhub/autor.pem \
       --name "Dein Name" --kontakt "du@example.com"
   ```

   Das schreibt `autor.json`: dein Name, dein Kontakt, dein öffentlicher Schlüssel und deine
   Unterschrift über dem **Quelltext**.

2. **Pull Request** mit einem Ordner unter `erweiterungen/<kennung>/` — **nur Quelltext**:
   `famhub.plugin.json`, `screens.json`, `migrations/`, `plugin.wat` (oder Rust-/Go-Quelle),
   `autor.json`, `LICENSE`. **Kein `plugin.wasm`**, keine Binärdateien.

3. Die Prüfung läuft von selbst und schreibt ihr Ergebnis in den Pull Request.

4. Wird er zusammengeführt, baut lokalkraft das Paket **aus deinem Quelltext**, unterschreibt das
   Verzeichnis und stellt es ins Regal. Eine neue Fassung ist derselbe Weg noch einmal.

## Was die beiden Unterschriften bedeuten

| Unterschrift | Von wem | Sagt |
|---|---|---|
| über dem Verzeichnis | lokalkraft | „Diesen Autor habe ich hereingelassen, und das Paket haben **wir** aus seinem Quelltext gebaut." |
| über dem Quelltext | dir | „Dieser Quelltext ist meiner, unverändert." |

lokalkraft bescheinigt damit **Identität und Aufnahme** — nicht, dass jede Zeile gelesen wurde.
Was geprüft wird, steht in [CONTRIBUTING.md](CONTRIBUTING.md).

## Du musst nicht hierher

Du kannst jederzeit **deine eigene Quelle** betreiben: `famhub-plugin verzeichnis` schreibt ein
signiertes `index.json`, jeder Betreiber trägt deine Adresse und deinen Schlüssel selbst ein. Dieser
Weg ist gleichberechtigt und braucht niemandes Zustimmung.
