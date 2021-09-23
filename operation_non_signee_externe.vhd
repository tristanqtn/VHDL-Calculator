library IEEE;
use work.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity un_extern_somme is 
    port( 
		    operande_1, operande_2 : in std_logic_vector(3 downto 0);
			 
			 led_off : out std_logic_vector(9 downto 0);
			 operande_extern_1, operande_extern_2 : out std_logic_vector(3 downto 0)
			 
		  );
end un_extern_somme;




architecture behavioral of un_extern_somme is 

begin

	led_off <= "0000000000";
	
	operande_extern_1 <= operande_1;
	operande_extern_2 <= operande_2;
		

end behavioral;