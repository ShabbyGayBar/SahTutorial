// Drawing support
#import "@preview/cetz:0.3.3"
#import "@preview/fletcher:0.5.6"

// SI unit support
#import "@preview/unify:0.7.1": num, qty, unit

// Subfigure support
#import "@preview/subpar:0.2.1"

// Fancy text box support
#import "@preview/showybox:2.0.4": showybox

// Code listing support
#import "@preview/codly:1.2.0": *
#import "@preview/codly-languages:0.1.1": *

// CJK bold font support
#import "@preview/cuti:0.2.1": show-cn-fakebold

// Tip message box setup
#let tip(body, title: "", color: blue) = {
  showybox(
    title-style: (
      weight: 900,
      color: color.darken(40%),
      sep-thickness: 0pt,
      align: center,
    ),
    frame: (
      title-color: color.lighten(80%),
      border-color: color.darken(40%),
      thickness: (left: 1pt),
      radius: 0pt,
    ),
    title: strong(title),
  )[#body]
}

// CJK font setup
#let ziti = (
  // 宋体，属于「有衬线字体」，一般可以等同于英文中的 Serif Font
  // 这一行分别是「新罗马体（有衬线英文字体）」、「宋体（MacOS）」、「宋体（Windows）」、「华文宋体」
  songti: ("Times New Roman", "Songti SC", "SimSun", "STSongti"),
  // 黑体，属于「无衬线字体」，一般可以等同于英文中的 Sans Serif Font
  // 这一行分别是「新罗马体（有衬线英文字体）」、「黑体（MacOS）」、「黑体（Windows）」、「华文黑体」
  heiti: ("Times New Roman", "Heiti SC", "SimHei", "STHeiti"),
  // 楷体
  // 这一行分别是「新罗马体（有衬线英文字体）」、「楷体（MacOS）」、「锴体（Windows）」、「华文黑体」、「方正楷体」
  kaiti: ("Times New Roman", "Kaiti SC", "KaiTi", "STKaiti", "KaiTi_GB2312"),
  // 仿宋
  // 这一行分别是「新罗马体（有衬线英文字体）」、「方正仿宋」、「仿宋（MacOS）」、「仿宋（Windows）」、「华文仿宋」
  fangsong: ("Times New Roman", "FangSong_GB2312", "FangSong SC", "FangSong", "STFangSong"),
  // 等宽字体，用于代码块环境，一般可以等同于英文中的 Monospaced Font
  // 这一行分别是「Menlo(MacOS 等宽英文字体)」、「Courier New(等宽英文字体)」、「黑体（MacOS）」、「黑体（Windows）」、「华文黑体」
  dengkuan: ("Menlo", "Courier New", "Heiti SC", "SimHei", "STHeiti"),
)

// Appendix environment setup
#let appendix(body) = {
  pagebreak()
  counter(heading).update(0) // Reset the heading counter
  set heading(
    numbering: "A.1.",
  )

  body
}