// Font used for all headings and for the whole title page. The body text font
// stays whatever `mainfont:` in the YAML says.
#let display-font = ("SF Pro Display",)

// GSI-/LMU-Deckblatt als Alternative zur Standard-Titelseite (siehe
// `deckblatt:` weiter unten in `article`).
// Der Alias ist nötig: `article` hat einen Parameter `deckblatt` (den Schalter
// aus dem YAML), der den importierten Namen innerhalb der Funktion sonst
// verdeckt — `deckblatt(...)` wäre dann ein Aufruf auf einen Boolean.
// Der Pfad ist relativ zur erzeugten `index.typ` im Projektordner, nicht zu
// dieser Datei: Quarto kopiert den Inhalt der Partials dorthin, bevor Typst
// übersetzt. Deshalb steht hier `template/` davor, obwohl beide Dateien
// nebeneinander liegen.
#import "template/deckblatt.typ": deckblatt as deckblatt-page

// First-line indent of body paragraphs. `all: false` keeps the indent off the
// first paragraph after a heading (or any other block-level element).
#let body-indent = (amount: 1.25em, all: false)

// Umrechnung von `linestretch` (Word-Lesart: 1 = einzeilig) in Typsts
// `leading`. Warum die Formel so aussieht, steht bei `set par(…)` in `article`.
#let leading-fuer(linestretch) = (linestretch * 1.15 - 1) * 1em

// Für Elemente, die den Zeilenabstand des Fließtexts nicht erben sollen:
// Tabellen und Anmerkungen. Relativ zur Schriftgröße, gilt also auch für deren
// kleinere Grade.
#let single-leading = leading-fuer(1)

