#import "conf.typ": *

#set document(
  title: [采样开关仿真],
  author: "Brian Li",
  description: "EE503-16 工程实践与科技创新II lab 4",
)

#show: mainmatter
#outline()
#pagebreak()

= 前置要求

- 安装Cadence Virtuoso IC23.1
- 安装SMIC18MMRF工艺库
- 了解*Linux*操作系统的基本概念。
- 能够在Linux操作系统中打开*终端 (Terminal)*，并输入教程中给出的命令。
- 了解基本的电路理论并能以此为根据进行基本的电路分析。
  - *KCL* (Kirchhoff's Current Law) 和 *KVL* (Kirchhoff's Voltage Law)。
  - 电阻、电容等基本元件的特性。
  - 一阶*RC网络*的低通频率响应。
- 了解*分贝* (#unit("dB"))的定义。
- 了解MOS管的*传输特性曲线，输出特性曲线*，以及其可以作为开关使用的原理#footnote[建议参考#link("https://shuiyuan.sjtu.edu.cn/t/topic/127792/32")]。
- 了解*傅里叶变换* (Fourier Transform) 和频谱分析 (Spectrum Analysis) 的基本概念#footnote[建议参考#link("https://shuiyuan.sjtu.edu.cn/t/topic/127792/117")]
- 了解噪声，尤其是*$(k T)/C$热噪声*的概念#footnote[建议参考#link("https://shuiyuan.sjtu.edu.cn/t/topic/127792/289")]
- 了解ADC相关指标的定义
  - *SNR* (Signal-to-Noise Ratio)
  - *SINAD* (Signal-to-Noise and Distortion Ratio)
  - *ENOB* (Effective Number of Bits)
  - *SFDR* (Spurious-Free Dynamic Range)
  - *THD* (Total Harmonic Distortion)
- 了解*栅压自举采样开关电路* (Bootstrapped Switch) 的基本原理#footnote[建议参考#link("https://zhuanlan.zhihu.com/p/564837987")]。

= 目的

本次教程中你将学会：

- 搭建一个*理想采样开关电路*
- 使用SMIC18MMRF工艺库搭建一个简单的*栅压自举采样开关电路* (Bootstrapped Switch)
- *相干采样* (Coherent Sampling) 的概念
- 使用*ADE Explorer*进行仿真
  - 瞬态仿真
  - 噪声仿真
  - 参数扫描仿真
  - 生成频谱及相关指标
  - 使用result browser查看电路中任意节点的电压波形
- 加快仿真进度的小技巧

#pagebreak()
= 步骤

== 创建新的设计库 (Library)

+ 打开Linux终端，输入以下命令：
  ```bash
  cd customize # 进入工作目录
  ee503 # 执行 cadence 环境配置
  virtuoso & # 启动 Virtuoso
  ```
  终端显示如@terminal
  #figure(
    image("figures/terminal.png", width: 80%),
    caption: [执行命令后的终端],
  ) <terminal>
  稍等片刻后，Virtuoso的主界面窗口 (CIW) (如@CIW 所示) 和库管理器 (Library Manager) 窗口 (如@lib_manager 所示) 将会弹出。
  #figure(
    image("figures/CIW.png", width: 80%),
    caption: [主界面窗口 (CIW)],
  ) <CIW>
  #figure(
    image("figures/lib_manager.png", width: 80%),
    caption: [库管理器 (Library Manager) 窗口],
  ) <lib_manager>
+ 在库管理器 (Library Manager) 界面中，点击菜单栏的`File`->`New`->`Library`
+ 在弹出的如@new_lib 所示的对话框中，创建一个新的设计库 (Library)，命名为`SARADC`。
  #figure(
    image("figures/new_lib.png", width: 50%),
    caption: [创建新的设计库],
  ) <new_lib>
+ 点击`OK`按钮，弹出如@new_lib_attach 所示的对话框。\
  在选项中选择`Attach to an existing technology library`，点击`OK`按钮。\
  这将使得我们在设计时只调用特定工艺库中的器件，以免出现不同工艺库之间的兼容性问题。
  #figure(
    image("figures/new_lib_attach.png", width: 40%),
    caption: [将新设计库绑定到现有工艺库],
  ) <new_lib_attach>
+ 在弹出的如@attach_tech_lib 所示的对话框中，选择`Technology Library`列中的`smic18mmrf`，点击`OK`按钮。
  #figure(
    image("figures/attach_tech_lib.png", width: 40%),
    caption: [选择工艺库],
  ) <attach_tech_lib>
+ 此时的库管理器窗口如@lib_manager_new_lib 所示。在左侧的`Library`栏中，可以看到新建的`SARADC`库。
  #figure(
    image("figures/lib_manager_new_lib.png", width: 80%),
    caption: [新建的设计库],
  ) <lib_manager_new_lib>

== 创建理想采样开关电路 <ideal_switch>

该采样开关既可以使用理想开关实现，也可使用VerilogA代码的形式 (@veriloga)。其中VerilogA的实现方法放在附录中作为补充材料。

+ 在库管理器 (Library Manager) 界面中，点击菜单栏的`File`->`New`->`Cell View`，创建一个新的单元 (CellView)。
+ 在弹出的如@cell_view_schematic 所示的对话框中，将Cell命名为`sample_switch`，选择`Schematic`类型。点击`OK`按钮。
  #figure(
    image("figures/cell_view_schematic.png", width: 30%),
    caption: [创建新的Schematic电路视图],
  ) <cell_view_schematic>
  如@schematic_ideal_switch_empty 所示，新的Schematic视图将会弹出。
  #figure(
    image("figures/schematic_ideal_switch_empty.png", width: 80%),
    caption: [Schematic视图],
  ) <schematic_ideal_switch_empty>
+ 在Schematic视图中，按键盘上的`i`键 (注意大小写，下同。若仍不注意使用了其他快捷键，可按键盘上的`esc`键取消)，打开`Add Instance`对话框。
+ 在弹出的如@add_instance_analogLib_switch 所示的对话框中，点击`Browse`按钮。
  #figure(
    image("figures/add_instance_analogLib_switch.png", width: 40%),
    caption: [添加实例],
  ) <add_instance_analogLib_switch>
+ 在弹出的如@lib_browser_analogLib_switch 所示的对话框中，选择`Library`列中的`analogLib`，`Cell`列中的`switch`，`View`列中的`symbol`。点击键盘上的`Enter`键。
  #figure(
    image("figures/lib_browser_analogLib_switch.png", width: 60%),
    caption: [选择sample_switch单元],
  ) <lib_browser_analogLib_switch>
  此时注意到Schematic视图中已经出现了一个如@analogLib_switch_shape 所示的，随鼠标拖动的黄色理想开关轮廓。
  #figure(
    image("figures/analogLib_switch_shape.png", width: 80%),
    caption: [理想开关轮廓],
  ) <analogLib_switch_shape>
+ 点击Schematic视图中的空白处，将理想开关实例化。如@schematic_analogLib_switch 所示。然后按键盘上的`esc`键关闭对话框。
  #figure(
    image("figures/schematic_analogLib_switch.png", width: 80%),
    caption: [理想开关实例化],
  ) <schematic_analogLib_switch>
+ 该理想开关没有指定任何属性，可能导致无法随控制信号断开或闭合。因此，需要指定理想开关的`Open voltage`和`Closed voltage`属性。\
  在Schematic视图中，左键点击理想开关，按键盘上的`q`键，打开`Edit Properties`对话框。
