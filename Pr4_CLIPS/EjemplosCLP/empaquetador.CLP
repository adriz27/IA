/*
Sistema de reglas para empaquetado de art�culos
Se quiere construir un sistema de reglas en CLIPS que permita empaquetar art�culos en cajas de forma autom�tica. Se partir� de un conjunto de hechos iniciales que describen los productos que tenemos que empaquetar y de las cajas disponibles en el almac�n. Dispongo de un n�mero ilimitado de cajas iguales, es decir, con la misma capacidad m�xima. 
PRODUCTOS 	
Nombre	cadena
Tipo 	Fr�gil/Pesado/Normal
Envuelto	Si/No
Volumen	Valor entre 0 y 200

Codificar las reglas necesarias para modelar el siguiente comportamiento:
-	Cada art�culo se envuelve de manera individual.
-	En las cajas s�lo podemos empaquetar art�culos envueltos.
-	Todos los art�culos de la misma caja son del mismo tipo, es decir, un art�culo fr�gil no se empaquetar� en una caja que ya se ha abierto para meter art�culos pesados.
-	Si tenemos una caja ya empezada con alg�n art�culo, seguiremos llen�ndola con art�culos del mismo tipo (fr�gil o pesado) antes de abrir una caja nueva. 
-	Cada art�culo y caja tienen unos vol�menes asociados, de forma que un art�culo podr� empaquetarse en una caja si el volumen disponible en �sta es mayor que el volumen del art�culo.
Ejecutar algunos ejemplos de prueba y comprobar c�mo se modifica la memoria de trabajo. 
Comenta c�mo afecta el cambio de estrategia de resoluci�n de conflictos en el resultado del sistema.
*/

(clear)
(deftemplate producto
    (slot nombre)
    (slot tipo)
    (slot envuelto (default no))
    (slot empaquetado (default no))
    (slot volumen)
)

(deftemplate caja	
    (slot id)
    (multislot productos)   ; se pueden guardar los productos que de en esta caja. Basta con mostrar el resultado.
    (slot tipo (default vacia))  ; el tipo se cambia al meter el primer producto en la caja
    (slot volumen (default 100))  ; volumen inicial para todas las cajas
)


; al principio no represento cajas porque como tengo un numero ilimitado puedo ir creando seg�n necesite. 
(deffacts inicio
    (producto (nombre p1)(tipo fragil) (volumen 20))
    (producto (nombre p2)(tipo fragil) (volumen 20))
    (producto (nombre p3)(tipo fragil) (volumen 20))
    (producto (nombre p4)(tipo fragil) (volumen 20))
    (producto (nombre p5)(tipo fragil) (volumen 20))
    )

(defrule inicializar
=> 
(assert (caja (id c1))) 					
(assert (caja (id c8))) 	
)

; regla para envolver productos
(defrule envolver
    ?h <-(producto (nombre ?p) (envuelto no) (empaquetado no))
    =>
   (modify ?h (envuelto si))
   (printout t "envolviendo producto  " ?p crlf)
)


(defrule empaquetar_en_caja_abierta
     ?h <- (caja (id ?c) (tipo ?tc) (volumen ?vc)(productos $?productos))
     ?hp <- (producto (nombre ?p) (tipo ?tp) (volumen ?vp) (empaquetado no) (envuelto si))    
     (test(eq ?tc ?tp))   ; miramos si es del mismo tipo 
     (test (>= (- ?vc ?vp) 0))  ;y si cabe el producto
  =>
     (printout t "Producto  " ?p " de tipo " ?tc " en caja " ?c crlf)
     (modify ?hp (empaquetado si))
     (modify ?h  (productos (insert$ $?productos 1 ?p)) (volumen (- ?vc ?vp))))
 

(defrule empaquetar_en_nueva_caja
     ?h <- (caja (id ?c) (tipo vacia) (volumen ?vc))
     ?hp <- (producto (nombre ?p) (tipo ?tp) (volumen ?vp) (empaquetado no) (envuelto si))
     (test (>= (- ?vc ?vp) 0))  ;y si cabe el producto
    =>
     (printout t "Producto  " ?p "de tipo " ?tp " en caja nueva " ?c crlf)
     (modify ?hp (empaquetado si))
     (modify ?h (productos (insert$ (create$) 1 ?p)) (volumen (- ?vc ?vp)) (tipo ?tp)))



;(printout t "Productos en la caja  " $?productos crlf))
     ;(modify ?h (productos (insert$ ?productos  ?p)))