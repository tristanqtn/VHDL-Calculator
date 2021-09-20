-- LIBRAIRIES ----------------------------------------------------------------------------
library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------
-- OPERATION NON SIGNEE ------------------------------------------------------------------
------------------------------------------------------------------------------------------
entity un_operation is 

    port( 
			 choix_op: in std_logic_vector (1 downto 0); -- choix du type d'opération à effectuer (2 bits)
		    operande_1, operande_2 : in std_logic_vector(3 downto 0); -- les deux opérandes reçues (4 bits)
			 
			 overflow : out std_logic; -- variable pour indication de resultat dépassant 4 bits (1 bit)
			 led_off : out std_logic_vector(4 downto 0); -- variable permettant d'eteindre les leds en trop (2 bits)
			 full_result : out std_logic_vector (3 downto 0); -- sortie de l'opération (8 bits)
			 seg1, seg2 : OUT std_logic_vector(7 downto 0) -- chaque variable correspond à un afficheur 7seg (8 bits)
		  );
		  
end un_operation; 
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
-- STRUCTURE OPERATION NON SIGNEE --------------------------------------------------------
------------------------------------------------------------------------------------------
architecture behavioral of un_operation is 

    signal un_result, sum, div, mult, sub, c : unsigned (7 downto 0); -- signaux utilisés pour les calculs 

begin

	sum <= unsigned("0000" & operande_1) + unsigned("0000" & operande_2); -- somme de deux vecteurs binaires non singés sur 4 bits 
	div <= "00000000" when unsigned(operande_2) = "0000" else (unsigned("0000" & operande_1) / unsigned("0000" & operande_2)); -- division euclidienne de deux vecteurs binaires non singés sur 4 bits si l'operande 2 n'est pas égale à 0000
	mult <= unsigned(operande_1) * unsigned(operande_2); -- multiplication de deux vecteurs binaires non singés sur 4 bits
	sub <= unsigned("0000" & operande_1) - unsigned("0000" & operande_2) when (unsigned(operande_1) >= unsigned(operande_2)) else "00000000"; -- différence dans les entiers naturels de deux vecteurs binaires non singés sur 4 bits
	
	--eteindre les leds inutilisées
	led_off<= "00000";
	
	
	--sélection du résultat selon le type d'opération choisie
	WITH choix_op SELECT 

			un_result <= 	sum  when "00",
								mult when "10",
								sub  when "01",
								div  when "11";
			
   
	overflow <= '1' when un_result >"1111" else '0';
	
	--stockage du résultat dans la sortie de l'entitée
	full_result <= std_logic_vector(un_result (3 downto 0));
	
	
	process(un_result) -- dès qu'un changment d'etat est repéré sur un_result
	begin
	
		c <= un_result; --stockage du resulatat unsigned dnas le signal temporaire c 
		
		
		if(c = "0000")then	-- 0 -------------------------------------------
			seg1 <= "11000000";	
			seg2 <= "11000000";

		elsif(c = "0001")then	-- 1
			seg1 <= "11111001";
			seg2 <= "11000000";

		elsif(c = "0010")then	--2
			seg1 <= "10100100";
			seg2 <= "11000000";

		elsif(c = "0011")then	-- 3
			seg1 <= "10110000";
			seg2 <= "11000000";

		elsif(c = "0100")then	-- 4
			seg1 <= "10011001";
			seg2 <= "11000000";

		elsif(c = "0101")then	-- 5
			seg1 <= "10010010";
			seg2 <= "11000000";

		elsif(c = "0110")then	-- 6
			seg1 <= "10000010";
			seg2 <= "11000000";

		elsif(c = "0111")then	-- 7
			seg1 <= "11111000";
			seg2 <= "11000000";

		elsif(c = "1000")then	-- 8
			seg1 <= "10000000";
			seg2 <= "11000000";

		elsif(c = "1001")then	-- 9
			seg1 <= "10010000";
			seg2 <= "11000000";

		elsif(c = "1010")then	-- 0	 10 -------------------------------------------
			seg1 <= "11000000";	
			seg2 <= "11111001";

		elsif(c = "1011")then	-- 1
			seg1 <= "11111001";
			seg2 <= "11111001";

		elsif(c = "1100")then	-- 2
			seg1 <= "10100100";
			seg2 <= "11111001";

		elsif(c = "1101")then	-- 3
			seg1 <= "10110000";
			seg2 <= "11111001";

		elsif(c = "1110")then	-- 4
			seg1 <= "10011001";
			seg2 <= "11111001";

		elsif(c = "1111")then	-- 5	
			seg1 <= "10010010";
			seg2 <= "11111001";

		elsif(c > "1111")then
			seg1 <= "00000000";
			seg2 <= "00000000";
		end if; -- fin du if
	end process; --fin du process

end behavioral;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
