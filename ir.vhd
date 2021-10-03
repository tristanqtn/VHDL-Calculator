-- LIBRAIRIES ----------------------------------------------------------------------------
LIBRARY IEEE;
USE work.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
--  ENTITE DE RECEPTION DU SIGNAL IR -----------------------------------------------------
------------------------------------------------------------------------------------------
ENTITY nec_receiver IS
	GENERIC (
		-- number of clocks for the leader code_on signal (assume 50MHZ clock)
		LC_on_max : INTEGER := 450000
	);
	PORT (
		-- outputs to the 6 7-segment displays. The remote control
		-- outputs 32 bits of binary data (each byte display as
		-- 2 7-segment displays)
	
		-- IN
		-- clock, data input, and system reset
		clk : IN std_logic;
		data_in : IN std_logic;
		bouton_signe : IN std_logic; -- bouton pour passer en signé
		bouton_reset : IN std_logic; -- reset avec bouton
						
		--OUT
		signe : OUT std_logic; -- signé ou non signé
		rd_data : OUT std_logic;
		operateur : OUT std_logic; -- addition ou multiplication
		op_a : OUT std_logic_vector (3 DOWNTO 0); -- operande a a receptionner
		op_b : OUT std_logic_vector (3 DOWNTO 0) -- operande b a receptionner 

 
	);
