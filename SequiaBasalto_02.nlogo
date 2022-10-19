;***********************************************************************
; ADAPTATION OF SEQUIA-BASALTO MODEL TO NETLOGO
;***********************************************************************
; The original model was built in CORMAS, for more information about the original model see Dieguez-Cameroni et al. (2012, 2014).
; Some aspects of the model related with the growth of livestock and the transition through different age classes are based on Robins et al. (2015).

globals [ ;  It defines new global variables. Global variables are "global" because they are accessible by all agents and can be used anywhere in a model. Most often, globals is used to define variables or constants that need to be used in many parts of the program.

;Climate related global variables

 climacoef ; External data, It relates the primary production in a season with the average for that season due to climate variations.
           ;;;;;;;;;;;;; AGENTS AFFECTED: patches; PROPERTY OF THE AGENT AFFECTED: grass-height (climaCoef variable)
 current-season ; Initial-season (slider) ;Variable to define the season in which the simulation begins, it should take the values: 0 = winter, 1 = spring, 2 = summer, 3 = fall.
 current-season-name ; this variable just converts the numbers "0, 1, 2, 3" of the seasons to text "winter, spring, summer, fall", and this variable ONLY is used in the reporter/procedure "to-report season-report"
 season-coef ;It affects the live weight gain in relation with the grass quality according to the season, winter = 1; spring = 1.15, summer = 1.05, fall = 1.
             ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: live-weight-gain (seasonCoef variable)

;Time related global variables

 days-per-tick ; variable to simulate time.
 number-of-season ; to keep track of the number of seasons in 10 years of simulation (10 years = 3680 days = 40 seasons).
 simulation-time ; variable to keep track of the days of the simulation.
 year-cnt ; year count: variable to keep track of the years of the simulation.

;Market prices & economic balance related global variables

  exploitation-costs ; External data, regular costs for maintaining the plot ($/ha).
  grazing-prices ; External data, costs for renting an external plot ($/head/season sent it to the external plot).
  supplement-prices ; External data, costs for feeding the animals with food supplements (grains, $/head/season).
  born-calves-prices ; External data, prices for selling born calves ($/Kg).
  weaned-calves-prices ; External data, prices for selling weaned calves ($/Kg).
  steers-prices ; External data, prices for selling born steers ($/Kg).
  heifers-prices ; External data, prices for selling heifers ($/Kg).
  cows-prices; External data, prices for selling empty cows ($/Kg).
  pregnant-cows-prices ; External data, prices for selling pregnant cows ($/Kg).
  lactating-cows-prices ; External data, prices for selling lactating cows ($/Kg).
  sheep-prices ; External data, prices for selling sheep-meat ($/Kg).
  wool-prices ; External data, prices for selling wool ($/Kg).
  exploitation-net-incomes
  exploitation-balance
  initial-balance ;


;Grass related global variables

 ;initial-grass-height; The initial grass height is chosen by users.
 kmax  ;Paramater: maximum carrying capacity (maximum grass height), it varies according to the season, winter= 7.4 cm, spring= 22.2 cm, summer= 15.6 cm, fall= 11.1 cm.
       ;;;;;;;;;;;;; AGENTS AFFECTED: patches; PROPERTY OF THE AGENT AFFECTED: grass-height (K variable)
 DM-cm-ha ;Parameter used to calculate the grass-height consumed from the dry matter consumed = 180 Kg of DM/cm/ha.
         ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: ddmc
 grass-energy ;Parameter: metabolizable energy per Kg of dry matter = 1.8 Mcal/Kg of DM.
         ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: ddmc (grass-energy variable)
 DM-kg-ha

;Livestock related global variables

 ;initial-num-cows (slider) ;The initial number of animals is chosen by users.
 maxLWG ;Parameter (mi) that defines the maximum live weight gain per animal according to the season. Spring= 60 Kg/animal; Winter, Summer and Fall= 40 Kg/animal.
        ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: live-weight-gain (mi variable = maxLWG)
 ni ;Parameter used to define the live weight gain per animal (it's a constant: 0.24 1/cm).
    ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: live-weight-gain (ni variable)
 xi ;Parameter used to define the live weight gain per animal (it's a constant: 132 kg/animal).
    ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: live-weight-gain (xi variable)
 weaned-calf-age-min ; 246 days (8 months (245 days) + 1 day) ; Esta global variable determina el comienzo de la etapa "weaned-calf" del ciclo de vida de livestock (es decir, cuando el turtle alcanza los 246 días de edad, pasa a la age class de "weaned-calf")
 heifer-age-min ; 369 days (1 year (368 days) + 1 day) ; Esta global variable determina el comienzo de la etapa "heifer/steer" (heifer = hembra; steer = macho) del ciclo de vida de livestock (es decir, cuando el turtle alcanza los 368 días de edad, pasa a la age class de "heifer/steer": el turtle tiene un 50% de probabilidades de convertirse en uno u otro)
 cow-age-min ; 737 (2 years (736 days) + 1 day) ; Esta global variable determina el comienzo de la etapa "cow" del ciclo de vida de livestock (es decir, cuando el turtle alcanza los 737 días de edad, pasa a la age class de "cow")
 cow-age-max ; 5520 days (15 years) ; Esta global variable determina la esperanza de vida de las vacas (es decir, cuando el turtle alcanza los 5520 días, muere)
 gestation-period ; 276 days (9 months) ; Determines the gestation period of pregnant cows ; Esta global variable determina el FINAL de la etapa "pregnant" del ciclo de vida de livestock (es decir, cuando el agente de la age class "pregnant" alcanza los 276 días, pasa a la age class de "cow-with-calf")
 lactation-period ; 184 days (6 months) ; Determines the lactating period of cows with calves ; Esta global variable determina el FINAL de la etapa "cow-with-calf" del ciclo de vida de livestock (es decir, cuando el agente de la age class "cow-with-calf" alcanza los 184 días, pasa a la age class de "cow")
 weight-gain-lactation ; 0.61 Kg / day. The born calves do not depend on grasslands. We assume that born calves increase their live weight by 0.61 Kg/day. After 6 months, they should reach 150 Kg (the initial weight for weaned calves).
;perception (slider); parameter used to define the degree of perception of the animals regarding to the surrounding pastures. Chosen by users
]

breed [cows cow] ;We consider cows as the unique type of livestock (***future-step: to include sheep or goats as other types of livestock, and producers as decision makers).

patches-own [ ; This keyword, like the globals, breed, <breed>-own, and turtles-own keywords, can only be used at the beginning of a program, before any function definitions. It defines the variables that all patches can use. All patches will then have the given variables and be able to use them.
  ;initial-grass-height (slider); The initial grass height is chosen by users; Grass is homogeneously distributed along the paddock.
  grass-height ;State of the grass height, determines the carrying capacity of the system.
               ;;;;;;;;;;;;; AGENTS AFFECTED: patches; PROPERTY OF THE AGENT AFFECTED: grass-height

report-initial-grass-height ;;;;TEMP
DDMC-patch00 ;;;;TEMP

gh-final ; patch variable with same value that grass-height, and its only fuction is to tell cows to not eat grass below 2 cm

  r ;Parameter: growth rate for the grass = 0.002 1/day
    ;;;;;;;;;;;;; AGENTS AFFECTED: patches; PROPERTY OF THE AGENT AFFECTED: grass-height (r variable)
  GH-consumed ; grass-height consumed from the total consumption of dry matter.
   ]

cows-own [ ; The turtles-own keyword, like the globals, breed, <breeds>-own, and patches-own keywords, can only be used at the beginning of a program, before any function definitions. It defines the variables belonging to each turtle. If you specify a breed instead of "turtles", only turtles of that breed have the listed variables. (More than one turtle breed may list the same variable.)
  age ;Variable that define the age of each animal (in days).
  born-calf?
  weaned-calf?
  heifer?
  steer?
  cow?
  cow-with-calf?
  pregnant?
  animal-units ;parameter used to calculate the stocking rate. Cow = 1, cow-with-calf= 1, born-calf= 0.2, weaned-calf= 0.5, steer= 0.7, heifer= 0.7.
  category-coef ;This parameter is used to obtain the DDMC. It varies according the category of the animal, is equal to 1 in all categories, except for cow-with-calf = 1.1.
                ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: ddmc (category-coef variable)
  initial-weight ;cow= 280Kg, born-calf= 40Kg, weaned-calf= 150Kg, steer= 150Kg, and heifer= 200Kg.
  min-weight ;parameter to define the critical weight which below the animal can die by forage crisis. Cow= 180 Kg, weaned-calf= 60 Kg, Steer= 100 Kg, Heifer= 100 Kg.
  live-weight ;variable that defines the state of the animals in terms of live weight.
  live-weight-gain ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: live-weight-gain
  DDMC ;Daily dry matter consumption, variable that defines the individual grass consumption (depends on LWG). *Note: 1 cm of grass/ha/92 days = 180 Kg of dry matter (Units: Kg/animal/day).
       ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: ddmc

  metabolic-body-size ;metabolic body size (MBS) = LW^(3/4)
                      ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: ddmc (LW^(3/4) = MBS variable)
  mortality-rate
  natural-mortality-rate ;annual natural mortality = 2% (in a day = 0.000054).
  except-mort-rate ;exceptional mortality rates increases to 15% (in a day = 0.00041) in cows, 30% (= 0.000815) in pregnant cows, and 23% (0.000625) in the rest of categories when animal Live Weight (LW) falls below a critical survival value (i.e., Minimun weight, min-weight in the code).
  pregnancy-rate ;is calculated as a logistic function of LW, but it also varies with the category of the animals.
                 ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: pregnancy-rate
  coefA ;constant used to calculate the pregnancy rate. Cow= 20000, cow-with-calf= 12000, heifer= 4000.
                 ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: pregnancy-rate (coefA variable)
  coefB ;constant used to calculate the pregnancy rate. Cow= 0.0285, cow-with-calf= 0.0265, heifer= 0.029.
        ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: pregnancy-rate (coefB variable)
  pregnancy-time ; variable to determine gestation-period.
  lactating-time ; variable to determine lactating-period.
  ]

to setup
  ca
  setup-globals ; Procedure para darle valores (info) a las globals variables
  setup-grassland
  if (model-version = "open access") or (model-version = "management model") [setup-livestock]
  reset-ticks
end






to setup-globals ; Procedure para darle valores (datos) a las globals variables
  set days-per-tick 1
  set number-of-season 0
  set current-season-name ["winter" "spring" "summer" "fall"] ;this variable just converts the numbers "0, 1, 2, 3" of the seasons to text "winter, spring, summer, fall", and this variable ONLY is used in the reporter/procedure "to-report season-report"
  set simulation-time 0
  set year-cnt 0 ; variable to keep track of the years of the simulation.
  set weaned-calf-age-min 246
  set heifer-age-min 369
  set cow-age-min 737
  set cow-age-max 5520
  set gestation-period 276
  set lactation-period 184
  set weight-gain-lactation 0.61
  set ni 0.24
  set xi 132
  set grass-energy 1.8
  set DM-cm-ha (180 / 92) * 0.4 ; parameter that defines that each centimeter per hectare contains 180 Kg of dry matter (acummulated in 92 days). Here we divide 180 / 92 days to obtain the accumulation of DM in one day, and multiply it by 0.4 because se considera un factor de uso o tasa de desaparición del forraje/pastura (TDF)  por parte del animal del 40%  (es decir, que si la acumulación de materia seca (DM) en invierno (por poner un ejemplo) en un prado en el que no hay vacas pastando es de 1331,54 kg DM/ha, las vacas solo podrán aprovechar algo menos de la mitad, es decir, 532,62 kg DM/ha. Es decir, del 100% de MS disponible en el pasto, asumimos que el 60% restante es consumido por otros animales en pastoreo, por otros herbívoros y las pérdidas de forraje por senescencia, pisoteo y descomposición)
  set season-coef [1 1.15 1.05 1] ; al usar corchetes se crea una lista de n valores (en este caso, 4). En este caso, la lógica de crear una lista con valores distintos para la misma variable es que, como veremos más adelante, haremos que esta variable tenga un valor u otro en función del valor de otra variable (utilizando el el comando de NetLogo "item"), de manera que la variable adoptará uno de estos valores en función del valor de otra variable (en este caso, current-season, que puede adoptar 4 valores posibles: 0, 1, 2 ,3). Es decir, cuando current-season tiene valor 0 (i.e., winter) , se llama al primer valor de la lista de season-coef, que es 1 (es decir, season-coef tiene un valor de 1 en winter)
  set kmax [7.4 22.2 15.6 11.1] ; 4 valores: misma lógica que antes
  set maxLWG [40 60 40 40] ; 4 valores: misma lógica que antes
  set current-season initial-season ; initial-season is the slider in Interface (0 = winter, 1 = spring, 2 = summer, 3 = fall). The initial season is chosen by the user.
  set climacoef [1.53 1.31 1.23	1.48 1.29	0.87 0.96	1.26 1.17	0.71 0.86	1.44 1.34	0.86 1.06 1.19 0.72	0.80 0.93	0.98 0.87	1.17 1.02	0.83 0.09	1.32 0.87	1.08 1.42	0.75 1.00	0.65 0.50	1.19 1.07	0.62 0.77 1.05 1.18 1.05] ; variable con 40 valores. Esto es así porque el tiempo que vamos a simular son 10 años. Como cada año tiene 4 estaciones, y como el ClimaCoef varía cada año pues tenemos que: 10 años * 4 estaciones = 40 estaciones en total = 40 valores distintos para climaCoef (recordemos que estos 40 valores son datos históricos)
  set exploitation-costs [5.76 5.76	5.76 5.76	6.25 6.25	6.25 6.25	6.80 6.80	6.80 6.80 5.50 5.50	5.50 5.50	6.63 6.63	6.63 6.63	8.53 8.53	8.53 8.53	11.03	11.03	11.03	11.03	12.50	12.50	12.50	12.50	15.88	15.88	15.88	15.88	16.15	16.15	16.15	16.15] ; 40 valores: misma lógica que antes
  set grazing-prices [4	10 16	8	9	19 20	12 12	22 22	9	8	19 19	13 21	20 21	17 18	13 19	20 34	10 22	16 7 21	20 24	26 12	19 24	20 15	36 36] ; 40 valores: misma lógica que antes
  set supplement-prices [0.09	0.09 0.09	0.09 0.09	0.09 0.09	0.09 0.09	0.09 0.09	0.09 0.08	0.08 0.1 0.1 0.11	0.13 0.1 0.09	0.09 0.1 0.1 0.1 0.1 0.12 0.13 0.13 0.14 0.15 0.15 0.16	0.19 0.21	0.23 0.15	0.15 0.15	0.15 0.15] ; 40 valores: misma lógica que antes
  set born-calves-prices [0.74 0.8 0.84	0.88 0.87	0.71 0.69	0.7	0.66 0.63	0.66 0.76	0.74 0.8 0.86	0.83 0.86	0.98 0.99	0.99 1.02	1.02 0.94	0.98 0.91	1.06 1.13	1.17 1.26	1.3	1.36 1.33	1.31 1.74	1.2	0.94 1.03	1.03 1.03 1.03] ; 40 valores: misma lógica que antes
  set weaned-calves-prices [0.83 0.81	0.88 0.9 0.89	0.76 0.81	0.72 0.73	0.69 0.71	0.73 0.77	0.84 0.87	0.93 0.88	0.95 1 1.05	1.05 1.05	1.01 0.98	0.95 1.17 1.09 1.2 1.3 1.27	1.38 1.35	1.36 1.67	1.21 0.92	1.04 1.04	1.04 1.04] ; 40 valores: misma lógica que antes
  set steers-prices [0.68	0.72 0.76	0.8	0.79 0.65	0.63 0.64	0.6	0.57 0.6 0.69	0.67 0.73	0.78 0.75	0.79 0.89	0.9	0.9	0.93 0.93	0.86 0.89	0.82 0.97 1.02 1.06	1.15 1.18	1.23 1.21	1.19 1.59	1.09 0.85	0.94 0.94	0.94 0.94] ; 40 valores: misma lógica que antes
  set heifers-prices [0.63 0.63	0.68 0.71	0.69 0.6 0.6 0.56	0.53 0.45	0.49 0.48	0.53 0.58	0.64 0.67	0.59 0.7 0.73	0.72 0.75	0.75 0.66	0.69 0.65	0.81 0.83	0.82 0.94	0.92 1.05	0.97 0.98	1.17 0.87	0.62 0.72	0.72 0.72	0.72] ; 40 valores: misma lógica que antes
  set cows-prices [0.45	0.48 0.49	0.57 0.49	0.51 0.51	0.44 0.45	0.4	0.37 0.43	0.48 0.49	0.47 0.59	0.51 0.57	0.62 0.6 0.55	0.55 0.56	0.63 0.46	0.7	0.65 0.74	0.78 0.74	0.89 0.79	0.94 1.17	0.67 0.52	0.5	0.5	0.5	0.5] ; 40 valores: misma lógica que antes
  set pregnant-cows-prices [0.45 0.48	0.49 0.57	0.49 0.51	0.51 0.44	0.45 0.4 0.37 0.43 0.48 0.49 0.47 0.59 0.51	0.57 0.62	0.6	0.55 0.55	0.56 0.63	0.46 0.7 0.65	0.74 0.78	0.74 0.89	0.79 0.94	1.17 0.67	0.52 0.5 0.5	0.5	0.5] ; 40 valores: misma lógica que antes
  set lactating-cows-prices [0.51	0.52 0.54	0.55 0.53	0.45 0.47	0.42 0.42	0.39 0.42	0.42 0.45	0.55 0.61	0.63 0.57	0.64 0.7 0.68	0.67 0.67	0.78 0.65	0.58 0.85	0.77 0.77	0.81 0.83	0.91 0.89	0.92 1.1 0.81	0.52 0.64	0.64 0.64	0.64] ; 40 valores: misma lógica que antes
  set sheep-prices [0.47 0.52	0.47 0.48	0.51 0.49	0.54 0.46	0.49 0.49	0.56 0.51	0.59 0.76	0.92 0.81	0.82 0.96	1.05 0.84	0.81 0.77	0.68 0.59	0.45 0.46	0.56 0.57	0.48 0.64	0.8	0.92 0.94	0.88 0.98	0.98 0.98	0.98 0.98	0.98] ; 40 valores: misma lógica que antes
  set wool-prices [5.6 5.81	5.65 5.76	6.18 5.81	5.86 7.08	9.52 9.31	11.83	13.01	13.79	8.65 12.37 12.43 12.69 12.53 11.59 10.64 10.43 10.01 9.85	8.52 8.26	9	9	9.15 11.1 12.78	14.27 15.4 17.36 17.75 16.07 8.17	8.17 8.17	8.17 8.17] ; 40 valores: misma lógica que antes
end






to setup-grassland ; Procedure para darle valores (info) a los "patches-own" variables
  ask patches [
    set grass-height initial-grass-height ; initial-grass height is the slider in Interface (from a minimum of 3 cm to a maximum of 7 cm)
    set GH-consumed 0 ; establecemos que GH-consumed = 0 en el momento de empezar la simulación (i.e., tick 0 o tiempo 0)
    ifelse grass-height < 2 ; vamos a pedirles a los parches que tengan una grass-height inferior a 2 cm que se coloreen de verde claro. Esto es interesante porque lo relacionamos con la asunción de que las vacas no pueden comer pastos con altura inferior a 2 cm.
    [set pcolor 37]
    [set pcolor scale-color green grass-height 23 0]
    set r 0.002
  ]

;ask patch 0 0 [set grass-height 20] ; añado esta línea de código temporal para trabajar en el problema de qué pasa cuando dos vacas consumen la hierba de un mismo parche ;;;;TEMP
;ask patch 0 0 [set report-initial-grass-height 20] ;;;;TEMP


end






to setup-livestock

create-cows initial-num-cows [ ; initial-num-cows is the slider in Interface (from 50 to 700)
    set shape "cow"
    ;set initial-weight random (280 - 180) + 180 ; this is an alternative option: to define randomly the initial weight of the animals between a reasonable range.
    set live-weight initial-weight-cows ; se establece que en el tiempo 0 de la simulación (cuando se pulsa setup), la variable live-weight sea igual a initial-weight
    set mortality-rate natural-mortality-rate; la variable "natural-mortality-rate" se encuentra definida en los procedures de "to-become-XXXX (cow/heifer/steer/etc)", así que ya tiene el valor dado: 0.000054 (i.e., 0.005 % diario = 2% anual)
    set DDMC 0; establecemos que el Daily dry matter consumption (DDMC) = 0 en el momento de empezar la simulación (i.e., tick 0 o tiempo 0)
    ;set age cow-age-min ; esta línea de código desactivada llama a la global variable "cow-age-min" que tiene un valor de 737.
    set age random (cow-age-max - cow-age-min) + cow-age-min ; this is an alternative option: to define randomly the age of the animals between the minimum and the maximum.
    setxy random-pxcor random-pycor
    become-cow ] ; become-cow es un procedure que define la age class "cow" del ciclo de vida del cattle: le estamos diciendo que todas las vacas que se crean en el tiempo 0 de la simulación sean del age class tipo "cow"


create-cows initial-num-heifers [
    set shape "cow"
    set initial-weight initial-weight-heifer
    set live-weight initial-weight
    set mortality-rate natural-mortality-rate
    set DDMC 0
    set age heifer-age-min
    ;set age random (cow-age-max - cow-age-min) + cow-age-min
    setxy random-pxcor random-pycor
    become-heifer ]


 ;create-cows initial-HEIFER-in-patch-00 [
    ;set shape "cow"
    ;set initial-weight initial-weight-heifer
    ;set live-weight initial-weight
    ;set mortality-rate natural-mortality-rate
    ;set DDMC 0
    ;set age heifer-age-min
    ;set age random (cow-age-max - cow-age-min) + cow-age-min
    ;setxy 0 0
    ;become-heifer ]


end






to go
  if ticks >= 92 [ ; en esta primera parte se escribe el código relacionado con el cambio de estaciones.
    set number-of-season number-of-season + 1 ; to count the number of seasons in the simulation period (useful for external data of weather and market prices).
    ifelse current-season = 0 [
      set current-season 1
      if (model-version = "management model") [ ; Los siguientes tres procedures están sin codificar (ve al final del código)
      sell-males
      extraordinary-sales
      sacrifice-animals
    ]]
      [ifelse current-season = 1 [set current-season 2]
        [ifelse current-season = 2 [set current-season 3]
          [set current-season 0]
        ]
    ]
    set year-cnt year-cnt + 1 / 4
    reset-ticks
  ]

  set simulation-time simulation-time + days-per-tick
  ;if simulation-time >= 3680 [stop]
  if (model-version = "open access") or (model-version = "management model") [if not any? cows [stop]]
  ;if any? patches with [pcolor = red] [stop]
   ;;; AÑADIDO POR DIEGO: el código que está escrito a partir de esta línea (hasta el ;;;) son incorporaciones nuevas hechas por Diego

  if simulation-time = 92 [stop] ;REPLICA: esta linea de codigo es para replicar los resultados de "Dinamica pastura" de la fig 2 de Dieguez-Cameroni et al 2012. Borrar cuando este todo en orden
  if simulation-time = 184 [stop]
  if simulation-time = 276 [stop]
  if simulation-time = 368 [stop]

  if simulation-time = 3404 [stop] ;REPLICA: esta linea de codigo es para replicar los resultados de "Dinamica pastura" de la fig 2 de Dieguez-Cameroni et al 2012. Borrar cuando este todo en orden
  if simulation-time = 3496 [stop]
  if simulation-time = 3588 [stop]
  if simulation-time = 3680 [stop]



  ;; Orden original de los procedimientos: grow-grass  update-grass-height  eat-grass  move  grow-livestock  reproduce


  grow-grass
  reports-initial-grass-height ;;;;TEMP

  eat-grass4NEW
  report-DDMC-patch00 ;;;;TEMP

  update-grass-height

  update-live-weight4

  grow-livestock

  reproduce

  move

  tick
end







to grow-grass ; Fórmula de GH (Primary production (biomass) expressed in centimeters)
ask patches [
set grass-height ((item current-season kmax / (1 + ((((item current-season kmax * set-climacoef) - (grass-height)) / (grass-height)) * (e ^ (- r * simulation-time))))) * set-climacoef) ; Interesante: con item, lo que hacemos es llamar a uno de los valores de una lista. La sintaxis es "item index list" i.e., "item número nombre-lista" (lee el ejemplo del diccionario de NetLogo para entenderlo mejor)
                                                                                                                                                                                         ; Por ejemplo, con "item current-season kmax", hay que tener en cuenta que kmax son una lista de 4 items [7.4 22.2 15.6 11.1]. Cuando current season es 0, se está llamando al item 0 de kmax, que es 7.4; cuando es 1, se llama a 22.2, y así sucesivamente.
                                                                                                                                                                                         ; La misma lógica se aplica con "item number-of-season climacoef". climacoef es una lista con 40 items. Number-of-season puede adquirir hasta 40 valores (por lo de 10 años de simulación * 4 estaciones en un año = 40 estaciones)
                                                                                                                                                                                         ; COMENTARIO IMPORTANTE SOBRE ESTA FORMULA: se ha añadido lo siguiente: ahora, la variable "K" del denominador ahora TAMBIÉN multiplica a "climacoef". Ahora que lo pienso, así tiene más sentido... ya que la capacidad de carga (K) se verá afectada dependiendo de la variabilidad climática (antes solo se tenía en cuenta en el numerador). Ahora que recuerdo, en Dieguez-Cameroni et al. 2012, se menciona lo siguiente sobre la variable K "es una constante estacional que determina la altura máxima de la pastura, multiplicada por el coeficiente climático (coefClima) explicado anteriormente", así que parece que la modificacion nueva que he hecho tiene sentido.
  ]

;ask patch 0 0 [print (word ">>> INITIAL grass-height " [grass-height] of patch 0 0)] ;;;;TEMP

end
to reports-initial-grass-height ;;;;TEMP

  ask patches [set report-initial-grass-height grass-height]

end










to eat-grass4NEW
ask cows [
set metabolic-body-size live-weight ^ (3 / 4)
; Otra alternativa para el metabolic-body-size (elegir esta alternativa si te da error por valores negativos en live-weight)
;ifelse live-weight >= 0 ; Este código lo he puesto para evitar valores de peso negativos que darían error a la hora de calcular el metabolic body size.
;         [set metabolic-body-size live-weight ^ (3 / 4)]
;         [set live-weight 0]


  ; Tercero, se calcula la cantidad de materia seca (Dry Matter = DM) que van a consumir las vacas. Este valor se tendrá en cuenta en el próximo procedure para que los patches puedan actualizar la altura de la hierba.
  ; A continuación se encuentra la fórmula del DDMC (Daily Dry Matter Consumption. Defines grass consumption) LA REDACCIÓN DE LA FÓRMULA SI COINCIDE CON LA FÓRMULA DEL PAPER
    ifelse born-calf? = true  ; SI el agente (la vaca) se encuentra en el age class "born-calf", entonces DDMC = 0
       [set DDMC 0] ; ; recordemos que los born-calf no dependen de las grassland: son lactantes, así que no se alimentan de hierba
       [ifelse grass-height >= 2  ;...PERO si el agente (la vaca) NO es un "born-calf" Y si GH es >= 2 (if this is TRUE), DDMC = fórmula que se escribe a continuación...
          [set DDMC ((0.107 * metabolic-body-size * (- 0.0132 *  grass-height + 1.1513) + (0.141 * metabolic-body-size * live-weight-gain) ) / grass-energy) * category-coef]
          [set DDMC 0]] ;... PERO si el grass-height < 2 (if >=2 is FALSE), establece DDMC = 0 (para evitar DDMC con valores negativos)
  ]

   ; Cuarto, una vez calculado el requerimiento diario de DM de las vacas (es decir, el DDMC), nos aseguramos de dos cosas: primero, que las vacas no puedan comer más DM del que hay disponible en un parche y, segundo, que estando en un parche en el que hay más de 2 cm de pasto, las vacas en un solo tick puedan bajar la altura del pasto a menos de 2 cm.
   ; Para conseguir lo segundo, primero es necesario calcular de antemano el grass-height final que tendrá el pasto una vez calculado el DDMC de los animales (básicamente es ejecutar el procedimiento "to update-grass-height" pero sin cambiar la altura final del pasto).

ask patches [
  set GH-consumed 0

  ask cows-here [
    let totDDMC sum [DDMC] of cows-here
    set GH-consumed totDDMC / DM-cm-ha ]

  set gh-final (grass-height - GH-consumed) ; Hacemos el cálculo de la altura que tendrá el pasto al final de este tick (i.e., "gh-final") teniendo en cuenta el DDMC de las vacas (recordemos que es la misma operación que ocurre en "to update-grass-height", pero sin llegar a actualizar la altura del pasto)

 ask cows-here [ ; Entonces, una vez calculado el "gh-"final", le pedimos a las vacas que se encuentran sobre el parche que...
   ifelse gh-final >= 2 ; ... si esta altura final es igual o mayor a 2 cm...
    [if sum [DDMC] of cows-here >= (grass-height * DM-cm-ha) [set DDMC ((grass-height * DM-cm-ha) / count cows-here)]] ;... (es decir, si gh-final >= 2 es TRUE) Y si la suma del DDMC que van a consumir las vacas que se encuentran en un determinado parche es mayor o igual al DM disponible en el parche, Le pedimos a las vacas de ese parche que dividan el DM disponible de ese parche entre el nº de vacas que hay en el parche, y que esta cantidad sea la DDMC de cada vaca.
    [set DDMC (((grass-height - 2) * DM-cm-ha) / count cows-here)] ;... PERO si el gh-final < 2 (es decir, si >= 2 is FALSE), le pedimos que las vacas calculen su DM requerida respetando los 2 cm mínimos que debe tener el pasto (recordemos la asunción de que las vacas no pueden comer pasto con altura inferior a 2 cm), y que esta DM requerida lo deividan entre el número de vacas que hay en ese parche. Esta es una forma de hacer que las vacas no puedan comer pasto por debajo de los 2 cm de altura.

    if DDMC < 0 [set DDMC 0] ; para evitar DDMC con valores negativos

    ]
  ]

;ask patch 0 0 [print (word ">>> gh-final "  [gh-final] of patch 0 0)]

end
to report-DDMC-patch00 ;;;;TEMP

  ask patch 0 0 [set DDMC-patch00 sum [DDMC] of cows-here]

end










to update-grass-height
ask patches [
  set GH-consumed 0 ; el GH-consumed se actualiza en cada tick partiendo de 0.
  ask cows-here [ ; recordemos que turtles-here o <breeds>-here (i.e., cows-here) es un reporter: reports an agentset containing all the turtles on the caller's patch (including the caller itself if it's a turtle). If the name of a breed is substituted for "turtles", then only turtles of that breed are included.
                  ; este procedimiento es para actualizar la altura de la hierba en cada parche, por eso usamos "cows-here" (siendo "here" en el parche en el que se encuentran los cows)
    let totDDMC sum [DDMC] of cows-here ; creamos variable local, llamada totDDMC: Using a local variable “totDDMC” we calculate the total (total = la suma ("sum") de toda la DM consumida ("DDMC") por todas las vacas que se encuentran en ese parche) daily dry matter consumption (DDMC) in each patch.
    set GH-consumed totDDMC / DM-cm-ha ] ; Actualizamos el GH-consumed: with the parameter “DM-cm-ha”, which defines that each centimeter per hectare contains 180 Kg of dry matter, we calculate the grass height consumed in each patch. Therefore, we update the grass height subtracting the grass height consumed from the current grass height.
                                        ; Una vez actualizado el GH-consumed de ese tick con la cantidad de DM que han consumido las vacas...
  set grass-height grass-height - GH-consumed ;... lo utilizamos para actualizar la grass-height de ese tick


  ;if grass-height <= 0 [set grass-height 0.001] ; to avoid negative values.


  ifelse grass-height < 2 [
     set pcolor 37][
     set pcolor scale-color green grass-height 23 0]
    if grass-height < 0 [set pcolor red]
  ]

;ask patch 0 0[print (word ">>> UPDATED grass-height "  [grass-height] of patch 0 0)] ;;;;TEMP

end










to update-live-weight4;
ask cows [
  ; A continuación se encuentra la fórmula del LWG (Defines the increment of weight) LA REDACCIÓN DE LA FÓRMULA SI COINCIDE CON LA FÓRMULA DEL PAPER
  ; Primero se le dice a las vacas de todo tipo que ganen peso (LWG) en función de si es lactante (born-calf) o de si no lo es (resto de age clases, en este caso se les pide que se alimenten de la hierba siempre y cuando la altura sea mayor o igual a 2 cm):
   ifelse born-calf? = true  ; SI el agente (la vaca) se encuentra en el age class "born-calf", entonces...
      [set live-weight-gain weight-gain-lactation]; ...entonces LWG = weight-gain-lactation. Recordemos que los born-calf no dependen de las grassland: son lactantes, así que le asumimos un weight-gain-lactation de 0.61 kg/day
      [ifelse grass-height >= 2 ;...PERO si el agente (la vaca) NO es un "born-calf" Y SI el grass-height en un patch es >= 2 (if this is TRUE), there are grass to eat and cows will gain weight using the LWG equation (i.e., LWG = fórmula que se escribe a continuación)...
         [set live-weight-gain ( item current-season maxLWG - ( xi * e ^ ( - ni * grass-height ) ) ) / ( 92 * item current-season season-coef )] ;
         [set live-weight-gain live-weight * -0.005]] ;... PERO If the grass-height in a patch is < 2 cm (if >=2 is FALSE), the cows lose 0.5% of their live weight (LW) daily (i.e., 0.005)

  ; Segundo, se les pide que actualicen su "live-weight" en función de lo que han comido
set live-weight live-weight + live-weight-gain
  ]
end











to grow-livestock
ask cows [
  set age age + days-per-tick
; Primero: se codifican las reglas por las que los animales mueren.
; Es interesante mencionar que, por ahora (en el open access (antes llamado "wild model"), los animales tienen dos formas de morir: por edad (age) o por mortality rate (que puede ser natural o expecional)
  if age > cow-age-max [die] ; Si la edad (age) del agente es mayor que la edad máxima establecida (cow-age-max), el agente muere
  ifelse live-weight < min-weight ; Pero si la edad se encuentra por debajo del cow-age-max Y SI el peso vivo del animal se encuentra por debajo del peso mínimo (min-weight)...
     [set mortality-rate except-mort-rate] ; ...si esto es TRUE, el animal tendrá una mortality rate = except-mort-rate (mortality rate excepcional, recordemos que exceptional mortality rates increases to 15% (= 0.00041 a day) in cows, 30% (= 0.000815) in pregnant cows, and 23% (0.000625) in the rest of categories.)
     [set mortality-rate natural-mortality-rate] ;...si esto es FALSE, el animal tendrá una mortality rate = natural-mortality rate (annual natural mortality = 2% (in a day = 0.000054))
  if random-float 1 < mortality-rate [die] ; Como el mortality rate es una probabilidad, el animal morirá cuando el mortality rate sea mayor que un número generado al azar entre 0 y 0.999

; Segundo: después, se codifican las reglas de como evoluciona una vaca siguiendo su ciclo de vida (la regla para las etapas "born-calf", "cow-with-calf" y "pregnant" se desarrollan en el procedure "reproduce")
  if age = weaned-calf-age-min [become-weaned-calf] ; aquí se describe la regla para weaned-calf: si el age = weaned-calf-age-min, el animal pasa a la age class "weaned-calf"
  if age = heifer-age-min [ ; si el age = heifer-age-min...
    ifelse random-float 1 < 0.5 ; ...hay un 50% de probabilidades de que el animal se convierta en el age class "heifer" o "steer".
      [become-heifer] ; la regla para heifer: Si un número generado al azar entre 0 y 0.99 (random-float 1) es menor que 0.5, el animal se convertira en "heifer"
      [become-steer]] ; la regla para steer: Si el número es mayor que 0.5, se convertirá en "steer"
  if (heifer? = true) and (age = cow-age-min) and (live-weight >= 280) [become-cow] ; la regla para cow: si el agente es un "heifer" (si esto es TRUE) Y el age = cow-age-min Y live-weight >= 280, el animal pasa al age class de "cow"

  if cow-with-calf? = true [set lactating-time lactating-time + days-per-tick] ; si el agente es un "cow-with-calf" (si esto es TRUE), se establece (set) que el lactating-time = lactating-time + days-per-tick
  if lactating-time = lactation-period [become-cow] ; la regla para cow: cuando el lactating-time = lactation-period, el agente del age class "cow-with-calf" se convierte en el age class "cow"
  ]
end










to reproduce ; A continuación aquí se encuentran la fórmula del Pregnancy rate y las reglas para convertirse en age class "Pregnant".  LA REDACCIÓN DE LA FÓRMULA SI COINCIDE CON LA FÓRMULA DEL PAPER PERO...
  ask cows [
  if (heifer? = true) or (cow? = true) or (cow-with-calf? = true) [set pregnancy-rate (1 / (1 + coefA * e ^ (- coefB * live-weight))) / 368] ; ...¿¿¿¿¿¿¿¿DUDA????? LO DIVIDE ENTRE 368, POR QUÉ?
                                                                                                                                             ; POSIBLE RESPUESTA: 368 parece que hace alusión a un año (aunque un año real tiene 365 días, en esta simulacion 1 año son 368 días, ya que 1 año = 4 estaciones, y 1 estacion = 92 días. Por tanto, 92 días * 4 estaciones = 368 días), ya que se dice que la simulación dura 10 años, y en el código original de Alicia pone que 10 años = 3680 days...
                                                                                                                                             ; ...así que en definitiva, al divir la fórmula entre los días que tiene un año, se calcula el pregnancy rate diario, es decir, la probabilidad de que una vaca del age class "heifer", "cow" o "cow-with-calf" se quede preñada en un día.
  if random-float 1 < pregnancy-rate [set pregnant? true] ; Por lo tanto, si esta probabilidad diaria es mayor que un número generado al azar entre 0 y 0.99, el agente se convertirá en un agente del age class "pregnant" (i.e., el agente quedará preñado)
  if pregnant? = true [ ; Si el agente pertenece al age-class "pregnant" (si esto es TRUE)...
    set pregnancy-time pregnancy-time + days-per-tick ; ...establecemos que el tiempo de embarazo = tiempo de embarazo + days-per-tick
    set except-mort-rate 0.3] ; y establecemos que la except-mort-rate para los animales del age class "pregnant" sea 0.3.  Recordemos que la except-mort-rate para las pregnants cows es de 0.3: 30% (= 0.000815) in pregnant cows
  if pregnancy-time = gestation-period [ hatch-cows 1 [ ; Cuando la pregnancy-time = gestation-period, nace un nuevo agente del breed "cows".
                                                        ; This turtle creates X number of new turtles. Each new turtle inherits of all its variables, including its location, from its parent. (Exceptions: each new turtle will have a new who number, and it may be of a different breed than its parent if the hatch-<breeds> form is used.). The new turtles then run commands (usando los corchetes "[ ]" después de haber escrito el comando "hatch-turtles X [ ]" ). You can use the commands to give the new turtles different colors, headings, locations, or whatever. (The new turtles are created all at once, then run one at a time, in random order.)
                                                        ; If the hatch-<breeds> form is used, the new turtles are created as members of the given breed. Otherwise, the new turtles are the same breed as their parent.
    setxy random-pxcor random-pycor
    become-born-calf] ; la regla para born-calf: se le pide al nuevo agente que ha nacido que se convierta en un age class del tipo "born-calf"
    set pregnant? false ; se le dice al agente que formaba parte del age class "pregnant" que deje de serlo
    set pregnancy-time 0 ; y que reinicie el tiempo de embarazo a 0.
    become-cow-with-calf] ; la regla para cow-with-calf: este agente que acaba de dar la luz a un nuevo agente, se le pide que, además, se convierta en un agente del age class del tipo "cow-with-calf"
  ]
end










to move ; Esto ha sido "inventado" por Alicia. El modelo original no es espacialmente explícito, pero Alicia ha querido representar a las vacas moviéndose por la parcela, así que para que se muevan, ha añadido este procedure y lo ha asociado al parámetro "perception"
ask cows [
  if grass-height < 5
    [ifelse random-float 1 < perception ; perception es un slider con valores entre 0 y 1
       [uphill grass-height] ; Moves the turtle to the neighboring patch with the highest value for patch-variable (en este caso, se llama a la patch-variable grass-height). If no neighboring patch has a higher value than the current patch, the turtle stays put. If there are multiple patches with the same highest value, the turtle picks one randomly. Non-numeric values are ignored. uphill considers the eight neighboring patches; uphill4 only considers the four neighbors.
       [move-to one-of neighbors]]
  ]
end










to sell-males ; DECISIONAL (I.E., MANAGEMENT) MODEL. POR HACER

end

to extraordinary-sales ; DECISIONAL (I.E., MANAGEMENT) MODEL. POR HACER

end

to sacrifice-animals ; DECISIONAL (I.E., MANAGEMENT) MODEL. POR HACER
end

; A continuación, se ponen los parámetros para cada una de las etapas del ciclo de vida de las vacas

to become-born-calf
  set born-calf? true
  set weaned-calf? false
  set heifer? false
  set steer? false
  set cow? false
  set cow-with-calf? false
  set pregnant? false
  set size 0.4
  set color sky
  set age 0
  set initial-weight 40
  set live-weight initial-weight
  set animal-units 0.2
  set min-weight 0
  set natural-mortality-rate 0.000054
  set except-mort-rate 0
  set category-coef 1
  set pregnancy-rate 0
  set coefA 0
  set coefB 0
  set pregnancy-time 0
  set lactating-time 0
end

to become-weaned-calf
  set born-calf? false
  set weaned-calf? true
  set heifer? false
  set steer? false
  set cow? false
  set cow-with-calf? false
  set size 0.6
  set color orange
  set animal-units 0.5
  set min-weight 60
  set natural-mortality-rate 0.000054
  set except-mort-rate 0.23
  set category-coef 1
  set pregnancy-rate 0
  set coefA 0
  set coefB 0
  set pregnancy-time 0
  set lactating-time 0
end

to become-heifer
  set born-calf? false
  set weaned-calf? false
  set heifer? true
  set steer? false
  set cow? false
  set size 0.8
  set color pink
  set animal-units 0.7 ; Haciendo cálculos de la SR de la Figura 4 de Dieguez-Cameroni et al. 2012, me sale que 1 heifer = 0.783 cows (calculos hechos: 0.47 LU/ha* 50 ha = 23.5 LU; 23.5 LU / 30 LU = 0.783 cows)
  set min-weight 100
  set natural-mortality-rate 0.000054
  set except-mort-rate 0.23
  set category-coef 1
  set pregnancy-rate 0
  set coefA 4000
  set coefB 0.029
  set pregnancy-time 0
  set lactating-time 0
end

to become-steer
  set born-calf? false
  set weaned-calf? false
  set heifer? false
  set steer? true
  set cow? false
  set cow-with-calf? false
  set size 0.9
  set color red
  set animal-units 0.7
  set min-weight 100
  set natural-mortality-rate 0.000054
  set except-mort-rate 0.23
  set category-coef 1
  set pregnancy-rate 0
  set coefA 0
  set coefB 0
  set pregnancy-time 0
  set lactating-time 0

end

to become-cow
  set born-calf? false
  set weaned-calf? false
  set heifer? false
  set steer? false
  set cow? true
  set cow-with-calf? false
  set size 1
  set color brown
  set animal-units 1
  set min-weight 180
  set natural-mortality-rate 0.000054
  set except-mort-rate 0.15
  set category-coef 1
  set pregnancy-rate 0
  set coefA 20000
  set coefB 0.0285
  set pregnancy-time 0
  set lactating-time 0
end

to become-cow-with-calf
  set born-calf? false
  set weaned-calf? false
  set heifer? false
  set steer? false
  set cow? false
  set cow-with-calf? true
  set size 1.1
  set color magenta
  set animal-units 1
  set min-weight 180
  set natural-mortality-rate 0.000054
  set except-mort-rate 0.3
  set category-coef 1.1
  set pregnancy-rate 0
  set coefA 12000
  set coefB 0.0265
  set pregnancy-time 0
  set lactating-time 0
end

 to-report stocking-rate ; Reporter to output the relation between the stock of livestock (in terms of animal units) and the grassland area (num of patches, 1 patch = 1 ha).
  report sum [animal-units] of cows / count patches
end

to-report grass-height-report ; To report the mean grass-height of the herbage
  report mean [grass-height] of patches
end

 ;;; AÑADIDO POR DIEGO: el código que está escrito a partir de esta línea (hasta el ;;;) son incorporaciones nuevas hechas por Diego

to-report season-report ; To show the name of the season
    report  item current-season current-season-name
end

 to-report dmgr ; Reporter to output the Dry Matter Growth Rate (DMGR, units: kgDM/ha/day)
  report DM-cm-ha * sum [grass-height] of patches
end

 to-report dm-cows ; Reporter to output the accumulation of DM AVAILABLE for the cows
  report DM-cm-ha * mean [grass-height] of patches * 0.4 ; Se considera un factor de uso o tasa de desaparición del forraje/pastura (TDF)  por parte del animal del 40%
                                                         ; (es decir, que si la acumulación de materia seca (DM) en invierno (por poner un ejemplo) en un prado en el que no hay vacas pastando es de 1331,54 kg DM/ha, las vacas solo podrán aprovechar algo menos de la mitad, es decir, 532,62 kg DM/ha. Es decir, del 100% de MS disponible en el pasto, asumimos que el 60% restante es consumido por otros animales en pastoreo, por otros herbívoros y las pérdidas de forraje por senescencia, pisoteo y descomposición)
end

; to-report grassland-area ;
;  report sum [animal-units] of cows / stocking-rate
;end

to-report crop-efficiency ; Reporter to output the crop eficiency (DM consumed / DM offered)
 let totDDMC sum [DDMC] of cows ; totDDMC = DM consumed
 report (totDDMC / (DM-cm-ha * sum [grass-height] of patches)) * 100 ; (DM-cm-ha * sum [grass-height] of patches) = DM offered

 ;; OTRA ALTERNATIVA PARA CALCULAR EL CROP-EFFICIENCY;;
  ;let totDDMC DM-cm-ha * sum [GH-consumed] of patches ; El "DM consumed" se puede calcular de otra manera: sumamos los cm de hierba que han perdido los patches como consecuencia de la alimentación de los animales. Como GH-consumed está en cm, lo multiplicamos por el DM-cm-ha para obtener la DM consumed (que se expresa en Kg/ha)
  ;report totDDMC / (DM-cm-ha * sum [grass-height] of patches)
 end


to-report bcs ; Reporter to output the Body Condition Score: The body condition score is calculated as a linear regression of LW, where the survival LW of the LU is 220 Kg, and each point of BCS represents 40 Kg of LW. Thus, BCS = (live weight – 220) / 40
  ;report (mean [live-weight] of cows - 220) / 40
  ;report (mean [live-weight] of cows - mean [min-weight] of cows) / 40
  report (mean [live-weight] of cows with [cow?] - mean [min-weight] of cows with [cow?]) / 40
end

;OTRA INFO DE INTERES
; Para exportar los resultados de un plot, escribir en el "Command center" de la pestaña "Interfaz" lo siguiente:
; export-plot plotname filename ; por ejemplo 1: export-plot "Dinamica del pasto" "dm_winter.csv"
;                                     ejemplo 2: export-plot "Average of grass height" "gh_winter.csv"
;                                     ejemplo 3: export-plot "Average of live-weight" "047_1_lw_winter.csv"



;;;

;REFERENCES
;Dieguez-Cameroni, F.J., et al. 2014. Virtual experiments using a participatory model to explore interactions between climatic variability
;and management decisions in extensive systems in the basaltic region of Uruguay. Agricultural Systems 130: 89–104.
;Dieguez-Cameroni, F., Bommel, P., Corral, J., Bartaburu, D., Pereira, M., Montes, E., Duarte, E., Morales-Grosskopf, H. 2012. Modelización
;de una explotación ganadera extensiva criadora en basalto. Agrociencia Uruguay 16(2): 120-130.
;Robins, R., Bogen, S., Francis, A., Westhoek, A., Kanarek, A., Lenhart, S., Eda, S. 2015. Agent-based model for Johne’s disease dynamics
;in a dairy herd. Veterinary Research 46: 68.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; OLD PROCEDURES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to eat-grass
ask cows [
  ; A continuación se encuentra la fórmula del LWG (Defines the increment of weight) LA REDACCIÓN DE LA FÓRMULA SI COINCIDE CON LA FÓRMULA DEL PAPER
  ; Primero se le dice a las vacas de todo tipo que ganen peso (LWG) en función de si es lactante (born-calf) o de si no lo es (resto de age clases, en este caso se les pide que se alimenten de la hierba siempre y cuando la altura sea mayor o igual a 2 cm):
   ifelse born-calf? = true  ; SI el agente (la vaca) se encuentra en el age class "born-calf", entonces...
      [set live-weight-gain weight-gain-lactation] ; ...entonces LWG = weight-gain-lactation. Recordemos que los born-calf no dependen de las grassland: son lactantes, así que le asumimos un weight-gain-lactation de 0.61 kg/day
      [ifelse grass-height >= 2 ;...PERO si el agente (la vaca) NO es un "born-calf" Y SI el grass-height en un patch es >= 2 (if this is TRUE), there are grass to eat and cows will gain weight using the LWG equation (i.e., LWG = fórmula que se escribe a continuación)...
         [set live-weight-gain ( item current-season maxLWG - ( xi * e ^ ( - ni * grass-height ) ) ) / ( 92 * item current-season season-coef )] ;
         [set live-weight-gain live-weight * -0.005]] ;... PERO If the grass-height in a patch is < 2 cm (if >=2 is FALSE), the cows lose 0.5% of their live weight (LW) daily (i.e., 0.005)

  ; Segundo, se les pide que actualicen su "live-weight" en función de lo que han comido
set live-weight live-weight + live-weight-gain
set metabolic-body-size live-weight ^ (3 / 4)
   ;print (word ">>> UPDATED live-weight-gain      " live-weight-gain)

  ; Tercero, se calcula la cantidad de materia seca (Dry Matter = DM) que van a consumir las vacas. Este valor se tendrá en cuenta en el próximo procedure para que los patches puedan actualizar la altura de la hierba.
; A continuación se encuentra la fórmula del DDMC (Daily Dry Matter Consumption. Defines grass consumption) LA REDACCIÓN DE LA FÓRMULA SI COINCIDE CON LA FÓRMULA DEL PAPER
    ifelse born-calf? = true  ; SI el agente (la vaca) se encuentra en el age class "born-calf", entonces DDMC = 0
       [set DDMC 0] ; ; recordemos que los born-calf no dependen de las grassland: son lactantes, así que no se alimentan de hierba
       [ifelse live-weight-gain > 0  ;...PERO si el agente (la vaca) NO es un "born-calf" Y si el LWG de la vaca es > 0 (if this is TRUE), DDMC = fórmula que se escribe a continuación...
         [set DDMC ((0.107 * metabolic-body-size * (- 0.0132 *  grass-height + 1.1513) + (0.141 * metabolic-body-size * live-weight-gain) ) / grass-energy) * category-coef]
         [set DDMC 0]] ;... PERO si live-weight-gain es < 0 (if > 0 is FALSE), establece DDMC = 0 (para evitar DDMC con valores negativos)

     ;print (word ">>> UPDATED DDMC                  " DDMC)
  ]
end



to eat-grassNEW
ask cows [
set metabolic-body-size live-weight ^ (3 / 4)
   ;print (word ">>> UPDATED live-weight-gain      " live-weight-gain)

  ; Tercero, se calcula la cantidad de materia seca (Dry Matter = DM) que van a consumir las vacas. Este valor se tendrá en cuenta en el próximo procedure para que los patches puedan actualizar la altura de la hierba.
; A continuación se encuentra la fórmula del DDMC (Daily Dry Matter Consumption. Defines grass consumption) LA REDACCIÓN DE LA FÓRMULA SI COINCIDE CON LA FÓRMULA DEL PAPER
    ifelse born-calf? = true  ; SI el agente (la vaca) se encuentra en el age class "born-calf", entonces DDMC = 0
       [set DDMC 0] ; ; recordemos que los born-calf no dependen de las grassland: son lactantes, así que no se alimentan de hierba
       [ifelse live-weight-gain > 0  ;...PERO si el agente (la vaca) NO es un "born-calf" Y si el LWG de la vaca es > 0 (if this is TRUE), DDMC = fórmula que se escribe a continuación...
         [set DDMC ((0.107 * metabolic-body-size * (- 0.0132 *  grass-height + 1.1513) + (0.141 * metabolic-body-size * live-weight-gain) ) / grass-energy) * category-coef]
         [set DDMC 0]] ;... PERO si live-weight-gain es < 0 (if > 0 is FALSE), establece DDMC = 0 (para evitar DDMC con valores negativos)

     ;print (word ">>> UPDATED DDMC                  " DDMC)
  ]
end


to update-live-weight
ask cows [
  ; A continuación se encuentra la fórmula del LWG (Defines the increment of weight) LA REDACCIÓN DE LA FÓRMULA SI COINCIDE CON LA FÓRMULA DEL PAPER
  ; Primero se le dice a las vacas de todo tipo que ganen peso (LWG) en función de si es lactante (born-calf) o de si no lo es (resto de age clases, en este caso se les pide que se alimenten de la hierba siempre y cuando la altura sea mayor o igual a 2 cm):
   ifelse born-calf? = true  ; SI el agente (la vaca) se encuentra en el age class "born-calf", entonces...
      [set live-weight-gain weight-gain-lactation] ; ...entonces LWG = weight-gain-lactation. Recordemos que los born-calf no dependen de las grassland: son lactantes, así que le asumimos un weight-gain-lactation de 0.61 kg/day
      [ifelse grass-height >= 2 ;...PERO si el agente (la vaca) NO es un "born-calf" Y SI el grass-height en un patch es >= 2 (if this is TRUE), there are grass to eat and cows will gain weight using the LWG equation (i.e., LWG = fórmula que se escribe a continuación)...
         [set live-weight-gain ( item current-season maxLWG - ( xi * e ^ ( - ni * grass-height ) ) ) / ( 92 * item current-season season-coef )] ;
         [set live-weight-gain live-weight * -0.005]] ;... PERO If the grass-height in a patch is < 2 cm (if >=2 is FALSE), the cows lose 0.5% of their live weight (LW) daily (i.e., 0.005)

  ; Segundo, se les pide que actualicen su "live-weight" en función de lo que han comido
set live-weight live-weight + live-weight-gain
  ]
end





to eat-grass2 ;en el DDMC, se ha cambiado el "ifelse live-weight-gain > 0" por "ifelse grass-height >= 2"
ask cows [
  ; A continuación se encuentra la fórmula del LWG (Defines the increment of weight) LA REDACCIÓN DE LA FÓRMULA SI COINCIDE CON LA FÓRMULA DEL PAPER
  ; Primero se le dice a las vacas de todo tipo que ganen peso (LWG) en función de si es lactante (born-calf) o de si no lo es (resto de age clases, en este caso se les pide que se alimenten de la hierba siempre y cuando la altura sea mayor o igual a 2 cm):
   ifelse born-calf? = true  ; SI el agente (la vaca) se encuentra en el age class "born-calf", entonces...
      [set live-weight-gain weight-gain-lactation]; ...entonces LWG = weight-gain-lactation. Recordemos que los born-calf no dependen de las grassland: son lactantes, así que le asumimos un weight-gain-lactation de 0.61 kg/day
      [ifelse grass-height >= 2 ;...PERO si el agente (la vaca) NO es un "born-calf" Y SI el grass-height en un patch es >= 2 (if this is TRUE), there are grass to eat and cows will gain weight using the LWG equation (i.e., LWG = fórmula que se escribe a continuación)...
         [set live-weight-gain ( item current-season maxLWG - ( xi * e ^ ( - ni * grass-height ) ) ) / ( 92 * item current-season season-coef )] ;
         [set live-weight-gain live-weight * -0.005]] ;... PERO If the grass-height in a patch is < 2 cm (if >=2 is FALSE), the cows lose 0.5% of their live weight (LW) daily (i.e., 0.005)

  ; Segundo, se les pide que actualicen su "live-weight" en función de lo que han comido
set live-weight live-weight + live-weight-gain

set metabolic-body-size live-weight ^ (3 / 4)
; Otra alternativa para el metabolic-body-size (elegir esta alternativa si te da error por valores negativos en live-weight)
;ifelse live-weight >= 0 ; Este código lo he puesto para evitar valores de peso negativos que darían error a la hora de calcular el metabolic body size.
;         [set metabolic-body-size live-weight ^ (3 / 4)]
;         [set live-weight 0]


  ; Tercero, se calcula la cantidad de materia seca (Dry Matter = DM) que van a consumir las vacas. Este valor se tendrá en cuenta en el próximo procedure para que los patches puedan actualizar la altura de la hierba.
  ; A continuación se encuentra la fórmula del DDMC (Daily Dry Matter Consumption. Defines grass consumption) LA REDACCIÓN DE LA FÓRMULA SI COINCIDE CON LA FÓRMULA DEL PAPER
    ifelse born-calf? = true  ; SI el agente (la vaca) se encuentra en el age class "born-calf", entonces DDMC = 0
       [set DDMC 0] ; ; recordemos que los born-calf no dependen de las grassland: son lactantes, así que no se alimentan de hierba
       [ifelse grass-height >= 2  ;...PERO si el agente (la vaca) NO es un "born-calf" Y si GH es >= 2 (if this is TRUE), DDMC = fórmula que se escribe a continuación...
          [set DDMC ((0.107 * metabolic-body-size * (- 0.0132 *  grass-height + 1.1513) + (0.141 * metabolic-body-size * live-weight-gain) ) / grass-energy) * category-coef]
          [set DDMC 0]] ;... PERO si el grass-height < 2 (if >=2 is FALSE), establece DDMC = 0 (para evitar DDMC con valores negativos)

  ]
end

to eat-grass3; cuando la suma total de DDMC <= grass-height * DM-cm-ha de un parche, se reparte el DDMC entre el numero de vacas de ese parche
ask cows [
  ; A continuación se encuentra la fórmula del LWG (Defines the increment of weight) LA REDACCIÓN DE LA FÓRMULA SI COINCIDE CON LA FÓRMULA DEL PAPER
  ; Primero se le dice a las vacas de todo tipo que ganen peso (LWG) en función de si es lactante (born-calf) o de si no lo es (resto de age clases, en este caso se les pide que se alimenten de la hierba siempre y cuando la altura sea mayor o igual a 2 cm):
   ifelse born-calf? = true  ; SI el agente (la vaca) se encuentra en el age class "born-calf", entonces...
      [set live-weight-gain weight-gain-lactation]; ...entonces LWG = weight-gain-lactation. Recordemos que los born-calf no dependen de las grassland: son lactantes, así que le asumimos un weight-gain-lactation de 0.61 kg/day
      [ifelse grass-height >= 2 ;...PERO si el agente (la vaca) NO es un "born-calf" Y SI el grass-height en un patch es >= 2 (if this is TRUE), there are grass to eat and cows will gain weight using the LWG equation (i.e., LWG = fórmula que se escribe a continuación)...
         [set live-weight-gain ( item current-season maxLWG - ( xi * e ^ ( - ni * grass-height ) ) ) / ( 92 * item current-season season-coef )] ;
         [set live-weight-gain live-weight * -0.005]] ;... PERO If the grass-height in a patch is < 2 cm (if >=2 is FALSE), the cows lose 0.5% of their live weight (LW) daily (i.e., 0.005)

  ; Segundo, se les pide que actualicen su "live-weight" en función de lo que han comido
set live-weight live-weight + live-weight-gain

set metabolic-body-size live-weight ^ (3 / 4)
; Otra alternativa para el metabolic-body-size (elegir esta alternativa si te da error por valores negativos en live-weight)
;ifelse live-weight >= 0 ; Este código lo he puesto para evitar valores de peso negativos que darían error a la hora de calcular el metabolic body size.
;         [set metabolic-body-size live-weight ^ (3 / 4)]
;         [set live-weight 0]


  ; Tercero, se calcula la cantidad de materia seca (Dry Matter = DM) que van a consumir las vacas. Este valor se tendrá en cuenta en el próximo procedure para que los patches puedan actualizar la altura de la hierba.
  ; A continuación se encuentra la fórmula del DDMC (Daily Dry Matter Consumption. Defines grass consumption) LA REDACCIÓN DE LA FÓRMULA SI COINCIDE CON LA FÓRMULA DEL PAPER
    ifelse born-calf? = true  ; SI el agente (la vaca) se encuentra en el age class "born-calf", entonces DDMC = 0
       [set DDMC 0] ; ; recordemos que los born-calf no dependen de las grassland: son lactantes, así que no se alimentan de hierba
       [ifelse grass-height >= 2  ;...PERO si el agente (la vaca) NO es un "born-calf" Y si GH es >= 2 (if this is TRUE), DDMC = fórmula que se escribe a continuación...
          [set DDMC ((0.107 * metabolic-body-size * (- 0.0132 *  grass-height + 1.1513) + (0.141 * metabolic-body-size * live-weight-gain) ) / grass-energy) * category-coef]
          [set DDMC 0]] ;... PERO si el grass-height < 2 (if >=2 is FALSE), establece DDMC = 0 (para evitar DDMC con valores negativos)
  ]
 ; Con el siguiente código de "ask patches" establecemos que las vacas no puedan comer más pasto del que hay en un parche. Esto se lee de la siguiente manera:
        ask patches [ ; "Pidele a los parches que...
         ask cows-here [ ; "... le pidan a las vacas que SE ENCUENTRAN SOBRE ELLOS (LOS PARCHES) que...
          if sum [DDMC] of cows-here >= (grass-height * DM-cm-ha) [set DDMC ((grass-height * DM-cm-ha) / count cows-here)]] ; "... si la suma del DDMC que van a consumir las vacas que se encuentran en un determinado parche es mayor o igual al DM disponible en el parche, que dividan el DM disponible de ese parche entre el nº de vacas que hay en el parche, y que esta cantidad sea la DDMC de cada vaca.
  ]

end

to eat-grass4;
ask cows [
  ; A continuación se encuentra la fórmula del LWG (Defines the increment of weight) LA REDACCIÓN DE LA FÓRMULA SI COINCIDE CON LA FÓRMULA DEL PAPER
  ; Primero se le dice a las vacas de todo tipo que ganen peso (LWG) en función de si es lactante (born-calf) o de si no lo es (resto de age clases, en este caso se les pide que se alimenten de la hierba siempre y cuando la altura sea mayor o igual a 2 cm):
   ifelse born-calf? = true  ; SI el agente (la vaca) se encuentra en el age class "born-calf", entonces...
      [set live-weight-gain weight-gain-lactation]; ...entonces LWG = weight-gain-lactation. Recordemos que los born-calf no dependen de las grassland: son lactantes, así que le asumimos un weight-gain-lactation de 0.61 kg/day
      [ifelse grass-height >= 2 ;...PERO si el agente (la vaca) NO es un "born-calf" Y SI el grass-height en un patch es >= 2 (if this is TRUE), there are grass to eat and cows will gain weight using the LWG equation (i.e., LWG = fórmula que se escribe a continuación)...
         [set live-weight-gain ( item current-season maxLWG - ( xi * e ^ ( - ni * grass-height ) ) ) / ( 92 * item current-season season-coef )] ;
         [set live-weight-gain live-weight * -0.005]] ;... PERO If the grass-height in a patch is < 2 cm (if >=2 is FALSE), the cows lose 0.5% of their live weight (LW) daily (i.e., 0.005)

  ; Segundo, se les pide que actualicen su "live-weight" en función de lo que han comido
set live-weight live-weight + live-weight-gain

set metabolic-body-size live-weight ^ (3 / 4)
; Otra alternativa para el metabolic-body-size (elegir esta alternativa si te da error por valores negativos en live-weight)
;ifelse live-weight >= 0 ; Este código lo he puesto para evitar valores de peso negativos que darían error a la hora de calcular el metabolic body size.
;         [set metabolic-body-size live-weight ^ (3 / 4)]
;         [set live-weight 0]


  ; Tercero, se calcula la cantidad de materia seca (Dry Matter = DM) que van a consumir las vacas. Este valor se tendrá en cuenta en el próximo procedure para que los patches puedan actualizar la altura de la hierba.
  ; A continuación se encuentra la fórmula del DDMC (Daily Dry Matter Consumption. Defines grass consumption) LA REDACCIÓN DE LA FÓRMULA SI COINCIDE CON LA FÓRMULA DEL PAPER
    ifelse born-calf? = true  ; SI el agente (la vaca) se encuentra en el age class "born-calf", entonces DDMC = 0
       [set DDMC 0] ; ; recordemos que los born-calf no dependen de las grassland: son lactantes, así que no se alimentan de hierba
       [ifelse grass-height >= 2  ;...PERO si el agente (la vaca) NO es un "born-calf" Y si GH es >= 2 (if this is TRUE), DDMC = fórmula que se escribe a continuación...
          [set DDMC ((0.107 * metabolic-body-size * (- 0.0132 *  grass-height + 1.1513) + (0.141 * metabolic-body-size * live-weight-gain) ) / grass-energy) * category-coef]
          [set DDMC 0]] ;... PERO si el grass-height < 2 (if >=2 is FALSE), establece DDMC = 0 (para evitar DDMC con valores negativos)
  ]

   ; Cuarto, una vez calculado el requerimiento diario de DM de las vacas (es decir, el DDMC), nos aseguramos de dos cosas: primero, que las vacas no puedan comer más DM del que hay disponible en un parche y, segundo, que estando en un parche en el que hay más de 2 cm de pasto, las vacas en un solo tick puedan bajar la altura del pasto a menos de 2 cm.
   ; Para conseguir lo segundo, primero es necesario calcular de antemano el grass-height final que tendrá el pasto una vez calculado el DDMC de los animales (básicamente es ejecutar el procedimiento "to update-grass-height" pero sin cambiar la altura final del pasto).

ask patches [
  set GH-consumed 0

  ask cows-here [
    let totDDMC sum [DDMC] of cows-here
    set GH-consumed totDDMC / DM-cm-ha ]

  set gh-final (grass-height - GH-consumed) ; Hacemos el cálculo de la altura que tendrá el pasto al final de este tick (i.e., "gh-final") teniendo en cuenta el DDMC de las vacas (recordemos que es la misma operación que ocurre en "to update-grass-height", pero sin llegar a actualizar la altura del pasto)

 ask cows-here [ ; Entonces, una vez calculado el "gh-"final", le pedimos a las vacas que se encuentran sobre el parche que...
   ifelse gh-final >= 2 ; ... si esta altura final es igual o mayor a 2 cm...
    [if sum [DDMC] of cows-here >= (grass-height * DM-cm-ha) [set DDMC ((grass-height * DM-cm-ha) / count cows-here)]] ;... (es decir, si gh-final >= 2 es TRUE) Y si la suma del DDMC que van a consumir las vacas que se encuentran en un determinado parche es mayor o igual al DM disponible en el parche, Le pedimos a las vacas de ese parche que dividan el DM disponible de ese parche entre el nº de vacas que hay en el parche, y que esta cantidad sea la DDMC de cada vaca.
    [set DDMC (((grass-height - 2) * DM-cm-ha) / count cows-here)] ;... PERO si el gh-final < 2 (es decir, si >= 2 is FALSE), le pedimos que las vacas calculen su DM requerida respetando los 2 cm mínimos que debe tener el pasto (recordemos la asunción de que las vacas no pueden comer pasto con altura inferior a 2 cm), y que esta DM requerida lo deividan entre el número de vacas que hay en ese parche. Esta es una forma de hacer que las vacas no puedan comer pasto por debajo de los 2 cm de altura.

    if DDMC < 0 [set DDMC 0] ; para evitar DDMC con valores negativos

    ]
  ]

;ask patch 0 0 [print (word ">>> gh-final "  [gh-final] of patch 0 0)]

end




@#$#@#$#@
GRAPHICS-WINDOW
385
70
851
537
-1
-1
19.9130435
1
10
1
1
1
0
1
1
1
-11
11
-11
11
1
1
1
days
30.0

BUTTON
27
72
91
105
Setup
Setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
162
72
225
105
Go
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
28
226
179
259
initial-num-cows
initial-num-cows
0
700
0.0
1
1
cows
HORIZONTAL

SLIDER
282
114
380
147
initial-season
initial-season
0
3
0.0
1
1
NIL
HORIZONTAL

PLOT
853
297
1148
439
Average of grass-height (GH)
Days
cm
0.0
92.0
0.0
0.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot grass-height-report"

PLOT
853
438
1148
581
Average of live-weight (LW)
Days
kg
0.0
92.0
0.0
0.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [live-weight] of cows"

MONITOR
566
20
644
65
Time (days)
simulation-time
2
1
11

PLOT
858
592
1099
785
Total number of cattle
Days
Heads
0.0
92.0
0.0
0.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count cows"

MONITOR
571
539
651
584
Stoking rate
stocking-rate
4
1
11

PLOT
1103
591
1521
786
Age classes population sizes
Days
Heads
0.0
92.0
0.0
0.0
true
true
"" ""
PENS
"Born-calf" 1.0 0 -13791810 true "" "plot count cows with [born-calf?]"
"Weaned-calf" 1.0 0 -955883 true "" "plot count cows with [weaned-calf?]"
"Heifer" 1.0 0 -2064490 true "" "plot count cows with [heifer?]"
"Steer" 1.0 0 -2674135 true "" "plot count cows with [steer?]"
"Cow" 1.0 0 -6459832 true "" "plot count cows with [cow?]"
"Cow-with-calf" 1.0 0 -5825686 true "" "plot count cows with [cow-with-calf?]"

SLIDER
11
525
148
558
perception
perception
0
1
0.7
0.1
1
NIL
HORIZONTAL

MONITOR
724
539
853
584
Total number of cattle
count cows
7
1
11

MONITOR
1148
440
1281
485
Average LW (kg)
mean [live-weight] of cows
3
1
11

SLIDER
26
114
167
147
initial-grass-height
initial-grass-height
1
7.4
7.0
0.1
1
cm
HORIZONTAL

CHOOSER
28
20
120
65
model-version
model-version
"grass model" "open access" "management model"
1

TEXTBOX
13
602
184
658
Only if you have selected the management model, you can chose between the reactive and the proctive strategies.
11
0.0
1

CHOOSER
10
663
158
708
management-strategy
management-strategy
"reactive" "proactive"
0

PLOT
853
10
1200
154
Dry-matter (DM) and DM consumption (DDMC)
Days
kg
0.0
92.0
0.0
0.0
true
true
"" ""
PENS
"DM" 1.0 0 -16777216 true "" "plot dmgr"
"DDMC" 1.0 0 -2674135 true "" "plot sum [DDMC] of cows"

TEXTBOX
307
54
457
110
0 = winter\n1 = spring\n2 = summer\n3 = fall
11
0.0
1

MONITOR
1148
297
1253
342
Average GH (cm)
grass-height-report
3
1
11

SLIDER
171
114
278
147
set-climaCoef
set-climaCoef
0.1
1.5
1.0
0.1
1
NIL
HORIZONTAL

MONITOR
385
20
472
65
Season
season-report
17
1
11

MONITOR
479
20
561
65
Time (years)
year-cnt
2
1
11

SLIDER
27
156
178
189
initial-num-heifers
initial-num-heifers
0
1000
50.0
1
1
NIL
HORIZONTAL

SLIDER
27
190
178
223
initial-weight-heifer
initial-weight-heifer
100
340
130.0
1
1
kg
HORIZONTAL

MONITOR
655
539
721
584
Area (ha)
count patches ;grassland-area, 1 patch = 1 ha\n; Other option:\n; sum [animal-units] of cows / count patches
7
1
11

PLOT
1280
443
1576
585
Average of daily live-weight-gain (LWG)
Days
kg
0.0
92.0
0.0
0.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [live-weight] of cows - (mean [live-weight] of cows - mean [live-weight-gain] of cows)"

MONITOR
1147
483
1279
528
Average daily LWG (kg)
mean [live-weight] of cows - (mean [live-weight] of cows - mean [live-weight-gain] of cows)
3
1
11

PLOT
853
154
1151
296
Crop-efficiency (CE)
Days
%
0.0
92.0
0.0
60.0
true
false
"" ""
PENS
"CE" 1.0 0 -16777216 true "" "plot crop-efficiency"

MONITOR
1149
154
1205
199
CE (%)
crop-efficiency
0
1
11

MONITOR
1199
54
1335
99
Total DDMC (kg/day)
sum [DDMC] of cows
3
1
11

MONITOR
1199
11
1335
56
Total DM (kg/day)
dmgr
3
1
11

PLOT
1335
10
1657
160
Seasonal Accumulation of dry-matter (DM) per ha
Days
kg/ha
0.0
92.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot DM-cm-ha * mean [grass-height] of patches * 92"

MONITOR
1657
10
1817
55
Accumulation of DM (kg/ha)
DM-cm-ha * mean [grass-height] of patches * 92
3
1
11

PLOT
635
592
856
785
Stocking rate
Days
AU/ha
0.0
92.0
0.0
0.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot stocking-rate"

MONITOR
1199
100
1345
145
Mean DDMC (kg/cow/day)
mean [DDMC] of cows
3
1
11

BUTTON
93
72
159
105
Go (1 day)
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
28
259
179
292
initial-weight-cows
initial-weight-cows
100
380
340.0
1
1
kg
HORIZONTAL

PLOT
1335
159
1745
301
Body Condition Score (BCS)
Days
points
0.0
92.0
0.0
5.0
true
true
"" ""
PENS
"Born-calf" 1.0 0 -13791810 true "" "plot (mean [live-weight] of cows with [born-calf?] - mean [min-weight] of cows with [born-calf?]) / 40"
"Weaned-calf" 1.0 0 -955883 true "" "plot (mean [live-weight] of cows with [weaned-calf?] - mean [min-weight] of cows with [weaned-calf?]) / 40"
"Heifer" 1.0 0 -2064490 true "" "plot (mean [live-weight] of cows with [heifer?] - mean [min-weight] of cows with [heifer?]) / 40"
"Steer" 1.0 0 -2674135 true "" "plot (mean [live-weight] of cows with [steer?] - mean [min-weight] of cows with [steer?]) / 40"
"Cow" 1.0 0 -6459832 true "" "plot (mean [live-weight] of cows with [cow?] - mean [min-weight] of cows with [cow?]) / 40"
"Cow-with-calf" 1.0 0 -5825686 true "" "plot (mean [live-weight] of cows with [cow-with-calf?] - mean [min-weight] of cows with [cow-with-calf?]) / 40"
"Average BCS" 1.0 0 -16777216 true "" "plot (mean [live-weight] of cows - mean [min-weight] of cows) / 40"

MONITOR
1745
159
1866
204
Average BCS (points)
(mean [live-weight] of cows - mean [min-weight] of cows) / 40
2
1
11

MONITOR
1745
204
1866
249
BCS of cows (points)
(mean [live-weight] of cows with [cow?] - mean [min-weight] of cows with [cow?]) / 40
2
1
11

MONITOR
1745
249
1875
294
BCS of heifers (points)
(mean [live-weight] of cows with [heifer?] - mean [min-weight] of cows with [heifer?]) / 40
2
1
11

PLOT
1335
300
1745
441
Pregnancy Rate (PR)
Days
%
0.0
92.0
0.0
1.0E-4
true
true
"" ""
PENS
"Heifer" 1.0 0 -2064490 true "" "plot mean [pregnancy-rate] of cows with [heifer?] * 368 * 100"
"Cow" 1.0 0 -6459832 true "" "plot mean [pregnancy-rate] of cows with [cow?] * 368 * 100"
"Cow-with-calf" 1.0 0 -5825686 true "" "plot mean [pregnancy-rate] of cows with [cow-with-calf?] * 368 * 100"
"Average PR" 1.0 0 -16777216 true "" "plot mean [pregnancy-rate] of cows * 368 * 100"

MONITOR
1745
300
1876
345
Average PR (%)
mean [pregnancy-rate] of cows * 368 * 100
2
1
11

MONITOR
1745
345
1877
390
PR of cows (%)
mean [pregnancy-rate] of cows with [cow?] * 368 * 100
2
1
11

MONITOR
1746
391
1889
436
PR of cows-with-calf (%)
mean [pregnancy-rate] of cows with [cow-with-calf?] * 368 * 100
2
1
11

MONITOR
1746
435
1879
480
PR of heifers (%)
mean [pregnancy-rate] of cows with [heifer?] * 368 * 100
2
1
11

SLIDER
2413
328
2605
361
initial-HEIFER-in-patch-00
initial-HEIFER-in-patch-00
0
100
0.0
1
1
NIL
HORIZONTAL

MONITOR
2386
566
2534
611
GH(FINAL) patch 00 (cm)
[grass-height] of patch 0 0
17
1
11

MONITOR
2530
566
2700
611
DM(FINAL) patch 00 (kg/day)
[grass-height] of patch 0 0 * DM-cm-ha
17
1
11

MONITOR
2717
517
2898
562
DDMC cow 0 (kg/day)
[ddmc] of cow 0
17
1
11

MONITOR
2716
567
2898
612
DDMC cow 1 (kg/day)
[ddmc] of cow 1
17
1
11

MONITOR
2529
458
2699
503
DDMC patch 00 (kg/day)
[DDMC-patch00] of patch 0 0
17
1
11

MONITOR
2385
517
2543
562
GH-consum patch 00 (cm)
[gh-consumed] of patch 0 0
17
1
11

MONITOR
2531
518
2699
563
DM-consum patch 00 (kg/day)
[gh-consumed] of patch 0 0 * DM-cm-ha
17
1
11

MONITOR
2385
393
2546
438
GH(INICIO) patch 00 (cm)
[report-initial-grass-height] of patch 0 0
17
1
11

MONITOR
2531
394
2704
439
DM(INICIO) patch 00 (kg/day)
[report-initial-grass-height] of patch 0 0 * DM-cm-ha
17
1
11

MONITOR
2385
459
2531
504
GH-consum patch 00 (cm)
[DDMC-patch00] of patch 0 0 / Dm-cm-ha
17
1
11

TEXTBOX
2290
413
2387
443
to grow-grass ->
11
0.0
1

TEXTBOX
2241
557
2380
576
to update-grass-height ->
11
0.0
1

TEXTBOX
2297
474
2387
493
to eat-grass ->
11
0.0
1

MONITOR
2715
617
2897
662
DDMC cow 2 (kg/day)
[ddmc] of cow 2
17
1
11

MONITOR
2715
666
2896
711
DDMC cow 3 (kg/day)
[ddmc] of cow 3
17
1
11

MONITOR
2714
715
2896
760
DDMC cow 4 (kg/day)
[ddmc] of cow 4
17
1
11

TEXTBOX
2409
252
2716
309
OUTPUTS QUE HE USADO PARA RESOLVER EL PROBLEMA DE QUE LAS VACAS COMIAN MÁS DE 2 CM EN UN PARCHE (YA SOLUCIONADO)
11
14.0
0

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="SA_sliders" repetitions="3" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>mean [live-weight] of cows</metric>
    <enumeratedValueSet variable="climacoef">
      <value value="0.5"/>
      <value value="1"/>
      <value value="1.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-grass-height" first="3" step="1" last="7"/>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-num-cows" first="1" step="1" last="14"/>
    <steppedValueSet variable="perception" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="SA_climacoef" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>mean [live-weight] of cows</metric>
    <enumeratedValueSet variable="climacoef">
      <value value="0.5"/>
      <value value="1"/>
      <value value="1.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_initial-grass-height" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>mean [live-weight] of cows</metric>
    <steppedValueSet variable="initial-grass-height" first="3" step="1" last="7"/>
  </experiment>
  <experiment name="SA_initial-season" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>mean [live-weight] of cows</metric>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_initial-num-cows" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>mean [live-weight] of cows</metric>
    <steppedValueSet variable="initial-num-cows" first="1" step="1" last="14"/>
  </experiment>
  <experiment name="SA_perception" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>mean [live-weight] of cows</metric>
    <steppedValueSet variable="perception" first="0" step="0.1" last="1"/>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
