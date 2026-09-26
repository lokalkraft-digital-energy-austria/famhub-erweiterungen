;; Strichliste — die Beispiel-Erweiterung im Sandkasten.
;;
;; Sie ist absichtlich in WebAssembly-Text geschrieben und nicht aus einer Hochsprache übersetzt:
;; So kann man Zeile für Zeile nachlesen, was eine Erweiterung im Sandkasten kann — und was nicht.
;; Sie hat genau **eine** Tür nach draußen (`famhub.host_call`), und alles, was sie erfährt, kommt
;; als JSON durch diese Tür zurück.
;;
;; Die Zeichenketten unten enden mit einem Null-Byte; `$strlen` zählt bis dorthin. Damit muss keine
;; Länge doppelt gepflegt werden.
(module
  ;; Was der Extism-Sandkasten an Werkzeug mitbringt: Speicher anfordern, Bytes hin- und herlegen,
  ;; eine Antwort setzen, einen Fehler setzen. Mehr gibt es nicht.
  (import "extism:host/env" "alloc" (func $alloc (param i64) (result i64)))
  (import "extism:host/env" "store_u8" (func $store_u8 (param i64 i32)))
  (import "extism:host/env" "length" (func $length (param i64) (result i64)))
  (import "extism:host/env" "output_set" (func $output_set (param i64 i64)))
  (import "extism:host/env" "error_set" (func $error_set (param i64)))
  ;; die einzige Tür zum Kern: JSON hinein, JSON heraus – 0 heißt „abgelehnt"
  (import "famhub" "host_call" (func $host_call (param i64) (result i64)))

  ;; Die Obergrenze (4 Seiten = 256 KB) steht **im Paket**. Ein Paket ohne Obergrenze lädt FamHub nicht.
  (memory (export "memory") 1 4)

  (data (i32.const 0) "[{\"method\":\"GET\",\"path\":\"/striche\",\"export\":\"striche\"},{\"method\":\"POST\",\"path\":\"/strich\",\"export\":\"strich\"},{\"method\":\"GET\",\"path\":\"/endlos\",\"export\":\"endlos\"},{\"method\":\"GET\",\"path\":\"/gierig\",\"export\":\"gierig\"}]\00")
  (data (i32.const 512) "{\"op\":\"db.exec\",\"sql\":\"insert into striche (tag) values (current_date)\"}\00")
  (data (i32.const 1024) "{\"op\":\"db.query\",\"sql\":\"select to_char(tag, 'DD.MM.YYYY') as \\\"name\\\", count(*)::int as n from striche group by tag order by tag desc limit 30\"}\00")
  (data (i32.const 1536) "Der Kern hat den Aufruf abgelehnt\00")
  (data (i32.const 1792) "{\"ok\":true}\00")

  (global $len (mut i32) (i32.const 0))

  ;; Länge einer Zeichenkette im eigenen Speicher (bis zum Null-Byte)
  (func $strlen (param $p i32) (result i32)
    (local $i i32)
    (block $done
      (loop $l
        (br_if $done (i32.eqz (i32.load8_u (i32.add (local.get $p) (local.get $i)))))
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (br $l)))
    (local.get $i))

  ;; eine Zeichenkette in den Speicher des Sandkastens legen; 0 heißt „kein Platz mehr"
  (func $put (param $p i32) (result i64)
    (local $n i32) (local $i i32) (local $off i64)
    (local.set $n (call $strlen (local.get $p)))
    (global.set $len (local.get $n))
    (local.set $off (call $alloc (i64.extend_i32_u (local.get $n))))
    (if (i64.eqz (local.get $off)) (then (return (i64.const 0))))
    (block $done
      (loop $l
        (br_if $done (i32.ge_u (local.get $i) (local.get $n)))
        (call $store_u8
          (i64.add (local.get $off) (i64.extend_i32_u (local.get $i)))
          (i32.load8_u (i32.add (local.get $p) (local.get $i))))
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (br $l)))
    (local.get $off))

  ;; eine feste Antwort zurückgeben
  (func $emit (param $p i32) (result i32)
    (local $o i64)
    (local.set $o (call $put (local.get $p)))
    (if (i64.eqz (local.get $o)) (then (return (i32.const 1))))
    (call $output_set (local.get $o) (i64.extend_i32_u (global.get $len)))
    (i32.const 0))

  (func $fail (result i32)
    (local $o i64)
    (local.set $o (call $put (i32.const 1536)))
    (if (i64.eqz (local.get $o)) (then (return (i32.const 1))))
    (call $error_set (local.get $o))
    (i32.const 1))

  ;; Welche Wege die Erweiterung anbietet – der Kern liest das einmal beim Laden.
  (func (export "routes") (result i32)
    (call $emit (i32.const 0)))

  ;; ein Strich für heute
  (func (export "strich") (result i32)
    (local $r i64)
    (local.set $r (call $host_call (call $put (i32.const 512))))
    (if (i64.eqz (local.get $r)) (then (return (call $fail))))
    (call $emit (i32.const 1792)))

  ;; die Striche, nach Tagen gezählt – die Antwort des Kerns wird unverändert durchgereicht
  (func (export "striche") (result i32)
    (local $r i64)
    (local.set $r (call $host_call (call $put (i32.const 1024))))
    (if (i64.eqz (local.get $r)) (then (return (call $fail))))
    (call $output_set (local.get $r) (call $length (local.get $r)))
    (i32.const 0))

  ;; Zum Beweis, dass die Zeitgrenze hält: eine Endlosschleife. Der Kern bricht sie ab.
  (func (export "endlos") (result i32)
    (loop $l (br $l))
    (i32.const 0))

  ;; Zum Beweis, dass die Speichergrenze hält: fordert Megabyte für Megabyte, bis der Kern nein sagt.
  (func (export "gierig") (result i32)
    (local $i i32) (local $o i64)
    (block $done
      (loop $l
        (local.set $o (call $alloc (i64.const 1048576)))
        (br_if $done (i64.eqz (local.get $o)))
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (br_if $done (i32.gt_u (local.get $i) (i32.const 4096)))
        (br $l)))
    ;; Hier ist Schluss: Der Kern hat den Speicher verweigert. Die Erweiterung stürzt ab –
    ;; und das ist der Punkt: Sie stürzt **allein** ab, der Server merkt es nur als Fehler.
    (unreachable))
)