END nec_receiver;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------
--  ARCHITECTURE IR ----------------------------------------------------------------------
------------------------------------------------------------------------------------------
ARCHITECTURE bvh OF nec_receiver IS

	SIGNAL reset : std_logic; -- faire un signal reset

	SIGNAL partie_1 : std_logic_vector(3 DOWNTO 0); -- operande a

	SIGNAL partie_2 : std_logic_vector(3 DOWNTO 0); -- operande 2

	SIGNAL nb_etapes : INTEGER;

	SIGNAL partie_op : std_logic;

	SIGNAL partie_signe : std_logic;

	SIGNAL A_neg, B_neg : std_logic;

	-- pour savoir a quelle etape on est



	----------------------------------------------------------------------------------- 
	----------------------------------------------------------------------------------- 

	-- leader code off duration
	-- lengths of symbols '1' and '0'
	-- length of transition time (error)
	CONSTANT LC_off_max : INTEGER := LC_on_max/2;
	CONSTANT one_clocks : INTEGER := LC_on_max/4;
	CONSTANT zero_clocks : INTEGER := LC_on_max/8; 
	CONSTANT trans_max : INTEGER := LC_on_max/50;
	CONSTANT LC_off_repeat_max : INTEGER := LC_off_max/2;

	------------------------------------------------------------------
	CONSTANT max_bits : INTEGER := 32;
	-- counter for measuring the duration of the leader code-on signal
	SIGNAL reading_LC_on : std_logic := '0';
	SIGNAL LC_on_counter : INTEGER RANGE 0 TO LC_on_max + trans_max;
	-- counter for measuring the duration of the leader code-off signal
	SIGNAL reading_LC_off : std_logic := '0';
	SIGNAL LC_off_counter : INTEGER RANGE 0 TO LC_off_max + trans_max;
	-- counter for measuring the duration of the data signal
	SIGNAL reading_data : std_logic := '0';
	SIGNAL clock_counter : INTEGER RANGE 0 TO one_clocks + trans_max;
	SIGNAL checking_data : std_logic := '0';
	-- signal which determine the bit that is communicated
	SIGNAL data_bit : std_logic := '0';

	-- counter to keep track of the number of bits transmitted
	SIGNAL data_counter : INTEGER := 0;
	-- signals for edge detection circuitry
	SIGNAL data : std_logic;
	SIGNAL data_follow : std_logic;
	SIGNAL pos_edge : std_logic;
	-- shift register which holds the transmitted bits
	SIGNAL shift_reg : std_logic_vector(max_bits - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL data_reg : std_logic_vector(max_bits - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL temp : std_logic_vector(max_bits - 1 DOWNTO 0) := (OTHERS => '0');

	-- state machine signals
	TYPE state_type IS (init, read_LC_on, check_LC_on_count, read_LC_off, 
	check_LC_off_count, read_data, check_data);
	SIGNAL state, nxt_state : state_type;

	-- The code is divided into different process: (i) LED process (ii) 7 Segment display (iii)State machine process
	-- LED signals
	SIGNAL command : std_logic_vector(7 DOWNTO 0);
	SIGNAL dt_rdy : std_logic := '0'; -- Data ready
	SIGNAL LG_reg : std_logic_vector(7 DOWNTO 0); -- Red LEDs

BEGIN
	-- state machine processes
	-- Defining clock
	state_proc : PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (reset = '0') THEN
				state <= init; -- Based on the assignment sheet
			ELSE
				state <= nxt_state;
			END IF;
		END IF;
	END PROCESS state_proc;
	nxt_state_proc : PROCESS (state, pos_edge, data, LC_on_counter, LC_off_counter, clock_counter, data_counter)
	BEGIN
		nxt_state <= state;-- Initialization of the various states
		reading_LC_on <= '0';
		reading_LC_off <= '0'; 
		reading_data <= '0'; 
		checking_data <= '0';
 
		--- The entire state machine was developed based
		--- on the details given in the assignment
		--- Nothing new was added
		CASE state IS
			WHEN init => 
				IF (data = '0') THEN
					nxt_state <= read_LC_on;
				ELSE
					nxt_state <= init;
				END IF;
			WHEN read_LC_on => 
				reading_LC_on <= '1';
				IF (pos_edge = '1') THEN
					nxt_state <= check_LC_on_count;
				ELSE
					nxt_state <= read_LC_on;
				END IF;
			WHEN check_LC_on_count => 
				IF ((LC_on_counter < LC_on_max + trans_max) AND (LC_on_counter > LC_on_max - trans_max)) THEN
					nxt_state <= read_LC_off;
				ELSE
					nxt_state <= init;
				END IF;
			WHEN read_LC_off => 
				reading_LC_off <= '1';
				IF (data = '0') THEN
					nxt_state <= check_LC_off_count;
				ELSE
					nxt_state <= read_LC_off;
				END IF;
			WHEN check_LC_off_count => 
				IF ((LC_off_counter < LC_off_max + trans_max) AND (LC_off_counter > LC_off_max - trans_max)) THEN
					nxt_state <= read_data;
				ELSIF ((LC_off_counter < LC_off_repeat_max + trans_max) AND (LC_off_counter > LC_off_repeat_max - trans_max)) THEN
					nxt_state <= init;
				ELSE
					nxt_state <= init;
				END IF;
			WHEN read_data => 
				reading_data <= '1';
				IF (pos_edge = '1') THEN
					nxt_state <= check_data;
				ELSE
					nxt_state <= read_data;
				END IF; 
			WHEN check_data => 
				checking_data <= '1';
				IF (data_counter /= (max_bits - 1)) THEN -- check data_counter for 32bits
					nxt_state <= read_data;
				ELSE
					nxt_state <= init;
				END IF;
 
			WHEN OTHERS => 
				nxt_state <= init;
		END CASE; 
	END PROCESS nxt_state_proc;
 
 
	-- Pulse detection circuitry
	pos_edge <= data AND data_follow;
	----------------------------------------------------------------------------------- 
	pos_edge_proc : PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (reset = '0') THEN
				data <= '0';
				data_follow <= '0';
			ELSE
				data <= data_in;
				data_follow <= NOT data;
			END IF;
		END IF;
	END PROCESS pos_edge_proc; 
	------------------------------------------------------------------------------------ 
 
 
	LC_on_counter_proc : PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF ((reset = '0') OR (LC_on_counter = LC_on_max + trans_max)) THEN
				LC_on_counter <= 0;
			ELSIF (reading_LC_on = '1') THEN
				LC_on_counter <= LC_on_counter + 1;
			ELSE
				LC_on_counter <= 0;
			END IF;
		END IF;
	END PROCESS LC_on_counter_proc; 
	------------------------------------------------------------------------------------ 
	-- LC_off counter
	-- Based on the state machine
	-- Either reset or in the buffer mode (2% tolerance)
	LC_off_counter_proc : PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF ((reset = '0') OR(LC_off_counter = LC_off_max + trans_max)) THEN
				LC_off_counter <= 0;
			ELSIF (reading_LC_off = '1') THEN
				LC_off_counter <= LC_off_counter + 1;
			ELSE
				LC_off_counter <= 0;
			END IF;
		END IF;
	END PROCESS LC_off_counter_proc; 
	------------------------------------------------------------------------------------ 
 
	-- clock counter can be written as process :
	cc_proc : PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF ((reset = '0') OR (clock_counter = one_clocks + trans_max) OR checking_data = '1') THEN
				clock_counter <= 0;
			ELSIF (reading_data = '1') THEN
				clock_counter <= clock_counter + 1;
			ELSE
				clock_counter <= 0;
			END IF;
		END IF;
	END PROCESS cc_proc;
	------------------------------------------------------------------------------------- 
	--To find the nature of the bit that is transmitted
	rd_data <= data_bit; 
	------------------------------------------------------------------------------------- 
	data_bit_proc : PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (reset = '0') THEN
				data_bit <= '0';
			ELSIF (checking_data = '1') THEN
				IF ((clock_counter < one_clocks + trans_max) AND (clock_counter > one_clocks - trans_max)) THEN
					data_bit <= '1'; 
				ELSIF ((clock_counter < zero_clocks + trans_max) AND (clock_counter > zero_clocks - trans_max)) THEN
					data_bit <= '0';
				END IF; 
			END IF;
		END IF;
	END PROCESS data_bit_proc;
	------------------------------------------------------------------------------------- 
	-- data counter process
	dc_proc : PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (reset = '0' OR data_counter = max_bits) THEN
				data_counter <= 0;
			ELSIF (checking_data = '1') THEN
				data_counter <= data_counter + 1;
			END IF;
		END IF;
	END PROCESS dc_proc;
 
	--This is the process to allow the shift register:
	shift_proc : PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (reset = '0') THEN
				shift_reg <= (OTHERS => '0');
			ELSIF (clock_counter = 0 AND data_counter /= (max_bits - 1)) THEN
				shift_reg <= data_bit & shift_reg(max_bits - 1 DOWNTO 1);
			END IF;
		END IF;
	END PROCESS shift_proc; 

	------------------------------------------------------------------------------------ 
	--final check and store 32 bits data, data reg process
	dr_reg_proc : PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (reset = '0') THEN
				data_reg <= (OTHERS => '0');
				temp <= (OTHERS => '0');
			ELSIF (data_counter = max_bits) THEN
				data_reg <= shift_reg(1 DOWNTO 0) & shift_reg(max_bits - 1 DOWNTO 2);
 
				dt_rdy <= '1'; 
 
			ELSE
				dt_rdy <= '0'; 
			END IF;
		END IF;
	END PROCESS dr_reg_proc; 
 
	--- Command Discrimination and Execution
	command <= data_reg(23 DOWNTO 16);-- be carreful this allow to display "00" or "01"

	----------------------------------- 
	initial_proc : PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (reset = '0') THEN
				LG_reg <= (OTHERS => '0');
			END IF;
		END IF;
	END PROCESS initial_proc; 
 
	----------------------------------------------------------------------------------- 
	----------------------------------------------------------------------------------- 

	-- envoyer les infos aux sorties
 

 
	PROCESS (bouton_reset, nb_etapes, bouton_signe)
 
		BEGIN
			reset <= '1';
 
 
			IF bouton_signe = '0' THEN -- passer en signé quand on appuie sur un bouton
				partie_signe <= '1'; -- on passe en signé
			END IF;

 
 
 
 
			----------------------------------------------------------------------------------------------------------------------------------
			------------------------------------------------------ ASSIGNER LES VALEURS ------------------------------------------------------
			----------------------------------------------------------------------------------------------------------------------------------
			IF nb_etapes = 0 THEN -- si on affecte operande_a
 
				IF partie_signe = '1' THEN -- si on est en signé
 
					CASE command IS
 
						WHEN x"2d" => partie_1 <= "0000";
						nb_etapes <= 1; -- op_a = 0
						WHEN x"19" => partie_1 <= "0001";
						nb_etapes <= 1; -- op_a = 1
						WHEN x"31" => partie_1 <= "0010";
						nb_etapes <= 1; -- op_a = 2
						WHEN x"bd" => partie_1 <= "0011";
						nb_etapes <= 1; -- op_a = 3
						WHEN x"11" => partie_1 <= "0100";
						nb_etapes <= 1; -- op_a = 4
						WHEN x"39" => partie_1 <= "0101";
						nb_etapes <= 1; -- op_a = 5
						WHEN x"b5" => partie_1 <= "0110";
						nb_etapes <= 1; -- op_a = 6
						WHEN x"85" => partie_1 <= "0111";
						nb_etapes <= 1; -- op_a = 7
						WHEN x"a5" => partie_1 <= "0111";
						nb_etapes <= 1; -- op_a = 7
						WHEN x"95" => partie_1 <= "0111";
						nb_etapes <= 1; -- op_a = 7
						WHEN x"8b" => partie_1 <= "0111";
						nb_etapes <= 1; -- op_a = 7
						WHEN x"8d" => partie_1 <= "0111";
						nb_etapes <= 1; -- op_a = 7
						WHEN x"8f" => partie_1 <= "0111";
						nb_etapes <= 1; -- op_a = 7
						WHEN x"89" => partie_1 <= "0111";
						nb_etapes <= 1; -- op_a = 7
						WHEN x"81" => partie_1 <= "0111";
						nb_etapes <= 1; -- op_a = 7
						WHEN x"87" => partie_1 <= "0111";
						nb_etapes <= 1; -- op_a = 7
						WHEN x"0f" => A_neg <= '1'; -- mettre a negatif
						WHEN OTHERS => nb_etapes <= 0; -- sinon, rester a 0 
 
					END CASE; 
				ELSE
 
 
					CASE command IS
 
						WHEN x"2d" => partie_1 <= "0000";
						nb_etapes <= 1; -- op_a = 0
						WHEN x"19" => partie_1 <= "0001";
						nb_etapes <= 1; -- op_a = 1
						WHEN x"31" => partie_1 <= "0010";
						nb_etapes <= 1; -- op_a = 2
						WHEN x"bd" => partie_1 <= "0011";
						nb_etapes <= 1; -- op_a = 3
						WHEN x"11" => partie_1 <= "0100";
						nb_etapes <= 1; -- op_a = 4
						WHEN x"39" => partie_1 <= "0101";
						nb_etapes <= 1; -- op_a = 5
						WHEN x"b5" => partie_1 <= "0110";
						nb_etapes <= 1; -- op_a = 6
						WHEN x"85" => partie_1 <= "0111";
						nb_etapes <= 1; -- op_a = 7
						WHEN x"a5" => partie_1 <= "1000";
						nb_etapes <= 1; -- op_a = 8
						WHEN x"95" => partie_1 <= "1001";
						nb_etapes <= 1; -- op_a = 9
						WHEN x"8b" => partie_1 <= "1010";
						nb_etapes <= 1; -- op_a = 10
						WHEN x"8d" => partie_1 <= "1011";
						nb_etapes <= 1; -- op_a = 11
						WHEN x"8f" => partie_1 <= "1100";
						nb_etapes <= 1; -- op_a = 12
						WHEN x"89" => partie_1 <= "1101";
						nb_etapes <= 1; -- op_a = 13
						WHEN x"81" => partie_1 <= "1110";
						nb_etapes <= 1; -- op_a = 14
						WHEN x"87" => partie_1 <= "1111";
						nb_etapes <= 1; -- op_a = 15
						WHEN OTHERS => nb_etapes <= 0; -- sinon, rester a 0
 
					END CASE;
 
				END IF;
 

			ELSIF nb_etapes = 1 THEN -- si on affecte operateur
 
				CASE command IS
 
					WHEN x"2b" => partie_op <= '0';
					nb_etapes <= 2; -- addition
					WHEN x"13" => partie_op <= '1';
					nb_etapes <= 2; -- multiplication
					WHEN OTHERS => nb_etapes <= 1; -- sinon rester a 1
 
				END CASE;
 
 
			ELSIF nb_etapes = 2 THEN -- si on affecte operande_b
 
				IF partie_signe = '1' THEN -- si on est en signé
 
					CASE command IS
 
						WHEN x"2d" => partie_2 <= "0000";
						nb_etapes <= 3; -- op_a = 0
						WHEN x"19" => partie_2 <= "0001";
						nb_etapes <= 3; -- op_a = 1
						WHEN x"31" => partie_2 <= "0010";
						nb_etapes <= 3; -- op_a = 2
						WHEN x"bd" => partie_2 <= "0011";
						nb_etapes <= 3; -- op_a = 3
						WHEN x"11" => partie_2 <= "0100";
						nb_etapes <= 3; -- op_a = 4
						WHEN x"39" => partie_2 <= "0101";
						nb_etapes <= 3; -- op_a = 5
						WHEN x"b5" => partie_2 <= "0110";
						nb_etapes <= 3; -- op_a = 6
						WHEN x"85" => partie_2 <= "0111";
						nb_etapes <= 3; -- op_a = 7
						WHEN x"a5" => partie_2 <= "0111";
						nb_etapes <= 3; -- op_a = 7
						WHEN x"95" => partie_2 <= "0111";
						nb_etapes <= 3; -- op_a = 7
						WHEN x"8b" => partie_2 <= "0111";
						nb_etapes <= 3; -- op_a = 7
						WHEN x"8d" => partie_2 <= "0111";
						nb_etapes <= 3; -- op_a = 7
						WHEN x"8f" => partie_2 <= "0111";
						nb_etapes <= 3; -- op_a = 7
						WHEN x"89" => partie_2 <= "0111";
						nb_etapes <= 3; -- op_a = 7
						WHEN x"81" => partie_2 <= "0111";
						nb_etapes <= 3; -- op_a = 7
						WHEN x"87" => partie_2 <= "0111";
						nb_etapes <= 3; -- op_a = 7
						WHEN x"0f" => B_neg <= '1'; -- mettre a negatif
						WHEN OTHERS => nb_etapes <= 2; -- sinon, rester a 0 
 
					END CASE; 
				ELSE
 
 
					CASE command IS
 
						WHEN x"2d" => partie_2 <= "0000";
						nb_etapes <= 3; -- op_a = 0
						WHEN x"19" => partie_2 <= "0001";
						nb_etapes <= 3; -- op_a = 1
						WHEN x"31" => partie_2 <= "0010";
						nb_etapes <= 3; -- op_a = 2
						WHEN x"bd" => partie_2 <= "0011";
						nb_etapes <= 3; -- op_a = 3
						WHEN x"11" => partie_2 <= "0100";
						nb_etapes <= 3; -- op_a = 4
						WHEN x"39" => partie_2 <= "0101";
						nb_etapes <= 3; -- op_a = 5
						WHEN x"b5" => partie_2 <= "0110";
						nb_etapes <= 3; -- op_a = 6
						WHEN x"85" => partie_2 <= "0111";
						nb_etapes <= 3; -- op_a = 7
						WHEN x"a5" => partie_2 <= "1000";
						nb_etapes <= 3; -- op_a = 8
						WHEN x"95" => partie_2 <= "1001";
						nb_etapes <= 3; -- op_a = 9
						WHEN x"8b" => partie_2 <= "1010";
						nb_etapes <= 3; -- op_a = 10
						WHEN x"8d" => partie_2 <= "1011";
						nb_etapes <= 3; -- op_a = 11
						WHEN x"8f" => partie_2 <= "1100";
						nb_etapes <= 3; -- op_a = 12
						WHEN x"89" => partie_2 <= "1101";
						nb_etapes <= 3; -- op_a = 13
						WHEN x"81" => partie_2 <= "1110";
						nb_etapes <= 3; -- op_a = 14
						WHEN x"87" => partie_2 <= "1111";
						nb_etapes <= 3; -- op_a = 15
						WHEN OTHERS => nb_etapes <= 2; -- sinon, rester a 0
 
					END CASE;
 
				END IF;
 
			END IF; 
 
 
 
			----------------------------------------------------------------------------------------------------------------------------------
			------------------------------------------------------- RESET AVEC BOUTON --------------------------------------------------------
			---------------------------------------------------------------------------------------------------------------------------------- 
 
			IF bouton_reset = '0' OR command = x"33" THEN -- si jappuie sur le bouton pour reset
 
				reset <= '0';
 
				partie_1 <= "0000"; -- remettre op a a 0
				partie_2 <= "0000"; -- remettre op b a 0
				partie_signe <= '0'; -- remettre signe a 0

				A_neg <= '0'; -- remettre negatif a a 0
				B_neg <= '0'; --remettre negatif b a 0
 
				nb_etapes <= 0; -- remettre le nb etape a 0
 
 
			END IF;
 
			--appliquer les signes en signé
 
			IF partie_signe = '1' THEN
 
				IF A_neg = '1' THEN
					partie_1(3) <= '1';
				END IF;
 
				IF B_neg = '1' THEN
					partie_2(3) <= '1';
				END IF;
			END IF;
 
		END PROCESS;
 
		------------------------------------------------
 
		op_a <= partie_1;
		op_b <= partie_2;
		operateur <= partie_op;
		signe <= partie_signe;
 
END bvh;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------