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
					
				led_off : out std_logic_vector(1 downto 0); -- variable permettant d'eteindre les leds en trop (2 bits)
				full_result : out std_logic_vector (7 downto 0); -- sortie de l'opération (8 bits)
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
	
	signal inverse_1, inverse_2, sum, tempo_result, c, sum_result, mult_result, div_result, mult_middle_result, div_middle_result : std_logic_vector (7 downto 0); -- signaux vectoriels pour les calculs
	
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
	led_off(1) <= '0';
	led_off(0) <= '0';
	
	-- SELECTION de la sortie selon le type d'opération
	WITH choix_op SELECT
		tempo_result <= sum_result  when "00", -- somme
							 "00000000"  when "01", -- opération inexistante
							 mult_result when "10", -- multiplication
							 div_result  when "11"; -- division
							
	full_result <= tempo_result; -- stockage du résultat dans un autre signal
						
	process(tempo_result) -- si modification de l'état du signal
	begin
		
		c <= tempo_result; -- stockage du résultat dans un autre signal			
		
		if(c(7) = '1')then	--negativité
			seg3 <= "10111111"; --affichage du signe moins
		elsif(c(7) = '0') then -- sinon 
			seg3 <= "11111111"; --affichage vide sur le 3eme afficheur 7seg	
		end if;
		
		
		if(c(6 downto 0) = "0000000")then	-- 0 -------------------------------------------
			seg1 <= "11000000";	
			seg2 <= "11000000";
		elsif(c(6 downto 0) = "0000001")then	-- 1
			seg1 <= "11111001";
			seg2 <= "11000000";
		elsif(c(6 downto 0) = "0000010")then	-- 2
			seg1 <= "10100100";
			seg2 <= "11000000";
		elsif(c(6 downto 0) = "0000011")then	-- 3
			seg1 <= "10110000";
			seg2 <= "11000000";
		elsif(c(6 downto 0) = "0000100")then	-- 4
			seg1 <= "10011001";
			seg2 <= "11000000";
		elsif(c(6 downto 0) = "0000101")then	-- 5
			seg1 <= "10010010";
			seg2 <= "11000000";
		elsif(c(6 downto 0) = "0000110")then	-- 6
			seg1 <= "10000010";
			seg2 <= "11000000";
		elsif(c(6 downto 0) = "0000111")then	-- 7
			seg1 <= "11111000";
			seg2 <= "11000000";
		elsif(c(6 downto 0) = "0001000")then	-- 8
			seg1 <= "10000000";
			seg2 <= "11000000";
		elsif(c(6 downto 0) = "0001001")then	-- 9
			seg1 <= "10010000";
			seg2 <= "11000000";
		elsif(c(6 downto 0) = "0001010")then	-- 0	 10 -------------------------------------------
			seg1 <= "11000000";	
			seg2 <= "11111001";
		elsif(c(6 downto 0) = "0001011")then	-- 1
			seg1 <= "11111001";
			seg2 <= "11111001";
		elsif(c(6 downto 0) = "0001100")then	-- 2
			seg1 <= "10100100";
			seg2 <= "11111001";
		elsif(c(6 downto 0) = "0001101")then	-- 3
			seg1 <= "10110000";
			seg2 <= "11111001";
		elsif(c(6 downto 0) = "0001110")then	-- 4
			seg1 <= "10011001";
			seg2 <= "11111001";
		elsif(c(6 downto 0) = "0001111")then	-- 5	
			seg1 <= "10010010";
			seg2 <= "11111001";
		elsif(c(6 downto 0) = "0010000")then	-- 6
			seg1 <= "10000010";
			seg2 <= "11111001";
		elsif(c(6 downto 0) = "0010001")then	-- 7
			seg1 <= "11111000";
			seg2 <= "11111001";
		elsif(c(6 downto 0) = "0010010")then	-- 8
			seg1 <= "10000000";
			seg2 <= "11111001";
		elsif(c(6 downto 0) = "0010011")then	-- 9
			seg1 <= "10010000";
			seg2 <= "11111001";
		elsif(c(6 downto 0) = "0010100")then	-- 0	20	-------------------------------------------
			seg1 <= "11000000";	
			seg2 <= "10100100";
		elsif(c(6 downto 0) = "0010101")then	-- 1
			seg1 <= "11111001";
			seg2 <= "10100100";
		elsif(c(6 downto 0) = "0010110")then	--2
			seg1 <= "10100100";
			seg2 <= "10100100";
		elsif(c(6 downto 0) = "0010111")then	-- 3
			seg1 <= "10110000";
			seg2 <= "10100100";
		elsif(c(6 downto 0) = "0011000")then	-- 4
			seg1 <= "10011001";
			seg2 <= "10100100";
		elsif(c(6 downto 0) = "0011001")then	-- 5
			seg1 <= "10010010";
			seg2 <= "10100100";
		elsif(c(6 downto 0) = "0011010")then	-- 6
			seg1 <= "10000010";
			seg2 <= "10100100";
		elsif(c(6 downto 0) = "0011011")then	-- 7
			seg1 <= "11111000";
			seg2 <= "10100100";
		elsif(c(6 downto 0) = "0011100")then	-- 8
			seg1 <= "10000000";
			seg2 <= "10100100";
		elsif(c(6 downto 0) = "0011101")then	-- 9
			seg1 <= "10010000";
			seg2 <= "10100100";
		elsif(c(6 downto 0) = "0011110")then	-- 0	30	-------------------------------------------	
			seg1 <= "11000000";	
			seg2 <= "10110000";
		elsif(c(6 downto 0) = "0011111")then	-- 1
			seg1 <= "11111001";
			seg2 <= "10110000";
		elsif(c(6 downto 0) = "0100000")then	-- 2
			seg1 <= "10100100";
			seg2 <= "10110000";
		elsif(c(6 downto 0) = "0100001")then	-- 3
			seg1 <= "10110000";
			seg2 <= "10110000";
		elsif(c(6 downto 0) = "0100010")then	-- 4
			seg1 <= "10011001";
			seg2 <= "10110000";
		elsif(c(6 downto 0) = "0100011")then	-- 5
			seg1 <= "10010010";
			seg2 <= "10110000";
		elsif(c(6 downto 0) = "0100100")then	-- 6
			seg1 <= "10000010";
			seg2 <= "10110000";
		elsif(c(6 downto 0) = "0100101")then	-- 7
			seg1 <= "11111000";
			seg2 <= "10110000";
		elsif(c(6 downto 0) = "0100110")then	-- 8
			seg1 <= "10000000";
			seg2 <= "10110000";
		elsif(c(6 downto 0) = "0100111")then	-- 9
			seg1 <= "10010000";
			seg2 <= "10110000";
		elsif(c(6 downto 0) = "0101000")then	-- 0	40	-------------------------------------------
			seg1 <= "11000000";	
			seg2 <= "10011001";
		elsif(c(6 downto 0) = "0101001")then	-- 1
			seg1 <= "11111001";
			seg2 <= "10011001";
		elsif(c(6 downto 0) = "0101010")then	-- 2
			seg1 <= "10100100";
			seg2 <= "10011001";
		elsif(c(6 downto 0) = "0101011")then	-- 3
			seg1 <= "10110000";
			seg2 <= "10011001";
		elsif(c(6 downto 0) = "0101100")then	-- 4
			seg1 <= "10011001";
			seg2 <= "10011001";
		elsif(c(6 downto 0) = "0101101")then	-- 5
			seg1 <= "10010010";
			seg2 <= "10011001";
		elsif(c(6 downto 0) = "101110")then	-- 6
			seg1 <= "10000010";
			seg2 <= "10011001";
		elsif(c(6 downto 0) = "101111")then	-- 7	
			seg1 <= "11111000";
			seg2 <= "10011001";
		elsif(c(6 downto 0) = "110000")then	-- 8
			seg1 <= "10000000";
			seg2 <= "10011001";
		elsif(c(6 downto 0) = "110001")then	-- 9
			seg1 <= "10010000";
			seg2 <= "10011001"; 
			
		end if; -- fin if
end process; -- fin process
	
end behavioral;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