+ 在弹出的如@edit_properties_analogLib_switch 所示的对话框中，在`Open voltage`属性栏输入`0.8`，`Closed voltage`属性栏输入`1` (不用写单位，属性栏失去鼠标焦点时会自动补全)。点击`OK`按钮。\
  在仿真中，当控制端电压高于`Closed voltage`时，理想开关闭合；当控制端电压低于`Open voltage`时，理想开关断开。
  #figure(
    image("figures/edit_properties_analogLib_switch.png", width: 50%),
    caption: [编辑理想开关属性],
  ) <edit_properties_analogLib_switch>
+ 在Schematic视图中，按键盘上的`i`键，再次打开`Add Instance`对话框。
+ 在弹出的如@add_instance_analogLib_switch 所示的对话框中，点击`Browse`按钮。
+ 在弹出的如@lib_browser_analogLib_res 所示的对话框中，选择`Library`列中的`analogLib`，`Cell`列中的`res`，`View`列中的`symbol`。点击键盘上的`Enter`键。
  #figure(
    image("figures/lib_browser_analogLib_res.png", width: 60%),
    caption: [选择res单元],
  ) <lib_browser_analogLib_res>
+ 点击Schematic视图中的空白处，将理想电阻实例化。如@schematic_analogLib_res 所示。按键盘上的`esc`键关闭对话框。
  #figure(
    image("figures/schematic_analogLib_res.png", width: 80%),
    caption: [理想电阻实例化],
  ) <schematic_analogLib_res>
+ 该理想电阻的阻值默认为#qty(1, "kilo ohm")。我们可以将其阻值设置为一个参数，以便后续仿真时更改。\
  在Schematic视图中，左键点击理想电阻，按键盘上的`q`键，打开`Edit Properties`对话框。
+ 在弹出的如@edit_properties_analogLib_res 所示的对话框中，在`Value`属性栏输入`ron`。点击`OK`按钮。\
  在仿真中，理想电阻的阻值将会被设置为`ron`。这也将是开关的导通电阻大小。
  #figure(
    image("figures/edit_properties_analogLib_res.png", width: 50%),
    caption: [编辑理想电阻属性],
  ) <edit_properties_analogLib_res>
+ 接下来添加Symbol中的端口。在Schematic视图中，按键盘上的`p`键，打开`Add Pin`对话框。
+ 在弹出的如@pin_vdd 所示的对话框中，在`Names`属性栏输入`vdd`，在`Direction`属性栏选择`inputOutput`，在`Usage`属性栏选择`power`。\
  此时将鼠标移动到Schematic视图，注意到Schematic视图中已经出现了一个如@schematic_add_pin 所示的，随鼠标拖动的黄色端口轮廓。
  #figure(
    image("figures/schematic_add_pin.png", width: 80%),
    caption: [端口轮廓],
  ) <schematic_add_pin>
  点击Schematic视图中的空白处，将该端口实例化。
  #figure(
    image("figures/pin_vdd.png", width: 40%),
    caption: [添加端口],
  ) <pin_vdd>
+ 重复上述步骤，添加`gnd`、`clk`、`in`、`out`等端口，如@pin_gnd、@pin_clk、@pin_in、@pin_out 所示。然后按键盘上的`esc`键关闭对话框。
  #grid(
    columns: 2,
    rows: 2,
    gutter: 8pt,
    [#figure(
        image("figures/pin_gnd.png", width: 80%),
        caption: [gnd端口],
      ) <pin_gnd>],
    [#figure(
        image("figures/pin_clk.png", width: 80%),
        caption: [clk端口],
      ) <pin_clk>],

    [#figure(
        image("figures/pin_in.png", width: 80%),
        caption: [in端口],
      ) <pin_in>],
    [#figure(
        image("figures/pin_out.png", width: 80%),
        caption: [out端口],
      ) <pin_out>],
  ) <add_pin>
+ 添加完端口后的Schematic视图如@schematic_pin 所示。此时点击`Check & Save`按钮#box(baseline: 20%, image("figures/button_check_and_save.png"), width: 12pt)，会弹出如@schematic_check 所示的警告，表明电路仍未完成。
  #figure(
    image("figures/schematic_pin.png", width: 80%),
    caption: [添加完端口后的Schematic视图],
  ) <schematic_pin>
  #figure(
    image("figures/schematic_check.png", width: 30%),
    caption: [点击`Check & Save`按钮后弹出的警告信息],
  ) <schematic_check>
+ 接下来需要完成端口和器件的连线。
  + 在Schematic视图中，按键盘上的`w`键，进入连线模式。
  + 左键单击需要连接的端口或器件。
  + 左键单击另一个端口或器件，或者在空白处双击，即可完成连线。
  要移动端口或器件时，
  + 在Schematic视图中，鼠标左键单击或长按鼠标左键框选需要移动的器件。
  + 按键盘上的`m`键。
  + 鼠标左键单击原理图空白处，该端口或器件即可随鼠标拖动。
  + 再次鼠标左键单击目标位置完成移动。
  + 按键盘上的`esc`键退出移动模式。
  最终连线后的Schematic如@schematic_wire 所示。
  #figure(
    image("figures/schematic_wire.png", width: 80%),
    caption: [连线],
  ) <schematic_wire>
+ 此时再次点击`Check & Save`按钮#box(baseline: 20%, image("figures/button_check_and_save.png"), width: 12pt)，仍然会弹出如@schematic_check 所示的警告，这是由于`vdd`端口仍然悬空。但这个节点在之后还会用到，因此需要告诉电路检查器将其忽略。在Schematic视图中，按键盘上的`i`键，打开`Add Instance`对话框。
+ 在弹出的如@add_instance_basic_noConn 所示的对话框中，点击`Browse`按钮。
  #figure(
    image("figures/add_instance_analogLib_switch.png", width: 40%),
    caption: [添加实例],
  ) <add_instance_basic_noConn>
+ 在弹出的如@lib_browser_basic_noConn 所示的对话框中，选择`Library`列中的`basic`，`Cell`列中的`noConn`，`View`列中的`symbol`。点击键盘上的`Enter`键。
  #figure(
    image("figures/lib_browser_basic_noConn.png", width: 60%),
    caption: [选择noConn单元],
  ) <lib_browser_basic_noConn>
+ 点击Schematic视图中的空白处，将`noConn`实例化并与`vdd`端口相连。如@schematic_ideal_switch 所示。
  #figure(
    image("figures/schematic_ideal_switch.png", width: 80%),
    caption: [noConn实例化],
  ) <schematic_ideal_switch>
+ 此时再次点击`Check & Save`按钮#box(baseline: 20%, image("figures/button_check_and_save.png"), width: 12pt)，不再弹出警告，且电路已保存。
+ 在Schematic视图中，点击菜单栏的`Create`->`CellView`->`From CellView`，定制Symbol，即采样开关在原理图中调用时的外观。在弹出的对话框中点击`OK`按钮。
+ 在弹出的对话框中，修改`Pin Specifications`中的端口位置使之如@symbol_pin_spec_schematic 所示 (也可以保持默认，但下一步的外观会有所不同，功能上没有影响)。点击`OK`按钮。
  #figure(
    image("figures/symbol_pin_spec_veriloga.png", width: 60%),
    caption: [Symbol生成设置],
  ) <symbol_pin_spec_schematic>
+ 如@symbol_schematic 所示，新的Symbol视图将会弹出。点击`Check & Save`按钮#box(baseline: 20%, image("figures/button_check_and_save.png"), width: 12pt)保存Symbol。然后点击右上角的`X`按钮关闭Symbol视图和Schematic视图。
  #figure(
    image("figures/symbol_veriloga.png", width: 80%),
    caption: [Symbol视图],
  ) <symbol_schematic>

== 搭建采样开关Testbench电路

