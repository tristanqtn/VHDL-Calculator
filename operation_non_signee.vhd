library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity un_operation is 
    port( 
		    operande_1, operande_2 : in std_logic_vector(3 downto 0);
			 full_result : out std_logic_vector (7 downto 0);
			 choix_op: in std_logic_vector (1 downto 0);
			 led_off : out std_logic_vector(1 downto 0)
		  );
end un_operation; 




architecture behavioral of un_operation is 

    signal un_result, sum, div, mult, sub : unsigned (7 downto 0);

begin

	sum <= unsigned("0000" & operande_1) + unsigned("0000" & operande_2) when choix_op = "00";
	div <= "00000000" when unsigned(operande_2) = "0000" else (unsigned("0000" & operande_1) / unsigned("0000" & operande_2));
	mult <= unsigned(operande_1) * unsigned(operande_2);
	sub <= unsigned("0000" & operande_1) - unsigned("0000" & operande_2) when (unsigned(operande_1) >= unsigned(operande_2)) else "00000000";
	
	led_off(1) <= '0';
	led_off(0) <= '0';
	
WITH choix_op SELECT 

		un_result <= 	sum when "00",
							mult when "10",
							sub when "01",
							div when "11";
		
    
	full_result <= std_logic_vector(un_result (7 downto 0));

end behavioral;