#let article(
  title: none,
  subtitle: none,
  authors: none,
  keywords: (),
  date: none,
  lang: "en",
  region: "US",
  font: none,
  fontsize: 11pt,
  mathfont: none,
  codefont: none,
  linestretch: 1.5,
  sectionnumbering: none,
  // Abstract aus dem YAML. Steht als eigene Vorspannseite vor dem
  // Inhaltsverzeichnis; `abstract-title` liefert Quarto sprachabhängig.
  abstract: none,
  abstract-title: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  // Titelseite. Mit `deckblatt: false` beginnt das Dokument direkt mit dem
  // Inhaltsverzeichnis bzw. dem Fließtext — Quartos Standard-Titelblock ist
  // hier bewusst nicht nachgebaut.
  deckblatt: false,
  universitaet: "Ludwig-Maximilians-Universität München",
  institut: "Geschwister-Scholl-Institut für Politikwissenschaft",
  semester: none,
  modul: none,
  veranstaltung: none,
  dozent: none,
  matrikelnummer: none,
  fachsemester: none,
  adresse: none,
  // Grundschrift des Deckblatts. Ohne Angabe im YAML folgt sie `mainfont`, also
  // derselben Schrift wie der Fließtext; Titel und Untertitel bekommen darüber
  // hinaus immer `display-font` — wie die Überschriften im Text.
  deckblatt-font: none,
  doc,
) = {
  // Set document metadata for PDF accessibility
  set document(title: title, keywords: keywords)
  set document(
    author: authors.map(author => content-to-string(author.name)).join(", ", last: " & "),
  ) if authors != none and authors != ()
  // `linestretch` aus dem YAML wird wie in Word gelesen: 1 = einzeilig,
  // 1.5 = anderthalbzeilig. Typst rechnet anders — `leading` ist nur der Abstand
  // *zwischen* zwei Zeilenboxen, deren Höhe von den Metriken der Schrift abhängt.
  // Mit den festen `top-edge`/`bottom-edge` unten ist jede Zeilenbox exakt 1em
  // hoch, der Zeilenabstand also `leading + 1em`; einzeilig entspricht 1.15em
  // (Word-Konvention). Quartos Standardformel `linestretch * 0.65em` ergäbe bei
  // 1.5 nur 19.65pt statt der erwarteten 20.7pt.
  let zeilenabstand = leading-fuer(linestretch)
  // `spacing` gleich `leading`: zwischen zwei Absätzen steht damit derselbe
  // Abstand wie zwischen zwei Zeilen, also kein zusätzlicher Absatzabstand.
  // Abgegrenzt werden Absätze über den Erstzeileneinzug (`body-indent`).
  // Abbildungen, Tabellen und Überschriften behalten ihre eigenen Abstände:
  // zwischen Absatz und Block gilt jeweils der größere der beiden Werte.
  set par(
    justify: true,
    leading: zeilenabstand,
    spacing: zeilenabstand,
  )
  // Abbildungen und Tabellen bekommen oben wie unten denselben Abstand: eine
  // Leerzeile des Fließtexts. Eine Zeile ist `1em` hoch (siehe `top-edge`/
  // `bottom-edge` unten), dazu kommt der Zeilenabstand.
  // Die Regel steht hier statt bei den übrigen Abbildungsregeln am Dateiende,
  // weil `linestretch` nur innerhalb von `article` bekannt ist.
  show figure: set block(above: 1em + zeilenabstand, below: 1em + zeilenabstand)
  // Abbildungen und Tabellen sind Floats: Passt eine nicht mehr auf die
  // angefangene Seite, rückt der nachfolgende Text auf und die Abbildung
  // wandert an den nächsten Seitenanfang oder ans Seitenende, statt eine
  // halbleere Seite zu hinterlassen. Der Preis: sie kann dabei auch über eine
  // Überschrift hinweg wandern. `placement: top` hält sie am Seitenanfang.
  // Anmerkungen müssen dafür innerhalb des Abbildungs-Divs stehen, sonst
  // bleiben sie im Textfluss zurück (siehe `note` am Dateiende).
  show figure: set figure(placement: auto)

  set text(lang: lang,
           region: region,
           size: fontsize,
           top-edge: 0.75em,
           bottom-edge: -0.25em)
  set text(font: font) if font != none
  show math.equation: set text(font: mathfont) if mathfont != none
  show raw: set text(font: codefont) if codefont != none

  set heading(numbering: sectionnumbering)
  show heading: set text(font: display-font, size: 12pt)
  // Space around headings; `below` is the gap to the first paragraph.
  show heading.where(level: 1): set block(above: 2em, below: 1.2em)
  show heading.where(level: 2): set block(above: 1.6em, below: 1em)

  // Reset of the page counter. It has to sit at the *end* of the last
  // unnumbered front page: a page's header is laid out before that page's
  // body, so a reset placed at the top of the first body page would not be
  // visible in its header yet.
  // Welche Seite das ist, hängt davon ab, was gesetzt ist — die Reihenfolge
  // des Vorspanns ist Deckblatt, Abstract, Inhaltsverzeichnis.
  let reset-page-counter = counter(page).update(0)
  let hat-abstract = abstract != none

  // ---------------------------------------------------------------
  // Page 1: Deckblatt (no header, no page number)
  //
  // `titel`, `untertitel`, `autoren` und `abgabedatum` kommen aus den Quarto-
  // Standardkeys `title:`, `subtitle:`, `author:` und `date:`, alles Weitere
  // aus den eigenen Keys im YAML.
  // ---------------------------------------------------------------
  if deckblatt {
    deckblatt-page(
      universitaet: universitaet,
      institut: institut,
      semester: semester,
      modul: modul,
      veranstaltung: veranstaltung,
      dozent: dozent,
      titel: title,
      untertitel: subtitle,
      // Je Person ein Dictionary; `deckblatt.typ` setzt sie nebeneinander in
      // Spalten. Matrikelnummer und Mailadresse gehören der einzelnen Person,
      // Fachsemester und Adresse gelten weiterhin für alle gemeinsam.
      autoren: if authors != none and authors != () {
        authors.map(a => (
          name: a.at("name", default: none),
          // Das top-level `matrikelnummer:` aus dem YAML bleibt Rückfallwert —
          // aber nur bei genau einer Person. Bei mehreren stünde dieselbe
          // Nummer unter jedem Namen und wäre für alle bis auf eine falsch.
          matrikelnummer: {
            let eigene = a.at("matrikelnummer", default: none)
            if eigene != none { eigene } else if authors.len() == 1 { matrikelnummer }
          },
          mail: a.at("email", default: none),
        ))
      } else { () },
      fachsemester: fachsemester,
      adresse: adresse,

      abgabedatum: date,
      // Die erste gesetzte Schrift gewinnt: YAML-Angabe, sonst `mainfont`.
      schrift: (deckblatt-font, font, ("Times New Roman",)).find(f => f != none),
      titel-schrift: display-font,
      // Ohne Abstract und ohne Inhaltsverzeichnis ist das Deckblatt die letzte
      // ungezählte Seite — der Reset gehört dann noch auf sie selbst.
      abschluss: if not hat-abstract and not toc { reset-page-counter },
    )
  }

  // ---------------------------------------------------------------
  // Abstract (no header, no page number)
  //
  // Eigene Seite vor dem Inhaltsverzeichnis. Die Überschrift steht wie die
  // Abschnittsüberschriften im Text (dieselben `show heading`-Regeln weiter
  // oben), ist aber weder nummeriert noch im Verzeichnis aufgeführt:
  // `numbering: none` hebt das `set heading(numbering: …)` für genau diese
  // Überschrift auf — der Abschnittszähler läuft dadurch erst im Fließtext
  // bei 1 los —, `outlined: false` hält sie aus dem `outline()` heraus.
  // ---------------------------------------------------------------
  if hat-abstract {
    page(header: none, footer: none, numbering: none)[
      #heading(level: 1, numbering: none, outlined: false)[
        #if abstract-title != none { abstract-title } else { "Abstract" }
      ]
      #abstract
      #if not toc { reset-page-counter }
    ]
  }

  // ---------------------------------------------------------------
  // Table of contents (no header, no page number)
  // ---------------------------------------------------------------
  if toc {
    page(header: none, footer: none, numbering: none)[
      #outline(
        title: toc_title,
        depth: toc_depth,
        indent: toc_indent
      )
      #reset-page-counter
    ]
  }

  // ---------------------------------------------------------------
  // Body: page number in the top-right header, restarting at 1
  // ---------------------------------------------------------------
  set page(
    numbering: none,
    footer: none,
    header: context align(right, counter(page).display("1")),
  )
  // Only from here on, so the Deckblatt and the outline stay unindented.
  set par(first-line-indent: body-indent)

  doc
}