+ 在库管理器 (Library Manager) 窗口中，点击菜单栏的`File`->`New`->`Cell View`，创建一个新的单元 (CellView)。
+ 在弹出的如@cell_view_schematic_tb 所示的对话框中，将Cell命名为`TB_sample_switch`，选择`Schematic`类型。点击`OK`按钮。
  #figure(
    image("figures/cell_view_schematic_tb.png", width: 40%),
    caption: [创建新的Schematic电路视图],
  ) <cell_view_schematic_tb>
+ 在Schematic视图中，按键盘上的`i`键 (注意大小写，下同。若仍不注意使用了其他快捷键，可按键盘上的`esc`键取消)，打开`Add Instance`对话框。
+ 在弹出的如@add_instance_analogLib_vdc 所示的对话框中，点击`Browse`按钮。
  #figure(
    image("figures/add_instance_analogLib_switch.png", width: 40%),
    caption: [添加实例],
  ) <add_instance_analogLib_vdc>
+ 在弹出的如@lib_browser_analogLib_vdc 所示的对话框中，选择`Library`列中的`analogLib`，`Cell`列中的`vdc`，`View`列中的`symbol`。点击键盘上的`Enter`键。
  #figure(
    image("figures/lib_browser_analogLib_vdc.png", width: 60%),
    caption: [选择vdc单元],
  ) <lib_browser_analogLib_vdc>
+ 点击Schematic视图中的空白处，将直流电压源实例化。
+ 再回到@add_instance_analogLib_vdc 所示的对话框中，点击`Browse`按钮，弹出`Library browser`对话框，选择`Library`列中的`analogLib`，`Cell`列中的`vpulse`，`View`列中的`symbol`。点击键盘上的`Enter`键。点击Schematic视图中的空白处，将理想时钟源实例化。
+ 仿照上一步骤，添加`analogLib` Library中的`vsin`(理想正弦波源)、`analogLib` Library中的`cap`(理想电容)、`analogLib` Library中的`gnd`(接地节点) 和`SARADC` Library中的`sample_switch`。
+ 添加完实例后，在器件之间连线，使Schematic视图如@schematic_add_instance_tb 所示。
  #figure(
    image("figures/schematic_add_instance_tb.png", width: 80%),
    caption: [Testbench电路],
  ) <schematic_add_instance_tb>
+ 接下来学习label功能的使用。\
  在Schematic视图中，按键盘上的`l` (小写L) 键，打开`Add Label`对话框。
+ 在弹出的如@add_label_tb 所示的对话框中，输入`clk`，点击Schematic视图中`vpulse`(理想时钟源)上方的孤立导线。此后即可用`clk`指代该节点。
  #figure(
    image("figures/add_label_tb.png", width: 30%),
    caption: [添加标签],
  ) <add_label_tb>
+ 仿照上一步骤，在理想正弦波源、理想电容、理想直流电压源上方导线添加`in`、`out`、`vdd`的label。
+ 添加label还有一种快捷方式。在Schematic视图中，左键单击`sampling_switch`，按键盘上的空格键，即可直接在器件端口上添加带label的导线。但需要注意的是，注意label的名称是否与其他节点label名字对应。例如这里的`gnd`端口就没有对应的label。下一步我们解决这个问题。
+ 在Schematic视图中，鼠标左键单击`sampling_switch`的`gnd`端口所在导线上的label，按键盘上的`q`键，打开`Edit Properties`对话框。将`Label`属性栏中的`gnd`改为`gnd!`。点击`OK`按钮。\
  `gnd!`是Cadence中的*特殊节点*名称，与和`analogLib` Library中的`gnd`器件相连一样，都和直接接地等效。
+ 最终连线后的Schematic如@schematic_wire_tb 所示。
  #figure(
    image("figures/schematic_wire_tb.png", width: 80%),
    caption: [连线],
  ) <schematic_wire_tb>
+ 接下来修改电路中各器件的参数。\
  鼠标左键单击理想直流电压源，按键盘上的`q`键，打开`Edit Properties`对话框。在`DC Voltage`属性栏输入`vdd`，如@edit_properties_analogLib_vdc 所示。点击`OK`按钮。\
  该直流电压源将会持续输出`vdd`#unit("V") 的电源电压。
  #figure(
    image("figures/edit_properties_analogLib_vdc.png", width: 50%),
    caption: [`vdc`的Edit Properties对话框],
  ) <edit_properties_analogLib_vdc>
+ 鼠标左键单击理想时钟源，按键盘上的`q`键，打开`Edit Properties`对话框。在`Voltage 0`属性栏输入`vdd`，`Period`属性栏输入`tClk`，`Rise Time`和`Fall Time`属性栏输入`trf`，如@edit_properties_analogLib_vpulse 所示。点击`OK`按钮。\
  该理想时钟源将会输出一个周期为`tClk`#unit("s") 的方波信号，其上升沿和下降沿时间为`trf`#unit("s")。
  #figure(
    image("figures/edit_properties_analogLib_vpulse.png", width: 50%),
    caption: [`vpulse`的Edit Properties对话框],
  ) <edit_properties_analogLib_vpulse>
+ 鼠标左键单击理想正弦波源，按键盘上的`q`键，打开`Edit Properties`对话框。在`Amplitude`属性栏输入`ampIn`，`Frequency`属性栏输入`fIn`，在`Offset Voltage`属性栏输入`vCm`，如@edit_properties_analogLib_vsin 所示。点击`OK`按钮。\
  该理想正弦波源将会输出幅值为`ampIn`#unit("V")、频率为`fIn`#unit("Hz") 的正弦波信号，其直流偏置电压为`vCm`#unit("V")。
  #figure(
    image("figures/edit_properties_analogLib_vsin.png", width: 50%),
    caption: [`vsin`的Edit Properties对话框],
  ) <edit_properties_analogLib_vsin>
+ 鼠标左键单击理想电容，按键盘上的`q`键，打开`Edit Properties`对话框。在`Capacitance`属性栏输入`cL`，如@edit_properties_analogLib_cap 所示。点击`OK`按钮。\
  该理想电容将会模拟一个电容值为`cL`#unit("F") 的电容。
  #figure(
    image("figures/edit_properties_analogLib_cap.png", width: 50%),
    caption: [`cap`的Edit Properties对话框],
  ) <edit_properties_analogLib_cap>
+ 此时点击`Check & Save`按钮#box(baseline: 20%, image("figures/button_check_and_save.png"), width: 12pt)，保存电路图。

== 采样开关电路仿真设置

=== 创建ADE Explorer

+ 在Schematic视图中，点击菜单栏的`Launch`->`ADE Explorer`，弹出如@create_ade0 所示的对话框。点击`Create New View`选项。点击`OK`按钮。
  #figure(
    image("figures/create_ade0.png", width: 30%),
    caption: [创建ADE Explorer],
  ) <create_ade0>
+ 在弹出的如@create_ade1 所示的对话框中。点击`OK`按钮，创建ADE Explorer。
  #figure(
    image("figures/create_ade1.png", width: 30%),
    caption: [创建ADE Explorer maestro view],
  ) <create_ade1>
+ 新创建的ADE Explorer界面如@ade_explorer 所示。其中红框部分为仿真设置区域，蓝框部分为仿真结果区域，绿框部分为仿真控制区域，黄框部分为工具和菜单栏。
  #figure(
    image("figures/ade_explorer.png", width: 80%),
    caption: [ADE Explorer],
  ) <ade_explorer>

=== 仿真参数设置

