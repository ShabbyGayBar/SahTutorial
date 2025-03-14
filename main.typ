#import "@preview/ilm:1.4.0": *
#import "conf.typ": *

#show: show-cn-fakebold
#set text(
  lang: "zh",
  font: ziti.songti
)
#show raw: set text(font: ziti.dengkuan, size: 12pt)
#show emph: text.with(font: ziti.kaiti)
#show strong: text.with(font: ziti.heiti)

#show: codly-init.with()
#codly(
  display-name: false,
  languages: codly-languages,
)

#show: ilm.with(
  title: [采样开关仿真],
  author: "EE503-16 工程实践与科技创新II",
  date: datetime(year: 2025, month: 03, day: 19),
  // abstract: [ ],
  // preface: [ ],
  // bibliography: bibliography("ref.bib"),
  // figure-index: (enabled: true),
  // table-index: (enabled: true),
  // listing-index: (enabled: true),
  appendix: (
    enabled: true,
    title: "附录", // optional
    heading-numbering-format: "A.1.1.", // optional
    body: include "contents/appendix.typ"
  ),
)

#include "contents/intro.typ"
#include "contents/steps.typ"

