-- LIBRAIRIES ----------------------------------------------------------------------------
library IEEE;
use work.all;
use IEEE.STD_LOGIC_1164.ALL;
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
-- SOMME EXTERNE NON SIGNEE --------------------------------------------------------------
------------------------------------------------------------------------------------------
entity un_extern_somme is 
    port( 
			 --IN
			 overflow : in std_logic;
			 extern_result : in std_logic_vector(3 downto 0);
		    operande_1, operande_2 : in std_logic_vector(3 downto 0);
			 
			 --OUT
			 intern_result : out std_logic_vector(3 downto 0);
			 operande_extern_1, operande_extern_2 : out std_logic_vector(3 downto 0)
			 
		  );
		  
end un_extern_somme;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
-- ARCHITECTURE SOMME EXTERNE NON SIGNEE -------------------------------------------------
------------------------------------------------------------------------------------------
architecture behavioral of un_extern_somme is 

begin
	
	operande_extern_1 <= operande_1; -- sortie de l'operande sur les pins GPIO pour utiliser l'additionneur externe
	operande_extern_2 <= operande_2; -- sortie de l'operande sur les pins GPIO pour utiliser l'additionneur externe
	intern_result <= extern_result; -- envoie du résultat lu sur les GPIO en sortie de l'additionneur

end behavioral;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------