+ 在ADE Explorer界面中，鼠标右键单击`Design Variables`，在右键菜单中选择`Copy From CellView`，发现`Design Variables`中已经自动添加了`vdd`、`tClk`、`trf`、`ron`、`ampIn`、`fIn`、`vCm`、`cL`等变量。如@ade_explorer_design_variables 所示，为各变量赋值。
  #figure(
    image("figures/ade_explorer_design_variables.png", width: 30%),
    caption: [Design Variables设置],
  ) <ade_explorer_design_variables>
+ 鼠标左键单击@ade_explorer_design_variables 中的`Clike to add variable`，在弹出的对话框中，在`Name`属性栏输入`N`，在`Value`属性栏输入`256`，点击`Add`按钮。再在`Name`属性栏输入`M`，在`Value`属性栏输入`3`，点击`Add`按钮。此时注意到@ade_explorer_design_variables 中的变量列表中已经添加了变量`N`和`M`。
  #grid(
    columns: 2,
    rows: 2,
    gutter: 8pt,
    [#figure(
        image("figures/ade_explorer_add_variable_N.png"),
        caption: [添加变量$N$],
      ) <ade_explorer_add_variable_N>],
    [#figure(
        image("figures/ade_explorer_add_variable_M.png"),
        caption: [添加变量$M$],
      ) <ade_explorer_add_variable_M>],
  )
+ 在ADE Explorer界面中，鼠标左键单击@ade_explorer 红框中`Analyses`栏下的`Click to add analysis`。\
  在弹出的对话框中在`Analysis`属性栏选择`tran`，在`Stop Time`属性栏输入仿真时长，由于我们取$N$为256，$f_"clk"$为#qty(100, "kHz")，因此仿真时长应至少为$256/f_"clk"= #qty(2.56, "ms")$。为留部分余量，这里我们输入2.6m。在`Accuracy Defaults (errpreset)`属性栏选择`conservative`。勾选`Transient Noise`，在`Noise Analysis`栏下的`Noise Fmax`属性栏输入1G。点击`OK`按钮。
  #figure(
    image("figures/ade_explorer_add_analysis_tran.png", width: 40%),
    caption: [添加transient analysis],
  ) <ade_explorer_add_analysis_tran>
+ 在ADE Explorer界面中，鼠标左键单击@ade_explorer 黄框中的`Outputs`->`To Be Plotted`->`Select On Design`。\
  TB_sample_switch的Schematic视图将会弹出在新选项卡中。\
  在Schematic视图中，点击节点`out`对应的导线或label，该节点会被高亮如@schematic_out_highlight 所示，点击@schematic_out_highlight 中左上方的`maestro`选项卡，发现`out`节点同时被添加到ADE Explorer的输出列表中，如@ade_explorer_add_output 所示。\
  同理，添加`in`节点到输出列表中。
  #figure(
    image("figures/schematic_out_highlight.png", width: 80%),
    caption: [选择输出节点],
  ) <schematic_out_highlight>
  #figure(
    image("figures/ade_explorer_add_output.png", width: 80%),
    caption: [添加输出节点后的ADE Explorer],
  ) <ade_explorer_add_output>

#tip(title: "相干采样")[
  假设你的*输入信号*的周期为 $T_"in"$，*采样*时间间隔 (采样周期) 为 $T_"s"$，而你打算采集$N$个样本来做*快速傅里叶变换* (FFT) 分析。

  为了获取这么多样本，显然你必须进行一段时间$T_"tot"$的仿真，且$T_"tot"$满足：
  $
    T_"tot" = N dot T_"s"
  $ <def_N>
  而这段仿真时长内，输入信号跑了几个周期呢？显然是：
  $
    M = T_"tot" / T_"in"
  $ <def_M>
  由@def_N 和@def_M 可得：
  $
    T_"tot" = N dot T_"s" = M dot T_"in"
  $ <def_Ttot>
  而如果你习惯用*频率*来表示，那么上式也可以写为：
  $
    N / f_"s" = M / f_"in"
  $ <def_f>
  接下来我们就可以引入*相干采样*的定义了。要实现相干采样，其*充分必要*条件是：
  + $N, M in NN_+$
  + $N, M$ 互质
  只要满足这两个条件，我们对样本进行FFT后，就可以得到如@coherent_sampling 所示的频谱。
  #figure(
    image("figures/coherent_sampling.png", width: 80%),
    caption: [$T_"s"=#qty(10, "us"), M=3, N=256$时的频谱],
  ) <coherent_sampling>

  第一个条件中，$N$为正整数是显然的，毕竟我们很难想象一个人出于什么样的目的才会采集小数个样本。但$M$为正整数这个条件就有点门道了。

  根据@coherent_sampling 我们可以注意到，FFT频谱是由$N$条"柱子"组成的，它们的*高度*对应相应频率区间内的*信号强度*。而信号对应的"柱子"则是其中左起的第$M+1$根 (第1根是直流分量)。那么无奖竞猜的时候来了：如果$M$改为3.2，FFT频谱中的信号"柱子"会出现在哪里呢？
  + 还是第三根
  + 在第三根和第四根之间以某种比例分摊
  + "柱子"会塌掉，高度在整个频谱上分摊
]

#tip(title: "相干采样")[
  答案是3。此时的频谱如@coherent_sampling_bad 所示，这个现象的正式名称是*频谱泄露*。考虑到读者可能没有上过信号与系统或数字信号处理课程，大家可以带着这个问题关注一下课程中讲述FFT的那一章。简单来说，采样开始和终止时信号的值必须相等，否则一旦存在突变，对于FFT来说将是灾难性的。而"采样开始和终止时信号的值必须相等"这个条件，正对应了$M$为正整数这个条件。
  #figure(
    image("figures/coherent_sampling_bad.png", width: 80%),
    caption: [$T_"s"=#qty(10, "us"), M=3.2, N=256$时的频谱],
  ) <coherent_sampling_bad>

  至于第二个条件，$N, M$ 互质，则避免了*重复采样*。想象一下，假如现在$M=4, N=256$。那么每过64个采样点，信号就回到了原来的值，而我们又会把刚才64个点的采样重复3次。既然如此，我们为什么不直接用这64个点来做$N=64$的FFT呢？

  眼尖的同学可能还发现，迄今为止我们的$N$一直都是*2的整数次幂*。对于相干采样而言，其实这并不是必须的，但对于计算机而言，这样的FFT运算会更*高效*。因此建议大家以后在进行FFT时，取$N=2^k (k in NN)$。
]

=== 运行简单的瞬态仿真

*瞬态仿真* (Transient Analysis) 是Cadence Virtuoso中最基本的仿真类型之一，仿真器将会模拟一个电路在一定时间内*实时*的响应，并生成各个节点的电压*波形*用于观察。在这里我们将运行一个简单的瞬态仿真，观察采样开关的工作情况。

+ 在ADE Explorer界面中，鼠标左键单击@ade_explorer 绿框中的运行仿真按钮#box(baseline: 20%, image("figures/button_run.png"), width: 12pt)。如@ade_explorer_log 所示的仿真log窗口弹出，仿真开始运行。
  #figure(
    image("figures/ade_explorer_log.png", width: 40%),
    caption: [仿真log窗口],
  ) <ade_explorer_log>
+ 一段时间后仿真完成，此时如@ade_explorer_plot 所示的仿真结果窗口将会弹出，内容为`out`节点的波形图。\
  可以看到，采样开关在时钟信号的控制下，对输入信号进行了采样。鼠标右键长按，框选部分波形后松开，可以放大查看该部分波形，再按键盘上的`f`键可以恢复全览视图。
  #figure(
    image("figures/ade_explorer_plot.png", width: 80%),
    caption: [仿真结果窗口],
  ) <ade_explorer_plot>

=== 频谱分析

