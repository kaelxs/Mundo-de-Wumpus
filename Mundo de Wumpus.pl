% ========================================
% SIMULACIÓN DEL MUNDO DEL WUMPUS EN PROLOG
% Mundo 8x15 con exploración automática del agente
% ========================================

% CONFIGURACIÓN DEL MUNDO EXPANDIDO
% Posición inicial del agente
agente_inicial(1, 1).

% Ubicación de elementos en el mundo 8x15
oro(7, 12).          % Oro más alejado para mayor desafío
oro(3, 8).           % Segundo oro (opcional)
wumpus(6, 10).       % Wumpus principal
wumpus(2, 5).        % Segundo Wumpus (más peligroso)

% Pozos distribuidos estratégicamente
pozo(2, 3).
pozo(4, 6).
pozo(5, 9).
pozo(1, 8).
pozo(7, 4).
pozo(3, 13).
pozo(6, 2).
pozo(8, 7).
pozo(4, 11).
pozo(1, 14).

% Límites del mundo 8x15
limite_filas(8).
limite_columnas(15).

% ========================================
% PREDICADOS DE PERCEPCIONES
% ========================================

% Detectar brisa (hay un pozo adyacente)
hay_brisa(X, Y) :-
    limite_filas(MaxY), limite_columnas(MaxX),
    X >= 1, X =< MaxX, Y >= 1, Y =< MaxY,
    (   adyacente(X, Y, Px, Py), pozo(Px, Py)
    ->  true
    ;   false
    ).

% Detectar hedor (hay un Wumpus adyacente)
hay_hedor(X, Y) :-
    limite_filas(MaxY), limite_columnas(MaxX),
    X >= 1, X =< MaxX, Y >= 1, Y =< MaxY,
    (   adyacente(X, Y, Wx, Wy), wumpus(Wx, Wy)
    ->  true
    ;   false
    ).

% Detectar brillo (hay oro en la posición actual)
hay_brillo(X, Y) :-
    oro(X, Y).

% Celdas adyacentes (arriba, abajo, izquierda, derecha)
adyacente(X, Y, X1, Y) :- 
    X1 is X + 1, 
    limite_columnas(MaxX), 
    X1 =< MaxX.
adyacente(X, Y, X1, Y) :- 
    X1 is X - 1, 
    X1 >= 1.
adyacente(X, Y, X, Y1) :- 
    Y1 is Y + 1, 
    limite_filas(MaxY), 
    Y1 =< MaxY.
adyacente(X, Y, X, Y1) :- 
    Y1 is Y - 1, 
    Y1 >= 1.

% ========================================
% LÓGICA DEL AGENTE
% ========================================

% Celda es segura si no hay pozo ni Wumpus
celda_segura(X, Y) :-
    limite_filas(MaxY), limite_columnas(MaxX),
    X >= 1, X =< MaxX, Y >= 1, Y =< MaxY,
    \+ pozo(X, Y),
    \+ wumpus(X, Y).

% Movimiento válido (dentro de límites y celda segura)
movimiento_valido(X, Y) :-
    limite_filas(MaxY), limite_columnas(MaxX),
    X >= 1, X =< MaxX,
    Y >= 1, Y =< MaxY,
    celda_segura(X, Y).

% Obtener movimientos posibles desde una posición
movimientos_posibles(X, Y, Movimientos) :-
    findall([Nx, Ny], 
           (adyacente(X, Y, Nx, Ny), movimiento_valido(Nx, Ny)), 
           Movimientos).

% ========================================
% SISTEMA DE EXPLORACIÓN INTELIGENTE
% ========================================

% Inicializar exploración
iniciar_exploracion :-
    retractall(visitado(_, _)),
    retractall(recorrido(_, _, _)),
    retractall(oro_encontrado(_, _)),
    agente_inicial(X, Y),
    assertz(visitado(X, Y)),
    assertz(recorrido(1, X, Y)),
    format('=== INICIANDO EXPLORACIÓN DEL MUNDO DEL WUMPUS EXPANDIDO ===~n'),
    format('Mundo: 8 filas x 15 columnas (120 celdas)~n'),
    format('Agente inicia en: (~w, ~w)~n', [X, Y]),
    format('Oros ubicados en: (7, 12) y (3, 8)~n'),
    format('Wumpus ubicados en: (6, 10) y (2, 5)~n'),
    format('Total de pozos: 10 distribuidos por el mundo~n~n'),
    explorar(X, Y, 1).

