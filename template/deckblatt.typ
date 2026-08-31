// deckblatt.typ — Titelblatt für Hausarbeiten
// Durchgehend linksbündig: Kopfblock oben (Universität bis Dozent, 12 pt),
// Titelblock im oberen Drittel (16 pt, Titel fett, Untertitel normal),
// Adressblock unten (12 pt). Titel und Untertitel stehen in der Display-
// Schrift des Dokuments, alles Übrige in der Grundschrift.

// Text aus einem beliebigen Wert ziehen. Quarto bringt dafür zwar
// `content-to-string` mit, die Funktion steht aber im Hauptdokument und ist
// aus diesem Modul heraus nicht sichtbar — Typst-Module teilen keinen Scope,
// ein `import` in `index.typ` importiert nur hierher, nicht umgekehrt.
// Die Variante hier bricht bei keinem Elementtyp ab: was sich nicht in Text
// auflösen lässt (etwa `linebreak()`), liefert einen leeren String. Für die
// reinen Textfelder des Deckblatts ist das genau richtig.

// `join` liefert über einem leeren Array `none` statt `""`. Das trifft leeren
// Content (`[]`) — etwa wenn jemand keine Mailadresse angibt, denn
// `typst-show.typ` schreibt `email: []` auch dann. `leer()` riefe darauf
// `.trim()` auf und bräche ab; dieser Fallback fängt das ab.
#let ohne-none(wert) = if wert == none { "" } else { wert }

#let inhalt-text(wert) = {
  if wert == none { "" }
  else if type(wert) == str { wert }
  else if type(wert) in (int, float) { str(wert) }
  // YAML-Listen (etwa mehrzeilige Adressen) kommen als Array an. Arrays haben
  // kein `has`, deshalb muss dieser Fall vor den Content-Zweigen stehen.
  else if type(wert) == array { ohne-none(wert.map(inhalt-text).join("")) }
  else if wert.has("text") { inhalt-text(wert.text) }
  else if wert.has("children") { ohne-none(wert.children.map(inhalt-text).join("")) }
  else if wert.has("body") { inhalt-text(wert.body) }
  else { "" }
}

