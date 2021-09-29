-- LIBRAIRIES ----------------------------------------------------------------------------
LIBRARY IEEE;
USE work.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- OPERATION NON SIGNEE ------------------------------------------------------------------
------------------------------------------------------------------------------------------
ENTITY un_operation IS

	PORT (
		choix_op : IN std_logic; -- choix du type d'opération à effectuer (2 bits)
		operande_1, operande_2 : IN std_logic_vector(3 DOWNTO 0); -- les deux opérandes reçues (4 bits)
 
		overflow : OUT std_logic; -- variable pour indication de resultat dépassant 4 bits (1 bit)
		full_result : OUT std_logic_vector (3 DOWNTO 0) -- sortie de l'opération (8 bits)
	);
 
END un_operation;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
-- STRUCTURE OPERATION NON SIGNEE --------------------------------------------------------
------------------------------------------------------------------------------------------
ARCHITECTURE behavioral OF un_operation IS

	SIGNAL un_result, sum, div, mult, sub, c : unsigned (7 DOWNTO 0); -- signaux utilisés pour les calculs

BEGIN
	sum <= unsigned("0000" & operande_1) + unsigned("0000" & operande_2); -- somme de deux vecteurs binaires non singés sur 4 bits
	div <= "00000000" WHEN unsigned(operande_2) = "0000" ELSE (unsigned("0000" & operande_1) / unsigned("0000" & operande_2)); -- division euclidienne de deux vecteurs binaires non singés sur 4 bits si l'operande 2 n'est pas égale à 0000
	mult <= unsigned(operande_1) * unsigned(operande_2); -- multiplication de deux vecteurs binaires non singés sur 4 bits
	sub <= unsigned("0000" & operande_1) - unsigned("0000" & operande_2) WHEN (unsigned(operande_1) >= unsigned(operande_2)) ELSE "00000000"; -- différence dans les entiers naturels de deux vecteurs binaires non singés sur 4 bits
 
 
	--sélection du résultat selon le type d'opération choisie
	WITH choix_op SELECT

	un_result <= sum WHEN '0', 
	             mult WHEN '1';
 
 
	overflow <= '1' WHEN un_result > "1111" ELSE '0';
 
	--stockage du résultat dans la sortie de l'entitée
	full_result <= std_logic_vector(un_result (3 DOWNTO 0));
 

END behavioral;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------