% Predicado principal de exploración con límite de pasos
explorar(X, Y, Paso) :-
    Paso =< 200,  % Límite de pasos para evitar bucles infinitos
    format('--- PASO ~w ---~n', [Paso]),
    format('Agente en posición: (~w, ~w)~n', [X, Y]),
    
    % Mostrar percepciones
    mostrar_percepciones(X, Y),
    
    % Verificar si encontró oro
    (   hay_brillo(X, Y)
    ->  format('¡ÉXITO! El agente encontró oro en (~w, ~w)!~n', [X, Y]),
        assertz(oro_encontrado(X, Y)),
        (   contar_oro_encontrado(Total), Total >= 2
        ->  format('¡MISIÓN COMPLETADA! Encontró todo el oro disponible.~n'),
            format('Exploración completada en ~w pasos.~n~n', [Paso]),
            mostrar_estadisticas_finales,
            mostrar_mapa_final
        ;   format('Continúa buscando más oro...~n~n'),
            continuar_exploracion(X, Y, Paso)
        )
    ;   % Continuar explorando
        continuar_exploracion(X, Y, Paso)
    ).

explorar(_, _, Paso) :-
    Paso > 200,
    format('Límite de pasos alcanzado (~w). Terminando exploración.~n', [Paso]),
    mostrar_estadisticas_finales,
    mostrar_mapa_final.

% Continuar exploración
continuar_exploracion(X, Y, Paso) :-
    format('Analizando movimientos posibles...~n'),
    (   encontrar_mejor_movimiento(X, Y, Nx, Ny)
    ->  format('Moviéndose a: (~w, ~w)~n~n', [Nx, Ny]),
        assertz(visitado(Nx, Ny)),
        Paso1 is Paso + 1,
        assertz(recorrido(Paso1, Nx, Ny)),
        explorar(Nx, Ny, Paso1)
    ;   format('No hay más movimientos seguros disponibles.~n'),
        format('Exploración terminada en ~w pasos.~n~n', [Paso]),
        mostrar_estadisticas_finales,
        mostrar_mapa_final
    ).

% Estrategia mejorada para encontrar el mejor movimiento
encontrar_mejor_movimiento(X, Y, Nx, Ny) :-
    movimientos_posibles(X, Y, Movimientos),
    (   % Priorizar celdas no visitadas
        member([Nx, Ny], Movimientos),
        \+ visitado(Nx, Ny)
    ;   % Si todas están visitadas, elegir cualquiera
        member([Nx, Ny], Movimientos)
    ).

% Contar oro encontrado
contar_oro_encontrado(Total) :-
    findall(_, oro_encontrado(_, _), Lista),
    length(Lista, Total).

% Mostrar percepciones del agente
mostrar_percepciones(X, Y) :-
    format('Percepciones: '),
    percepciones_lista(X, Y, Lista),
    (   Lista = []
    ->  format('Ninguna~n')
    ;   format('~w~n', [Lista])
    ).

% Generar lista de percepciones
percepciones_lista(X, Y, Lista) :-
    findall(Percepcion,
           (   (hay_brisa(X, Y), Percepcion = 'Brisa')
           ;   (hay_hedor(X, Y), Percepcion = 'Hedor')
           ;   (hay_brillo(X, Y), Percepcion = 'Brillo')
           ),
           Lista).

% ========================================
% VISUALIZACIÓN DEL MAPA EXPANDIDO
% ========================================

% Mostrar estadísticas finales
mostrar_estadisticas_finales :-
    format('=== ESTADÍSTICAS DE LA EXPLORACIÓN ===~n'),
    findall(_, visitado(_, _), Visitadas),
    length(Visitadas, TotalVisitadas),
    TotalCeldas is 8 * 15,
    Porcentaje is (TotalVisitadas * 100) / TotalCeldas,
    format('Celdas visitadas: ~w/~w (~1f%)~n', [TotalVisitadas, TotalCeldas, Porcentaje]),
    contar_oro_encontrado(OroEncontrado),
    format('Oro encontrado: ~w/2~n', [OroEncontrado]),
    findall(_, recorrido(_, _, _), Pasos),
    length(Pasos, TotalPasos),
    format('Total de pasos: ~w~n~n', [TotalPasos]).

% Mostrar mapa final compacto para mundo grande
mostrar_mapa_final :-
    format('=== MAPA FINAL DEL RECORRIDO (8x15) ===~n'),
    format('Leyenda: O=Oro, W=Wumpus, P=Pozo, *=Visitado, -=No visitado~n~n'),
    format('    '),
    mostrar_numeros_columnas(1, 15),
    nl,
    limite_filas(MaxY),
    mostrar_filas_expandido(MaxY, MaxY).

% Mostrar números de columnas para referencia
mostrar_numeros_columnas(X, Max) :-
    X > Max, !.
mostrar_numeros_columnas(X, Max) :-
    (   X < 10
    ->  format(' ~w', [X])
    ;   format('~w', [X])
    ),
    X1 is X + 1,
    mostrar_numeros_columnas(X1, Max).

% Mostrar filas del mapa expandido (de arriba hacia abajo)
mostrar_filas_expandido(0, _) :- !.
mostrar_filas_expandido(Y, Max) :-
    format('~w | ', [Y]),
    limite_columnas(MaxX),
    mostrar_columnas_expandido(1, Y, MaxX),
    nl,
    Y1 is Y - 1,
    mostrar_filas_expandido(Y1, Max).

% Mostrar columnas de una fila (versión compacta)
mostrar_columnas_expandido(X, Y, Max) :-
    X > Max, !.
