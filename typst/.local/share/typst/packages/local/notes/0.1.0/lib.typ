// ─── NOTES ──────────────────────────────────────────────────

#let notes(
  title: "",
  course: "",
  author: "Yudi Wu",
  body,
) = {
  set document(title: title, author: author)

  set page(
    paper: "a4",
    margin: (x: 2.5cm, y: 3cm),
    numbering: "1",
    number-align: center,
  )

  set text(font: "New Computer Modern", size: 11pt, lang: "en")
  set par(justify: true, leading: 0.75em, spacing: 1.2em)
  set heading(numbering: "1.1")
  set math.equation(numbering: "(1)")

  show heading: it => {
    v(0.5em)
    it
    v(0.3em)
  }

  align(center)[
    #text(16pt, weight: "bold")[#title] \
    #v(0.2em)
    #text(11pt, style: "italic")[#course] \
    #text(9pt, fill: gray)[#author]
  ]

  v(1.5em)
  outline(indent: auto)
  pagebreak()

  body
}

// ─── THEOREM ENVIRONMENTS ───────────────────────────────────

#let thmbox(title, color, body) = block(
  width: 100%,
  inset: 10pt,
  radius: 4pt,
  stroke: color,
  fill: color.lighten(92%),
)[
  #text(weight: "bold")[#title] #h(0.5em) #body
]

#let theorem(title: "", body) = thmbox("Theorem" + if title != "" [. #title] + ".", blue, body)
#let definition(title: "", body) = thmbox("Definition" + if title != "" [. #title] + ".", green, body)
#let lemma(title: "", body) = thmbox("Lemma" + if title != "" [. #title] + ".", purple, body)
#let corollary(title: "", body) = thmbox("Corollary" + if title != "" [. #title] + ".", teal, body)
#let claim(title: "", body) = thmbox("Claim" + if title != "" [. #title] + ".", red.lighten(20%), body)
#let remark(body) = thmbox("Remark.", orange, body)
#let example(title: "", body) = thmbox("Example" + if title != "" [. #title] + ".", gray, body)
#let proof(title: "", body) = block(inset: (left: 1em))[
  _Proof#if title != "" [. #title] else [.]_ #body #h(1fr) $square$
]
#let algorithm(title: "", body) = block(
  width: 100%,
  inset: 10pt,
  radius: 4pt,
  stroke: black,
  fill: luma(245),
)[
  #text(weight: "bold")[Algorithm#if title != "" [. #title]] \
  #v(0.3em)
  #set text(font: "New Computer Modern Mono")
  #body
]
