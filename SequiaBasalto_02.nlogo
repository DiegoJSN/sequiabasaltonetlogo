;***********************************************************************
; ADAPTATION OF SEQUIA-BASALTO MODEL TO NETLOGO
;***********************************************************************
; The original model was built in CORMAS, for more information about the original model see Dieguez-Cameroni et al. (2012, 2014).
; Some aspects of the model related with the growth of livestock and the transition through different age classes are based on Robins et al. (2015).

globals [

;Climate

 climacoef ; External data, It relates the primary production in a season with the average for that season due to climate variations.
 ;initial-season ;Variable to define the season in which the simulation begins, it should take the values: 0 = winter, 1 = spring, 2 = summer, 3 = fall.
 current-season  ; 0 = winter, 1 = spring, 2 = summer, 3 = fall.
 season-coef ;It affects the live weight gain in relation with the grass quality according to the season, winter = 1; spring = 1.15, summer = 1.05, fall = 1.

;Time

 days-per-tick ; variable to simulate time.
 number-of-season ; to keep track of the number of seasons in 10 years of simulation (40 seasons).
 simulation-time ; variable to keep track of the years of the simulation.

;Market prices & economic balance

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


;Grass

 ;initial-grass-height ; slider
 kmax ;Paramater: maximum carrying capacity (maximum grass height), it varies according to the season, winter= 7.4 cm, spring= 22.2 cm, summer= 15.6 cm, fall= 11.1 cm.
 DM-cm-ha ;Parameter used to calculate the grass-height consumed from the dry matter consumed = 180 Kg of DM/ cm*Ha.
 grass-energy ;Parameter: metabolizable energy per Kg of dry matter = 1.8 Mcal/Kg of DM.

;Livestock

 ;initial-num-cows ;The initial number of animals is chosen by users.
 maxLWG ;Parameter (mi) that defines the maximum live weight gain per animal according to the season. Spring= 60 Kg/animal; Winter, Summer and Fall= 40 Kg/animal.
 ni ;Parameter used to define the live weight gain per animal (it's a constant).
 xi ;Parameter used to define the live weight gain per animal (it's a constant).
 weaned-calf-age-min ; 246 days (8 months + 1 day)
 heifer-age-min ; 369 days (1 year + 1 day)
 cow-age-min ; 737 (2 years + 1 day)
 cow-age-max ; 5520 days (15 years)
 gestation-period ; 276 days (9 months)
 lactation-period ; 184 days (6 months)
 weight-gain-lactation; 0.61 Kg / day
 ;perception ; parameter used to define the degree of perception of the animals regarding to the surroubding pastures.
  ]

breed [cows cow] ;We consider cows as the unique type of livestock (***future-step: to include sheep or goats as other types of livestock, and producers as decision makers).

patches-own [
  ;initial-grass-height ; homogeneously distributed along the paddock.
  grass-height ;State of the grass height, determines the carrying capacity of the system.
  r ;Parameter: growth rate for the grass = 0.002 1/day
  GH-consumed ; grass-height consumed from the total consumption of dry matter.
   ]

cows-own [
  age ;Variable that define the age of each animal (in days).
  born-calf?
  weaned-calf?
  heifer?
  steer?
  cow?
  cow-with-calf?
  pregnant?
  animal-units ;parameter used to calculate de stocking rate. Cow = 1, cow-with-calf= 1, born-calf= 0.2, weaned-calf= 0.5, steer= 0.7, heifer= 0.7.
  category-coef ;This parameter is used to obtain the DDMC. It varies according the category of the animal, is equal to 1 in all categories, except for cow-with-calf = 1.1.
  initial-weight ;cow= 280Kg, born-calf= 40Kg, weaned-calf= 150Kg, steer= 150Kg, and heifer= 200Kg.
  min-weight ;parameter to define the critical weight which below the animal can die by forage crisis. Cow= 180 Kg, weaned-calf= 60 Kg, Steer= 100 Kg, Heifer= 100 Kg.
  live-weight ;variable that defines the state of the animals in terms of live weight.
  live-weight-gain
  DDMC ;Daily dry matter consumption, variable that defines the individual grass consumption (depends on LWG). *Note:1 cm of grass/ha = 180 Kg of dry matter (Units: KgDM/animal*day).
  metabolic-body-size ;LW ^ (3/4)
  mortality-rate
  natural-mortality-rate ;annual natural mortality = 2% (in a day = 0.000054).
  except-mort-rate ;exceptional mortality rates increases to 15% (= 0.00041) in cows, 30% (= 0.000815) in pregnant cows, and 23% (0.000625) in the rest of categories.
  pregnancy-rate ;is calculated as a logistic function of LW, but it also varies with the category of the animals.
  coefA ;constant used to calculate the pregnancy rate. Cow= 20000, cow-with-calf= 12000, heifer= 4000.
  coefB ;constant used to calculate the pregnancy rate. Cow= 0.0285, cow-with-calf= 0.0265, heifer= 0.029.
  pregnancy-time ; variable to determine gestation-period.
  lactating-time ; variable to determine lacating-period.
  ]

to setup
  ca
  setup-globals
  setup-grassland
  if (model-version = "wild model") or (model-version = "management model") [setup-livestock]
  reset-ticks
end

to setup-globals
  set days-per-tick 1
  set number-of-season 0
  set simulation-time 0
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
  set DM-cm-ha 180
  set season-coef [1 1.15 1.05 1]
  set kmax [7.4 22.2 15.6 11.1]
  set maxLWG [40 60 40 40]
  set current-season initial-season
  set climacoef [1.53 1.31 1.23	1.48 1.29	0.87 0.96	1.26 1.17	0.71 0.86	1.44 1.34	0.86 1.06 1.19 0.72	0.80 0.93	0.98 0.87	1.17 1.02	0.83 0.09	1.32 0.87	1.08 1.42	0.75 1.00	0.65 0.50	1.19 1.07	0.62 0.77 1.05 1.18 1.05]
  set exploitation-costs [5.76 5.76	5.76 5.76	6.25 6.25	6.25 6.25	6.80 6.80	6.80 6.80 5.50 5.50	5.50 5.50	6.63 6.63	6.63 6.63	8.53 8.53	8.53 8.53	11.03	11.03	11.03	11.03	12.50	12.50	12.50	12.50	15.88	15.88	15.88	15.88	16.15	16.15	16.15	16.15]
  set grazing-prices [4	10 16	8	9	19 20	12 12	22 22	9	8	19 19	13 21	20 21	17 18	13 19	20 34	10 22	16 7 21	20 24	26 12	19 24	20 15	36 36]
  set supplement-prices [0.09	0.09 0.09	0.09 0.09	0.09 0.09	0.09 0.09	0.09 0.09	0.09 0.08	0.08 0.1 0.1 0.11	0.13 0.1 0.09	0.09 0.1 0.1 0.1 0.1 0.12 0.13 0.13 0.14 0.15 0.15 0.16	0.19 0.21	0.23 0.15	0.15 0.15	0.15 0.15]
  set born-calves-prices [0.74 0.8 0.84	0.88 0.87	0.71 0.69	0.7	0.66 0.63	0.66 0.76	0.74 0.8 0.86	0.83 0.86	0.98 0.99	0.99 1.02	1.02 0.94	0.98 0.91	1.06 1.13	1.17 1.26	1.3	1.36 1.33	1.31 1.74	1.2	0.94 1.03	1.03 1.03 1.03]
  set weaned-calves-prices [0.83 0.81	0.88 0.9 0.89	0.76 0.81	0.72 0.73	0.69 0.71	0.73 0.77	0.84 0.87	0.93 0.88	0.95 1 1.05	1.05 1.05	1.01 0.98	0.95 1.17 1.09 1.2 1.3 1.27	1.38 1.35	1.36 1.67	1.21 0.92	1.04 1.04	1.04 1.04]
  set steers-prices [0.68	0.72 0.76	0.8	0.79 0.65	0.63 0.64	0.6	0.57 0.6 0.69	0.67 0.73	0.78 0.75	0.79 0.89	0.9	0.9	0.93 0.93	0.86 0.89	0.82 0.97 1.02 1.06	1.15 1.18	1.23 1.21	1.19 1.59	1.09 0.85	0.94 0.94	0.94 0.94]
  set heifers-prices [0.63 0.63	0.68 0.71	0.69 0.6 0.6 0.56	0.53 0.45	0.49 0.48	0.53 0.58	0.64 0.67	0.59 0.7 0.73	0.72 0.75	0.75 0.66	0.69 0.65	0.81 0.83	0.82 0.94	0.92 1.05	0.97 0.98	1.17 0.87	0.62 0.72	0.72 0.72	0.72]
  set cows-prices [0.45	0.48 0.49	0.57 0.49	0.51 0.51	0.44 0.45	0.4	0.37 0.43	0.48 0.49	0.47 0.59	0.51 0.57	0.62 0.6 0.55	0.55 0.56	0.63 0.46	0.7	0.65 0.74	0.78 0.74	0.89 0.79	0.94 1.17	0.67 0.52	0.5	0.5	0.5	0.5]
  set pregnant-cows-prices [0.45 0.48	0.49 0.57	0.49 0.51	0.51 0.44	0.45 0.4 0.37 0.43 0.48 0.49 0.47 0.59 0.51	0.57 0.62	0.6	0.55 0.55	0.56 0.63	0.46 0.7 0.65	0.74 0.78	0.74 0.89	0.79 0.94	1.17 0.67	0.52 0.5 0.5	0.5	0.5]
  set lactating-cows-prices [0.51	0.52 0.54	0.55 0.53	0.45 0.47	0.42 0.42	0.39 0.42	0.42 0.45	0.55 0.61	0.63 0.57	0.64 0.7 0.68	0.67 0.67	0.78 0.65	0.58 0.85	0.77 0.77	0.81 0.83	0.91 0.89	0.92 1.1 0.81	0.52 0.64	0.64 0.64	0.64]
  set sheep-prices [0.47 0.52	0.47 0.48	0.51 0.49	0.54 0.46	0.49 0.49	0.56 0.51	0.59 0.76	0.92 0.81	0.82 0.96	1.05 0.84	0.81 0.77	0.68 0.59	0.45 0.46	0.56 0.57	0.48 0.64	0.8	0.92 0.94	0.88 0.98	0.98 0.98	0.98 0.98	0.98]
  set wool-prices [5.6 5.81	5.65 5.76	6.18 5.81	5.86 7.08	9.52 9.31	11.83	13.01	13.79	8.65 12.37 12.43 12.69 12.53 11.59 10.64 10.43 10.01 9.85	8.52 8.26	9	9	9.15 11.1 12.78	14.27 15.4 17.36 17.75 16.07 8.17	8.17 8.17	8.17 8.17]
end

to setup-grassland
  ask patches [
    set grass-height initial-grass-height
    set GH-consumed 0
    ifelse grass-height < 2 [set pcolor 37]
    [set pcolor scale-color green grass-height 23 0]
    set r 0.002]
end

to setup-livestock
  create-cows initial-num-cows [
    set shape "cow"
    set initial-weight random (280 - 180) + 180 ; alternative option: to define randomly the initial weight of the animals between a reasonable range.
    ;set initial-weight 280
    set live-weight initial-weight
    set mortality-rate natural-mortality-rate
    set DDMC 0
    set age random (cow-age-max - cow-age-min) + cow-age-min ; alternative option: to define randomly the age of the animals between the minimum and the maximum.
    ;set age cow-age-min
    setxy random-pxcor random-pycor
    become-cow ]
end

to go
  if ticks >= 92 [
    set number-of-season number-of-season + 1 ; to count the number of seasons in the simulation period (useful for external data of weather and market prices).
    ifelse current-season = 0 [
      set current-season 1
      if (model-version = "management model") [
      sell-males
      extraordinary-sales
      sacrifice-animals
    ]]
      [ifelse current-season = 1 [set current-season 2]
        [ifelse current-season = 2 [set current-season 3]
          [set current-season 0]
        ]
    ]
    reset-ticks
  ]
  set simulation-time simulation-time + days-per-tick
  if simulation-time >= 3680 [stop]
  if (model-version = "wild model") or (model-version = "management model") [if not any? cows [stop]]
  ask patches [grow-grass update-grass-height]
  if (model-version = "wild model") or (model-version = "management model") [ask cows [eat-grass move grow-livestock reproduce]]


  tick
end

to grow-grass
set grass-height grass-height + r * grass-height * (1 - grass-height / item current-season kmax) * item number-of-season climacoef
end

to eat-grass
ifelse born-calf? = true [set live-weight-gain weight-gain-lactation] [
   ifelse grass-height >= 2 [
   set metabolic-body-size live-weight ^ (3 / 4)
   set live-weight-gain ( item current-season maxLWG - ( xi * e ^ ( - ni * grass-height ) ) ) / ( 92 * item current-season season-coef )]
        [set live-weight-gain live-weight * -0.005]]
set live-weight live-weight + live-weight-gain
    ifelse born-calf? = true [set DDMC 0] [ifelse live-weight-gain > 0 [
    set DDMC ((0.107 * metabolic-body-size * (- 0.0132 *  grass-height + 1.1513) + (0.141 * metabolic-body-size * live-weight-gain) ) / grass-energy) * category-coef]
    [set DDMC 0]]
end

to update-grass-height
set GH-consumed 0
  ask cows-here [
    let totDDMC sum [DDMC] of cows-here
    set GH-consumed totDDMC / DM-cm-ha]
  set grass-height grass-height - GH-consumed
  if grass-height < 0 [set grass-height 0] ; to avoid negative values.
  ifelse grass-height < 2 [set pcolor 37] [set pcolor scale-color green grass-height 23 0]
end

to move
  if grass-height < 5 [ifelse random-float 1 < perception [uphill grass-height] [move-to one-of neighbors]]
end

to grow-livestock
set age age + days-per-tick
  if age > cow-age-max [die]
  ifelse live-weight < min-weight [set mortality-rate except-mort-rate] [set mortality-rate natural-mortality-rate]
    if random-float 1 < mortality-rate [die]

  if age = weaned-calf-age-min [become-weaned-calf]
  if age = heifer-age-min [ifelse random-float 1 < 0.5 [become-heifer] [become-steer]]
  if (heifer? = true) and (age = cow-age-min) and (live-weight >= 280) [become-cow]

  if cow-with-calf? = true [set lactating-time lactating-time + days-per-tick]
  if lactating-time = lactation-period [
      become-cow]
end

to reproduce
  if (heifer? = true) or (cow? = true) or (cow-with-calf? = true) [set pregnancy-rate (1 / (1 + coefA * e ^ (- coefB * live-weight))) / 368]
  if random-float 1 < pregnancy-rate [set pregnant? true]
  if pregnant? = true [
    set pregnancy-time pregnancy-time + days-per-tick
    set except-mort-rate 0.3]
  if pregnancy-time = gestation-period [ hatch-cows 1 [
    setxy random-pxcor random-pycor
    become-born-calf]
    set pregnant? false
    set pregnancy-time 0
    become-cow-with-calf]
end

to sell-males

end

to extraordinary-sales

end

to sacrifice-animals
end

to become-born-calf
  set born-calf? true
  set weaned-calf? false
  set heifer? false
  set steer? false
  set cow? false
  set cow-with-calf? false
  set pregnant? false
  set size 0.4
  set color brown
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
  set animal-units 0.7
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

to-report stocking-rate ;Variable to define the relation between the stock of livestock (in terms of animal units) and the grassland area.
  report sum [animal-units] of cows / count patches
end

;REFERENCES
;Dieguez-Cameroni, F.J., et al. 2014. Virtual experiments using a participatory model to explore interactions between climatic variability
;and management decisions in extensive systems in the basaltic region of Uruguay. Agricultural Systems 130: 89–104.
;Dieguez-Cameroni, F., Bommel, P., Corral, J., Bartaburu, D., Pereira, M., Montes, E., Duarte, E., Morales-Grosskopf, H. 2012. Modelización
;de una explotación ganadera extensiva criadora en basalto. Agrociencia Uruguay 16(2): 120-130.
;Robins, R., Bogen, S., Francis, A., Westhoek, A., Kanarek, A., Lenhart, S., Eda, S. 2015. Agent-based model for Johne’s disease dynamics
;in a dairy herd. Veterinary Research 46: 68.
@#$#@#$#@
GRAPHICS-WINDOW
210
10
678
479
-1
-1
20.0
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
32
71
96
104
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
109
71
172
104
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
26
194
197
227
initial-num-cows
initial-num-cows
50
700
250.0
50
1
cows
HORIZONTAL

SLIDER
26
115
198
148
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
697
12
897
162
Average of grass height
Days
cm
0.0
3680.0
0.0
30.0
false
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [grass-height] of patches"

PLOT
1115
10
1315
160
Average of live-weight
Days
Kg
0.0
3680.0
0.0
600.0
false
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [live-weight] of cows"

PLOT
1116
169
1316
319
Mean age of cows
Days
age (days)
0.0
3680.0
0.0
5520.0
false
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [ age ] of cows"

MONITOR
1118
328
1196
373
Time (days)
simulation-time
2
1
11

PLOT
908
12
1108
162
Total number of cows
Days
Heads
0.0
3680.0
0.0
700.0
false
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count cows"

MONITOR
1120
381
1200
426
Stoking rate
stocking-rate
2
1
11

PLOT
693
181
1110
455
Age classes population sizes
Days
Heads
0.0
3680.0
0.0
1000.0
false
true
"" ""
PENS
"Born-calf" 1.0 0 -14454117 true "" "plot count cows with [born-calf?]"
"Weaned-calf" 1.0 0 -955883 true "" "plot count cows with [weaned-calf?]"
"Heifer" 1.0 0 -2064490 true "" "plot count cows with [heifer?]"
"Steer" 1.0 0 -2674135 true "" "plot count cows with [steer?]"
"Cow" 1.0 0 -6459832 true "" "plot count cows with [cow?]"
"Cow-with-calf" 1.0 0 -5825686 true "" "plot count cows with [cow-with-calf?]"

MONITOR
1207
381
1307
426
Mean DDMC
mean [DDMC] of cows
2
1
11

SLIDER
26
233
198
266
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
1201
328
1305
373
Total DDMC
sum [DDMC] of cows
2
1
11

MONITOR
1121
431
1237
476
Total number of cows
count cows
2
1
11

MONITOR
1243
431
1307
476
Mean LW
mean [live-weight] of cows
2
1
11

SLIDER
26
153
198
186
initial-grass-height
initial-grass-height
3
7
6.0
1
1
cm
HORIZONTAL

CHOOSER
33
19
189
64
model-version
model-version
"grass model" "wild model" "management model"
1

TEXTBOX
27
273
198
329
Only if you have selected the management model, you can chose between the reactive and the proctive strategies.
11
0.0
1

CHOOSER
25
334
173
379
management-strategy
management-strategy
"reactive" "proactive"
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
NetLogo 6.1.1
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
