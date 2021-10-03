-- LIBRAIRIES ----------------------------------------------------------------------------
LIBRARY IEEE;
USE work.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
-- SOMME EXTERNE NON SIGNEE --------------------------------------------------------------
------------------------------------------------------------------------------------------
ENTITY sig_externe_somme IS
	PORT (
		--IN
		extern_overflow : IN std_logic;
		extern_result : IN std_logic_vector(3 DOWNTO 0);
		operande_1, operande_2 : IN std_logic_vector(3 DOWNTO 0);

		--OUT
		overflow : OUT std_logic;
		intern_result : OUT std_logic_vector(3 DOWNTO 0);
		operande_extern_1, operande_extern_2 : OUT std_logic_vector(3 DOWNTO 0)
		
	);

END sig_externe_somme;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
ARCHITECTURE behavioral OF sig_externe_somme IS

	SIGNAL inverse_1, inverse_2, tempo_result, temp : std_logic_vector(3 DOWNTO 0); -- signaux vectoriels pour les calculs
	
BEGIN
	-- SOMME
	inverse_1 <= std_logic_vector(0 - unsigned('0' & operande_1 (2 DOWNTO 0))) WHEN operande_1(3) = '1' ELSE
	             operande_1; -- inversion de l'opérande 1 si le MSB = 1
	inverse_2 <= std_logic_vector(0 - unsigned('0' & operande_2 (2 DOWNTO 0))) WHEN operande_2(3) = '1' ELSE operande_2; -- inversion de l'opérande 2 si le MSB = 1

	tempo_result <= extern_result;

	PROCESS (operande_1, operande_2, extern_result)
	BEGIN
		IF (operande_1(3) = '0' AND operande_2(3) = '0') THEN
			temp <= '0' & tempo_result(2 DOWNTO 0);
			operande_extern_1 <= operande_1; -- sortie de l'operande sur les pins GPIO pour utiliser l'additionneur externe
			operande_extern_2 <= operande_2; -- sortie de l'operande sur les pins GPIO pour utiliser l'additionneur externe

			IF (tempo_result(3) = '1') THEN
				overflow <= '1';
			ELSE
				overflow <= '0';
			END IF;
			
		ELSIF (operande_1(3) = '1' AND operande_2(3) = '1') THEN
			temp <= '1' & tempo_result(2 DOWNTO 0);
			IF (tempo_result(3) = '1') THEN
				overflow <= '1';
			ELSE
				overflow <= '0';
			END IF;

			operande_extern_1 <= operande_1; -- sortie de l'operande sur les pins GPIO pour utiliser l'additionneur externe
			operande_extern_2 <= operande_2; -- sortie de l'operande sur les pins GPIO pour utiliser l'additionneur externe

			
		ELSE
		
			IF(extern_overflow = '1' AND (operande_1(2 DOWNTO 0) /= operande_2(2 DOWNTO 0))) THEN
				temp <= tempo_result;
			ELSE
				temp <= std_logic_vector(0 - unsigned('0' & tempo_result (2 DOWNTO 0)));
			END IF;
			
			operande_extern_1 <= inverse_1; -- sortie de l'operande sur les pins GPIO pour utiliser l'additionneur externe
			operande_extern_2 <= inverse_2; -- sortie de l'operande sur les pins GPIO pour utiliser l'additionneur externe

			overflow <= '0';
		
		END IF; 
	END PROCESS;

	intern_result <= temp;
 

END behavioral;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------