-- LIBRAIRIES ----------------------------------------------------------------------------
LIBRARY IEEE;
USE work.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- ARCHITECTURE PRINCIPALE ---------------------------------------------------------------
------------------------------------------------------------------------------------------
ENTITY architecture_principale IS

	PORT (
		bouton_signe, bouton_non_signe : IN std_logic;
		choix_op_main : IN std_logic_vector (1 DOWNTO 0); -- choix du type d'opération à effectuer (2 bits)
		operande_1_main, operande_2_main : IN std_logic_vector (3 DOWNTO 0); -- les deux opérandes reçues (4 bits)
 
		led_off : OUT std_logic_vector(4 DOWNTO 0);
		led_signe : OUT std_logic;
		led_op : OUT std_logic_vector(3 DOWNTO 0);
		final_result_main : OUT std_logic_vector (7 DOWNTO 0); -- sortie de l'opération (8 bits)
		seg1_main, seg2_main, seg3_main, seg4_main : OUT std_logic_vector(7 DOWNTO 0) -- chaque variable correspond à un afficheur 7seg (8 bits)
 
	);
 
END architecture_principale;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
-- DETAILS ARCHITECTURE ------------------------------------------------------------------
------------------------------------------------------------------------------------------

ARCHITECTURE bhv OF architecture_principale IS
 
	SIGNAL signe_main : std_logic;
	SIGNAL signed_result, unsigned_result, display_result_main : std_logic_vector(7 DOWNTO 0);
 
	-- états de la machine à état
	TYPE state IS (op_un, op_si, empty);
	SIGNAL current_state, next_state : state;
 
BEGIN
	f1 : ENTITY sig_operation
		PORT MAP(operande_1 => operande_1_main, operande_2 => operande_2_main, choix_op => choix_op_main, full_result => signed_result);
 
	f2 : ENTITY un_operation
		PORT MAP(operande_1 => operande_1_main, operande_2 => operande_2_main, choix_op => choix_op_main, full_result => unsigned_result);
 
	f3 : ENTITY affichage
			PORT MAP(seg1 => seg1_main, seg2 => seg2_main, seg3 => seg3_main, seg4 => seg4_main, resultat => display_result_main, signe => signe_main);

				led_off <= "00000";
				led_signe <= signe_main;
				led_op <= "0001" WHEN choix_op_main = "00" ELSE 
				          "0010" WHEN choix_op_main = "01" ELSE
				          "0100" WHEN choix_op_main = "10" ELSE
				          "1000" WHEN choix_op_main = "11";
 
	--------------------------------------------
	-- MACHINE A ETATS -------------------------
	
	PROCESS (choix_op_main, signe_main, operande_1_main, operande_2_main)
	BEGIN
		IF (bouton_signe = '0' AND bouton_non_signe = '1') THEN -- choix du résultat de l'opération interne non signee
			current_state <= op_si;
			signe_main <= '1';
 

		ELSIF (bouton_signe = '1' AND bouton_non_signe = '0') THEN -- choix du résultat de l'opération interne signee
			current_state <= op_un;
			signe_main <= '0';
 
		END IF; -- fin if
	END PROCESS; -- fin process
	
	
	PROCESS (current_state)
		BEGIN
			CASE current_state IS

				-- opération interne non signee
				WHEN op_un => 
					final_result_main <= unsigned_result; -- stockage du résultat dans le signal temporaire
					display_result_main <= unsigned_result;
 
					-- opération interne signee
				WHEN op_si => 
					final_result_main <= signed_result; -- stockage du résultat dans le signal temporaire
					display_result_main <= signed_result;

				WHEN empty => 
					final_result_main <= "00000000";
					display_result_main <= "00000000";
 
			END CASE; -- fin case
	END PROCESS; -- fin process
	--------------------------------------------
	--------------------------------------------

	END bhv;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------