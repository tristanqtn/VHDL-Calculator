-- LIBRAIRIES ----------------------------------------------------------------------------
LIBRARY IEEE;
USE work.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
-- ENTITE AFFICHAGE ----------------------------------------------------------------------
------------------------------------------------------------------------------------------
ENTITY affichage IS
	PORT (
		signe, overflow : IN std_logic;
		result : IN std_logic_vector (3 DOWNTO 0);
 
		seg1, seg2, seg3 : OUT std_logic_vector(7 DOWNTO 0)
	);
END affichage;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
-- ARCHITECTURE AFFICHAGE ----------------------------------------------------------------
------------------------------------------------------------------------------------------
ARCHITECTURE behavioral OF affichage IS

	SIGNAL c : std_logic_vector(3 DOWNTO 0);

BEGIN
	PROCESS (result, signe, overflow) -- dès qu'un changment d'etat est repéré sur un_result
	BEGIN
		c <= result; --stockage du resulatat unsigned dnas le signal temporaire c
 
		--AFFICHAGE NON SIGNE
		IF (signe = '1') THEN
			seg3 <= "11111111";
 
			IF (overflow = '1') THEN -- overflow donc affichage ERROR
				seg3 <= "10000110";
				seg1 <= "10001000";
				seg2 <= "10001000";
 
			ELSIF (c = "0000") THEN -- 0 -------------------------------------------
				seg1 <= "11000000"; 
				seg2 <= "11000000";

			ELSIF (c = "0001") THEN -- 1
				seg1 <= "11111001";
				seg2 <= "11000000";

			ELSIF (c = "0010") THEN --2
				seg1 <= "10100100";
				seg2 <= "11000000";

			ELSIF (c = "0011") THEN -- 3
				seg1 <= "10110000";
				seg2 <= "11000000";

			ELSIF (c = "0100") THEN -- 4
				seg1 <= "10011001";
				seg2 <= "11000000";

			ELSIF (c = "0101") THEN -- 5
				seg1 <= "10010010";
				seg2 <= "11000000";

			ELSIF (c = "0110") THEN -- 6
				seg1 <= "10000010";
				seg2 <= "11000000";

			ELSIF (c = "0111") THEN -- 7
				seg1 <= "11111000";
				seg2 <= "11000000";

			ELSIF (c = "1000") THEN -- 8
				seg1 <= "10000000";
				seg2 <= "11000000";

			ELSIF (c = "1001") THEN -- 9
				seg1 <= "10010000";
				seg2 <= "11000000";

			ELSIF (c = "1010") THEN -- 0 10 -------------------------------------------
				seg1 <= "11000000"; 
				seg2 <= "11111001";

			ELSIF (c = "1011") THEN -- 1
				seg1 <= "11111001";
				seg2 <= "11111001";

			ELSIF (c = "1100") THEN -- 2
				seg1 <= "10100100";
				seg2 <= "11111001";

			ELSIF (c = "1101") THEN -- 3
				seg1 <= "10110000";
				seg2 <= "11111001";

			ELSIF (c = "1110") THEN -- 4
				seg1 <= "10011001";
				seg2 <= "11111001";

			ELSIF (c = "1111") THEN -- 5 
				seg1 <= "10010010";
				seg2 <= "11111001";
			END IF; -- fin du if
 
			--AFFICHAGE SIGNE
		ELSIF (signe = '0') THEN
 
			IF (c(3) = '1' AND overflow = '0') THEN --negativité
				seg3 <= "10111111"; --affichage du signe moins
			ELSIF (c(3) = '0') THEN -- sinon
				seg3 <= "11111111"; --affichage vide sur le 3eme afficheur 7seg 
			END IF;
 
			IF (overflow = '1') THEN -- overflow donc affichage ERROR
				seg3 <= "10000110";
				seg1 <= "10001000";
				seg2 <= "10001000";
 
			ELSIF (c(2 DOWNTO 0) = "000") THEN -- 0 -------------------------------------------
				seg1 <= "11000000"; 
				seg2 <= "11000000";
			ELSIF (c(2 DOWNTO 0) = "001") THEN -- 1
				seg1 <= "11111001";
				seg2 <= "11000000";
			ELSIF (c(2 DOWNTO 0) = "010") THEN -- 2
				seg1 <= "10100100";
				seg2 <= "11000000";
			ELSIF (c(2 DOWNTO 0) = "011") THEN -- 3
				seg1 <= "10110000";
				seg2 <= "11000000";
			ELSIF (c(2 DOWNTO 0) = "100") THEN -- 4
				seg1 <= "10011001";
				seg2 <= "11000000";
			ELSIF (c(2 DOWNTO 0) = "101") THEN -- 5
				seg1 <= "10010010";
				seg2 <= "11000000";
			ELSIF (c(2 DOWNTO 0) = "110") THEN -- 6
				seg1 <= "10000010";
				seg2 <= "11000000";
			ELSIF (c(2 DOWNTO 0) = "111") THEN -- 7
				seg1 <= "11111000";
				seg2 <= "11000000";

			END IF; -- fin if
			
		END IF; -- fin if
		
	END PROCESS; -- fin process
	
END behavioral;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------