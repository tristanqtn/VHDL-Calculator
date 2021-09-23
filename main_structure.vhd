-- LIBRAIRIES ----------------------------------------------------------------------------
library IEEE;
use work.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- ARCHITECTURE PRINCIPALE ---------------------------------------------------------------
------------------------------------------------------------------------------------------
entity main_architecture is
	port 
	( 	--IN
		signe_main, externe, reset : in std_logic;
		type_operation : in std_logic_vector (1 downto 0);
		operande_1_main, operande_2_main, lecture_externe : in std_logic_vector (3 downto 0);
	  
		--OUT
		final_overflow : out std_logic;
		led_off : out std_logic_vector (4 downto 0);
		final_result  : out std_logic_vector (3 downto 0);
		seg1_main, seg2_main, seg3_main : out std_logic_vector (7 downto 0)
	 
	);
end main_architecture;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
--DETAILS DE L'ARCHITECTURE PRINCIPALE ---------------------------------------------------
------------------------------------------------------------------------------------------
architecture behavioral of main_architecture is

	-- états de la machine à état
	type state is (op_un_in, op_si_in, op_un_ex,  empty);
	signal current_state, next_state : state;
	
	-- variables temporaire pour le transit des informations
	signal overflow_1, overflow_2, overflow_3, overflow_main, tempo : std_logic;
	signal result_1, result_2, result_3, result_main  : std_logic_vector (3 downto 0);

begin

	tempo <= '0'; -- a remplacer quand on basculera les entrées des switchs vers la télécommande
	led_off <= "00000"; --variable seulement utilisée pour éteindre les leds

	-- calcul interne non signe
	f1 : ENTITY un_operation PORT MAP(operande_1 => operande_1_main, operande_2 => operande_2_main, choix_op => type_operation,  full_result => result_1, overflow => overflow_1);
	
	-- calcul interne signe
	f2 : ENTITY sig_operation PORT MAP(operande_1 => operande_1_main, operande_2 => operande_2_main, choix_op => type_operation, full_result => result_2, overflow => overflow_2);
	
	-- somme externe non signe
	f3 : ENTITY un_extern_somme PORT MAP(operande_1 => operande_1_main, operande_2 => operande_2_main, extern_result => lecture_externe, intern_result => result_3, overflow => overflow_3);	
	
	-- affichage du résultat sur les 7segs
	f5 : ENTITY affichage PORT MAP(result => result_main, signe => signe_main, overflow => overflow_main, seg1 => seg1_main, seg2 => seg2_main, seg3 => seg3_main);

	
	--------------------------------------------
	-- MACHINE A ETATS -------------------------
	process(reset, type_operation, signe_main, externe, operande_1_main, operande_2_main)
	begin
	
		if(reset = '0') then -- reset de la machine, mise à l'état "vide" ou rien ne se passe 
			current_state <= empty;
		
		elsif ((signe_main = '1') and (tempo = '0')) then -- choix du résultat de l'opération interne non signee
			current_state <= op_un_in;
		
		elsif((signe_main = '0') and (tempo = '0')) then -- choix du résultat de l'opération interne signee
			current_state <= op_si_in;
		
		elsif((signe_main = '1') and (tempo = '1')) then -- choix du résultat de la somme externe non signee
			current_state <= op_un_ex;
		
		end if; -- fin if
	
	end process; -- fin process
	
	
	process(current_state)
	begin
	
		case current_state is
		
			-- opération interne non signee
			when op_un_in =>
				result_main <= result_1; -- stockage du résultat dans le signal temporaire
				
				if(overflow_1 = '1') then -- si le calcul rend une retenue
					overflow_main <= overflow_1; -- stockage de la retenue dans le signal temporaire
				else -- sinon
					overflow_main <= '0';
				end if;
			
			-- opération interne signee
			when op_si_in =>
				result_main <= result_2; -- stockage du résultat dans le signal temporaire
				
				if(overflow_2 = '1') then -- si le calcul rend une retenue
					overflow_main <= overflow_2; -- stockage de la retenue dans le signal temporaire
				else -- sinon
					overflow_main <= '0';
				end if;
			
			-- somme externe non signee 	
			when op_un_ex =>
				result_main <= result_3;
				
			if(overflow_3 = '1') then -- si le calcul rend une retenue
				overflow_main <= overflow_3; -- stockage de la retenue dans le signal temporaire
			else -- sinon
				overflow_main <= '0';
			end if;
				
			when empty =>
				result_main <= "0000";
				
		end case; -- fin case
	end process; -- fin process
	--------------------------------------------
	--------------------------------------------
	
	
	--stockage final des résultats pour pouvoir ensuite les afficher
	final_result <= result_main; -- resultat operation
	final_overflow <= overflow_main; -- retenue
	
end behavioral;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------