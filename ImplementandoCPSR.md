# Implementando las banderas de CPSR #

## Descripción del problema ##
Hay varias opciones para implementar ese registro. Pero para saber por qué hay mas de una manera correcta de hacerlo, hay que conocer el problema.

  1. En ambos modos (ARM y Thumb) la mayoría de las instrucciones hacen uso de una o más banderas de manera individual. Por esta razón debemos tener una manera rapida, eficiente y práctica de prender o apagar los bits de este registro.
  1. Por otro lado, en las instrucciones de ARM se tiene el campo de condicionales el cual necesita acceso directo y rapido a los bits del registro CPSR.
  1. Por último, como CPSR es un registro completo de 32 bits, algunas instrucciones hacen use de este en forma de registro por lo que los datos deben estar disponibles en forma de un registro de 32 bits.


## Propuestas ##

  1. Una primer propuesta es tener el registro CPSR definido como una variable de 32 bits y usar operaciones de bits complejas en cada instrucción para prender o apagar los diferentes bits.
    * **Ventajas:** Es la forma mas simple (fuerza bruta). El registro siempre esta listo.
    * **Desventajas:** Muy propenso a errores que luego son difíciles de encontrar. La implementación de cada instrucción se vuelve poco legible.
  1. La segunda propuesta sería utilizar funciones (métodos de acceso). Esto mismo utilizo en el emulador BioGB. La idea es tener funciones como _zFlag()_ o _nFlag()_ donde si se llama sin parámetros regrese el valor del bit y si se llama con parámetros establezcamos el valor del bit.
    * **Ventajas:** El código se vuelve mucho más legible. Concentramos todo el manejo de bits en este grupo de funciones en vez de en cada opcode.
    * **Desventajas:** Agrega mucha sobrecarga tener que llamar funciones completas para cambiar un simple bit por lo que es una solcuión mas lenta. Aunque esto podría arreglarse usando _inline_ o hasta macros (lo cual no es recomendable).
  1. Otra propuesta sería teners las banderas por separado, es decir, una variable bool por cada bandera. Y para poder juntarlas utilizar una función que sustituya el registro CPSR.
    * **Ventajas:** El código se vuelve aun más legible y fácil de implementar y entender ya que las asignaciones son mas intuitivas. También es una opción rápida ya que no necesitamos hacer ninguna operación para prender o apagar un bit. Leer los bits se vuelve una tarea sumamente trivial.
    * **Desventajas:** Dejamos de tener el registro CPSR como una variable. En vez de variable usamos un par de funciones: una para leer y otra para escribir. Cada vez que queramos leer el registro CPSR la función junta con operadores de bits todas las banderas en el orden indicado y regresa el valor de 32 bits. Para escribir, se pasa un valor de 32 bits a la función y se obtienen todos los unos y se van prendiendo o apagando los bits segun este patrón.




Se vale agregar mas propuestas.