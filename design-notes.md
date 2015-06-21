##Design Notes for BlueESC

These design notes are written for the rev3 (two board) design, although they should pertain to the previous revisions as well.

##Component Selection

###MOSFETs

* Choose SiR158DP
* Max current is 30A and max duty cycle is about 33% (because it is three phase); Rdson is 0.0023 worst case and there are two FETs per phase so that P = 30^2*.33*.0023*2 = 1.36 W; This results in a junction-to-ambient rise of 23*1.36 = 31.3 C
* Output capacitance is 915 pF and input resistor is 100 ohm. Therefore, the RC time constant is 91.5 ns.
* According to (http://www.ti.com/lit/an/slva504/slva504.pdf), the switching power dissipation can be estimated as Psw = 0.5*(24V)*(30A)*(91.5E-9s)*(18000hz) = 0.60 W x 2 FETs = 1.20 W. This would lead to a temperature rise of 27.6 C.
* Using these numbers combined, the maximum temperature if ambient temp is 25C would be 84C. The max allowable temperature of the MOSFET is 150C.


#Other Collected Notes

MOSFETs:

Heat losses come from Rdson, which is usually small for most FETs. Rdson accounts for some of the heat.

More heat comes from the internal diodes, which are built into the silicon and are not Schottky. The reverse current spikes caused by the inductance of the motor causing back flowing current. The voltage drop turns into heat. This is most significant around the 50% duty cycle area. It's related to the switching frequency and the inductance of the motor.

If there is a lot of heat from diodes, external Schottky diodes could be added to reduce heat loss from voltage drop.

Choosing MOSFET and reading data sheet: The most important values for estimating performance are the temperature rise from junction to ambient per watt and the allowable temp, which should be derated. (Derates everything by x/0.6).

Most of the heat will be coming out of the big pad on the MOSFET, not the case. The copper there should be thick and large to distribute heat as well as possible. Hopefully the thermally conductive potting compound will help conduct heat from the traces.

The 100 ohm resistors that turn on the FETs are important to size properly, too large will turn them on slowly, increasing switching losses, and too small could cause the low side FETs to turn on accidentally. Recommended 22 ohm but  100 ohm was fine.

The charge pumps work by charging the capacitor to 12V when the low side is on, then when the high side turns on, the capacitor is already at 12V but the low side of the capacitor goes up to 12V, meaning that the high side of the capacitor is now 24V. It's only needed on the high side because the EMF of the motor is high when switching. Might be 10Vand Vin to MOSFET at 12V --> bad switching.

The charge pump diode needs to be sized the handle the current that rushes through it when switching. A small current limiting resistor could be used to help. 0.5-1.0 amp (what I have now) is more than sufficient.

The charge pump capacitor will never have more than the input voltage across it, so 12V or the max voltage.

If there are heat problems, it is most likely switching losses, then diode losses, then everything else.

CAPACITORS:

Recommend 500-1000uF for decoupling. Tantalums can be used, they have packages that are double high.

OTHER:

Strongly recommends current sensors to automatically limit current spikes when starting.

The software probably has a time delay between switching high and low, but you can also do it with hardware with a diode and sizing the resistors properly.

Guessed that motor inductance was 200-400 uH and that would be a low value for fast switching.