// The first column gets no left padding, so the table's text lines up with the
// caption and the body text instead of sitting 6pt to the right of them.
#set table(
  inset: (x, y) => if x == 0 { (left: 0pt, rest: 6pt) } else { 6pt },
  stroke: none
)

// Tables: sans, 11pt, bold header row, no justification inside cells, single
// line spacing inside multi-line cells.
#show table: set text(font: display-font, size: 11pt)
#show table: set par(justify: false, leading: single-leading)
#show table.cell.where(y: 0): strong

// No rule under the header row. This has to be a `set` rule on the stroke:
// pandoc emits an explicit `table.hline()` element, but the grid layout reads
// its stroke directly, so `show table.hline: none` does not remove it.
#set table.hline(stroke: none)

// Tables flush left. Typst's `figure` centres its body, and pandoc's percentage
// column widths do not quite sum to 100%, so the table would sit slightly
// inset. Wrapping it in a full-width block left-aligns it.
#show table: t => block(width: 100%, align(left, t))

// Figure captions: above the figure, "Abbildung 1:" bold, caption text regular,
// both in the display font.
#show figure.caption: it => block(width: 100%)[
  #set align(left)
  #set text(font: display-font, size: 0.9em)
  #if it.numbering != none {
    strong[#it.supplement #context it.counter.display(it.numbering)#it.separator]
  }
  #it.body
]

// Anmerkung unter einer Abbildung oder Tabelle: #note[Anmerkung: …]
// Gehört ins Abbildungs-Div hinein, nicht dahinter — nur dann wandert sie beim
// Floaten mit (siehe `placement` in `article`). Sie steht deshalb als letztes
// Element im Figure-Körper: oben ein schmaler Abstand zur Abbildung, unten
// keiner, weil die Abbildung selbst schon eine Leerzeile unter sich aufspannt.
// `align(left)`, weil `figure` seinen Inhalt sonst zentriert.
#let note(body) = align(left, block(width: 100%, above: 0.45em, below: 0em)[
  #set text(font: display-font, size: 0.85em)
  #set par(first-line-indent: 0em, leading: single-leading)
  #body
])

// Bullet lists: en dash instead of the default bullet, and the whole list a bit
// further in. `indent` moves the marker away from the margin, `body-indent` is
// the gap between marker and text.
#set list(marker: [–], indent: 1em, body-indent: 0.5em)

// Literaturverzeichnis. Mit `citeproc: true` im YAML setzt Pandoc die Zitate,
// nicht Typst — nur so überleben Präfixe wie in `[siehe @autor2024, …]`. Das
// Verzeichnis ist damit kein `bibliography`-Element mehr, auf das sich `set`
// und `show` anwenden ließen, sondern ein Block mit dem Label `<refs>`.
// Die Überschrift kommt aus `## Literaturverzeichnis` am Ende der .qmd.
#show selector(<refs>): it => {
  set text(size: 10pt)
  set par(hanging-indent: 1.5em, first-line-indent: 0em)
  it
}