+ 如@ade_explorer_plot_zoom 和@ade_explorer_plot_zoom_2 所示，框选最后一段波形并放大，可以看到最后一个采样保持电路输出的样本位于#qty(2.595, "ms")时刻，这也是之后FFT样本序列的终止时间。
  #figure(
    image("figures/ade_explorer_plot_zoom.png", width: 80%),
    caption: [放大框选部分波形],
  ) <ade_explorer_plot_zoom>
  #figure(
    image("figures/ade_explorer_plot_zoom_2.png", width: 80%),
    caption: [框选部分波形放大后的结果],
  ) <ade_explorer_plot_zoom_2>
+ 鼠标左键单击@ade_explorer_plot_zoom_2 中的`out`节点对应的波形，在顶部菜单栏中点击`Measurements`->`Spectrum`，右侧弹出如@ade_explorer_spectrum_setup 所示的频谱分析窗口。\
  在`FFT input method`属性栏选择`Calculate Start Time`，`Start/Stop Time`的第二个属性栏输入`2.595m`，`Sample Count/Freq`属性栏分别输入256，100k，接着点击`Start/End Freq`属性栏的按钮#box(baseline: 20%, image("figures/button_auto_cal.png"), width: 12pt)，如@ade_explorer_spectrum_setup 所示。点击`plot`按钮。
#figure(
  image("figures/ade_explorer_spectrum_setup.png", width: 30%),
  caption: [频谱分析设置窗口],
) <ade_explorer_spectrum_setup>
+ 此时如@ade_explorer_spectrum_plot 所示的`out`节点波形的FFT频谱窗口将会弹出。\
  可以看到，频谱上存在两根相当"高"的"柱子"，他们从左到右分别对应于直流分量和交流信号的频率分量。同时也可以发现其他"柱子"的幅值都很小，他们可以算作是噪声分量。\
  鼠标右键单击频谱窗口中信号列表的`spectrum_/out`，在右键菜单中选择`Send To`->`ADE`，频谱窗口将会被添加到ADE Explorer的输出列表中。\
  接着，鼠标右键单击@ade_explorer_spectrum_plot 中右下角`Output`栏中的`ENOB`，选择`Send To ADE`，ENOB也会被添加到ADE Explorer的输出列表中，同理，将`SNR`、`SINAD`、`SFDR`、`THD`也添加到ADE Explorer的输出列表中，如@ade_explorer_spectrum_plot_2 所示。
  #figure(
    image("figures/ade_explorer_spectrum_plot.png", width: 80%),
    caption: [频谱输出窗口],
  ) <ade_explorer_spectrum_plot>
  #figure(
    image("figures/ade_explorer_spectrum_plot_2.png", width: 80%),
    caption: [频谱输出添加到ADE Explorer],
  ) <ade_explorer_spectrum_plot_2>

=== 扫描参数仿真 <sweep>

+ 在ADE Explorer界面中，鼠标左键双击@ade_explorer_design_variables 中的`ron`，将这一栏改为\ `1k,2k,5k,10k`，如@ade_explorer_design_variables_sweep 所示。
  #figure(
    image("figures/ade_explorer_design_variables_sweep.png", width: 40%),
    caption: [参数扫描设置],
  ) <ade_explorer_design_variables_sweep>
+ 在ADE Explorer界面中，鼠标左键单击@ade_explorer 绿框中的运行仿真按钮#box(baseline: 20%, image("figures/button_run.png"), width: 12pt)。
+ 仿真完成后，如@ade_explorer_plot_sweep 所示的仿真结果窗口将会弹出，同时ADE Explorer的仿真结果区变为如@ade_explorer_result_sweep 所示。\
  可以看到，@ade_explorer_plot_sweep 中的曲线非常多且乱，@ade_explorer_result_sweep 中的表格也比较复杂。
  #figure(
    image("figures/ade_explorer_plot_sweep.png", width: 80%),
    caption: [参数扫描仿真结果],
  ) <ade_explorer_plot_sweep>
  #figure(
    image("figures/ade_explorer_result_sweep.png", width: 80%),
    caption: [ADE Explorer参数扫描仿真后的仿真结果区],
  ) <ade_explorer_result_sweep>
+ 鼠标左键单击@ade_explorer_result_sweep 中左上角的`Output Setup`选项卡，取消勾选除`spectrum_snr`以外的所有输出信号的`Plot`勾选框，如@ade_explorer_result_sweep_output_setup 所示。
  #figure(
    image("figures/ade_explorer_result_sweep_output_setup.png", width: 80%),
    caption: [ADE Explorer输出设置],
  ) <ade_explorer_result_sweep_output_setup>
+ 鼠标左键单击@ade_explorer 绿框中的生成波形按钮#box(baseline: 20%, image("figures/button_waveform.png"), width: 12pt)，可以查看参数扫描后SNR的变化情况。如@ade_explorer_waveform_sweep 所示，随着电阻阻值的增大，SNR并没有明显变化。这与噪声功率无关于导通电阻的预期相符。
  #figure(
    image("figures/ade_explorer_waveform_sweep.png", width: 80%),
    caption: [SNR随电阻阻值变化],
  ) <ade_explorer_waveform_sweep>
+ 鼠标左键单击@ade_explorer 黄框中的保存按钮#box(baseline: 20%, image("figures/button_save.png"), width: 12pt)，保存当前ADE Explorer的设置。鼠标左键单击ADE Explorer界面中右上角的`X`按钮，关闭ADE Explorer，并同理关闭Schematic视图。

#tip(title: "课外拓展")[
  在@ade_explorer_add_analysis_tran 中，将`Noise Analysis`栏下的`Noise Fmax`属性栏改为`10M`，重新运行@sweep 的仿真。

  请回答以下问题：
  + 仿真*速度*有何变化？
  + 采样开关的*SNR*在扫描导通电阻后的曲线有何变化？
  + 造成上述变化的*原因*是什么？
  + 如果你是仿真测试工程师，你会如何选择`Noise Fmax`的值？
]

=== $(k T)/C$噪声仿真

+ 在ADE Explorer界面中，修改`Design Variables`中的`ron`为`1k`，`cL`为`1p,2p,5p,10p`，如@ade_explorer_design_variables_kT_C 所示。
  #figure(
    image("figures/ade_explorer_design_variables_kT_C.png", width: 40%),
    caption: [$(k T)/C$噪声仿真Design Variables设置],
  ) <ade_explorer_design_variables_kT_C>
+ 在ADE Explorer界面中，鼠标左键单击@ade_explorer 绿框中的运行仿真按钮#box(baseline: 20%, image("figures/button_run.png"), width: 12pt)。
+ 仿真完成后，如@ade_explorer_plot_kT_C 所示的仿真结果窗口将会弹出，注意到该曲线类似对数函数曲线。\
  为方便观察，鼠标右键单击SNR变化曲线的横轴，在右键菜单中选择`Log Scale`，如@ade_explorer_plot_kT_C_log 所示，可以使用对数坐标轴。\
  此时观察到SNR随采样电容值呈#qty(10, "dB")/dec (dec指扩大10倍) 的增长趋势。这与噪声功率正比于$(k T)/C$的关系相符。
  #figure(
    image("figures/ade_explorer_plot_kT_C.png", width: 80%),
    caption: [$(k T)/C$噪声仿真结果],
  ) <ade_explorer_plot_kT_C>
  #figure(
    image("figures/ade_explorer_plot_kT_C_log.png", width: 80%),
    caption: [$(k T)/C$噪声仿真结果的对数坐标],
  ) <ade_explorer_plot_kT_C_log>

== 搭建简易采样保持电路

