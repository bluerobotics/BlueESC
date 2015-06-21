# AVR CMakeLists file

# Notable targets:
#  ${PROJECT_NAME}: Creates ${PROJECT_NAME}.elf
#  ihex:            Creates ${PROJECT_NAME}.hex as Intel hex file
#  program:         Programs device using cached settings with avrdude

# Required programs:
#  * avr-gcc, avr-g++: Compilation
#  * grep, sed, cat:   Conversion from PDE file to CPP file
#  * find, tr:         Discovering library subdirectories

# Required source files:
#  * ${PROJECT_NAME}.pde

###############################################################################
#                       Cross-compilation configuration                       #
# Leave these commands alone.                                                 #
# Only change them if the cross-compilers on your system have different names.#
###############################################################################
set(CMAKE_SYSTEM_NAME "Generic")
set(CMAKE_C_COMPILER "avr-gcc")
set(CMAKE_CXX_COMPILER "avr-g++")
cmake_minimum_required (VERSION 2.6)

###############################################################################
#                         Project-specific parameters                         #
# They should be changed to reflect the used libraries and source files,      #
# as well as the project's name.                                              #
###############################################################################
project (HardwareTest)
set(arduino_libs)
set(sources )

###############################################################################
#                            Default make settings                            #
# These parameters can be configured through cmake-gui or an interactive      #
# cmake session. They should be given defaults that are sensible for the      #
# project.                                                                    #
#                                                                             #
# NOTE: If you just want to compile the program with different settings, you  #
#  should use the GUI or an interactive cmake session to configure the build  #
#  as you want. These are just defaults and should only be changed by the     #
#  authoritative maintainer, only to sensible defaults, and only on a         #
#  per-project (as opposed to per-build) basis.                               #
###############################################################################
set(f_cpu "16000000" CACHE STRING "Clock speed of the microcontroller")
set(mcu "atmega8" CACHE STRING "Part name of the microcontroller (as known by avr-gcc)")
set(arduino_dir "${CMAKE_CURRENT_SOURCE_DIR}/arduino" CACHE PATH "Path to arduino root directory")
set(arduino_ver "22" CACHE STRING "Version of arduino application/library")
set(programmer_baud 9600 CACHE STRING "Baud rate of the programmer")
set(programmer_type stk500v2 CACHE STRING "Programmer type (as known by avrdude)")
set(programmer_port "/dev/ttyUSB0" CACHE FILEPATH "Path to programmer device file")
set(sketch_warnings "-Wall -Werror=return-type" CACHE STRING "Warning flags to use for building sketch files")
set(library_warnings "-w" CACHE STRING "Warning flags to use for building Arduino core and library files")
mark_as_advanced(sketch_warnings library_warnings)

###############################################################################
#                              Compilation flags                              #
# These parameters define the compilation flags used for all object code      #
# generation, except for warnings which are advanced user-configurable        #
# settings above.                                                             #
###############################################################################
add_definitions(-g)                  # add debugging information
add_definitions(-Os)                 # highest space optimization
add_definitions(-fno-exceptions)     # disable exceptions
add_definitions(-ffunction-sections)
add_definitions(-fdata-sections)
add_definitions(-std=c++0x)

###############################################################################
#                           TARGETS, COMMANDS, ETC.                           #
# The commands below configure CMake for Makefile generation, based on the    #
# variables and settings above as well as discovered directory structures.    #
# They should not ever have to be altered.                                    #
###############################################################################

#### Auto-generated variables and flags
add_definitions(-DF_CPU=${f_cpu}UL -mmcu=${mcu} -DARDUINO=${arduino_ver})

#### Setting sanity checks
if(NOT EXISTS "${arduino_dir}" OR NOT IS_DIRECTORY "${arduino_dir}")
	message(FATAL_ERROR "Arduino directory specififed does not exist.")
endif(NOT EXISTS "${arduino_dir}" OR NOT IS_DIRECTORY "${arduino_dir}")
if(${CMAKE_CURRENT_SOURCE_DIR} STREQUAL ${CMAKE_CURRENT_BINARY_DIR})
	message(WARNING
		"It is suggested that the build (current working) directory be distinct from the source directory."
		" Consider creating a \"build\" subdirectory in the source directory, changing into it, and invoking \"cmake ..\"."
	)
