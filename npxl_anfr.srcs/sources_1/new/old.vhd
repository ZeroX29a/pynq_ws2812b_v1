
library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.MATH_REAL;

entity lighting is
    port (
        red : in std_logic_vector(7 downto 0);
        blu : in std_logic_vector(7 downto 0);
        gre : in std_logic_vector(7 downto 0);
        spexify : in std_logic_vector(7 downto 0);
        --    clk1: in std_logic;    -- 125MHz clock
        refresh_led: in std_logic;
        clk,enable: in std_logic;    -- 125MHz clock
        Dout: out std_logic -- Output to first header pins on my PMOD board

    );
end lighting;

architecture Behavioral of lighting is
    constant size: integer := 24;         -- Number of LEDs
    constant tp_clock: real := 1.0 / 125.0e6; -- Get time period, for 125MHz clock

    type ram is array(0 to (size*2)-1) of std_logic_vector(0 to 23); -- allocate BRAM for double buffering
    signal vram : ram := (others => "000000000000000000000000"); -- initialise 

    signal led_bits: unsigned(0 to 23) := "000000000000000000000000"; -- each LED is 24 bits, we output the same bitstream to all LEDs

    signal long: integer := integer(0.85e-6 / tp_clock);       -- long duration
    signal spexify_valid: std_logic := '0';       -- long duration
    signal short: integer := integer(0.4e-6 / tp_clock);       -- short duration
    signal refresh: integer := integer((74.0e-6) / tp_clock);  -- refresh duration, when strip is driven low, MUST be ABOVE 50uS

    signal clock_counter: integer := 0;    -- Counts clock pulses
    signal led_bit_counter: integer := 0;  -- Counts the Nth bit of an LED's colour data (24 bits total)
    signal led_counter: integer := 0;      -- LED number we're sending data for    
    signal pulse: integer := 0;            -- Keeps track if we are outputting a high

    signal spi_counter: integer := 0;         -- Counts the bit from SPI for the Nth bit of a single LED 
    signal spi_frame_counter: integer := 0;   -- Data for the Nth LED
    signal spi_data: std_logic_vector(0 to 23) := "000000000000000000000000";

    signal vram_part: bit := '0';            -- Writing SPI data, to first or second part of BRAM
    signal vram_part_tmp: bit := '0';        -- mirrors above, for choosing where to read from BRAM

    signal colour_counter: unsigned(23 downto 0) := "000000000000000000000000"; -- Counters address of BRAM for writing to
    signal color: std_logic_vector(23 downto 0) := "111111110000000000000000";
    --        signal color: unsigned(23 downto 0) :=red&blu&gre;

    attribute dont_touch : string;                               -- Hack so synthesis works
    attribute dont_touch of colour_counter : signal is "true";   -- Hack so synthesis works

    signal read_addr: integer := 0;          -- Store address to read data from of double buffer
    signal write_addr: integer := 0;         -- Store address to write data to in double buffer
    signal marker: integer := 25;
begin

    process(spexify)
    begin
        if integer(spexify)<24 then
            marker<=integer(spexify);
        end if;
    end process;


    process(refresh_led)
    begin
        if rising_edge(refresh_led) then
            color <= red&blu&gre;
        end if;
    end process;



    fill_bram : process(clk,enable)
    begin
        if rising_edge(clk) and enable ='1' then


            if vram_part = '0' then
                write_addr <= 0 ;
            else
                write_addr <= size  ;
            end if;

            if colour_counter >= size then
                colour_counter <= "000000000000000000000000";
                vram_part <= not vram_part;
            else


                    if colour_counter = marker then   -- mark specific LED
                        vram(to_integer(colour_counter)+write_addr) <=     "111111110000000000000000";
                    else 
                        if colour_counter(0) = '1' then -- generate alternating pattern
                            vram(to_integer(colour_counter)+write_addr) <= "000000000000000011111111";
                        else 
                            vram(to_integer(colour_counter)+write_addr) <= "000000001111111100000000";
                        end if;
                    end if;
    
                colour_counter <= colour_counter + 1;
            end if;
        end if;
    end process fill_bram;


    write_leds: process(clk,enable)
    begin
        if rising_edge(clk) and enable ='1' then

            -- Counting clock edges
            clock_counter <= clock_counter + 1;

            if vram_part_tmp = '0' then
                read_addr <= led_counter+size ;
            else
                read_addr <= led_counter  ;
            end if;

            led_bits <= vram(read_addr);

            -- Check if we've reached end of LED strip
            if led_counter = size then
                -- Check if we have finished refresh duration
                if clock_counter > refresh then
                    clock_counter <= 0;
                    led_counter <= 0;
                    vram_part_tmp <= vram_part;
                else
                    Dout <= '0';
                end if;
            else
                -- Check if at the end of a WS2812B '0' or '1'
                if clock_counter > short+long then

                    clock_counter <= 0;
                    led_bit_counter <= led_bit_counter + 1;

                    if led_bit_counter = 23 then
                        led_bit_counter <= 0;
                        led_counter <= led_counter + 1;
                    end if;

                elsif led_bits(led_bit_counter) = '1' and clock_counter > long then
                    Dout <= '0';
                elsif led_bits(led_bit_counter) = '0' and clock_counter > short then
                    Dout <= '0';
                else
                    Dout <= '1';
                end if;

            end if;
        end if;
    end process write_leds;
end Behavioral;