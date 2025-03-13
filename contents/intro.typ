#import "../conf.typ": *

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
- 了解MOS管的*传输特性曲线，输出特性曲线*，以及其可以作为开关使用的原理#footnote[建议参考https://shuiyuan.sjtu.edu.cn/t/topic/127792/32]。
- 了解*傅里叶变换* (Fourier Transform) 和频谱分析 (Spectrum Analysis) 的基本概念#footnote[建议参考https://shuiyuan.sjtu.edu.cn/t/topic/127792/117]
- 了解噪声，尤其是*$(k T)/C$热噪声*的概念#footnote[建议参考https://shuiyuan.sjtu.edu.cn/t/topic/127792/289]
- 了解ADC相关指标的定义
  - *SNR* (Signal-to-Noise Ratio)
  - *SINAD* (Signal-to-Noise and Distortion Ratio)
  - *ENOB* (Effective Number of Bits)
  - *SFDR* (Spurious-Free Dynamic Range)
  - *THD* (Total Harmonic Distortion)
- 了解*栅压自举采样开关电路* (Bootstrapped Switch) 的基本原理#footnote[建议参考https://zhuanlan.zhihu.com/p/564837987]。

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
