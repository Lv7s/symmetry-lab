import Foundation

struct Lesson: Identifiable {
    var id: Int
    var title: String
    var idea: String
    var figure: String
    var objective: String
    var studentMoves: String
    var typicalError: String
    var openGroup: String?
    var openPlane: String?
    var openTriangle: Bool
    var openSpace: Int? = nil
    var body: String
}

enum CourseCatalog {
    static let all: [Lesson] = [
        Lesson(
            id: 1,
            title: "Qué es un grupo · objeto finito 2D",
            idea: "Conjunto + operación binaria; 4 condiciones. El triángulo da C3 y, con espejos, D3.",
            figure: "Triángulo equilátero con vértices A (ápice), B (derecha), C (izquierda); tabla 6×6.",
            objective: "Ver que las simetrías de un objeto forman un grupo, y distinguir C3 de D3.",
            studentMoves: "Aplicar E, R, R² y los tres espejos; leer la tabla (fila primero).",
            typicalError: "Creer que el orden de composición no importa. D3 no es abeliano.",
            openGroup: nil,
            openPlane: nil,
            openTriangle: true,
            body: class1
        ),
        Lesson(
            id: 2,
            title: "De 2D a 3D: los 32",
            idea: "Impropias 3D = ejes barra. 2̄ ≡ m. Solo 1,2,3,4,6 → 32 grupos en 7 sistemas.",
            figure: "Tabla de los 32 por filas. Agua = mm2. Tetraedro = 4̄. Toblerone = 6̄ ≡ 3/m.",
            objective: "Memorizar la tabla por sistemas; 11 enantiomorfos, 11 Laue, polares.",
            studentMoves: "Abrir 6̄ y 2/m en el estereograma.",
            typicalError: "Poner el eje 2 del monoclínico en z. En el curso va en y.",
            openGroup: "-6", openPlane: nil, openTriangle: false,
            body: "Richard pasa a objetos finitos 3D. Impropias = rotación-inversión n̄ (inversión por un punto sobre el eje, no «alrededor del eje»). 2̄ es un espejo ⊥ al eje: por eso nunca se escribe 2̄, se escribe m.\n\nCristalográficamente solo importan 1, 2, 3, 4, 6 y sus barras. Combinaciones permitidas: 32 grupos puntuales, 7 sistemas. Unique-b: en monoclínico el eje único es Y.\n\n11 grupos solo de rotaciones propias (quirales: proteínas). 11 centrosimétricos al final de cada línea (grupos de Laue). Polares: más de un punto queda fijo (1, 2, m, mm2, 3, 3m, 4, 4mm, 6, 6mm).\n\n6̄ ≡ 3/m: no hay 3/m en la tabla, es hexagonal."
        ),
        Lesson(
            id: 3,
            title: "Primeros estereogramas",
            idea: "GEP = óvalo; +/− = piso de z; coma = mano cambiada; óvalo partido = + y − juntos.",
            figure: "Círculos de 1, 1̄, 2 (eje en Y), 2/m, mm2, 4̄.",
            objective: "Dibujar GEP y reconocer propia vs impropia en el círculo.",
            studentMoves: "Arrastrar un GEP en 2 y en 2/m.",
            typicalError: "Poner coma en una rotación. Las propias no cambian la mano.",
            openGroup: "2/m", openPlane: nil, openTriangle: false,
            body: "Convención de Garratt: primer GEP siempre + (arriba del papel). Inversión: (x,y,z) → (x̄,ȳ,z̄) con coma. Eje 2 en Y: (x,y,z) → (x̄,y,z̄) sin coma.\n\n2/m (pizarra clase 3): el eje 2 sale del papel (rombo al centro). El espejo ⊥ a ese eje es el plano del papel: se dibuja como círculo más grueso, no como orla. El espejo manda cada GEP de + a − justo debajo, y cambia la mano → hay que partir el óvalo en dos (+ sin coma / − con coma). 2 × m genera el centro 1̄. Subgrupo {E, 2} dentro de {E, 2, m, 1̄}.\n\nmm2: dos espejos que se cortan a lo largo de z; el 2 corre por la intersección. Polar.\n\n4̄: invertir y rotar 90°. Hay un 2 subyacente; no hay 4 propio ni centro."
        ),
        Lesson(
            id: 4,
            title: "3̄, 6̄ ≡ 3/m, 222 y mmm",
            idea: "3̄ trae 3 y centro. 6̄ es idéntico a 3/m. Dos 2 perpendiculares generan el tercero.",
            figure: "3̄ (triángulo con punto). 3 vs 3/m vs 6̄. 222 (4 GEP) vs mmm (8 GEP).",
            objective: "Ver subelementos: 3̄ ⊃ {3, 1̄}; 6̄ ⊃ {3, mh}.",
            studentMoves: "Comparar 3, 3̄ y 6̄ en el visor.",
            typicalError: "Buscar 3/m entre los trigonales. Está como 6̄, hexagonal.",
            openGroup: "-6", openPlane: nil, openTriangle: false,
            body: "3̄ = inversión + rotación 120°. Aparecen un eje 3 y un centro: 3̄ ≡ 3 + 1̄. Distinto de 4̄, que no trae 4 ni 1̄.\n\nPizarra clase 4: 3/m (círculo grueso + triángulo) es idéntico a 6̄. El símbolo de 6̄ es hexágono con triángulo adentro: 6̄ = 3 + m. No existe 3/m en la tabla: es hexagonal 6̄.\n\n3m: una sola familia de espejos (el 3 las recorre). 4mm y 6mm: dos familias (el eje par no mezcla diagonales con horizontales).\n\n222: dos 2 perpendiculares generan el tercero. No hay puntual 22. mmm: tres espejos generan tres 2 y un centro; 8 GEP."
        ),
        Lesson(
            id: 5,
            title: "4/mmm y la red",
            idea: "Cierra puntuales con 4/mmm (16 GEP). Entra la red: singonía, celdilla, P/C/F/I → 14 Bravais.",
            figure: "Estereograma 4/mmm. Red 2D con espejos. Celdilla primitiva vs centrada.",
            objective: "Elegir celdilla que respete la simetría de la red.",
            studentMoves: "Ver 4/mmm y las 14 Bravais.",
            typicalError: "Elegir una celdilla que no sigue los espejos de la red.",
            openGroup: "4/mmm", openPlane: nil, openTriangle: false,
            body: "4/mmm: 4 ⊥ mh + dos familias de espejos verticales → 16 GEP. El 4 genera el segundo espejo de cada familia.\n\nRed: puntos idénticos. La singonía es el puntual que ves sentado en un nudo (siempre centrosimétrica: 1̄, 2/m, mmm, 3̄m, 4/mmm, 6/mmm, m3̄m).\n\nSe elige celdilla paralelepípeda con esa simetría. Precio: a veces hay nudos extra (centramientos P, C, F, I). Matematicamente 7 sistemas × 4 centrados = 28, pero muchas se reducen cambiando ejes (p. ej. C tetragonal → P). Quedan 14 redes de Bravais. Solo esas 14 importan."
        ),
        Lesson(
            id: 6,
            title: "14 Bravais y forma de la celdilla",
            idea: "a,b,c,α,β,γ. Unique-b en monoclínico. Trigonal = cubo estirado en una diagonal.",
            figure: "Paralelepípedo diestro. Restricciones por sistema. I ortorrómbica no es C monoclínica.",
            objective: "Conectar sistema cristalino con métrica de la celdilla.",
            studentMoves: "Girar las 14 redes.",
            typicalError: "Poner el 2 monoclínico en c. El curso (y casi todo el software) usa b.",
            openGroup: nil, openPlane: nil, openTriangle: false,
            body: "Triclínico: sin restricción. Monoclínico: β ≠ 90°, eje 2 ∥ b. Ortorrómbico: ángulos 90°, aristas distintas. Tetragonal: a = b, 4 ∥ c. Hexagonal: a = b, γ = 120°. Trigonal: romboedro (a = b = c, ángulos iguales ≠ 90°) o celdilla hexagonal. Cúbico: cubo.\n\nSiempre triedro diestro. ITA dibuja monoclínicos dos veces (unique-b y unique-c); Garratt usa unique-b."
        ),
        Lesson(
            id: 7,
            title: "Tornillos y deslizamientos",
            idea: "Espacial = puntual + traslaciones. Nuevos elementos: nᵣ y glides.",
            figure: "2₁ a lo largo de b. 3₁ diestra vs 3₂ zurda.",
            objective: "Definir nᵣ = rotación 360°/n + traslación r/n a lo largo del eje.",
            studentMoves: "En Redes, pgg: ver glides; apagar traslaciones.",
            typicalError: "Creer que 2₁ tiene sentido de hélice. 180° no distingue mano.",
            openGroup: nil, openPlane: "pgg", openTriangle: false,
            body: "La traslación mueve todos los puntos: ya no hay grupo puntual. El grupo espacial combina rotaciones/reflexiones/inversiones con la red.\n\nTornillo nᵣ: rotación 360°/n + traslación (r/n) del vector de eje. 2₁, 3₁/3₂, 4₁/4₂/4₃, 6₁…6₅. 3₁ y 3₂ son espejos uno del otro.\n\nGlide: espejo + traslación ½ (a, b, c, n diagonal, d diamante).\n\nSi se apagan las traslaciones queda el puntual isogonal.\n\nLos 17 grupos planos (Alhambra) existen y estan en ITA. Richard no los dibuja: dice que estudiar esas proyecciones es un ejercicio un tanto tonto y no da informacion util para resolver estructuras. En el visor estan como consulta ITA, no como temario."
        ),
        Lesson(
            id: 8,
            title: "Primeros grupos espaciales: P1, P1̄, C2",
            idea: "P1 trivial. P1̄: 8 centros. C2: el centramiento genera 2₁ intercalados.",
            figure: "Celdilla P1̄ con GEP +/− y coma. C2 con rombos 2 y patitas 2₁.",
            objective: "Plantar el puntual en cada nudo y completar por traslación.",
            studentMoves: "Abrir P2 (nº 3) y C2 (nº 5) en la lista de 230.",
            typicalError: "Confundir centro de simetría con nudo de red. No todos los centros son nudos.",
            openGroup: "-1", openPlane: nil, openTriangle: false,
            body: "Triedro: A abajo, B a la derecha, C saliente. Monoclínico se mira a lo largo de b.\n\nP1: un GEP por celdilla. P1̄: se pone 1̄ en el origen; aparecen centros a mitades. En 3D hay 8 centros independientes.\n\nC2: partir de P2 y copiar todo por (½,½,0). Eso genera 2₁ a ¼. C2 ≡ C2₁."
        ),
        Lesson(
            id: 9,
            title: "Del espacial al puntual; unidad asimétrica",
            idea: "Quitar del símbolo todo lo que sea traslación → puntual isogonal.",
            figure: "P2, C2, P2₁ → 2. Cc → m. I2₁2₁2₁ → 222. Fm3̄c → m3̄m.",
            objective: "Leer el puntual en el nombre internacional.",
            studentMoves: "En 230, abrir P2/m (nº 10) y Cc (nº 9).",
            typicalError: "Pensar que el número de moléculas lo fija la química. Lo fija el grupo (Z' aparte).",
            openGroup: "2/m", openPlane: nil, openTriangle: false, openSpace: 10,
            body: "Tras P2, C2, Pm y Pc queda el puntual 2/m. P2/m es simórfico: se plantan los 2 en los nudos (y se repiten a ½ a y ½ c). Se mira a lo largo de b; a a la derecha, c abajo, β ≠ 90°.\n\nNúmero de GEP = (operaciones del puntual) × primitividad. En P2/m: 4 × 1 = 4. El espejo en el papel parte cada óvalo en +/−.\n\nLos espejos van a y = 0 y y = ½. El recuadro de E y 2 del puntual sigue siendo subgrupo.\n\nCc (pizarra): C-centrada + glide c. Cuatro GEP: + , ½+ , − con coma , ½−. Al apagar la traslación del glide queda m. Cc → m.\n\nRegla del nombre: borrar P/I/F/C, el subíndice del tornillo y cambiar glide por m → puntual isogonal."
        ),
        Lesson(
            id: 10,
            title: "Polares, simórficos, regla de Bellow",
            idea: "Polar: no se fija el origen solo con simetría. Bellow corre el elemento ⊥ una mitad de la traslación del tornillo/glide.",
            figure: "P2, Pm, P2/m, P2₁/m (mh a ¼). P2₁/c.",
            objective: "Dibujar P2₁/m y P2₁/c con los elementos corridos.",
            studentMoves: "Comparar P21/m (nº 11) y P21/c (nº 14).",
            typicalError: "Olvidar que el glide c también corre el 2₁ (no solo al revés). Apilar los GEP de P21/c como si fuera m.",
            openGroup: "2/m", openPlane: nil, openTriangle: false, openSpace: 14,
            body: "Lamina de cuatro (unique-b, a →, c ↓):\n\nP2: 2 macizos (sin hueco) en nudos y a 1/2. Dos GEP propios +. Polar: no hay m.\n\nPm: solo el espejo paralelo al papel (marca 0, 1/2). Un GEP con coma. Polar.\n\nP2/m: 2 con hueco (= centro en el papel) + m a 0 y 1/2. GEP partidos +/−. Simórfico.\n\nP21/m: el 2 se vuelve 21 (rombo con pata). Bellow: el tornillo traslada 1/2 b y corre el espejo la mitad = 1/4 b (marca 1/4, 3/4). GEP apilados 1/2+ y 1/2- con coma. El centro no coincide con el 21.\n\nP21/c (pizarra): el espejo se vuelve glide c. Sigue a 1/4 y 3/4, pero ahora corre 1/2 c: los GEP ya no se apilan, quedan + y 1/2- (coma) desplazados a lo largo de c. 2_1 en los bordes // c. Centro de inversion (punto rojo) a 1/2 b. Vista de lado: y en 0, glide a 1/4, inversion a 1/2, pareja a 1/2-y."
        ),
        Lesson(
            id: 11,
            title: "Ortorrómbicos P222 … P2₁2₁2₁",
            idea: "En el símbolo, 1.ª posición ∥ a, 2.ª ∥ b, 3.ª ∥ c. En P2₁2₁2₁ los tornillos no se cortan.",
            figure: "P222 (2 se cortan en el origen). P222₁ (2₁ en c, 2 a ¼). P2₁2₁2₁ (corridos ¼).",
            objective: "Leer Puvw: qué hay paralelo a cada eje.",
            studentMoves: "Lista 16–24. Abrir P222 (nº 16), P2221 (nº 17) y P212121 (nº 19).",
            typicalError: "Dibujar los tres 2₁ cortándose. En P2₁2₁2₁ se extrañan. Confundir la vista de P222 (a sale) con la de P222₁ / P212121 (c sale).",
            openGroup: "222", openPlane: nil, openTriangle: false, openSpace: 19,
            body: "P222 (pizarra): en la primera lamina se mira a lo largo de a. Los tres 2 se cortan en el origen. Simorfico.\n\nP2221: se mira a lo largo de c (triedro de las clases 11-12). El 2_1 va en c. Los 2 // a y // b quedan a z = 1/4. Si los dos 2 se cortaran, el tercero seria 2 y no 2_1.\n\nP212121 (pizarra + transcrito 11): Bellow, cada 2_1 separa a los otros dos por 1/4. Resultado: ninguno se corta y ninguno pasa por el origen (el origen ITA esta a 1/4 de cada tornillo).\n  2_1 // a baja, corrido 1/4 en b\n  2_1 // b a la derecha, a z = 1/4\n  2_1 // c sale, corrido 1/4 en a\n4 GEP (puntual 222 x primitividad 1). Proteinas."
        ),
        Lesson(
            id: 12,
            title: "I222: el centramiento genera 2₁",
            idea: "I = copiar cada GEP +(½,½,½). Aparecen 2₁ a ¼ que sí se cortan entre sí.",
            figure: "P222 → I222 (2 y 2₁ se cortan). P2₁2₁2₁ → I2₁2₁2₁ (no se cortan).",
            objective: "Completar simetría: de cada GEP a cada otro en un solo movimiento.",
            studentMoves: "I222 (nº 23) vs I212121 (nº 24).",
            typicalError: "Creer que I222 e I212121 son el mismo grupo porque ambos tienen 2 y 2₁ en a, b y c.",
            openGroup: "222", openPlane: nil, openTriangle: false, openSpace: 23,
            body: "Receta (transcrito 12): no se transforma P212121 en I222. Son dos recetas paralelas.\n\n1. Dibuja P222 (4 GEP). Copia cada GEP +(1/2, 1/2, 1/2). Quedan 8 (puntual 4 x primitividad 2).\n2. Completar: de cada GEP a cada otro con UN solo elemento. Los 4 nuevos no los explican los 2 de P222. Aparecen tres 2_1 que se CORTAN en (1/4, 1/4, 1/4). Los 2 siguen cortandose en 000. Eso es I222.\n\nLa misma receta sobre P212121 da I212121: tambien 8 GEP, tambien 2 y 2_1 en a, b y c, PERO ni los 2 ni los 2_1 se cortan (siguen extrañandose 1/4).\n\nEso es lo que pregunta el examen (clase 15): I222 e I212121 se parecen en el diagrama de difraccion (mismos tornillos, mismas ausencias). Se distinguen porque en uno se cortan y en el otro no."
        ),
        Lesson(
            id: 13,
            title: "Pbca y la elección de origen",
            idea: "Tres glides + 2₁. Centrosimétrico: origen en 1̄. 8 GEP.",
            figure: "Pbca con 8 GEP. P2/m con 8 centros distintos.",
            objective: "Derivar xyz de Pbca después de aplicar Bellow.",
            studentMoves: "Pbca es nº 61.",
            typicalError: "Confundir «elegir origen» con una decisión consciente. En la práctica lo fija el método de resolución.",
            openGroup: "mmm", openPlane: nil, openTriangle: false,
            body: "Pbca: b ⊥ a, c ⊥ b, a ⊥ c. Puntual mmm. Bellow corre los glides respecto del centro en el origen. 8 GEP.\n\nHay 8 centros distintos; solo los de los vértices son nudos si P es primitiva. Polar vs no polar otra vez: en P2 el origen queda en algún sitio del eje 2."
        ),
        Lesson(
            id: 14,
            title: "Cómo se lee el Volumen A",
            idea: "Nº 1–230, Hermann–Mauguin, unique-b, posiciones generales vs especiales, ausencias.",
            figure: "Página ITA de P2₁ (nº 4): 0k0 k = 2n. P2 sí tiene especiales, P2₁ no.",
            objective: "Saber qué se puede leer de una página de ITA sin redibujar todo.",
            studentMoves: "P2₁ nº 4 en la lista.",
            typicalError: "Poner una molécula finita en un tornillo. El tornillo es infinito: no hay posición especial.",
            openGroup: "2", openPlane: nil, openTriangle: false,
            body: "Richard: no vamos a dibujar los 230. Es incapaz de dibujarlos todos; los cubicos son un infierno. El curso cubre la logica en triclínico, monoclínico y ortorrómbico. El resto se lee en las Tablas Internacionales (Vol. A). En la practica profesional no se derivan: se consultan.\n\nLa lista de 230 del visor es esa consulta. Solo estan dibujados los que salieron en la pizarra.\n\nSchoenflies del espacial (C₂²) no informa: por eso cristalografía usa Hermann–Mauguin.\n\nPosición especial = coincidir con un elemento puntual (2, m, 1̄), nunca con tornillo ni glide.\n\nAusencias sistemáticas delatan traslación: 2₁ ∥ b → 0k0 solo k par. P2 y P2₁ tienen el mismo Laue; se distinguen por ausencias."
        ),
        Lesson(
            id: 15,
            title: "Tetragonales y pares enantiomorfos",
            idea: "Eje único en c. En P4, a mitad de a y b aparece un 2, no un 4. 4₁ y 4₃ son espejos.",
            figure: "P4. P4₃2₁2 (lisozima): 4₃ ∥ c, 2₁ ∥ a y b, 2 en [110].",
            objective: "Interpretar el símbolo tetragonal y la ambigüedad 4₁/4₃.",
            studentMoves: "P4 (nº 75), P4₃2₁2 (nº 96).",
            typicalError: "Resolver la proteína en el enantiomorfo equivocado y forzar L-aminoácidos.",
            openGroup: "4", openPlane: nil, openTriangle: false,
            body: "Tetragonal: a = b, 4 (o 4̄) ∥ c. P4₃2₁2: primera posición = 4₃ ∥ c; segunda = 2₁ ∥ a y ∥ b; tercera = 2 en la diagonal.\n\n4₁ y 4₃ dan las mismas ausencias (00l, l = 4n). Igual 6₁/6₅. No se distinguen por el patrón; hay que resolver la estructura (o anomalía). 2₁ no tiene mano."
        ),
        Lesson(
            id: 16,
            title: "Trigonal, hexagonal, cúbico",
            idea: "P3: ambigüedad de cuál triángulo llenar. P6: los dos triángulos son equivalentes. R3: romboedro o hexágono triple.",
            figure: "P3 vs P6. Página ITA de R3. Hexágono confundible con C-ortorrómbico si a/b = √3.",
            objective: "No mezclar celdilla hexagonal de P3 con la de P6, ni R con C-ortorrómbica.",
            studentMoves: "P3, P6, R3 en la lista. Estereograma 6 y 3.",
            typicalError: "Indexar un hexagonal genuino como C-ortorrómbico.",
            openGroup: "3", openPlane: nil, openTriangle: false,
            body: "La celdilla trigonal/hexagonal es un paralelepípedo de dos triángulos, no un prisma hexagonal (eso lo usan a veces los físicos del sólido).\n\nEn P3 los dos triángulos no son equivalentes: hay ambigüedad de celda al fusionar datos. En P6 el 6 los iguala.\n\nR3 se puede dibujar como romboedro o como hexágono triplemente primitivo (nodos en ⅓ y ⅔).\n\nUn hexagonal P se puede confundir con C-ortorrómbico; la pista es a = √3 b y la presencia del 6."
        ),
    ]

