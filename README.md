# nucleo-h753zi ethernet NetXDuo example

Setting up ethernet on the nucleo-h753zi was quite cumbersome, so this repository might help as a working reference.

## Prerequisites  

Install
* [STM32CubeMX](https://www.st.com/en/development-tools/stm32cubemx.html)
* [VS Code](https://code.visualstudio.com/download)
* [arm-none-eabi- toolchain v14 including gdb](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads) 
* [cmake](https://cmake.org/download/)
* [ninja](https://ninja-build.org/)
* [openocd](https://openocd.org/)
* [just command runner](https://github.com/casey/just)

Make sure to add all tools to the PATH if you are running on Windows.

### VS Code

* Open the repo in VS Code
* Install the recommended extensions
* Select the cmake Debug preset
* Start the `Cortex Debug OpenOCD` configuration

### CLI

Run `just` to list the available commands.

## Notes

### IP address

The stm32 ip addresses is statically configured to `192.168.82.1` to avoid clashes with common subnets. 
So set your host pc to `192.168.82.2` or another address in the subnet.

### NetXDuo startup delay

I noticed that the ethernet only works if there is a slight delay at the start of the `MX_NetXDuo_Init` function in [app_netxduo.c](NetXDuo/App/app_netxduo.c). 
I initially achieved this using a breakpoint in the debugger and then tried using `HAL_Delay()`. 
This HAL function will not work because it interferes with the ThreadX RTOS. 
`tx_thread_sleep` from ThreadX can only be called from threads, but we are still in the initialization code. 
Then I tried using `tx_get_time`, but this always returns 0 at this point, so also not available yet. 
That is why I implemented a busy wait function called `busy_cycle_sleep_ms` which works just fine. 

### linker and MPU configuration

I moved all the main code from DTCMRAM to RAM. The Ethernet descriptors and NetXPoolSection are placed in the RAM_D2. 
Have a look at the [linker file](STM32H753XX_FLASH.ld) 

Then I added a MPU Region for this memory region. Load up the `.ioc` in CubeMX to see the exact details.


## References

* https://community.st.com/t5/stm32-mcus/creating-a-dual-ipv6-amp-ipv4-netxduo-udp-application-for/ta-p/570521 
  this guide is almost for the same board, but it is only working partly
* [YT Tutorial on STM32 MPU](https://www.youtube.com/watch?v=5xVKIGCPy2s)
  this really helped me to understand why & how the MPU needs to be configured
* [Memory Management in STM32](https://www.youtube.com/watch?v=MJfUiw8bZEI)
* https://community.st.com/t5/stm32-mcus/debugging-tips-when-working-with-an-ethernet-peripheral/ta-p/696898https://community.st.com/t5/stm32-mcus/debugging-tips-when-working-with-an-ethernet-peripheral/ta-p/696898
