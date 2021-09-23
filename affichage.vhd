-- LIBRAIRIES ----------------------------------------------------------------------------
library IEEE;
use work.all;
use IEEE.STD_LOGIC_1164.ALL;
------------------------------------------------------------------------------------------

entity affichage is
	port 
	(
		signe, overflow : in std_logic;
		result : in std_logic_vector (3 downto 0);
		
		seg1, seg2, seg3 : OUT std_logic_vector(7 downto 0)
	);
end affichage;


architecture behavioral of affichage is 

	signal c : std_logic_vector(3 downto 0);

begin 

	process(result, signe, overflow) -- dès qu'un changment d'etat est repéré sur un_result
	begin
	
		c <= result; --stockage du resulatat unsigned dnas le signal temporaire c 
		
		--AFFICHAGE NON SIGNE
		if(signe = '1') then
			seg3 <= "11111111";
			
			if(overflow = '1')then -- overflow donc affichage ERROR
				seg3 <= "10000110";
				seg1 <= "10001000";
				seg2 <= "10001000";
			
			elsif(c = "0000")then	-- 0 -------------------------------------------
				seg1 <= "11000000";	
				seg2 <= "11000000";

			elsif(c = "0001")then	-- 1
				seg1 <= "11111001";
				seg2 <= "11000000";

			elsif(c = "0010")then	--2
				seg1 <= "10100100";
				seg2 <= "11000000";

			elsif(c = "0011")then	-- 3
				seg1 <= "10110000";
				seg2 <= "11000000";

			elsif(c = "0100")then	-- 4
				seg1 <= "10011001";
				seg2 <= "11000000";

			elsif(c = "0101")then	-- 5
				seg1 <= "10010010";
				seg2 <= "11000000";

			elsif(c = "0110")then	-- 6
				seg1 <= "10000010";
				seg2 <= "11000000";

			elsif(c = "0111")then	-- 7
				seg1 <= "11111000";
				seg2 <= "11000000";

			elsif(c = "1000")then	-- 8
				seg1 <= "10000000";
				seg2 <= "11000000";

			elsif(c = "1001")then	-- 9
				seg1 <= "10010000";
				seg2 <= "11000000";

			elsif(c = "1010")then	-- 0	 10 -------------------------------------------
				seg1 <= "11000000";	
				seg2 <= "11111001";

			elsif(c = "1011")then	-- 1
				seg1 <= "11111001";
				seg2 <= "11111001";

			elsif(c = "1100")then	-- 2
				seg1 <= "10100100";
				seg2 <= "11111001";

			elsif(c = "1101")then	-- 3
				seg1 <= "10110000";
				seg2 <= "11111001";

			elsif(c = "1110")then	-- 4
				seg1 <= "10011001";
				seg2 <= "11111001";

			elsif(c = "1111")then	-- 5	
				seg1 <= "10010010";
				seg2 <= "11111001";
			end if; -- fin du if
		
		--AFFICHAGE SIGNE
		elsif(signe ='0') then
		
			if(c(3) = '1' and overflow = '0')then	--negativité
				seg3 <= "10111111"; --affichage du signe moins
			elsif(c(3) = '0') then -- sinon 
				seg3 <= "11111111"; --affichage vide sur le 3eme afficheur 7seg	
			end if;
			
			if(overflow = '1')then -- overflow donc affichage ERROR
				seg3 <= "10000110";
				seg1 <= "10001000";
				seg2 <= "10001000";
			
			elsif(c(2 downto 0) = "000")then	   -- 0 -------------------------------------------
				seg1 <= "11000000";	
				seg2 <= "11000000";
			elsif(c(2 downto 0) = "001")then	-- 1
				seg1 <= "11111001";
				seg2 <= "11000000";
			elsif(c(2 downto 0) = "010")then	-- 2
				seg1 <= "10100100";
				seg2 <= "11000000";
			elsif(c(2 downto 0) = "011")then	-- 3
				seg1 <= "10110000";
				seg2 <= "11000000";
			elsif(c(2 downto 0) = "100")then	-- 4
				seg1 <= "10011001";
				seg2 <= "11000000";
			elsif(c(2 downto 0) = "101")then	-- 5
				seg1 <= "10010010";
				seg2 <= "11000000";
			elsif(c(2 downto 0) = "110")then	-- 6
				seg1 <= "10000010";
				seg2 <= "11000000";
			elsif(c(2 downto 0) = "111")then	-- 7
				seg1 <= "11111000";
				seg2 <= "11000000";

			end if; -- fin if
		end if; -- fin if
end process; -- fin process


end behavioral;