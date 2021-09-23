-- LIBRAIRIES ----------------------------------------------------------------------------
library IEEE;
use work.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------
-- OPERATION SIGNEE ----------------------------------------------------------------------
------------------------------------------------------------------------------------------
entity sig_operation is 

    port( 
				choix_op : in std_logic_vector (1 downto 0); -- choix du type d'opération à effectuer (2 bits)
				operande_1, operande_2 : in std_logic_vector (3 downto 0); -- les deux opérandes reçues (4 bits)
					
				overflow : out std_logic;
				full_result : out std_logic_vector (3 downto 0) -- sortie de l'opération (8 bits)
	 );
	 
end sig_operation;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------




------------------------------------------------------------------------------------------
-- STRUCTURE OPERATION SIGNEE ------------------------------------------------------------
------------------------------------------------------------------------------------------
architecture  behavioral of sig_operation is

	signal MSB_result : std_logic; -- signal pour les calculs
	signal inverse_1, inverse_2, sum, tempo_result, sum_result, mult_result, div_result, mult_middle_result, div_middle_result : std_logic_vector (7 downto 0); -- signaux vectoriels pour les calculs
	
begin

	MSB_result <= operande_1(3) xor operande_2(3); -- calcul du signe de la multiplication/divison selon les règles arithmétiques
	
	-- MULTIPLICATION
	mult_middle_result <= "00" & (operande_1(2 downto 0) * operande_2(2 downto 0)); -- multiplication des 2 operande sans le MSB
	mult_result <= std_logic_vector(MSB_result & mult_middle_result(6 downto 0)); -- concaténation du sogne (MSB) et du résultat de la multiplication
	
	-- SOMME
	inverse_1 <= std_logic_vector(0 - unsigned( "00000" & operande_1 (2 downto 0))) when operande_1(3) = '1' else "0000" & operande_1; -- inversion de l'opérande 1 si le MSB = 1
	inverse_2 <= std_logic_vector(0 - unsigned( "00000" & operande_2 (2 downto 0))) when operande_2(3) = '1' else "0000" & operande_2; -- inversion de l'opérande 2 si le MSB = 1
	
	sum <= std_logic_vector (unsigned(inverse_1) + unsigned(inverse_2)); -- somme des deux valeurs absolues 
	sum_result <= std_logic_vector(0 - unsigned( '0' & sum (6 downto 0))) when sum(7) = '1' else sum; -- si le résultat est négatif on fait le complément à 2 pour retrouver la bonne valeur
	
	-- DIVISION
	div_middle_result <= "00000000" when unsigned(operande_2 (2 downto 0)) = "000" else std_logic_vector(unsigned("00000" & operande_1(2 downto 0)) / unsigned("00000" & operande_2(2 downto 0))); -- division euclidiènne des deux opérande si l'opérande 2 différente de 00000000
	div_result <= std_logic_vector(MSB_result & div_middle_result(6 downto 0)); -- concaténation du signe (MSB) et du résultat de la division euclidiènne


	
	-- SELECTION de la sortie selon le type d'opération
	WITH choix_op SELECT
		tempo_result <= sum_result  when "00", -- somme
							 "00000000"  when "01", -- opération inexistante
							 mult_result when "10", -- multiplication
							 div_result  when "11"; -- division
							
	overflow <= '1' when tempo_result(5 downto 0) > "000111" else '0';
							
	full_result <= tempo_result(7) & tempo_result(2 downto 0); -- stockage du résultat dans un autre signal
	
end behavioral;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------