# WS2812b or Neopixel Driver for PYNQ-Z2
## An implementation of NeoPxl driver 
Finally a dynamic controller which is easy to implement and use.

![schmatics](img.png)


## External Pin Layout
* Dout -> AR[0]
* enable -> SW0
* clk  -> H16 Pin from Eth PHY

## Internal Pin Layout
* green -> GPIO[0 7]
* red -> GPIO[8 15]
* blue -> GPIO[16 23]
* refresh_led -> 24

refresh_led is supposed to be toggled inorder for the color to be absorbed into the module


##jupyter notebooks are shared having helper functions to help control the LEDs
this is based on Project of mine based on Lightdriver by anfractuosity modeled on a 
circular ws2812b ring consisting of 24 LEDs

Demo is given Below.

![demo](output.gif)

Source is [pynq_ws2812b_anfry](https://github.com/ZeroX29a/pynq_ws2812b_anfry)
