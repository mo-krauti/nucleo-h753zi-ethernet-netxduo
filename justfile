project_name := "nucleo-h753zi-ethernet-netxduo"

build_config := "Debug"

# https://community.st.com/t5/stm32-mcus-products/compatibility-between-nucleo-h743zi2-and-h753zi/td-p/693172
openocd_config := "board/st_nucleo_h743zi.cfg"

default:
  just --list

setup_build:
  mkdir -p build/{{build_config}}; cd build/{{build_config}}; cmake -G Ninja ../../;
build: setup_build
  cmake --build build/{{build_config}} --config {{build_config}}

flash: build
  openocd -f {{openocd_config}} -c "program build/{{build_config}}/{{project_name}}.elf verify reset exit"
# https://github.com/zephyrproject-rtos/zephyr/issues/45778
debug_openocd:
  openocd -f {{openocd_config}} -c '$_CHIPNAME.cpu0 configure -rtos auto'
reset_board:
  openocd -f {{openocd_config}} -c 'init; reset init; reset run; exit'

debug:
  /usr/bin/arm-none-eabi-gdb -ex 'target extended-remote localhost:3333' build/{{build_config}}/{{project_name}}.elf
