##Design Notes for BlueESC

These design notes are written for the rev3 (two board) design, although they should pertain to the previous revisions as well.

###General layout

There will be two boards. The bottom board will have power electronics and the top board will have the logic.

####Bottom Board

* MOSFETs on bottom side with large traces for heat dissipation
* Big capacitors on top. Generally try to keep V+ on one side and GND on the other.
* Switching components on top side to maximize heat dissipation on bottom. 
* Thermistor and current sensor here too.
* Power interface

####Top Board

* Microcontroller
* Voltage regulator
* Comm interface

##Component Selection

###Decoupling Capacitors

* Tantalum for pressure tolerance.
* Max input voltage 20V. Derate to 30V.
* Try to get ~200uF or more.
* Choose 2917 package
* Choose 4 x 47uF
* Part: T495X476K035ATE300

###MOSFETs

* Choose SiR158DP
* Max current is 30A and max duty cycle is about 33% (because it is three phase); Rdson is 0.0023 worst case and there are two FETs per phase so that P = 30^2*.33*.0023*2 = 1.36 W; This results in a junction-to-ambient rise of 23*1.36 = 31.3 C
* Output capacitance is 915 pF and input resistor is 100 ohm. Therefore, the RC time constant is 91.5 ns.
* According to (http://www.ti.com/lit/an/slva504/slva504.pdf), the switching power dissipation can be estimated as Psw = 0.5*(24V)*(30A)*(91.5E-9s)*(18000hz) = 0.60 W x 2 FETs = 1.20 W. This would lead to a temperature rise of 27.6 C.
* Using these numbers combined, the maximum temperature if ambient temp is 25C would be 84C. The max allowable temperature of the MOSFET is 150C.