+ 在库管理器 (Library Manager) 窗口中，找到`SARADC` Library->`sample_switch` Cell->`Schematic` View，鼠标左键双击该CellView，打开@ideal_switch 中创建的电路原理图。\
  如果未创建过该CellView，请参考@ideal_switch 的第1-2和15-18步创建原理图并添加端口，然后跳过下一步进入第3步。
+ 在修改原理图之前先对当前的CellView进行保存。在Schematic视图中，按键盘上的`Ctrl`+`s`键，在弹出的对话框中，将`View`属性栏中的`schematic`改为`schematic_0`，如@schematic_save 所示。点击`OK`按钮。
  #figure(
    image("figures/schematic_save.png", width: 30%),
    caption: [保存Schematic代码],
  ) <schematic_save>
+ 接下来删除电路中的器件和连线。在Schematic视图中，按键盘上的`delete`键进入删除模式，光标右下角出现X形，鼠标左键单击需要删除的器件或连线，只保留`vdd`上的`noConn`。删除后如@schematic_delete 所示。
  #figure(
    image("figures/schematic_delete.png", width: 80%),
    caption: [删除器件和连线],
  ) <schematic_delete>
+ 在Schematic视图中，按键盘上的`i`键，打开`Add Instance`对话框。
+ 在弹出的如@add_instance_analogLib_switch 所示的对话框中，点击`Browse`按钮。
+ 在弹出的如@lib_browser_n18 所示的对话框中，展开`Library`列中的`SMIC_LIB`并选择其中的`smic18mmrf`，`Cell`列中的`n18`，`View`列中的`symbol`。点击键盘上的`Enter`键。
  #figure(
    image("figures/lib_browser_n18.png", width: 60%),
    caption: [选择NMOS器件],
  ) <lib_browser_n18>
+ 点击Schematic视图中的空白处，将NMOS实例化。如@schematic_n18 所示。然后按键盘上的`esc`键关闭对话框。
  #figure(
    image("figures/schematic_n18.png", width: 80%),
    caption: [NMOS实例化],
  ) <schematic_n18>
+ 在Schematic视图中，如@schematic_simple_switch 所示，完成连线。
  #figure(
    image("figures/schematic_simple_switch.png", width: 80%),
    caption: [简易采样开关电路],
  ) <schematic_simple_switch>
+ 鼠标左键单击`n18`，按键盘上的`q`键，打开`Edit Properties`对话框。在`Finger Width`属性栏输入`1u`，如@edit_properties_n18 所示。点击`OK`按钮。\
  在SMIC18MMRF以及其他许多现代工艺中，假如工程师需要一个宽#qty(8, "um")的NMOS，那么他们不会直接做一个宽#qty(8, "um")的NMOS，而是使用 (打个比方) 8个#qty(1, "um")的小NMOS并将其并联，这样方便后续版图设计。这里每一个小NMOS被称为一个`Finger`，因此NMOS的宽度就是`Finger Width`乘以`Fingers`。
  #figure(
    image("figures/edit_properties_n18.png", width: 60%),
    caption: [`n18`的Edit Properties对话框],
  ) <edit_properties_n18>
+ 在Schematic视图中，点击菜单栏的`Check & Save`按钮#box(baseline: 20%, image("figures/button_check_and_save.png"), width: 12pt)，保存电路图。
+ 按键盘上的`Ctrl`+`s`键，在弹出的对话框中，将`View`属性栏中的`schematic_0`改为`schematic_1`，保存电路图备份。点击`OK`按钮。
+ 点击Schematic视图右上角的`X`按钮，关闭Schematic视图。

== 仿真简易采样保持电路

+ 在库管理器 (Library Manager) 窗口中，找到`SARADC` Library->`TB_sample_switch` Cell->`maestro` View，鼠标左键双击该CellView，打开ADE Explorer。
+ 修改`Design Variables`中的`vdd`、`tClk`、`trf`、`ron`、`ampIn`、`fIn`、`vCm`、`cL`的值为与@ade_explorer_design_variables_simple_switch 中相同的值。
  #figure(
    image("figures/ade_explorer_design_variables_simple_switch.png", width: 30%),
    caption: [Design Variables设置],
  ) <ade_explorer_design_variables_simple_switch>
+ 勾选所有输出信号的`Plot`勾选框，如@ade_explorer_simple_switch_output_setup 所示。
  #figure(
    image("figures/ade_explorer_simple_switch_output_setup.png", width: 80%),
    caption: [ADE Explorer输出设置],
  ) <ade_explorer_simple_switch_output_setup>
+ 鼠标左键单击@ade_explorer 绿框中的运行仿真按钮#box(baseline: 20%, image("figures/button_run.png"), width: 12pt)。
+ 仿真完成后，仿真结果窗口将会弹出，包括如@ade_explorer_simple_switch_spectrum 和@ade_explorer_simple_switch_waveform 所示的频谱和波形。ADE Explorer的仿真结果区如@ade_explorer_simple_switch_result 所示。
  #figure(
    image("figures/ade_explorer_simple_switch_spectrum.png", width: 80%),
    caption: [简易采样保持电路的输出频谱],
  ) <ade_explorer_simple_switch_spectrum>
  #figure(
    image("figures/ade_explorer_simple_switch_waveform.png", width: 80%),
    caption: [简易采样保持电路的输入输出波形],
  ) <ade_explorer_simple_switch_waveform>
  #figure(
    image("figures/ade_explorer_simple_switch_result.png", width: 80%),
    caption: [简易采样保持电路的仿真结果],
  ) <ade_explorer_simple_switch_result>
+ 鼠标左键单击仿真结果窗口中右上角的`X`按钮，关闭波形图。
+ 鼠标左键单击@ade_explorer 黄框中的保存按钮#box(baseline: 20%, image("figures/button_save.png"), width: 12pt)，保存当前ADE Explorer的设置。

== 使用Result Browser查看仿真波形 <result_browser>

在上一小节中我们查看了`out`节点的波形。但是对于*其他*没有添加到ADE Explorer输出列表中的*节点*，例如`clk`，`in`，我们可以通过*Result Browser*查看其波形。

甚至通过Result Browser的一些简易功能，我们可以查看刚才搭建的简易采样保持电路中NMOS的$V_"GS"$，从而进一步了解为什么简易采样保持电路具有如此糟糕的性能，以及如何改进。

+ 鼠标左键单击@ade_explorer 黄框中的菜单栏`Tools`->`Result Browser`，弹出如@result_browser_bootstrap_switch 所示的Result Browser窗口。
  #figure(
    image("figures/result_browser_bootstrap_switch.png", width: 80%),
    caption: [Result Browser窗口],
  ) <result_browser_bootstrap_switch>
+ 展开@result_browser_bootstrap_switch 中窗口左侧的`.SARADC_TB_sample_switch_1/psf`词条，鼠标左键单击其中的`tran`词条，如@result_browser_simple_switch_psf 所示。可以查看电路中所有节点的瞬态波形。
  #figure(
    image("figures/result_browser_simple_switch_psf.png", width: 20%),
    caption: [展开后的词条],
  ) <result_browser_simple_switch_psf>
+ 在@result_browser_simple_switch_psf 中，鼠标左键单击`clk`节点，再双击@result_browser_simple_switch_psf 上方的绘制波形按钮#box(baseline: 20%, image("figures/button_waveform_result_browser.png"), width: 12pt)，右侧result browser的视图中出现如@result_browser_simple_switch_clk_waveform 所示的波形图。
  #figure(
    image("figures/result_browser_simple_switch_clk_waveform.png", width: 80%),
    caption: [`clk`节点的波形图],
  ) <result_browser_simple_switch_clk_waveform>
