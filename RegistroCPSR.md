# Registro CPSR (Current Program Status Register) #

El control de las banderas y del modo del CPU se encuentran en este registro. Cuando ocurre alguna interrupción el contenido del registro CPSR es almacenado en el registro **SPSR.**
El registro se compone de la siguiente manera:
| **Bit** |   | **Expl.** |
|:--------|:--|:----------|
|31|    | **N** - Sign Flag       (0=Not Signed, 1=Signed)|
|30|    | **Z** - Zero Flag       (0=Not Zero, 1=Zero)|
|29|    | **C** - Carry Flag      (0=No Carry, 1=Carry)|
|28|    | **V** - Overflow Flag   (0=No Overflow, 1=Overflow)|
|27|    | **Q** - Sticky Overflow (1=Sticky Overflow, ARMv5TE and up only)|
| **26-8** |  |Reserved            (For future use) - Do not change manually!|
|7 |     | **I** - IRQ disable     (0=Enable, 1=Disable)|
|6 |     | **F** - FIQ disable     (0=Enable, 1=Disable)|
|5 |     | **T** - State Bit       (0=ARM, 1=THUMB) - Do not change manually!|
|4-0|   | **M4-M0** - Mode Bits   (See below)|

Del bit 7-0: Son los bits que cambian cuando ocurren excepciones.
<br>
Los bits I y F activan las interrupciones IRQ y FIQ respectivamente.<br>
El bit T el que indica en que modo nos encontramos, solo las instrucciones BX pueden cambiar el valor de este bit.<br>
Los bist 4-0 son los que indican que registros son usados. Los registros <a href='https://code.google.com/p/biogba/source/detail?r=0'>R0</a> - <a href='https://code.google.com/p/biogba/source/detail?r=7'>R7</a> son de acceso en cualquier modo, sin embargo los restantes se accede de acuerdo con el modo que se encuentre.<br>
<br>
<table><thead><th> <b>Binary</b> </th><th> </th><th> <b>Hex</b> </th><th> </th><th> <b>Dec</b> </th><th>  </th><th> <b>Expl.</b> </th></thead><tbody>
<tr><td>10000</td><td>  </td><td>10</td><td>  </td><td>16</td><td>  </td><td>User (non-privileged)</td></tr>
<tr><td>10001</td><td>  </td><td>11</td><td>  </td><td>17</td><td>  </td><td>FIQ</td></tr>
<tr><td>10010</td><td>  </td><td>12</td><td>  </td><td>18</td><td>  </td><td>IRQ</td></tr>
<tr><td>10011</td><td>  </td><td>13</td><td>  </td><td>19</td><td>  </td><td>Supervisor (SWI)</td></tr>
<tr><td>10111</td><td>  </td><td>17</td><td>  </td><td>23</td><td>  </td><td>Abort</td></tr>
<tr><td>11011</td><td>  </td><td>1B</td><td>  </td><td>27</td><td>  </td><td>Undefined</td></tr>
<tr><td>11111</td><td>  </td><td>1F</td><td>  </td><td>31</td><td>  </td><td>System (privileged 'User' mode) (ARMv4 and up)</td></tr></tbody></table>

<h1>Registro SPSR (Saved Program Status Registers)</h1>
En este registro se almacena el contenido del registro CPSR cuando ocurre una excepción. <br>
Existen 5 registros del tipo SPSR: SPSR_fiq, SPSR_svc, SPSR_abt, SPSR_irq, SPSR_und. <br>
Al ocurrir una excepción el CPSR se guarda en el SPSR_Mode.<br>
<br>
Las excepciones pueden ser por:<br>
- Reset<br>
- Data Abort<br>
- FIQ<br>
- IRQ<br>
- Prefetch Abort<br>
- Software Interrupt<br>
- Undefined Instruction<br>
<br>