mostrar_columnas_expandido(X, Y, Max) :-
    simbolo_celda_compacto(X, Y, Simbolo),
    format('~w ', [Simbolo]),
    X1 is X + 1,
    mostrar_columnas_expandido(X1, Y, Max).

% Determinar símbolo compacto para cada celda
simbolo_celda_compacto(X, Y, Simbolo) :-
    (   oro_encontrado(X, Y)
    ->  Simbolo = 'O'  % Oro encontrado
    ;   oro(X, Y)
    ->  Simbolo = 'G'  % Oro no encontrado (Gold)
    ;   wumpus(X, Y)
    ->  Simbolo = 'W'  % Wumpus
    ;   pozo(X, Y)
    ->  Simbolo = 'P'  % Pozo
    ;   visitado(X, Y)
    ->  Simbolo = '*'  % Visitado
    ;   Simbolo = '-'   % No visitado
    ).

% ========================================
% PREDICADOS AUXILIARES Y CONSULTAS
% ========================================

% Mostrar configuración del mundo expandido
mostrar_mundo :-
    format('=== CONFIGURACIÓN DEL MUNDO EXPANDIDO (8x15) ===~n'),
    agente_inicial(Ax, Ay),
    format('Agente inicial: (~w, ~w)~n', [Ax, Ay]),
    findall([Ox, Oy], oro(Ox, Oy), Oros),
    format('Oros: ~w~n', [Oros]),
    findall([Wx, Wy], wumpus(Wx, Wy), Wumpuses),
    format('Wumpuses: ~w~n', [Wumpuses]),
    findall([Px, Py], pozo(Px, Py), Pozos),
    length(Pozos, NumPozos),
    format('Pozos (~w total): ~w~n~n', [NumPozos, Pozos]).

% Verificar percepciones en una posición específica
consultar_percepciones(X, Y) :-
    format('Percepciones en (~w, ~w): ', [X, Y]),
    percepciones_lista(X, Y, Lista),
    (   Lista = []
    ->  format('Ninguna~n')
    ;   format('~w~n', [Lista])
    ).

% Mostrar área de peligro alrededor de una posición
mostrar_area_peligro(X, Y) :-
    format('=== ANÁLISIS DE PELIGRO EN (~w, ~w) ===~n', [X, Y]),
    format('Celdas adyacentes:~n'),
    findall([Ax, Ay], adyacente(X, Y, Ax, Ay), Adyacentes),
    mostrar_analisis_celdas(Adyacentes).

mostrar_analisis_celdas([]).
mostrar_analisis_celdas([[X, Y]|Resto]) :-
    format('  (~w, ~w): ', [X, Y]),
    (   pozo(X, Y)
    ->  format('POZO - PELIGROSO~n')
    ;   wumpus(X, Y)
    ->  format('WUMPUS - PELIGROSO~n')
    ;   oro(X, Y)
    ->  format('ORO - ¡OBJETIVO!~n')
    ;   format('Seguro~n')
    ),
    mostrar_analisis_celdas(Resto).

% ========================================
% COMANDOS PRINCIPALES
% ========================================

% Comando principal para ejecutar la simulación
simular :- iniciar_exploracion.

% Comando para mostrar información del mundo
info :- mostrar_mundo.

% Reiniciar simulación
reiniciar :-
    retractall(visitado(_, _)),
    retractall(recorrido(_, _, _)),
    retractall(oro_encontrado(_, _)),
    format('Simulación reiniciada.~n').

% Modo exploración paso a paso
explorar_paso_a_paso :-
    reiniciar,
    agente_inicial(X, Y),
    assertz(visitado(X, Y)),
    assertz(recorrido(1, X, Y)),
    format('Modo paso a paso activado. Use siguiente_paso para continuar.~n'),
    assertz(modo_paso_a_paso(X, Y, 1)).

siguiente_paso :-
    modo_paso_a_paso(X, Y, Paso),
    retract(modo_paso_a_paso(X, Y, Paso)),
    explorar(X, Y, Paso).

% ========================================
% INSTRUCCIONES DE USO EXPANDIDAS
% ========================================

% Para usar esta simulación expandida:
% 1. Cargar el archivo en SWI-Prolog
% 2. Ejecutar: ?- simular.
% 3. Para ver información del mundo: ?- info.
% 4. Para reiniciar: ?- reiniciar.
% 5. Para consultar percepciones: ?- consultar_percepciones(X, Y).
% 6. Para análisis de peligro: ?- mostrar_area_peligro(X, Y).
% 7. Para modo paso a paso: ?- explorar_paso_a_paso.

% EJEMPLO DE CONSULTAS:
% ?- simular.                    % Ejecutar simulación completa
% ?- info.                       % Mostrar configuración del mundo expandido
% ?- consultar_percepciones(7,12). % Ver percepciones donde está el oro
% ?- mostrar_area_peligro(2,5).  % Analizar área del Wumpus
% ?- explorar_paso_a_paso.       % Modo controlado manualmente