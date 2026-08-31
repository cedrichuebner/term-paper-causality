#show: doc => article(
$if(title)$
  title: [$title$],
$endif$
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(by-author)$
  authors: (
$for(by-author)$
$if(it.name.literal)$
    ( name: [$it.name.literal$],
      affiliation: [$for(it.affiliations)$$it.name$$sep$, $endfor$],
      email: [$it.email$],
$-- Eigener Key je Person. Quarto steckt alles, was nicht zum Autorenschema
$-- gehört, unter `metadata` — dort landet `matrikelnummer:` aus dem YAML.
$-- Der `$else$`-Zweig ist Pflicht und darf nicht entfallen: Typst-Dictionaries
$-- sind je Eintrag eigenständig, und `authors.map(a => a.matrikelnummer)` im
$-- Template bräche ab, sobald ein Eintrag den Key nicht hätte.
      matrikelnummer: $if(it.metadata.matrikelnummer)$[$it.metadata.matrikelnummer$]$else$none$endif$ ),
$endif$
$endfor$
    ),
$endif$
$-- Als String, nicht als Content: In Typst-Markup läse `[17. August 2026]`
$-- die Ziffer als Aufzählungspunkt.
$if(date)$
  date: "$date$",
$endif$
$if(lang)$
  lang: "$lang$",
$endif$
$if(region)$
  region: "$region$",
$endif$
$if(mainfont)$
  font: ("$mainfont$",),
$elseif(brand.typography.base.family)$
  font: $brand.typography.base.family$,
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$elseif(brand.typography.base.size)$
  fontsize: $brand.typography.base.size$,
$endif$
$-- Quartos Standardpartial reicht hier Schrift, Gewicht, Stil, Farbe und
$-- Zeilenhöhe der Überschriften durch (aus `brand:` bzw. `mainfont:`).
$-- Das Template setzt all das fest, die Werte kämen nur an, um ignoriert zu
$-- werden. Gleiches gilt für `thanks` und die drei Linkfarben.
$-- `abstract-title` steht wie bei Quarto innerhalb von `$if(abstract)$`: ohne
$-- Abstract gibt es auch keine Überschrift dafür. `labels.abstract` ist der
$-- sprachabhängige Titel, also "Abstract" bei `lang: en`.
$if(abstract)$
  abstract: [$abstract$],
  abstract-title: "$labels.abstract$",
$endif$
$if(section-numbering)$
  sectionnumbering: "$section-numbering$",
$endif$
$if(mathfont)$
  mathfont: ($for(mathfont)$"$mathfont$",$endfor$),
$endif$
$if(codefont)$
  codefont: ($for(codefont)$"$codefont$",$endfor$),
$elseif(brand.typography.monospace.family)$
  codefont: $brand.typography.monospace.family$,
$endif$
$if(linestretch)$
  linestretch: $linestretch$,
$endif$
$if(keywords)$
  keywords: ($for(keywords)$"$keywords$",$endfor$),
$endif$
$if(toc)$
  toc: $toc$,
$endif$
$if(toc-title)$
  toc_title: [$toc-title$],
$endif$
$if(toc-indent)$
  toc_indent: $toc-indent$,
$endif$
  toc_depth: $toc-depth$,
$-- Eigene Keys für das GSI-/LMU-Deckblatt. Quarto reicht unbekannte Keys unter
$-- `format: typst:` zwar als Pandoc-Metadaten durch, der Standard-Show-Partial
$-- kennt sie aber nicht — ohne diese Zeilen kämen sie nie bei `article()` an.
$if(deckblatt)$
  deckblatt: true,
$endif$
$if(universitaet)$
  universitaet: [$universitaet$],
$endif$
$if(institut)$
  institut: [$institut$],
$endif$
$if(semester)$
  semester: [$semester$],
$endif$
$if(modul)$
  modul: [$modul$],
$endif$
$if(veranstaltung)$
  veranstaltung: [$veranstaltung$],
$endif$
$if(dozent)$
  dozent: [$dozent$],
$endif$
$-- Bleibt als Rückfallwert erhalten: Bei genau einer Person darf die Nummer
$-- weiterhin hier unter `format: typst:` stehen statt am Autoreneintrag.
$-- Bei mehreren Personen greift sie bewusst nicht (siehe `typst-template.typ`).
$if(matrikelnummer)$
  matrikelnummer: [$matrikelnummer$],
$endif$
$if(fachsemester)$
  fachsemester: [$fachsemester$],
$endif$
$-- Mehrzeilig über eine YAML-Liste; ein einzelner String ergibt eine Zeile.
$-- Ein `\` im String funktioniert nicht: Pandoc macht daraus ein `~`.
$if(adresse)$
  adresse: [$for(adresse)$$adresse$$sep$#linebreak()$endfor$],
$endif$
$-- Einzelner String oder YAML-Liste (Fallback-Kette).
$if(deckblatt-font)$
  deckblatt-font: ($for(deckblatt-font)$"$deckblatt-font$",$endfor$),
$endif$
  doc,
)
