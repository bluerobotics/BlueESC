BlueESC
=======

The BlueESC is a simple, open-source electronic speed controller for three-phase brushless motors. It is designed to run the [SimonK firmware](http://github.com/sim-/tgy) on an Atmega8 microcontroller.

The hardware is licensed under GPLv3. It was inspired by and draws from other open-source ESC projects including [AfroESC](https://code.google.com/p/afrodevices/), [WiiESC](https://code.google.com/p/wii-esc/), and others. We owe a big thanks to everyone who has shared their open-source ESC designs and firmware.

We also thank Bernhard Konze and SimonK for the [tgy firmware](http://github.com/sim-/tgy). Please see the firmware license at the top of [tgy.asm](https://github.com/bluerobotics/tgy/blob/master/tgy.asm). The firmware configuration files for the BlueESC are maintained in [our fork of the tgy project](http://github.com/bluerobotics/tgy).

##Features

* Atmega8 microcontroller
* PWM, I2C, and serial signal interfaces
* 5-16 volt input (2-4s lipo)
* Reprogrammable via PWM pin using bootloader
* Status and warning LED indicators
* Very simple: No battery-eliminator-circuit (BEC), no limiting
* N-Channel MOSFETs

##Rev.1

The first revision was designed as a proof-of-concept. It is designed on a simple 2-layer PCB and space is not highly optimized. It exposes all interfaces and programming pins.

###Specifications

* 5-16 volt input (2-4s lipo)
* 25 amps continuous current (*not yet tested*)
* Dimensions: 41mm x 57mm (1.60" x 2.25")
* MOSFETs: Vishay SiR158DP (N-channel)

##Rev.2

The second revision is designed to work with the [BlueRobotics T100 Thruster](http://www.bluerobotics.com/thruster/). It is highly compact, 4-layers, and is potted in an aluminum enclosure that acts as a heat sink. 

###Specifications (*subject to change*)

* 5-16 volt input
* 25 amps continuous current (air)
* 35 amps continuous current (water)
* Enclosure diameter: 40.3 mm (1.59")
* Enclosure length: 13 mm (0.5")

##Initial Firmware Flashing

The BlueESC can be flashed using any AVR ISP programmer.

```bash
avrdude -c [programmer] -p m8 -U flash:w:bluesc.hex:i 
```

The fuses should be set per the instructions in the [tgy](http://github.com/sim-/tgy) instructions.

```bash
avrdude -c [programmer] -p m8 -U lfuse:w:0x3f:m -U hfuse:w:0xca:m
```

##Firmware Flashing Through Bootloader

Once the ESC has had the firmware (including bootloader) flashed the first time, it can be reprogrammed subsequently through the PWM input pin using a programmer like the [Turnigy USB Linker](http://www.hobbyking.com/hobbyking/store/__10628__turnigy_usb_linker_for_aquastar_super_brain.html) or the [AfroESC Programmer](http://www.hobbyking.com/hobbyking/store/__39437__afro_esc_usb_programming_tool.html). This can be done through the Makefile in the **tgy** project as follows.

```bash
make program_tgy_bluesc
```

It can also be done with avrdude and the compiled hex files as follows.

```bash
avrdude -c stk500v2 -b 9600 -P [programmer port] -p m8 -U flash:w:bluesc.hex:i
```

##I2C Commands and Address

To be completed.

##Releases
