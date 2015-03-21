# Recomendaciones #

Estas son algunas recomendaciones para evitar conflictos a la hora de programar.

  1. Evitar trabajar en las mismas secciones al mismo tiempo lo más que se pueda.
  1. Sólo sube (push) el código cuando hayas terminado tu sesión de trabajo. Es preferible tener sólo un commit con una buena descripción que una serie de pequeños commits con cambios mínimos.
  1. Evita modificar de manera arbitraria código que no has escrito. Para esto, primero avisa a quien lo creo.
  1. Siempre haz un pull antes de empezar a trabajar al menos que exista una razón para no  hacerlo.
  1. La descripción del commit debe ser lo mas completa posible explicando que archivos se modificaron, por qué se modificaron, que hace falta, errores encontrados o corregidos, etc.

# Formato para los commits #

Los mensajes de cada commit nos dan una idea de que trabajo se hizo en el código. De esta manera se lleva un orden. Por lo tanto, los mensajes deben ser claros y completos. A continuación pongo una lista de sugerencias para los commits y sus mensajes.

  1. El primer renglón de la descripción debe ser el título que explique el punto mas importante de ese commit. Ejemplo: _"Implementación de los opcodes  XX"_.
  1. Después del título se deja un renglón en blanco y a continuación se escribe la descripción.
  1. La primer parte de la descripción debe contener el código agregado y modificado.
  1. La segunda parte de la descripción debe contener lo que aun falta dentro de lo implementado. Por ejemplo: _"En el opcode XX aun falta implementar la bandera Carry"_.
  1. Finalmente en la tercera parte se exponen problemas con alguna parte del código o algo similar. Por ejemplo: "_Aun no se como implementar XX opcode._".
  1. Muy importante verificar si el código es compilable. Una notación que uso es poner al final la nota _"Compila / No compila"_.

Se pueden agregar mas secciones. El punto es tener un orden y ser claros. De esta manera podremos estar mas al pendiente de las modificaciones que hacen los demás.

Estas recomendaciones no son reglas. Se pueden cambiar o ignorar según sea el caso. La idea es que conforme se vaya desarrollando el proyecto estas recomendaciones se vayan afinando hasta llegar a un conjunto que sea verdaderamente útil y ayude a la productividad.