    static func byId(_ n: Int) -> Lesson { all.first { $0.id == n } ?? all[0] }
}

private let class1 = """
Clase 1 · Richard C. Garratt (transcrito). El curso empieza desde cero: nadie se supone que ya sepa simetría.

Qué es un grupo
Para tener un grupo hacen falta dos cosas: un conjunto de elementos y una operación binaria (algo que toma dos elementos y produce un tercero). Cuatro condiciones, todas obligatorias:

1. Cerradura — el resultado de operar dos elementos sigue dentro del conjunto.
2. Elemento nulo (identidad) E — no cambia al otro: E ∘ x = x. En suma es el 0; en simetría es «no hagas nada» (rotar 360°).
3. Inverso — para cada x hay un y con x ∘ y = E. Un espejo es su propio inverso. El inverso de 3¹ (120°) es 3² (240°).
4. Asociatividad — (a ∘ b) ∘ c = a ∘ (b ∘ c).

La conmutatividad (a ∘ b = b ∘ a) no es necesaria. Si se cumple, el grupo es abeliano. C3 lo es; D3 no.

Enteros con la suma
{1…6} con + no es grupo (sale 7). Enteros positivos con 0 fallan el inverso. ℤ (positivos, 0 y negativos) con + sí es grupo, infinito. Los grupos espaciales también serán infinitos.

Objeto finito 2D: triángulo equilátero
Simetría = operación que deja el objeto indistinguible del original. En 2D hay rotaciones (propias) y espejos (impropias). Un eje n-fold rota 360°/n.

Triángulo sin «patitas»:
• E
• 3¹ = R = 120° horario
• 3² = R² = 240°
• m1 por el ápice A (b ↔ c)
• m2 por B (derecha)
• m3 por C (izquierda) — así está en la pizarra de la clase 1; las notas 03 tenían m2/m3 al revés

Eso es D3, orden 6. Si se ponen patitas en los vértices se rompen los espejos y queda C3 = {E, R, R²}.

Convención del triángulo (pizarra de Garratt): A = ápice, B = derecha, C = izquierda. 3¹ horario: A top, C left, B right → C top, B left, A right.

El ejemplo de la clase (no conmuta): 3¹ luego m2 ≡ m3; m2 luego 3¹ ≡ m1. La diagonal de la tabla no es espejo: D3 no es abeliano. Las rotaciones {E, 3¹, 3²} son un subgrupo (C3). Tarea: completar el resto de la tabla 6×6.

Propias e impropias
Propia: no cambia la quiralidad (rotaciones). Se puede hacer con un objeto físico.
Impropia: cambia la mano (espejo). Las dos manos: no hay rotación que lleve la izquierda a la derecha.

Regla: propio∘propio = propio; propio∘impropio = impropio; impropio∘impropio = propio.

Grupos puntuales 2D
Se llaman puntuales porque al menos un punto no se mueve. Polar: se mueve más de un punto (todos los del espejo, o todos los del eje). Nombres: 1, 2, 3, … y m, 2m, 3m, 4mm… (n impar → una familia de espejos; n par → dos, de ahí 4mm). Hay infinitos puntuales 2D. En 3D también infinitos, pero para cristales solo 32.

Hermann–Mauguin es la nomenclatura del curso (extensible a espaciales). Schoenflies (C3, D3) se menciona para quien viene de química y después se deja.

Ejercicio de la clase: completar la tabla 6×6 del triángulo y convencerse de cerradura, nulo, inversos y asociatividad. El laboratorio C3/D3 de esta app es exactamente eso.
"""