endif(${CMAKE_CURRENT_SOURCE_DIR} STREQUAL ${CMAKE_CURRENT_BINARY_DIR})

#### Sketch (c, cpp, and pde files) compilation and final linkage
# Create PROJECT_NAME.cpp from PROJECT_NAME.pde by prepending "#include <WProgram.h>".
# If the pde file contains "#include <FastSerial.h>" (or with quotes instead of angle brackets),
# it will be inserted immediately after the FastSerial inclusion instead.
add_custom_command(
	OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.cpp
	COMMAND $ENV{SHELL} -c "(if grep -q -E \"^#include[ \\t]+[<\\\"]FastSerial.h[>\\\"] *$\" \"${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}.pde\"; then sed -r '/^#include[ \\t]+[<\\\"]FastSerial.h[>\\\"] *$/ a #include <WProgram.h>' \"${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}.pde\"; else echo \\#include \\<WProgram.h\\>; cat \"${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}.pde\"; fi) > ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.cpp;"
	DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}.pde
	VERBATIM
)

# Sketch compilation
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
add_executable(${PROJECT_NAME} ${sources} ${PROJECT_NAME}.cpp)
set_target_properties(${PROJECT_NAME} PROPERTIES
	LINK_FLAGS "-Wl,--gc-sections -g -gdwarf-2 -mmcu=${mcu}"
	OUTPUT_NAME "${PROJECT_NAME}.elf"
	COMPILE_FLAGS "${sketch_warnings}"
)

#### Arduino libraries compilation and archival
foreach(lib_name ${arduino_libs})
	aux_source_directory(${arduino_dir}/libraries/${lib_name} lib_sources) # Scan library directory for source files
	include_directories(${arduino_dir}/libraries/${lib_name})
	if(lib_sources)
		add_library(${lib_name} STATIC ${lib_sources})
		# Create include flags for all subdirectories of library directory.
		# We do this so we can include them only for compiling said library.
		# For everything else, there's MasterCard (by which I mean, just the root library directory).
		# This isn't the best way, since it technically breaks the ability for CMake to adjust to different
		# compilers that specify include directories in some way other than "-I<include directory>", but
		# it works for now.
		execute_process(COMMAND $ENV{SHELL} -c "find \"${arduino_dir}/libraries/${lib_name}\" -type d -not -name '.' | sed s/^/-I/ | tr \\\\n \\ " OUTPUT_VARIABLE  subdirectories)
		set_target_properties(${lib_name} PROPERTIES
			COMPILE_FLAGS "${subdirectories} ${library_warnings}"
		)
		target_link_libraries(${PROJECT_NAME} ${lib_name})
	endif(lib_sources)
	# There's no such thing as loop-scoped variables, only global ones.
	# Without unsetting what we did, each iteration will _append_ to the old values, as
	# opposed to overwritting them.
	unset(lib_sources)
	unset(subdirectories)
endforeach(lib_name)

#### Arduino core compiliation and archival
include_directories(${arduino_dir}/hardware/arduino/cores/arduino)
aux_source_directory(${arduino_dir}/hardware/arduino/cores/arduino arduino_sources)
add_library(arduino STATIC ${arduino_sources})
set_target_properties(arduino PROPERTIES
	COMPILE_FLAGS "${library_warnings}"
)
target_link_libraries(${PROJECT_NAME} arduino -lc -lm -lc)

#### iHex file creation
add_custom_command(
	OUTPUT "${PROJECT_NAME}.hex"
	COMMAND avr-objcopy -O ihex -R .eeprom -R .fuse -R .lock -R .signature "${PROJECT_NAME}.elf" "${PROJECT_NAME}.hex"
	DEPENDS ${PROJECT_NAME}
	COMMENT "Extracting iHex file"
	VERBATIM
)
add_custom_target(
	ihex ALL
	DEPENDS "${PROJECT_NAME}.hex"
)

#### avrdude programming
add_custom_target(
	program
	COMMAND avrdude -p ${mcu} -b ${programmer_baud} -c ${programmer_type} -P ${programmer_port} -U "flash:w:${PROJECT_NAME}.hex"
	DEPENDS "${PROJECT_NAME}.hex"
	COMMENT "Programming device"
	VERBATIM
)
