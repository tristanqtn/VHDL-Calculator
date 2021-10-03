-- LIBRAIRIES ----------------------------------------------------------------------------
LIBRARY IEEE;
USE work.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
-- OPERATION SIGNEE ----------------------------------------------------------------------
------------------------------------------------------------------------------------------
ENTITY sig_operation IS

	PORT (
		choix_op : IN std_logic_vector (1 DOWNTO 0); -- choix du type d'opération à effectuer (2 bits)
		operande_1, operande_2 : IN std_logic_vector (3 DOWNTO 0); -- les deux opérandes reçues (4 bits)
 
 
		full_result : OUT std_logic_vector (7 DOWNTO 0) -- sortie de l'opération (8 bits) 
	);
 
END sig_operation;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
-- STRUCTURE OPERATION SIGNEE ------------------------------------------------------------
------------------------------------------------------------------------------------------
ARCHITECTURE behavioral OF sig_operation IS

	SIGNAL MSB_result : std_logic; -- signal pour les calculs
 
	SIGNAL inverse_1, inverse_2, sum, tempo_result, c, sum_result, mult_result, div_result, mult_middle_result, div_middle_result : std_logic_vector (7 DOWNTO 0); -- signaux vectoriels pour les calculs
 
BEGIN
	MSB_result <= operande_1(3) XOR operande_2(3); -- calcul du signe de la multiplication/divison selon les règles arithmétiques
 
	-- MULTIPLICATION
	mult_middle_result <= "00" & (operande_1(2 DOWNTO 0) * operande_2(2 DOWNTO 0)); -- multiplication des 2 operande sans le MSB
	mult_result <= std_logic_vector(MSB_result & mult_middle_result(6 DOWNTO 0)); -- concaténation du sogne (MSB) et du résultat de la multiplication
 
	-- SOMME
	inverse_1 <= std_logic_vector(0 - unsigned("00000" & operande_1 (2 DOWNTO 0))) WHEN operande_1(3) = '1' ELSE "0000" & operande_1; -- inversion de l'opérande 1 si le MSB = 1
	inverse_2 <= std_logic_vector(0 - unsigned("00000" & operande_2 (2 DOWNTO 0))) WHEN operande_2(3) = '1' ELSE "0000" & operande_2; -- inversion de l'opérande 2 si le MSB = 1
 
	sum <= std_logic_vector (unsigned(inverse_1) + unsigned(inverse_2)); -- somme des deux valeurs absolues
	sum_result <= std_logic_vector(0 - unsigned('0' & sum (6 DOWNTO 0))) WHEN sum(7) = '1' ELSE
	              sum; -- si le résultat est négatif on fait le complément à 2 pour retrouver la bonne valeur
 
	-- DIVISION
	div_middle_result <= "00000000" WHEN unsigned(operande_2 (2 DOWNTO 0)) = "000" ELSE std_logic_vector(unsigned("00000" & operande_1(2 DOWNTO 0)) / unsigned("00000" & operande_2(2 DOWNTO 0))); -- division euclidiènne des deux opérande si l'opérande 2 différente de 00000000
	div_result <= std_logic_vector(MSB_result & div_middle_result(6 DOWNTO 0)); -- concaténation du signe (MSB) et du résultat de la division euclidiènne
 
	-- SELECTION de la sortie selon le type d'opération
	WITH choix_op SELECT
	tempo_result <= sum_result WHEN "00", -- somme
	                "00000000" WHEN "01", -- opération inexistante
	                mult_result WHEN "10", -- multiplication
	                div_result WHEN "11"; -- division
 
	full_result <= tempo_result; -- stockage du résultat dans un autre signal

 
END behavioral;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------