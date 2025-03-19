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
)

#include "contents/intro.typ"
#include "contents/steps.typ"

#show: appendix
#include "contents/appendix.typ"