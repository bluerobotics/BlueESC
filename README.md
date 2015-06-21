BlueESC
=======

![BlueESC Rev1 Prototype](https://raw.githubusercontent.com/bluerobotics/BlueESC/master/images/blueesc-rev1-1.jpg "BlueESC Rev1 Prototype")

The BlueESC is a simple, open-source electronic speed controller for three-phase brushless motors. It is designed to run the [SimonK firmware](http://github.com/sim-/tgy) on an Atmega8 microcontroller.

The hardware is licensed under GPLv3. It was inspired by and draws from other open-source ESC projects including [AfroESC](https://code.google.com/p/afrodevices/), [WiiESC](https://code.google.com/p/wii-esc/), and others. We owe a big thanks to everyone who has shared their open-source ESC designs and firmware.

We also thank Bernhard Konze and SimonK for the [tgy firmware](http://github.com/sim-/tgy). Please see the firmware license at the top of [tgy.asm](https://github.com/bluerobotics/tgy/blob/master/tgy.asm). The firmware configuration files for the BlueESC are maintained in [our fork of the tgy project](http://github.com/bluerobotics/tgy).

##Features

* Atmega8 microcontroller
* PWM and I2C signal interfaces
* 5-22 volt input (2-5s lipo)
* Reprogrammable via PWM pin using bootloader (usblinker)
* Status and warning LED indicators
* Sensors for voltage, current, temperature, and RPM
* No battery-eliminator-circuit (BEC)
* N-Channel MOSFETs

##Current Version: Rev. 5

This major revision is designed to work with the [BlueRobotics T100 Thruster](http://www.bluerobotics.com/thruster/). It is highly compact and is potted in an aluminum enclosure that acts as a heat sink. The board is built with two 2-layer boards, one for the power electronics and one for logic. The boards are connected by headers. This allows components to be placed on three sides, simplifies design, and minimizes cost.

![BlueESC Rev3 Prototype](https://raw.githubusercontent.com/bluerobotics/BlueESC/master/images/blueesc-rev3-1.jpg "BlueESC Rev3 Prototype")

###Features

* Hall effect current sense IC (ACS711EX)
* Thermistor temperature sensor (10K)

###Specifications

* 6-22 volt input
* 25 amps continuous current (air)
* 35+ amps continuous current (water)
* 400 uF decoupling capacitance
* Enclosure diameter: 40 mm (1.58")
* Enclosure length: 18.5 mm (0.73")

##Firmware Compilation

The BlueESC uses the [tgy firmware located in the BlueRobotics fork](https://github.com/bluerobotics/tgy).

*Mac:* (Uses Homebrew)

```bash
brew update
brew install avra
make bluesc.hex
```

##Initial Firmware Flashing

The BlueESC can be flashed using any AVR ISP programmer.

```bash
avrdude -c [programmer] -p m8 -U flash:w:bluesc.hex:i 
```

The fuses should be set per the instructions in the [tgy](http://github.com/sim-/tgy) instructions.

```bash
avrdude -c [programmer] -p m8 -U lfuse:w:0x3f:m -U hfuse:w:0xca:m
```

The Rev5 version of the board does not include an ISP header or pads. The microcontroller must be flashed with a special tool that connects directly to the microcontroller pins. Make sure that the board is powered when programming.

##Firmware Flashing Through Bootloader

Once the ESC has had the firmware (including bootloader) flashed the first time, it can be reprogrammed subsequently through the PWM input pin using a programmer like the [Turnigy USB Linker](http://www.hobbyking.com/hobbyking/store/__10628__turnigy_usb_linker_for_aquastar_super_brain.html). This can be done through the Makefile in the **tgy** project as follows.

```bash
make program_tgy_bluesc
```

It can also be done with avrdude and the compiled hex files as follows.

```bash
avrdude -c stk500v2 -b 19200 -P [programmer port] -p m8 -U flash:w:bluesc.hex:i
```

##I2C Commands and Address

The I2C message format allows speed and direction to be set and voltage, current, rpm, temperature, and status to be requested.

###Speed Command (Register 0x00-0x01)
* cmd: Command, sent as int16_t. Full range, negative for reverse, positive for forward.
  * Forward: 0 to 32767
  * Reverse: 0 to -32767

####Bytes
* Byte 0: throttle_h
* Byte 1: throttle_l

###Sensor Data (Register 0x02-0x0A)
* pulse_count: Commutation pulses since last request. Sent as uint16_t.
  * Calculate rpm with pulse_count/dt*60/motor_pole_count
* voltage: ADC measurement scaled to 16 bits
  * Calculate voltage with voltage/2016
* temperature: ADC measurement scaled to 16 bits
  * Calculate temperature with the Steinhart equation
* current: ADC measurement scaled to 16 bits
  * Calculate current with (current-32767)/891

####Bytes
* Byte 0: pulse_count_h
* Byte 1: pulse_count_l
* Byte 2: voltage_h
* Byte 3: voltage_l
* Byte 4: temperature_h
* Byte 5: temperature_l
* Byte 6: current_h
* Byte 7: current_l
* Byte 8: 0xab (identifier to check if ESC is alive)

##Releases

v0.13 - Rev5 shipping. Currently shipping.

##Video

<a href="http://www.youtube.com/watch?feature=player_embedded&v=qJa0dBeoZHA
" target="_blank"><img src="http://img.youtube.com/vi/qJa0dBeoZHA/0.jpg" 
alt="BlueESC Prototype Test Video" width="240" height="180" border="10" /></a>
