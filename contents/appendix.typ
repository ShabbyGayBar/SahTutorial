#import "../conf.typ": *

= 使用VerilogA搭建理想采样开关 <veriloga>

*VerilogA*和鼎鼎大名的Verilog类似，都属于*硬件描述语言* (Hardware Description Language)。

在语言风格上两者有不少相似之处，但也仅限于此。两者编译器不互通，且语法无法一一对应。更重要的是，Verilog是"*可综合的*"，这意味着其可以转化成实际的电路图。而VerilogA只能用于给器件建模。

这是由于VerilogA被设计用于描述模拟电路，而Verilog仅用于数字。也有人在两者基础上建立了一个*通用*的语言，即*Verilog-AMS*，但由于两者的应用场景不同，且受限于仿真性能，Verilog-AMS并没有被广泛使用。

Cadence Virtuoso支持以上*全部*三种语言进行器件建模。但其中Verilog和Verilog-AMS在仿真时都依赖一种叫做*AMS*的专用仿真器，其仿真运行过程中需要不断将数字逻辑转化为各种电气特性，这*拖累*了仿真速度。相比之下，VerilogA则是一种"原生"的模拟语言，可以直接使用*SPICE*仿真器进行仿真，速度更快。

尽管如此，由于模拟工程师在数量上远远不如数字工程师，VerilogA的使用范围相对较窄，社区也相对萎缩。以至于在简体中文互联网上很难找到关于VerilogA的系统性的教程#footnote[有条件的同学建议参考#link("https://verilogams.com")]，你甚至没法在VS Code中找到一个支持给VerilogA做语法高亮的插件。

也正是由于VerilogA的冷门，使得我决定将这个教程放在最后的附录中。

了解这些后，我们将在本次教程中，使用VerilogA代码来实现一个采样开关。

+ 在库管理器 (Library Manager) 界面中，点击菜单栏的`File`->`New`->`Cell View`，创建一个新的单元 (CellView)。
+ 在弹出的如@cell_view_veriloga 所示的对话框中，将Cell命名为`sample_switch`，选择`VerilogA`类型。点击`OK`按钮。
  #figure(
    image("../figures/cell_view_veriloga.png", width: 50%),
    caption: [创建新的VerilogA电路视图],
  ) <cell_view_veriloga>
+ 在新创建的Verilog-A文本编辑器视图中，输入以下代码：
  ```verilog
  // VerilogA for SARADC, sample_switch, veriloga
  `include "constants.vams"
  `include "disciplines.vams"

  module sample_switch(clk, in, out, vdd, gnd);
  input clk, in;
  inout out, vdd, gnd;
  electrical clk, in, out, vdd, gnd;
  parameter real ron = 25; // on resistance
  parameter real vtrans = 1.65;
  real iout;
  genvar i;

  analog begin
  	@(initial_step) begin
  		iout=0;
  	end
  	@(cross(V(clk)-vtrans,-1)) begin // Hold
  		iout=0;
  	end
  	if (V(clk)>vtrans) begin // Track
  		iout=V(out,in)/ron;
  	end
  	I(out) <+ iout;
  	I(in) <+ -iout;
  end
  endmodule
  ```
+ 点击Toolbar中的`Check & Save`按钮#box(baseline: 20%, image("../figures/button_check_and_save.png"), width: 12pt)保存代码。
+ 在弹出的如@create_symbol_veriloga 所示的对话框中。点击`OK`按钮定制Symbol，即采样开关在原理图中调用时的外观。
  #figure(
    image("../figures/create_symbol_veriloga.png", width: 30%),
    caption: [保存VerilogA代码后弹出的对话框],
  ) <create_symbol_veriloga>
+ 如果你已经在@ideal_switch 中创建了Symbol，那么这里将会弹出一个如@create_symbol_schematic 所示的对话框，询问是否覆盖之前创建的Symbol，这里点击`Cancel`按钮，并直接点击右上角的`X`按钮关闭Schematic视图。反之则进入下一步骤。
  #figure(
    image("../figures/create_symbol_schematic.png", width: 30%),
    caption: [保存Schematic代码后弹出的对话框],
  ) <create_symbol_schematic>
// 此处增加signal_type修改
+ 在弹出的对话框中，修改`Pin Specifications`中的端口位置使之如@symbol_pin_spec_veriloga 所示 (也可以保持默认，但下一步的外观会有所不同，功能上没有影响)。点击`OK`按钮。
  #figure(
    image("../figures/symbol_pin_spec_veriloga.png", width: 60%),
    caption: [Symbol生成设置],
  ) <symbol_pin_spec_veriloga>
+ 如@symbol_veriloga 所示，新的Symbol视图将会弹出。点击`Check & Save`按钮#box(baseline: 20%, image("../figures/button_check_and_save.png"), width: 12pt)保存Symbol。然后点击右上角的`X`按钮关闭Symbol视图和VerilogA编辑器。
  #figure(
    image("../figures/symbol_veriloga.png", width: 80%),
    caption: [Symbol视图],
  ) <symbol_veriloga>

= 加快仿真进度的方法

随着电路*复杂度*的增加，仿真时间也会相应增加。为了*加快*仿真进度，可以尝试以下方法，推荐程度不分先后：

- 最直觉的方法就是用*精度*换速度。可以在@ade_explorer_add_analysis_tran 中`Analysis`栏下的`Accuracy Defaults (errpreset)`属性栏选择`moderate`甚至`liberal`，这样仿真会更快完成。但会牺牲一定的仿真精度。
- 相对更稳妥的方法是改进仿真的*算法*。
  + 鼠标左键单击在@ade_explorer 中黄框部分的`Setup`->`High-Performance Simulation`，弹出如@ade_explorer_spectre 所示的对话框。
    #figure(
      image("../figures/ade_explorer_spectre.png", width: 60%),
      caption: [高性能仿真设置],
    ) <ade_explorer_spectre>
  + 在`Simulation Performance Mode`属性栏选择`Spectre X`，在`Preset`属性栏选择`CX`，如@ade_explorer_spectre_x 所示。点击`OK`按钮即可。
    #figure(
      image("../figures/ade_explorer_spectre_x.png", width: 60%),
      caption: [Spectre X设置],
    ) <ade_explorer_spectre_x>
  + 如果`Simulation Performance Mode`属性栏中没有`Spectre X`选项，可以转而使用APS。在`Simulation Performance Mode`属性栏选择`APS`，其余选项保持默认，如@ade_explorer_aps 所示。点击`OK`按钮即可。
    #figure(
      image("../figures/ade_explorer_aps.png", width: 60%),
      caption: [APS设置],
    ) <ade_explorer_aps>
- 在transient analysis设置中勾选`Transient Noise`会对电路中的*噪声*进行仿真，这会*极大减慢*仿真进度。如果仅对电路进行*功能性验证*或*非线性*仿真，可以不勾选`Transient Noise`。
- 使用*参数扫描*时，每个参数值都会进行一次仿真，因此参数值越多，仿真时间越长。如果同时开启*多个任务*，进行多个参数值的仿真，就能减少仿真排队时间。在@ade_explorer 中黄框部分的`Setup`->`Job Setup`，弹出如@ade_explorer_job_setup 所示的对话框。在`Max. Jobs`属性栏输入你希望同时进行的仿真数，建议该值选取不要超过5，以免给服务器造成太大压力。其余选项保持默认。点击`OK`按钮即可。
  #figure(
    image("../figures/ade_explorer_job_setup.png", width: 40%),
    caption: [多任务设置],
  ) <ade_explorer_job_setup>
