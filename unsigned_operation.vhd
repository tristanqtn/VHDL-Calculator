------------------------------------------------------------------------------------------
--ADDITION NON SIGNEE---------------------------------------------------------------------
------------------------------------------------------------------------------------------
library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity un_addition is 
    port( operande_1, operande_2 : in std_logic_vector(3 downto 0);
			 full_result : out std_logic_vector (7 downto 0) );
end un_addition;

architecture  behavioral of un_addition is

    signal un_result : unsigned (7 downto 0);
    
begin

   un_result <= unsigned("0000" & operande_1) + unsigned("0000" & operande_2);
    
	full_result <= std_logic_vector(un_result (7 downto 0));
	 
end  behavioral;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------





------------------------------------------------------------------------------------------
--MULTIPLICATION NON SIGNEE---------------------------------------------------------------
------------------------------------------------------------------------------------------
library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity un_multiplication is 
    port( operande_1, operande_2 : in std_logic_vector(3 downto 0);
			 full_result : out std_logic_vector (7 downto 0) );
end un_multiplication;

architecture  behavioral of un_multiplication is

    signal un_result : unsigned (7 downto 0);
    
begin

   un_result <= unsigned(operande_1) * unsigned(operande_2);
    
	full_result <= std_logic_vector(un_result (7 downto 0));
	 
end  behavioral;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------




------------------------------------------------------------------------------------------
--DIVISION NON SIGNEE---------------------------------------------------------------------
------------------------------------------------------------------------------------------
library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity un_division is 
    port( operande_1, operande_2 : in std_logic_vector(3 downto 0);
			 full_result : out std_logic_vector (7 downto 0) );
end un_division;

architecture  behavioral of un_division is

    signal un_result : unsigned (7 downto 0);
    
begin

   un_result <= "00000000" when unsigned(operande_2) = "0000" else unsigned("0000" & operande_1) / unsigned("0000" & operande_2);
    
	full_result <= std_logic_vector(un_result (7 downto 0));
	 
end  behavioral;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------





------------------------------------------------------------------------------------------
--SOUSTRACTION NON SIGNEE-----------------------------------------------------------------
------------------------------------------------------------------------------------------
library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity un_soustraction is 
    port( operande_1, operande_2 : in std_logic_vector(3 downto 0);
			 full_result : out std_logic_vector (7 downto 0) );
end un_soustraction;

architecture  behavioral of un_soustraction is

    signal un_result : unsigned (7 downto 0);
    
begin

	un_result <= unsigned("0000" & operande_1) - unsigned("0000" & operande_2) when (unsigned(operande_1) >= unsigned(operande_2)) else "00000000";	
	 
	full_result <= std_logic_vector(un_result(7 downto 0));
	 
end  behavioral;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------






















































--LIBRAIRIE------------------------------------------------------------------------------
library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
--MULTIPLICATION NON SIGNEE---------------------------------------------------------------
------------------------------------------------------------------------------------------
entity sig_multiplication is 
    port( operande_1, operande_2 : in std_logic_vector (3 downto 0);
          result : out std_logic_vector (3 downto 0);
		  full_result : out std_logic_vector (7 downto 0);
		  overload : out std_logic);
end sig_multiplication;

architecture  behavioral of sig_multiplication is

    signal sig_result : unsigned (7 downto 0);
    
begin

    sig_result <= unsigned(operande_1) * unsigned(operande_2);
    
	full_result <= std_logic_vector(sig_result(7 downto 0));
	 
	result <= std_logic_vector(sig_result(3 downto 0));
	overload <= '0' when unsigned(sig_result(7 downto 4)) = "0000" else '1';
	 
end  behavioral; 
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
--ADDITION NON SIGNEE---------------------------------------------------------------------
------------------------------------------------------------------------------------------
entity sig_addition is 
    port( operande_1, operande_2 : in std_logic_vector (3 downto 0);
          result : out std_logic_vector (3 downto 0);
		  full_result : out std_logic_vector (7 downto 0);
		  overload : out std_logic);
end sig_addition;

architecture  behavioral of sig_addition is

    signal sig_result : unsigned (7 downto 0);
    
begin

    sig_result <= unsigned("0000" & operande_1) + unsigned("0000" &operande_2);
    
	full_result <= std_logic_vector(sig_result(7 downto 0));
	 
	result <= std_logic_vector(sig_result(3 downto 0));
	overload <= '0' when unsigned(sig_result(7 downto 4)) = "0000" else '1';
	 
end  behavioral; 
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
--SOUSTRACTION NON SIGNEE-----------------------------------------------------------------
------------------------------------------------------------------------------------------
entity sig_substraction is 
    port( operande_1, operande_2 : in std_logic_vector (3 downto 0);
          result : out std_logic_vector (3 downto 0);
		  full_result : out std_logic_vector (7 downto 0);
		  overload : out std_logic);
end sig_substraction;

architecture  behavioral of sig_substraction is

    signal sig_result : unsigned (7 downto 0);
    
begin

    sig_result <= unsigned("0000" & operande_1) - unsigned("0000" &operande_2);
    
	full_result <= std_logic_vector(sig_result(7 downto 0));
	 
	result <= std_logic_vector(sig_result(3 downto 0));
	overload <= '0' when unsigned(sig_result(7 downto 4)) = "0000" else '1';
	 
end  behavioral; 
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
--DIVISION NON SIGNEE---------------------------------------------------------------------
------------------------------------------------------------------------------------------
entity sig_division is 
    port( operande_1, operande_2 : in std_logic_vector (3 downto 0);
          result : out std_logic_vector (3 downto 0);
		  full_result : out std_logic_vector (7 downto 0);
		  overload : out std_logic);
end sig_division ;

architecture  behavioral of sig_division  is

    signal sig_result : unsigned (7 downto 0);
    
begin

    sig_result <= unsigned("0000" & operande_1) / unsigned("0000" & operande_2);
    
	full_result <= std_logic_vector(sig_result(7 downto 0));
	 
	result <= std_logic_vector(sig_result(3 downto 0));
	overload <= '0' when unsigned(sig_result(7 downto 4)) = "0000" else '1';
	 
end  behavioral; 
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------