-- LIBRAIRIES ----------------------------------------------------------------------------
library IEEE;
use work.all;
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
			 full_result : out std_logic_vector (3 downto 0) -- sortie de l'opération (8 bits)
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
	
	
	--sélection du résultat selon le type d'opération choisie
	WITH choix_op SELECT 

			un_result <= 	sum  when "00",
								mult when "10",
								sub  when "01",
								div  when "11";
			
   
	overflow <= '1' when un_result >"1111" else '0';
	
	--stockage du résultat dans la sortie de l'entitée
	full_result <= std_logic_vector(un_result (3 downto 0));
	

end behavioral;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------