+ Result browser还支持查看两个节点之间的差分电压，我们可以利用此功能查看NMOS的$V_"GS"$。根据@schematic_simple_switch，不难发现NMOS的栅极为`clk`节点，而源极为`in`节点。因此，绘制NMOS的$V_"GS"$即可转换为绘制`clk`和`in`节点电压的差值。\
  在@result_browser_simple_switch_psf 中，鼠标左键单击`clk`节点，长按键盘上的`Ctrl`键，鼠标左键单击`in`节点，然后双击@result_browser_simple_switch_psf 上方的绘制差分波形按钮#box(baseline: 20%, image("figures/button_waveform_diff_result_browser.png"), width: 12pt)，右侧result browser的视图中出现如@result_browser_simple_switch_VGS_waveform 所示的波形图。其中黄色的波形即为NMOS的$V_"GS"$。
  #figure(
    image("figures/result_browser_simple_switch_VGS_waveform.png", width: 80%),
    caption: [NMOS的$V_"GS"$波形图],
  ) <result_browser_simple_switch_VGS_waveform>
+ 鼠标左键单击Result Browser窗口右上角的`X`按钮，关闭Result Browser窗口。
+ 鼠标左键单击ADE Explorer界面右上角的`X`按钮，关闭ADE Explorer。

#tip(title: "课外拓展")[
  根据@result_browser_simple_switch_VGS_waveform ，结合MOSFET的$I$-$V$特性解释为什么简易采样保持电路会产生极大的非线性。
]

== 搭建栅压自举采样保持电路

+ 在库管理器 (Library Manager) 窗口中，找到`SARADC` Library->`sample_switch` Cell->`Schematic` View，鼠标左键双击该CellView，打开电路原理图。
+ 删除电路中当前的连线以及`vdd`节点上的`noConn`，并重新排列端口和器件，如@schematic_bootstrap_switch_1 所示。
  #figure(
    image("figures/schematic_bootstrap_switch_1.png", width: 80%),
    caption: [栅压自举采样保持电路],
  ) <schematic_bootstrap_switch_1>
+ 在Schematic视图中，按键盘上的`i`键，打开`Add Instance`对话框。在弹出的如@add_instance_analogLib_switch 所示的对话框中，点击`Browse`按钮。在弹出的Library Browser对话框中，展开`Library`列中的`SMIC_LIB`并选择其中的`smic18mmrf`，`Cell`列中的`p18`，`View`列中的`symbol`。点击键盘上的`Enter`键。
+ 点击Schematic视图中的空白处，将PMOS实例化。如@schematic_p18 所示。然后按键盘上的`esc`键关闭对话框。
  #figure(
    image("figures/schematic_p18.png", width: 80%),
    caption: [PMOS实例化],
  ) <schematic_p18>
+ 在Schematic视图中，鼠标左键单击`p18`，按键盘上的`q`键，打开`Edit Properties`对话框。在`Finger Width`属性栏输入`1u`，如@edit_properties_p18 所示。点击`OK`按钮。
  #figure(
    image("figures/edit_properties_p18.png", width: 60%),
    caption: [`p18`的Edit Properties对话框],
  ) <edit_properties_p18>
+ 在Schematic视图中，鼠标左键单击或长按鼠标左键拖动并框选`n18`，按键盘上的`c`键，进入复制模式，此时注意到Schematic视图中已经出现了一个随鼠标拖动的黄色`n18`轮廓。\
  鼠标左键单击Schermatic视图中的空白处，将`n18`复制一份。如@schematic_n18_copy 所示。\
  此时Schematic视图中已经有两个`n18`，之后将按其右上角的红色器件代号 (如`NM0`) 进行指代。
  #figure(
    image("figures/schematic_n18_copy.png", width: 80%),
    caption: [复制`n18`],
  ) <schematic_n18_copy>
+ 在Schematic视图中，鼠标左键单击或长按鼠标左键拖动并框选`NM0`，按键盘上的`r`键，进入旋转模式，此时注意到光标右下角出现了一个旋转箭头。\
  鼠标左键单击Schermatic视图中的空白处，将`NM0`逆时针旋转#qty(90, "degree")。如@schematic_n18_rotate 所示。
  #figure(
    image("figures/schematic_n18_rotate.png", width: 80%),
    caption: [旋转`n18`],
  ) <schematic_n18_rotate>
+ 在Schematic视图中，按键盘上的`i`键，打开`Add Instance`对话框。\
  在弹出的如@add_instance_analogLib_switch 所示的对话框中，点击`Browse`按钮。\
  在弹出的Library Browser对话框中，展开`Library`列中的`SMIC_LIB`并选择其中的`smic18mmrf`，`Cell`列中的`mim2_ckt`，`View`列中的`symbol`。点击键盘上的`Enter`键。
+ 点击Schematic视图中的空白处，将MIM电容实例化。如@schematic_mim 所示。然后按键盘上的`esc`键关闭对话框。
  #figure(
    image("figures/schematic_mim.png", width: 80%),
    caption: [MIM电容实例化],
  ) <schematic_mim>
+ 在Schematic视图中，按键盘上的`i`键，打开`Add Instance`对话框。\
  在弹出的如@add_instance_analogLib_switch 所示的对话框中，点击`Browse`按钮。\
  在弹出的Library Browser对话框中，展开`Library`列中的`SMIC_LIB`并选择其中的`scc018ug_uhd_rvt_oa`，`Cell`列中的`INUHDV1`，`View`列中的`symbol`。点击键盘上的`Enter`键。
+ 点击Schematic视图中的空白处，将$1 times$反相器实例化。同理，再添加$4 times$反相器`INUHDV4`，如@schematic_inv 所示。然后按键盘上的`esc`键关闭对话框。
  #figure(
    image("figures/schematic_inv.png", width: 80%),
    caption: [反相器实例化],
  ) <schematic_inv>
+ 综合使用添加器件，复制，移动，旋转，连线和label功能，完成栅压自举采样保持电路的搭建。如@schematic_bootstrap_switch_2 所示。
  #figure(
    image("figures/schematic_bootstrap_switch_2.png", width: 80%),
    caption: [栅压自举采样保持电路],
  ) <schematic_bootstrap_switch_2>
+ 点击`Check & Save`按钮#box(baseline: 20%, image("figures/button_check_and_save.png"), width: 12pt)，保存电路图。
+ 按键盘上的`Ctrl`+`s`键，在弹出的对话框中，将`View`属性栏中的`schematic`改为`schematic_2`，保存电路图备份。点击`OK`按钮。
+ 点击Schematic视图右上角的`X`按钮，关闭Schematic视图。

== 仿真栅压自举采样保持电路

+ 在库管理器 (Library Manager) 窗口中，找到`SARADC` Library->`TB_sample_switch` Cell->`maestro` View，鼠标左键双击该CellView，打开ADE Explorer。
+ 鼠标左键单击@ade_explorer 绿框中的运行仿真按钮#box(baseline: 20%, image("figures/button_run.png"), width: 12pt)。
+ 仿真完成后，仿真结果窗口将会弹出，包括如@ade_explorer_bootstrap_switch_spectrum 和@ade_explorer_bootstrap_switch_waveform 所示的频谱和波形。ADE Explorer的仿真结果区如@ade_explorer_bootstrap_switch_result 所示。
  #figure(
    image("figures/ade_explorer_bootstrap_switch_spectrum.png", width: 80%),
    caption: [栅压自举采样保持电路的输出频谱],
  ) <ade_explorer_bootstrap_switch_spectrum>
  #figure(
    image("figures/ade_explorer_bootstrap_switch_waveform.png", width: 80%),
    caption: [栅压自举采样保持电路的输入输出波形],
  ) <ade_explorer_bootstrap_switch_waveform>
  #figure(
    image("figures/ade_explorer_bootstrap_switch_result.png", width: 80%),
    caption: [栅压自举采样保持电路的仿真结果],
  ) <ade_explorer_bootstrap_switch_result>

