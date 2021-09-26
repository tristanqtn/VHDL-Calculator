-- LIBRAIRIES ----------------------------------------------------------------------------
LIBRARY ieee;
USE work.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- ENTITE BUZZER -------------------------------------------------------------------------
------------------------------------------------------------------------------------------
ENTITY buzzer IS
	PORT (
		resultat : IN std_logic_vector(3 DOWNTO 0);
		button_reset : IN std_logic; -- le bouton qui active le son
		clk : IN std_logic; -- horloge interne
		
		S : OUT std_logic; -- la sortie
 
		signe : IN std_logic
		
	); -- SIGNE
 
END buzzer;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- ARCHITECTURE BUZZER -------------------------------------------------------------------
------------------------------------------------------------------------------------------
ARCHITECTURE bhv OF buzzer IS

	SIGNAL compteur : unsigned(25 DOWNTO 0); -- compteur qui compte le nombre de cycles de la clock (//nb front montant)
	SIGNAL toggle : std_logic := '0'; -- toggle on/off pour la sortie
	SIGNAL diviseur : INTEGER; -- diviseur d'horloge, permet de sonner un
	SIGNAL compteur_temps : unsigned(25 DOWNTO 0); -- compteur pour faire sonner qu'une seconde le buzzer
 
	SIGNAL decompteur : INTEGER; -- le nombre de foi qu'on va devoir compter en horloge
 
	SIGNAL dc_unefoi : std_logic; -- pour bip le -
 
BEGIN
	PROCESS (clk, button_reset)
	BEGIN
		-- clock
 
		IF rising_edge(clk) THEN -- a chaque front montant
 
			--- si je reset avec le bouton (bouton a 0)
 
			IF button_reset = '0' THEN
 
				compteur <= (OTHERS => '0');
				compteur_temps <= (OTHERS => '0'); -- mettre les compteurs a 0
				dc_unefoi <= '1';
 
				----------------------------------------------- UNSIGNED -----------------------------------------------
 
				IF signe = '0' THEN
 
					-- case pour le decompteur de 0 a 15
 
					CASE resultat IS -- assigner une valeur pour le decompteur
 
						WHEN "0001" => decompteur <= 1;
						WHEN "0010" => decompteur <= 2;
						WHEN "0011" => decompteur <= 3;
						WHEN "0100" => decompteur <= 4;
						WHEN "0101" => decompteur <= 5;
						WHEN "0110" => decompteur <= 6;
						WHEN "0111" => decompteur <= 7;
						WHEN "1000" => decompteur <= 8;
						WHEN "1001" => decompteur <= 9;
						WHEN "1010" => decompteur <= 10;
						WHEN "1011" => decompteur <= 11;
						WHEN "1100" => decompteur <= 12;
						WHEN "1101" => decompteur <= 13;
						WHEN "1110" => decompteur <= 14;
						WHEN "1111" => decompteur <= 15;
						WHEN OTHERS => decompteur <= 0;
 
					END CASE;
 
					----------------------------------------------- SIGNED -----------------------------------------------
				ELSE
 
					CASE resultat IS
 
						WHEN "0001" => decompteur <= 1;
						WHEN "0010" => decompteur <= 2;
						WHEN "0011" => decompteur <= 3;
						WHEN "0100" => decompteur <= 4;
						WHEN "0101" => decompteur <= 5;
						WHEN "0110" => decompteur <= 6;
						WHEN "0111" => decompteur <= 7;
						WHEN "1001" => decompteur <= 1;
						WHEN "1010" => decompteur <= 2;
						WHEN "1011" => decompteur <= 3;
						WHEN "1100" => decompteur <= 4;
						WHEN "1101" => decompteur <= 5;
						WHEN "1110" => decompteur <= 6;
						WHEN "1111" => decompteur <= 7;
						WHEN OTHERS => decompteur <= 0;
					END CASE;
 
				END IF; 
 
			ELSE -- sinon, bipper pendant une seconde
 
				-- si signé et negatif
				IF signe = '1' AND resultat(3) = '1' THEN
					diviseur <= 125e3;
				ELSE
					diviseur <= 3125e1;
				END IF;
 
				-- sinon
 
				compteur <= compteur + 1; -- compteur augmente normalement
 
				compteur_temps <= compteur_temps + 1; -- compteur temps augment aussi
 
				IF compteur = diviseur AND compteur_temps < 10e6 AND decompteur > 0 THEN-- si le compteur atteint le diviseur et que le compteur de temps est < .2 seconde
 
					compteur <= (OTHERS => '0'); -- reset compteur pr continuer de compter
 
					IF (toggle = '0') THEN -- toggle le signal en sortie pr le buzzer
 
						toggle <= '1';
 
					ELSE
						toggle <= '0';
					END IF;
 
				ELSIF compteur_temps > 35e6 AND decompteur > 0 THEN -- passer a la prochaine cloche .5 secondes apres
 
					decompteur <= decompteur - 1; -- baisser le decompteur
					compteur_temps <= (OTHERS => '0'); -- reset le compteur temps
					compteur <= (OTHERS => '0'); -- reset le compteur
 
				END IF;
 
 
			END IF;
 
		END IF;
 
	END PROCESS;
 
	S <= toggle;

END bhv;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------