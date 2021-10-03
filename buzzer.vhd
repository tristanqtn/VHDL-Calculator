-- LIBRAIRIES ----------------------------------------------------------------------------
LIBRARY ieee;
USE work.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BUZZER --------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
ENTITY buzzer IS
	PORT 
	(
		resultat     : IN std_logic_vector(3 DOWNTO 0); -- resultat recu sur 4 bits
 
		button_reset : IN std_logic; -- le bouton qui active le son
 
		clk          : IN std_logic; -- horloge interne a 10Mhz
 
		S            : OUT std_logic; -- la sortie vers le buzzer
 
		signe        : IN std_logic); -- le signe de l'operation
 
END buzzer;
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------
-- ARCHITECTURE DU BUZZER ------------------------------------------------------------------
--------------------------------------------------------------------------------------------
ARCHITECTURE bhv OF buzzer IS

	SIGNAL compteur       : integer; -- compteur qui compte le nombre de cycles de la clock (//nb front montant)
 
	SIGNAL toggle         : std_logic := '0'; -- bascule on/off pour la sortie
 
	SIGNAL diviseur       : INTEGER; -- "diviseur" d'horloge, permet de modifier la fréquence du son
 
	SIGNAL compteur_temps : integer; -- compteur pour faire sonner qu'une seconde le pendant un temps spécifique
 
	SIGNAL decompteur     : INTEGER; -- le nombre de foi qu'on va devoir sonner
 
BEGIN

	PROCESS (clk, button_reset)
	
	BEGIN
		-- clock
 
		IF rising_edge(clk) THEN -- a chaque front montant
 
			--- si je reset avec le bouton (bouton a 0)
 
			IF button_reset = '0' THEN
 
				compteur       <= 0;
				
				compteur_temps <= 0; -- mettre les compteurs a 0
  
				----------------------------------------------- UNSIGNED -----------------------------------------------
 
				IF signe = '0' THEN
 
 				decompteur <= 0;
 
					 case resultat is -- assigner une valeur pour le decompteur
					 
					 when "0001" => decompteur <= 1;
					 when "0010" => decompteur <= 2;
					 when "0011" => decompteur <= 3;
					 when "0100" => decompteur <= 4;
					 when "0101" => decompteur <= 5;
					 when "0110" => decompteur <= 6;
					 when "0111" => decompteur <= 7;
					 when "1000" => decompteur <= 8;
					 when "1001" => decompteur <= 9;
					 when "1010" => decompteur <= 10;
					 when "1011" => decompteur <= 11;
					 when "1100" => decompteur <= 12;
					 when "1101" => decompteur <= 13;
					 when "1110" => decompteur <= 14;
					 when "1111" => decompteur <= 15;
					 when others => decompteur <= 0;
					 
					 end case;
 
					----------------------------------------------- SIGNED -----------------------------------------------
				ELSE
				
				decompteur <= 0;
 
					 case resultat is
					 
					 when "0001" => decompteur <= 1;
					 when "0010" => decompteur <= 2;
					 when "0011" => decompteur <= 3;
					 when "0100" => decompteur <= 4;
					 when "0101" => decompteur <= 5;
					 when "0110" => decompteur <= 6;
					 when "0111" => decompteur <= 7;
					 when "1001" => decompteur <= 1;
					 when "1010" => decompteur <= 2;
					 when "1011" => decompteur <= 3;
					 when "1100" => decompteur <= 4;
					 when "1101" => decompteur <= 5;
					 when "1110" => decompteur <= 6;
					 when "1111" => decompteur <= 7;
					 when others => decompteur <= 0;
					 end case;
 
				END IF; 
 
			ELSE -- sinon, bipper pendant une seconde
 
				-- si signé et negatif
				
				IF signe = '1' AND resultat(3) = '1' THEN
				
					diviseur <= 25e3; -- valeur negative du diviseur, frequence de 200Hz
					
				ELSE
				
					diviseur <= 625e1; -- valeur positive du diviseur, frequence de 800Hz
					
				END IF;
  
				compteur  <= compteur + 1; -- compteur augmente normalement
 
				compteur_temps <= compteur_temps + 1; -- compteur temps augment aussi
 
				IF compteur = diviseur AND compteur_temps < 2e6 AND decompteur > 0 THEN-- si le compteur atteint le diviseur et que le compteur de temps est < .2 seconde
 
					compteur <= 0; -- reset compteur pr continuer de compter
 
					toggle   <= NOT toggle;
 
				ELSIF compteur_temps > 8e6 THEN -- passer a la prochaine cloche .5 secondes apres
 
					decompteur     <= decompteur - 1; -- baisser le decompteur
 
					compteur_temps <= 0; -- reset le compteur temps
 
					compteur       <= 0; -- reset le compteur
 
				END IF;
 
 
			END IF;
 
		END IF;
 
	END PROCESS;
 
	S <= toggle;

END bhv;
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
