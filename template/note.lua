-- note.lua — eine Quelle für Anmerkungen unter Abbildungen und Tabellen.
--
-- `::: {.note} … :::` wird formatabhängig übersetzt:
--   Typst → `#note[ … ]`, also die Funktion aus typst-template.typ
--   HTML  → bleibt ein `<div class="note">` und wird per CSS gestylt
--
-- Der Inhalt wird dabei nicht in Text umgewandelt, sondern als Blöcke
-- durchgereicht. Kursives, Zitate und Zeilenumbrüche bleiben dadurch in
-- beiden Formaten erhalten.

function Div(div)
  if not div.classes:includes("note") then
    return nil
  end

  if quarto.doc.is_format("typst") then
    local blocks = pandoc.List()
    blocks:insert(pandoc.RawBlock("typst", "#note["))
    blocks:extend(div.content)
    blocks:insert(pandoc.RawBlock("typst", "]"))
    return blocks
  end

  return nil
end
