# Lista de errores — 1.0

Los códigos se muestran en hexadecimal. 00 significa que no hay error.
Los valores de APU, CFG/STATUS, SD CMD/R1, LBA y ARG/CRC son datos
de diagnóstico; el código del fallo aparece junto a ERROR.

## microSD / SPI

| Código | Significado |
|---|---|
| **03** | Los datos del sector no superaron la comprobación CRC16. |
| **10** | Tiempo de espera agotado en la interfaz SPI del cartucho; también es esperado en emuladores sin esa interfaz SD. |
| **11** | La SD no respondió al comando (R1) dentro del límite de espera. |
| **12** | La SD rechazó CMD58: consulta de estado y capacidad. |
| **13** | La SD informa que su inicialización todavía está incompleta. |
| **14** | La SD rechazó CMD17: lectura de un sector. |
| **15** | No llegó el indicador de inicio de los datos del sector. |
| **16** | Llegó un indicador inesperado o de error al esperar el sector. |
| **18** | CMD0 no consiguió poner la SD en su estado inicial tras los reintentos. |
| **19** | Respuesta inesperada o inválida durante la identificación CMD8. |
| **1A** | La SD rechazó CMD55 o ACMD41 durante su inicialización. |
| **1B** | La SD permaneció sin inicializarse tras todos los reintentos. |
| **1C** | La SD declara un rango de voltaje incompatible; no es una medición de la alimentación de la consola. |
| **1D** | Una tarjeta SDSC rechazó configurar bloques de 512 bytes mediante CMD16. |

## FAT32 / archivos

| Código | Significado |
|---|---|
| **20** | Falta la firma 55AA del sector de arranque o de particiones. |
| **21** | No se encontró una partición FAT32 reconocida. |
| **22** | Parámetros FAT32 (BPB) inválidos o incompatibles. |
| **23** | Distribución del volumen o cantidad de clústeres incompatible con FAT32. |
| **31** | Número de clúster inválido o fuera del volumen. |
| **32** | La exploración de la carpeta superó 1024 sectores; puede ser muy grande o tener una cadena FAT circular. |
| **33** | Se alcanzó el límite de 15 niveles de subcarpetas. |
| **41** | El archivo contiene menos de los 66 048 bytes necesarios para cargar el SPC. |
| **42** | La cadena de clústeres terminó antes de leer todos los datos necesarios del SPC. |

## Audio / compatibilidad

| Código | Significado |
|---|---|
| **51** | La APU no quedó lista en su estado IPL para recibir el archivo. |
| **52** | Falló la confirmación durante la transferencia o preparación del SPC en la APU. |
| **53** | No se pudo detener y recuperar la APU o liberar el audio del menú. |
| **54** | El driver no confirmó el inicio final de la reproducción. |
| **67** | Falló la validación del SPC: formato inválido, driver/variante no compatible o estado/distribución de memoria que no permite controles seguros. |
| **68** | El driver no respondió a un comando durante la reproducción: controles o lectura de datos del DSP. |

El error **67 no implica necesariamente un SPC dañado**. Un archivo válido
puede necesitar soporte para su driver, estado o distribución de memoria
para conservar los controles y cambiar de canción sin RESET.

## Códigos antiguos

Pertenecen a cargadores anteriores. La validación normal de 1.0 devuelve
67 para estos rechazos de compatibilidad.

| Código | Significado original |
|---|---|
| **61** | Falló la validación del antiguo cargador: cabecera SPC o estructura esperada de C700. |
| **62** | P3 no reconoció ninguno de los drivers de juegos que admitía aquel cargador. |
| **63** | La zona reservada para el antiguo control de parada estaba ocupada o no era apta. |
| **64** | El puerto guardado contenía el valor reservado para el antiguo comando de parada. |
| **66** | El estado del SPC no cumplía las condiciones del antiguo cargador general. |

**7E** existe solo en ROM de pruebas: falta un sector en el sistema de
archivos simulado. No está activo en las ROM de producción.