#let deckblatt(
  universitaet: "Ludwig-Maximilians-Universität München",
  institut: "Geschwister-Scholl-Institut für Politikwissenschaft",
  semester: none,          // z. B. "Wintersemester 2026/27"
  modul: none,             // z. B. "P 4 Vergleichende Politikwissenschaft"
  veranstaltung: none,
  dozent: none,
  titel: none,
  untertitel: none,
  // Je Eintrag ein Dictionary mit `name`, `matrikelnummer` und `mail`.
  // Mehrere Einträge stehen unten nebeneinander, eine Spalte je Person.
  autoren: (),
  fachsemester: none,      // gilt gemeinsam für alle Personen
  adresse: none,           // gemeinsam; mehrzeilig über eine YAML-Liste
  abgabedatum: none,
  // Inhalt, der noch auf das Deckblatt selbst gehört, bevor umgebrochen wird.
  // Gedacht für den Reset des Seitenzählers (siehe `typst-template.typ`): Der
  // muss am Ende der letzten ungezählten Seite stehen, nicht dahinter — nach
  // dem `pagebreak` unten läge er schon auf der Folgeseite und käme dort eine
  // Seite zu spät.
  abschluss: none,
  schrift: ("Times New Roman",),      // Grundschrift des Deckblatts
  titel-schrift: ("SF Pro Display",), // nur Titel und Untertitel
) = {
  // `numbering`/`header`/`footer` müssen explizit abgeschaltet werden: Quarto
  // setzt vor dem Aufruf von `article` global `page(numbering: "1")`, und ein
  // `set page(...)` überschreibt nur die hier genannten Felder.
  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2cm, x: 2.5cm),
    numbering: none,
    header: none,
    footer: none,
  )
  set text(font: schrift, size: 12pt, weight: "regular", lang: "de")
  set par(leading: 0.5em, spacing: 0.5em, justify: false)

  // Leer im Sinne des Deckblatts: nicht gesetzt oder inhaltsleer. Fängt auch
  // den Fall ab, dass Quarto für einen fehlenden Wert ein leeres Content-
  // Element (`[]`) liefert statt gar keines.
  let leer(wert) = inhalt-text(wert).trim() == ""

  // Kopfblock oben links, ohne Leerzeilen dazwischen. Die Zeilen werden mit
  // `join` gesetzt statt mit `\` am Zeilenende, damit fehlende Angaben — etwa
  // kein `dozent:` im YAML — keine leere Zeile hinterlassen.
  align(left)[
    #(
      universitaet,
      institut,
      semester,
      modul,
      veranstaltung,
      dozent,
    ).filter(z => not leer(z)).map(z => [#z]).join(linebreak())
  ]

  // Dehnbare Abstände statt fester Leerzeilen: sie halten das Deckblatt auf
  // einer Seite, unabhängig davon, wie lang Titel und Adressblock ausfallen.
  // Das Verhältnis 0.5 : 1 setzt den Titelblock ins obere Drittel.
  v(0.5fr)

  align(left)[
    #set text(font: titel-schrift, size: 16pt)
    #if not leer(titel) { strong(titel) }
    #if not leer(untertitel) [\ #untertitel]
  ]

  v(1fr)

  // Name und Matrikelnummer stehen in einer Zeile, die Nummer in Klammern.
  // Der dreifache Zweig verhindert einsame Klammern, wenn nur eines der
  // beiden Felder gesetzt ist; sind beide leer, liefert die Bindung `none`
  // und fällt unten im `filter` weg.
  let namenszeile(name, nummer) = if not leer(name) and not leer(nummer) {
    [#name (#nummer)]
  } else if not leer(name) {
    [#name]
  } else if not leer(nummer) {
    [#nummer]
  }

  // Mailadressen enthalten keine Leerzeichen und liefen als ein einziges Wort
  // über die Spalte hinaus in die Spalte daneben. Ein Zero-Width-Space nach
  // `@` und `.` gibt Typst Umbruchstellen, ohne sichtbar etwas einzufügen —
  // Silbentrennung hilft hier nicht, die setzte einen Bindestrich in die
  // Adresse. Nur diese beiden Zeichen, damit die Adresse an ihren natürlichen
  // Stellen bricht und beim Kopieren möglichst wenig Unsichtbares mitkommt.
  let umbrechbar(wert) = {
    let s = inhalt-text(wert)
    if s == "" { none } else { s.replace(regex("[@.]"), m => m.text + "\u{200B}") }
  }

  // Eine Spalte je Person: Name mit Matrikelnummer, darunter die Mailadresse.
  // Gleiches Muster wie der Kopfblock — fehlende Angaben fallen ersatzlos weg,
  // statt eine leere Zeile zu hinterlassen. Das `map(z => [#z])` hebt alles
  // auf Content, weil ein Teil der Werte als String ankommt, der Rest als
  // Content, und `join` Einheitlichkeit braucht.
  let autor-spalte(person) = (
    namenszeile(
      person.at("name", default: none),
      person.at("matrikelnummer", default: none),
    ),
    umbrechbar(person.at("mail", default: none)),
  ).filter(z => not leer(z)).map(z => [#z]).join(linebreak())

  // Eine YAML-Liste als Adresse wird unten per `..` zu eigenen Zeilen
  // aufgefaltet; ein einzelner Wert wird dafür in ein Array verpackt.
  let adress-zeilen = if type(adresse) == array { adresse } else { (adresse,) }

  // Personen nebeneinander, höchstens drei je Zeile: bei mehr Autorinnen und
  // Autoren bricht das Grid von selbst um, statt die Spalten immer schmaler
  // werden zu lassen. `1fr` statt `auto`, damit die zweite Spalte an einer
  // vorhersehbaren Stelle beginnt und nicht an der Länge des ersten Namens
  // klebt. Bei genau einer Person ist es eine Spalte über die volle Breite,
  // das Deckblatt sieht dann aus wie zuvor.
  // `above`/`below` explizit auf den Zeilenabstand: sonst setzte Typst den
  // Grid-Block als eigenen Absatz ab und risse eine Lücke in den Adressblock.
  let besetzte = autoren.filter(person => not leer(autor-spalte(person)))
  // Vier Personen stehen als 2 × 2 besser als 3 + 1, sonst so viele Spalten
  // wie Personen, höchstens drei.
  let spalten = if besetzte.len() == 4 { 2 } else { calc.min(besetzte.len(), 3) }
  if besetzte.len() > 0 {
    block(width: 100%, above: 0em, below: 0.5em, grid(
      columns: (1fr,) * spalten,
      column-gutter: 1em,
      // Deutlich mehr als der Zeilenabstand: Sonst liest sich eine umbrochene
      // zweite Zeile wie die Fortsetzung der ersten Spalte statt als neue Zeile.
      row-gutter: 1.2em,
      ..besetzte.map(person => autor-spalte(person)),
    ))
  }

  // Gemeinsamer Block darunter: Angaben, die für alle Personen gelten. Nach
  // demselben Muster wie der Kopfblock, eine Zeile je Angabe.
  align(left)[
    #(
      if not leer(fachsemester) { [#fachsemester. Fachsemester] },
      ..adress-zeilen,
      // Bewusst als String statt als Original-Content: so ist der
      // Aufzählungspunkt endgültig aufgelöst und wird nicht neu geparst.
      if not leer(abgabedatum) { inhalt-text(abgabedatum) },
    ).filter(z => not leer(z)).map(z => [#z]).join(linebreak())
  ]

  abschluss
  pagebreak(weak: true)
}
