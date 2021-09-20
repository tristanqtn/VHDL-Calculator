-- LIBRAIRIES ----------------------------------------------------------------------------
library IEEE;
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
				led_off : out std_logic_vector(4 downto 0); -- variable permettant d'eteindre les leds en trop (4 bits)
				full_result : out std_logic_vector (3 downto 0); -- sortie de l'opération (8 bits)
				seg1, seg2, seg3 : OUT std_logic_vector(7 downto 0) -- chaque variable correspond à un afficheur 7seg (8 bits)
			 
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
	signal shorten_result, c : std_logic_vector(3 downto 0);
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
	
	-- extinction des LED inutilisées
	led_off <= "00000";

	
	-- SELECTION de la sortie selon le type d'opération
	WITH choix_op SELECT
		tempo_result <= sum_result  when "00", -- somme
							 "00000000"  when "01", -- opération inexistante
							 mult_result when "10", -- multiplication
							 div_result  when "11"; -- division
							
	overflow <= '1' when tempo_result(5 downto 0) > "000111" else '0';
							
	shorten_result <= tempo_result(7) & tempo_result(2 downto 0); -- stockage du résultat dans un autre signal
						
	process(shorten_result) -- si modification de l'état du signal
	begin
		
		c <= shorten_result; -- stockage du résultat dans un autre signal			
		
		if(c(3) = '1')then	--negativité
			seg3 <= "10111111"; --affichage du signe moins
		elsif(c(3) = '0') then -- sinon 
			seg3 <= "11111111"; --affichage vide sur le 3eme afficheur 7seg	
		end if;
		
		
		if(tempo_result(6 downto 0) = "0000000")then	   -- 0 -------------------------------------------
			seg1 <= "11000000";	
			seg2 <= "11000000";
		elsif(tempo_result(6 downto 0) = "0000001")then	-- 1
			seg1 <= "11111001";
			seg2 <= "11000000";
		elsif(tempo_result(6 downto 0) = "0000010")then	-- 2
			seg1 <= "10100100";
			seg2 <= "11000000";
		elsif(tempo_result(6 downto 0) = "0000011")then	-- 3
			seg1 <= "10110000";
			seg2 <= "11000000";
		elsif(tempo_result(6 downto 0) = "0000100")then	-- 4
			seg1 <= "10011001";
			seg2 <= "11000000";
		elsif(tempo_result(6 downto 0) = "0000101")then	-- 5
			seg1 <= "10010010";
			seg2 <= "11000000";
		elsif(tempo_result(6 downto 0) = "0000110")then	-- 6
			seg1 <= "10000010";
			seg2 <= "11000000";
		elsif(tempo_result(6 downto 0) = "0000111")then	-- 7
			seg1 <= "11111000";
			seg2 <= "11000000";
		elsif(tempo_result(6 downto 0) > "0000111")then
			seg1 <= "00000000";
			seg2 <= "00000000";
		

		end if; -- fin if
end process; -- fin process
	
	full_result <= shorten_result;
	
end behavioral;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
