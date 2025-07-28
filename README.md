
# Mundo del Wumpus en Prolog

Simulación de un agente inteligente que explora un mundo de **8×15 celdas**, evita **wumpus** y **pozos**, y recolecta **oro** usando percepciones (brisa, hedor, brillo). Implementado en **Prolog** con lógica declarativa, exploración automática y visualización del recorrido final.

 Descripción del Mundo

- **Tamaño:** 8 filas × 15 columnas (120 celdas)
- **Inicio del agente:** `(1, 1)`
- **Objetivos:** Encontrar 2 piezas de oro en `(7,12)` y `(3,8)`
- **Peligros:**
  - **Wumpus:** `(6,10)` y `(2,5)`
  - **Pozos (10):** `(2,3)`, `(4,6)`, `(5,9)`, `(1,8)`, `(7,4)`, `(3,13)`, `(6,2)`, `(8,7)`, `(4,11)`, `(1,14)`



Percepciones del Agente

El agente percibe indirectamente los peligros:
- **Brisa:** Si hay un pozo en una celda adyacente.
- **Hedor:** Si hay un wumpus cercano.
- **Brillo:** Si está sobre una celda con oro.

No ve directamente los elementos, sino que razona a partir de estas señales.

---

##  Cómo Ejecutar

### Requisitos
- [SWI-Prolog](https://www.swi-prolog.org/) instalado

### Pasos
1. Abre el archivo en SWI-Prolog:
   ```bash
   swipl src/wumpus_simulacion.pl