== 使用Calculator查看仿真波形

与@result_browser 不同，这一次根据@schematic_bootstrap_switch_2，可以发现NMOS的栅极为`I0`的内部节点`I0/clk_boost`，而源极仍为`in`节点。因为两节点在*不同*的电路*层次*中，所以无法使用result browser中的绘制差分波形#box(baseline: 20%, image("figures/button_waveform_diff_result_browser.png"), width: 12pt)功能。但这也引出了更加强大的Calculator功能。本小节将介绍Calculator的一些基本使用方法。

+ 鼠标左键单击@ade_explorer 黄框中的菜单栏`Tools`->`Result Browser`，弹出如@result_browser_bootstrap_switch 所示的Result Browser窗口。
+ 展开@result_browser_bootstrap_switch 中窗口左侧的`.SARADC_TB_sample_switch_1/psf`词条，并依次展开其中的`tran`，`I0`词条，如@result_browser_bootstrap_switch_psf 所示。可以查看电路中所有节点的瞬态波形。
  #figure(
    image("figures/result_browser_bootstrap_switch_psf.png", width: 20%),
    caption: [展开后的词条],
  ) <result_browser_bootstrap_switch_psf>
+ 鼠标右键单击`clk_boost`节点，在右键菜单中选择`Calculator`，如@result_browser_send_to_calculator 所示。
  #figure(
    image("figures/result_browser_send_to_calculator.png", width: 20%),
    caption: [将`I0/clk_boost`添加到Calculator],
  ) <result_browser_send_to_calculator>
+ 弹出如@calculator 的Calculator窗口。在中间的表达式区，可以看到`I0/clk_boost`已经添加到Calculator中。
  #figure(
    image("figures/calculator.png", width: 80%),
    caption: [Calculator窗口],
  ) <calculator>
+ 修改表达式区中的表达式，将 \
  `v("/I0/clk_boost" ?result "tran")`改为 \
  `v("/I0/clk_boost" ?result "tran") - v("/in" ?result "tran")`。\
+ 点击@calculator 上方工具栏中的Send to ADE按钮#box(baseline: 20%, image("figures/button_send_to_ade.png"), width: 12pt)，可将该表达式添加到ADE Explorer的输出列表中。
+ 点击@calculator 上方工具栏中的Evaluate按钮#box(baseline: 20%, image("figures/button_evaluate.png"), width: 12pt)，弹出如@calculator_result 所示的NMOS $V_"GS"$波形图。
  #figure(
    image("figures/calculator_result.png", width: 80%),
    caption: [NMOS的$V_"GS"$波形图],
  ) <calculator_result>

#tip(title: "课外拓展")[
  对比@result_browser_simple_switch_VGS_waveform 和@calculator_result，结合MOSFET的$I$-$V$特性解释栅压自举电路是如何降低简易采样保持电路带来的非线性的。
]

#show: appendix

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
    image("figures/cell_view_veriloga.png", width: 50%),
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
+ 点击Toolbar中的`Check & Save`按钮#box(baseline: 20%, image("figures/button_check_and_save.png"), width: 12pt)保存代码。
+ 在弹出的如@create_symbol_veriloga 所示的对话框中。点击`OK`按钮定制Symbol，即采样开关在原理图中调用时的外观。
  #figure(
    image("figures/create_symbol_veriloga.png", width: 30%),
    caption: [保存VerilogA代码后弹出的对话框],
  ) <create_symbol_veriloga>
+ 如果你已经在@ideal_switch 中创建了Symbol，那么这里将会弹出一个如@create_symbol_schematic 所示的对话框，询问是否覆盖之前创建的Symbol，这里点击`Cancel`按钮，并直接点击右上角的`X`按钮关闭Schematic视图。反之则进入下一步骤。
  #figure(
    image("figures/create_symbol_schematic.png", width: 30%),
    caption: [保存Schematic代码后弹出的对话框],
  ) <create_symbol_schematic>
// 此处增加signal_type修改
+ 在弹出的对话框中，修改`Pin Specifications`中的端口位置使之如@symbol_pin_spec_veriloga 所示 (也可以保持默认，但下一步的外观会有所不同，功能上没有影响)。点击`OK`按钮。
  #figure(
    image("figures/symbol_pin_spec_veriloga.png", width: 60%),
    caption: [Symbol生成设置],
  ) <symbol_pin_spec_veriloga>
+ 如@symbol_veriloga 所示，新的Symbol视图将会弹出。点击`Check & Save`按钮#box(baseline: 20%, image("figures/button_check_and_save.png"), width: 12pt)保存Symbol。然后点击右上角的`X`按钮关闭Symbol视图和VerilogA编辑器。
  #figure(
    image("figures/symbol_veriloga.png", width: 80%),
    caption: [Symbol视图],
  ) <symbol_veriloga>

= 加快仿真进度的方法

随着电路*复杂度*的增加，仿真时间也会相应增加。为了*加快*仿真进度，可以尝试以下方法，推荐程度不分先后：

- 最直觉的方法就是用*精度*换速度。可以在@ade_explorer_add_analysis_tran 中`Analysis`栏下的`Accuracy Defaults (errpreset)`属性栏选择`moderate`甚至`liberal`，这样仿真会更快完成。但会牺牲一定的仿真精度。
- 相对更稳妥的方法是改进仿真的*算法*。
  + 鼠标左键单击在@ade_explorer 中黄框部分的`Setup`->`High-Performance Simulation`，弹出如@ade_explorer_spectre 所示的对话框。
    #figure(
      image("figures/ade_explorer_spectre.png", width: 60%),
      caption: [高性能仿真设置],
    ) <ade_explorer_spectre>
  + 在`Simulation Performance Mode`属性栏选择`Spectre X`，在`Preset`属性栏选择`CX`，如@ade_explorer_spectre_x 所示。点击`OK`按钮即可。
    #figure(
      image("figures/ade_explorer_spectre_x.png", width: 60%),
      caption: [Spectre X设置],
    ) <ade_explorer_spectre_x>
  + 如果`Simulation Performance Mode`属性栏中没有`Spectre X`选项，可以转而使用APS。在`Simulation Performance Mode`属性栏选择`APS`，其余选项保持默认，如@ade_explorer_aps 所示。点击`OK`按钮即可。
    #figure(
      image("figures/ade_explorer_aps.png", width: 60%),
      caption: [APS设置],
    ) <ade_explorer_aps>
- 在transient analysis设置中勾选`Transient Noise`会对电路中的*噪声*进行仿真，这会*极大减慢*仿真进度。如果仅对电路进行*功能性验证*或*非线性*仿真，可以不勾选`Transient Noise`。
- 使用*参数扫描*时，每个参数值都会进行一次仿真，因此参数值越多，仿真时间越长。如果同时开启*多个任务*，进行多个参数值的仿真，就能减少仿真排队时间。在@ade_explorer 中黄框部分的`Setup`->`Job Setup`，弹出如@ade_explorer_job_setup 所示的对话框。在`Max. Jobs`属性栏输入你希望同时进行的仿真数，建议该值选取不要超过5，以免给服务器造成太大压力。其余选项保持默认。点击`OK`按钮即可。
  #figure(
    image("figures/ade_explorer_job_setup.png", width: 40%),
    caption: [多任务设置],
  ) <ade_explorer_job_setup>
