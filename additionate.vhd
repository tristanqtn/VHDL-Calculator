library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity 1_bit_adder is
    port (  operande_1 : in std_logic := 0;
            operande_2 : in std_logic := 0;
            retenue_entree : in std_logic := 0;
            retenue_sortie : in std_logic := 0;
            somme : out std_logic := 0);
end 1_bit_adder;


architecture behavioral of 1_bit_adder is
begin
        somme <= (operande_1 xor operande_2) xor retenue; --calcul de la somme des deux opérandes
        retenue_sortie <= (operande_1 and(operande_2 or retenue_entree)) or (retenue_entree and operande_2); --calcul de la retenue de sortie de l'additionneur sur 1 bit
end behavioral;

--4 bit Adder Subtractor
entity 4_bit_adder is
   port(  operande_1, operande_2  : in std_logic_vector(3 downto 0);
          somme  : out std_logic_vector(3 downto 0));
end 4_bit_adder;
 
architecture struct of 4_bit_adder is

    signal tempo1, tempo2, tempo3, tempo4: std_logic;
 
begin

    bit0: entity work.1_bit_adder(behavioral)
        port map(operande_1(0), operande_2(0), 0, tempo1, somme(0)); 
    bit1: entity work.1_bit_adder(behavioral)
        port map(operande_1(1), operande_2(1), tempo1, tempo2,somme(1)); 
    bit2: entity work.1_bit_adder(behavioral)
        port map(operande_1(2), operande_2(2), tempo2, tempo3,somme(2)); 
    bit3: entity work.1_bit_adder(behavioral)
        port map(operande_1(3), operande_2(3), tempo3, tempo4,somme(3));

end struct
-- un test

entity 4_bit_subtractor is
    port(  operande_1, operande_2  : in std_logic_vector(3 downto 0);
            somme  : out std_logic_vector(3 downto 0));
end  4_bit_subtractor;
    
architecture struct of  4_bit_subtractor is

    signal tempo1, tempo2, tempo3, tempo4: std_logic;

begin

    bit0: entity work.1_bit_adder(behavioral)
        port map(operande_1(0), not(operande_2(0)), 0, tempo1, somme(0)); 
    bit1: entity work.1_bit_adder(behavioral)
        port map(operande_1(1), not(operande_2(1)), tempo1, tempo2,somme(1)); 
    bit2: entity work.1_bit_adder(behavioral)
        port map(operande_1(2), not(operande_2(2)), tempo2, tempo3,somme(2)); 
    bit3: entity work.1_bit_adder(behavioral)
        port map(operande_1(3), not(operande_2(3)), tempo3, tempo4,somme(3));


bit0: entity work.1_bit_adder(behavioral)
        port map(somme(0), 1, 0, tempo1, somme(0)); 
    bit1: entity work.1_bit_adder(behavioral)
        port map(somme(1), 0, tempo1, tempo2,somme(1)); 
    bit2: entity work.1_bit_adder(behavioral)
        port map(somme(2), 0, tempo2, tempo3,somme(2)); 
    bit3: entity work.1_bit_adder(behavioral)
        port map(somme(3), 0, tempo3, tempo4,somme(3));

end struct;
