library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sig_operation is 

    port( 
		operande_1, operande_2 : in std_logic_vector (3 downto 0);
		choix_op : in std_logic;
		
		full_result : out std_logic_vector (7 downto 0)
	 );
	 
end sig_operation;


architecture  behavioral of sig_operation is

	signal inverse_1, inverse_2, sum : std_logic_vector (7 downto 0);
	signal middle_result : std_logic_vector (7 downto 0);
	signal MSB_result : std_logic;
	
	signal sum_result, mult_result : std_logic_vector (7 downto 0);
	
begin

	MSB_result <= operande_1(3) xor operande_2(3);
	
	middle_result <= "00" & (operande_1(2 downto 0) * operande_2(2 downto 0)); 
	
	mult_result <= std_logic_vector(MSB_result & middle_result(6 downto 0));
	
	inverse_1 <= std_logic_vector(0 - unsigned( "00000" & operande_1 (2 downto 0))) when operande_1(3) = '1' else "0000" & operande_1; 
	inverse_2 <= std_logic_vector(0 - unsigned( "00000" & operande_2 (2 downto 0))) when operande_2(3) = '1' else "0000" & operande_2; 
	
	
	sum <= std_logic_vector (unsigned(inverse_1) + unsigned(inverse_2));
	
	
	sum_result <= std_logic_vector(0 - unsigned( '0' & sum (6 downto 0))) when sum(7) = '1' else sum;
	

WITH choix_op SELECT
	full_result <= sum_result when '0',
						mult_result when '1';

end behavioral;