-- LIBRAIRIES ----------------------------------------------------------------------------
LIBRARY IEEE;
USE work.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- ARCHITECTURE PRINCIPALE ---------------------------------------------------------------
------------------------------------------------------------------------------------------
ENTITY main_architecture IS
	PORT (
	
		--IN
		CLK_main : IN std_logic;
		signe_main, externe, reset : IN std_logic;
		reset_button_main : IN std_logic;
		type_operation : IN std_logic;
		operande_1_main, operande_2_main, lecture_externe : IN std_logic_vector (3 DOWNTO 0);
 
 
		--OUT
		final_overflow : OUT std_logic;
		pin_buzzer : OUT std_logic;
		led_off : OUT std_logic_vector (4 DOWNTO 0);
		final_result : OUT std_logic_vector (3 DOWNTO 0);
		seg1_main, seg2_main, seg3_main, seg4_main, seg5_main, seg6_main : OUT std_logic_vector (7 DOWNTO 0);
 
 
		--OPERATIONS EXTERNES
		extern_overflow_main : IN std_logic;

 
		extern_operande_1, extern_operande_2 : OUT std_logic_vector (3 DOWNTO 0) 
	);
END main_architecture;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
--DETAILS DE L'ARCHITECTURE PRINCIPALE ---------------------------------------------------
------------------------------------------------------------------------------------------
ARCHITECTURE behavioral OF main_architecture IS

	-- états de la machine à état
	TYPE state IS (op_un_in, op_si_in, op_un_ex, op_si_ex, empty);
	SIGNAL current_state, next_state : state;
 
	-- variables temporaire pour le transit des informations
	SIGNAL overflow_1, overflow_2, overflow_4, overflow_main, tempo : std_logic;
	SIGNAL result_1, result_2, result_3, result_4, result_main : std_logic_vector (3 DOWNTO 0);
 
	SIGNAL signal_extern_operande_1_1, signal_extern_operande_2_1, signal_extern_operande_1_2, signal_extern_operande_2_2 : std_logic_vector (3 DOWNTO 0);
 
BEGIN

	tempo <= '0'; -- a remplacer quand on basculera les entrées des switchs vers la télécommande
	led_off <= "00000"; --variable seulement utilisée pour éteindre les leds

	-- calcul interne non signe
	f1 : ENTITY un_operation
		PORT MAP(operande_1 => operande_1_main, operande_2 => operande_2_main, choix_op => type_operation, full_result => result_1, overflow => overflow_1);
 
	-- calcul interne signe
	f2 : ENTITY sig_operation
		PORT MAP(operande_1 => operande_1_main, operande_2 => operande_2_main, choix_op => type_operation, full_result => result_2, overflow => overflow_2);
 
	-- somme externe non signe
	f3 : ENTITY un_externe_somme
		PORT MAP(operande_1 => operande_1_main, operande_2 => operande_2_main, extern_result => lecture_externe, intern_result => result_3, operande_extern_1 => signal_extern_operande_1_1, operande_extern_2 => signal_extern_operande_2_1); 
 
	-- somme signee externe
	f4 : ENTITY sig_externe_somme
		PORT MAP(operande_1 => operande_1_main, operande_2 => operande_2_main, extern_result => lecture_externe, intern_result => result_4, operande_extern_1 => signal_extern_operande_1_2, operande_extern_2 => signal_extern_operande_2_2, overflow => overflow_4, extern_overflow => extern_overflow_main);
 
	-- affichage du résultat sur les 7segs
	f5 : ENTITY affichage
		PORT MAP(result => result_main, signe => signe_main, overflow => overflow_main, operande_1 => operande_1_main, operande_2 => operande_2_main, seg1 => seg1_main, seg2 => seg2_main, seg3 => seg3_main, seg4 => seg4_main, seg5 => seg5_main, seg6 => seg6_main);

	-- buzzer le resultat
	f6 : ENTITY buzzer
		PORT MAP(signe => signe_main, s => pin_buzzer, clk => CLK_main, button_reset => reset_button_main, resultat =>result_main);
		
	
 
	--------------------------------------------
	-- MACHINE A ETATS -------------------------
	PROCESS (reset, type_operation, signe_main, externe, operande_1_main, operande_2_main)
	BEGIN
		IF (reset = '0') THEN -- reset de la machine, mise à l'état "vide" ou rien ne se passe
			current_state <= empty;
 
		ELSIF ((signe_main = '0') AND (externe = '0')) THEN -- choix du résultat de l'opération interne non signee
			current_state <= op_un_in;
 
		ELSIF ((signe_main = '1') AND (externe = '0')) THEN -- choix du résultat de l'opération interne signee
			current_state <= op_si_in;
 
		ELSIF ((signe_main = '0') AND (externe = '1')) THEN -- choix du résultat de la somme externe non signee
			current_state <= op_un_ex;
 
		ELSIF ((signe_main = '1') AND (externe = '1')) THEN -- choix du résultat de la somme externe non signee
			current_state <= op_si_ex;
		END IF; -- fin if
 
	END PROCESS; -- fin process
 
 
	PROCESS (current_state)
	BEGIN
		CASE current_state IS

			-- opération interne non signee
			WHEN op_un_in => 
				result_main <= result_1; -- stockage du résultat dans le signal temporaire

				IF (overflow_1 = '1') THEN -- si le calcul rend une retenue
					overflow_main <= '1'; -- stockage de la retenue dans le signal temporaire
				ELSE -- sinon
					overflow_main <= '0';
				END IF;

				-- opération interne signee
			WHEN op_si_in => 
				result_main <= result_2; -- stockage du résultat dans le signal temporaire

				IF (overflow_2 = '1') THEN -- si le calcul rend une retenue
					overflow_main <= '1'; -- stockage de la retenue dans le signal temporaire
				ELSE -- sinon
					overflow_main <= '0';
				END IF;

				-- somme externe non signee 
			WHEN op_un_ex => 

				result_main <= result_3;
				extern_operande_1 <= signal_extern_operande_1_1;
				extern_operande_2 <= signal_extern_operande_2_1;

				IF (extern_overflow_main = '1') THEN -- si le calcul rend une retenue
					overflow_main <= '1'; -- stockage de la retenue dans le signal temporaire
				ELSE -- sinon
					overflow_main <= '0';
				END IF;

				--somme externe signée
			WHEN op_si_ex => 

				result_main <= result_4;
				extern_operande_1 <= signal_extern_operande_1_2;
				extern_operande_2 <= signal_extern_operande_2_2;

				IF (overflow_4 = '1') THEN-- si le calcul rend une retenue
					overflow_main <= '1';-- stockage de la retenue dans le signal temporaire
				ELSE--sinon
					overflow_main <= '0';
				END IF;

			WHEN empty => 
				result_main <= "0000";

		END CASE; -- fin case
	END PROCESS; -- fin process
	--------------------------------------------
	--------------------------------------------


--stockage final des résultats pour pouvoir ensuite les afficher
final_result <= result_main; -- resultat operation
final_overflow <= overflow_main; -- retenue

END behavioral;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------