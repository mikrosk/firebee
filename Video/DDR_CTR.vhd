-- Xilinx XPort Language Converter, Version 4.1 (110)
-- 
-- AHDL Design Source: DDR_CTR.tdf
-- VHDL Design Output: DDR_CTR.vhd
-- Created 11-Jan-2016 06:52 PM
--
-- Copyright (c) 2016, Xilinx, Inc.  All Rights Reserved.
-- Xilinx Inc makes no warranty, expressed or implied, with respect to
-- the operation and/or functionality of the converted output files.
-- 

-- ddr_ctr


--  CREATED BY FREDI ASCHWANDEN
--  FIFO WATER MARK
--  {{ALTERA_PARAMETERS_BEGIN}} DO NOT REMOVE THIS LINE!
--  {{ALTERA_PARAMETERS_END}} DO NOT REMOVE THIS LINE!
Library IEEE;
   use IEEE.std_logic_1164.all;
   use IEEE.std_logic_arith.all;
entity DDR_CTR is

--  {{ALTERA_IO_BEGIN}} DO NOT REMOVE THIS LINE!
--  {{ALTERA_IO_END}} DO NOT REMOVE THIS LINE!
   Port (
      FB_ADR: in std_logic_vector(31 downto 0);
      nFB_CS1, nFB_CS2, nFB_CS3, nFB_OE, FB_SIZE0, FB_SIZE1, nRSTO, MAIN_CLK,
	    FB_ALE, nFB_WR, DDR_SYNC_66M, CLR_FIFO: in std_logic;
      VIDEO_RAM_CTR: in std_logic_vector(15 downto 0);
      BLITTER_ADR: in std_logic_vector(31 downto 0);
      BLITTER_SIG, BLITTER_WR, DDRCLK0, CLK33M: in std_logic;
      FIFO_MW: in std_logic_vector(8 downto 0);
      VA: buffer std_logic_vector(12 downto 0);
      nVWE, nVRAS, nVCS, VCKE, nVCAS: buffer std_logic;
      FB_LE: buffer std_logic_vector(3 downto 0);
      FB_VDOE: buffer std_logic_vector(3 downto 0);
      SR_FIFO_WRE, SR_DDR_FB, SR_DDR_WR, SR_DDRWR_D_SEL: buffer std_logic;
      SR_VDMP: buffer std_logic_vector(7 downto 0);
      VIDEO_DDR_TA, SR_BLITTER_DACK: buffer std_logic;
      BA: buffer std_logic_vector(1 downto 0);
      DDRWR_D_SEL1: buffer std_logic;
      VDM_SEL: buffer std_logic_vector(3 downto 0);
      FB_AD: inout std_logic_vector(31 downto 0)
   );
end DDR_CTR;


architecture DDR_CTR_behav of DDR_CTR is

--  START (NORMAL 8 CYCLES TOTAL = 60ns)
--  CONFIG
--  READ CPU UND BLITTER,
--  WRITE CPU UND BLITTER
--  READ FIFO
--  CLOSE FIFO BANK
--  REFRESH 10X7.5NS=75NS
   signal FB_REGDDR_3: std_logic_vector(2 downto 0);
   signal FB_REGDDR_d: std_logic_vector(2 downto 0);
   signal FB_REGDDR_q: std_logic_vector(2 downto 0);
   signal DDR_SM_6: std_logic_vector(5 downto 0);
   signal DDR_SM_d: std_logic_vector(5 downto 0);
   signal DDR_SM_q: std_logic_vector(5 downto 0);
   signal FB_B: std_logic_vector(3 downto 0);
   signal VA_P: std_logic_vector(12 downto 0);
   signal VA_P_d: std_logic_vector(12 downto 0);
   signal VA_P_q: std_logic_vector(12 downto 0);
   signal BA_P: std_logic_vector(1 downto 0);
   signal BA_P_d: std_logic_vector(1 downto 0);
   signal BA_P_q: std_logic_vector(1 downto 0);
   signal VA_S: std_logic_vector(12 downto 0);
   signal VA_S_d: std_logic_vector(12 downto 0);
   signal VA_S_q: std_logic_vector(12 downto 0);
   signal BA_S: std_logic_vector(1 downto 0);
   signal BA_S_d: std_logic_vector(1 downto 0);
   signal BA_S_q: std_logic_vector(1 downto 0);
   signal MCS: std_logic_vector(1 downto 0);
   signal MCS_d: std_logic_vector(1 downto 0);
   signal MCS_q: std_logic_vector(1 downto 0);
   signal SR_VDMP_d: std_logic_vector(7 downto 0);
   signal SR_VDMP_q: std_logic_vector(7 downto 0);
   signal CPU_ROW_ADR: std_logic_vector(12 downto 0);
   signal CPU_BA: std_logic_vector(1 downto 0);
   signal CPU_COL_ADR: std_logic_vector(9 downto 0);
   signal BLITTER_ROW_ADR: std_logic_vector(12 downto 0);
   signal BLITTER_BA: std_logic_vector(1 downto 0);
   signal BLITTER_COL_ADR: std_logic_vector(9 downto 0);
   signal FIFO_ROW_ADR: std_logic_vector(12 downto 0);
   signal FIFO_BA: std_logic_vector(1 downto 0);
   signal FIFO_COL_ADR: std_logic_vector(9 downto 0);
   signal DDR_REFRESH_CNT: std_logic_vector(10 downto 0);
   signal DDR_REFRESH_CNT_d: std_logic_vector(10 downto 0);
   signal DDR_REFRESH_CNT_q: std_logic_vector(10 downto 0);
   signal DDR_REFRESH_SIG: std_logic_vector(3 downto 0);
   signal DDR_REFRESH_SIG_d: std_logic_vector(3 downto 0);
   signal DDR_REFRESH_SIG_q: std_logic_vector(3 downto 0);
   signal VIDEO_BASE_L_D: std_logic_vector(7 downto 0);
   signal VIDEO_BASE_L_D_d: std_logic_vector(7 downto 0);
   signal VIDEO_BASE_L_D_q: std_logic_vector(7 downto 0);
   signal VIDEO_BASE_M_D: std_logic_vector(7 downto 0);
   signal VIDEO_BASE_M_D_d: std_logic_vector(7 downto 0);
   signal VIDEO_BASE_M_D_q: std_logic_vector(7 downto 0);
   signal VIDEO_BASE_H_D: std_logic_vector(7 downto 0);
   signal VIDEO_BASE_H_D_d: std_logic_vector(7 downto 0);
   signal VIDEO_BASE_H_D_q: std_logic_vector(7 downto 0);
   signal VIDEO_BASE_X_D: std_logic_vector(2 downto 0);
   signal VIDEO_BASE_X_D_d: std_logic_vector(2 downto 0);
   signal VIDEO_BASE_X_D_q: std_logic_vector(2 downto 0);
   signal VIDEO_ADR_CNT: std_logic_vector(22 downto 0);
   signal VIDEO_ADR_CNT_d: std_logic_vector(22 downto 0);
   signal VIDEO_ADR_CNT_q: std_logic_vector(22 downto 0);
   signal VIDEO_BASE_ADR: std_logic_vector(22 downto 0);
   signal VIDEO_ACT_ADR: std_logic_vector(26 downto 0);
   signal u0_data: std_logic_vector(7 downto 0);
   signal u0_tridata: std_logic_vector(7 downto 0);
   signal FB_REGDDR_0_clk_ctrl, SR_VDMP0_clk_ctrl, MCS0_clk_ctrl,
	 VA_S0_clk_ctrl, BA_S0_clk_ctrl, VA_P0_clk_ctrl, BA_P0_clk_ctrl,
	 DDR_SM_0_clk_ctrl, VIDEO_ADR_CNT0_clk_ctrl, VIDEO_ADR_CNT0_ena_ctrl,
	 DDR_REFRESH_CNT0_clk_ctrl, DDR_REFRESH_SIG0_clk_ctrl,
	 DDR_REFRESH_SIG0_ena_ctrl, VIDEO_BASE_L_D0_clk_ctrl,
	 VIDEO_BASE_L_D0_ena_ctrl, VIDEO_BASE_M_D0_clk_ctrl,
	 VIDEO_BASE_M_D0_ena_ctrl, VIDEO_BASE_H_D0_clk_ctrl,
	 VIDEO_BASE_H_D0_ena_ctrl, VIDEO_BASE_X_D0_clk_ctrl,
	 VIDEO_BASE_X_D0_ena_ctrl, VA12_2, VA12_1, VA11_2, VA11_1, VA10_2,
	 VA10_1, VA9_2, VA9_1, VA8_2, VA8_1, VA7_2, VA7_1, VA6_2, VA6_1, VA5_2,
	 VA5_1, VA4_2, VA4_1, VA3_2, VA3_1, VA2_2, VA2_1, VA1_2, VA1_1, VA0_2,
	 VA0_1, BA1_2, BA1_1, BA0_2, BA0_1, BUS_CYC_d_2, BUS_CYC_d_1,
	 FIFO_BANK_OK_d_2, FIFO_BANK_OK_d_1, u0_enabledt, gnd, vcc,
	 VIDEO_CNT_H, VIDEO_CNT_M, VIDEO_CNT_L, VIDEO_BASE_H, VIDEO_BASE_M,
	 VIDEO_BASE_L, REFRESH_TIME_q, REFRESH_TIME_clk, REFRESH_TIME_d,
	 REFRESH_TIME, DDR_REFRESH_REQ_q, DDR_REFRESH_REQ_clk,
	 DDR_REFRESH_REQ_d, DDR_REFRESH_REQ, DDR_REFRESH_ON, FIFO_BANK_NOT_OK,
	 FIFO_BANK_OK_q, FIFO_BANK_OK_clk, FIFO_BANK_OK_d, FIFO_BANK_OK,
	 SR_FIFO_WRE_q, SR_FIFO_WRE_clk, SR_FIFO_WRE_d, STOP_q, STOP_clk,
	 STOP_d, STOP, CLEAR_FIFO_CNT_q, CLEAR_FIFO_CNT_clk, CLEAR_FIFO_CNT_d,
	 CLEAR_FIFO_CNT, CLR_FIFO_SYNC_q, CLR_FIFO_SYNC_clk, CLR_FIFO_SYNC_d,
	 CLR_FIFO_SYNC, FIFO_ACTIVE, FIFO_AC_q, FIFO_AC_clk, FIFO_AC_d,
	 FIFO_AC, FIFO_REQ_q, FIFO_REQ_clk, FIFO_REQ_d, FIFO_REQ, BLITTER_AC_q,
	 BLITTER_AC_clk, BLITTER_AC_d, BLITTER_AC, BLITTER_REQ_q,
	 BLITTER_REQ_clk, BLITTER_REQ_d, BLITTER_REQ, BUS_CYC_END, BUS_CYC_q,
	 BUS_CYC_clk, BUS_CYC_d, BUS_CYC, CPU_AC_q, CPU_AC_clk, CPU_AC_d,
	 CPU_AC, CPU_REQ_q, CPU_REQ_clk, CPU_REQ_d, CPU_REQ, CPU_SIG,
	 SR_DDRWR_D_SEL_q, SR_DDRWR_D_SEL_clk, SR_DDRWR_D_SEL_d, SR_DDR_WR_q,
	 SR_DDR_WR_clk, SR_DDR_WR_d, DDR_CONFIG, DDR_CS_q, DDR_CS_ena,
	 DDR_CS_clk, DDR_CS_d, DDR_CS, DDR_SEL, CPU_DDR_SYNC_q,
	 CPU_DDR_SYNC_clk, CPU_DDR_SYNC_d, CPU_DDR_SYNC, VWE, VRAS, VCAS, LINE:
	 std_logic;

-- Sub Module Interface Section


   component lpm_bustri_BYT
      Port (
	 data: in std_logic_vector(7 downto 0);
	 enabledt: in std_logic;
	 tridata: buffer std_logic_vector(7 downto 0)
      );
   end component;

   Function to_std_logic(X: in Boolean) return Std_Logic is
   variable ret : std_logic;
   begin
   if x then ret := '1';  else ret := '0'; end if;
   return ret;
   end to_std_logic;


   -- sizeIt replicates a value to an array of specific length.
   Function sizeIt(a: std_Logic; len: integer) return std_logic_vector is
      variable rep: std_logic_vector( len-1 downto 0);
   begin for i in rep'range loop rep(i) := a;  end loop; return rep;
   end sizeIt;
begin

-- Sub Module Section
   u0: lpm_bustri_BYT port map (data=>u0_data, enabledt=>u0_enabledt,
	 tridata=>u0_tridata);

-- Register Section

   SR_FIFO_WRE <= SR_FIFO_WRE_q;
   process (SR_FIFO_WRE_clk) begin
      if SR_FIFO_WRE_clk'event and SR_FIFO_WRE_clk='1' then
	 SR_FIFO_WRE_q <= SR_FIFO_WRE_d;
      end if;
   end process;

   SR_DDR_WR <= SR_DDR_WR_q;
   process (SR_DDR_WR_clk) begin
      if SR_DDR_WR_clk'event and SR_DDR_WR_clk='1' then
	 SR_DDR_WR_q <= SR_DDR_WR_d;
      end if;
   end process;

   SR_DDRWR_D_SEL <= SR_DDRWR_D_SEL_q;
   process (SR_DDRWR_D_SEL_clk) begin
      if SR_DDRWR_D_SEL_clk'event and SR_DDRWR_D_SEL_clk='1' then
	 SR_DDRWR_D_SEL_q <= SR_DDRWR_D_SEL_d;
      end if;
   end process;

   SR_VDMP <= SR_VDMP_q;
   process (SR_VDMP0_clk_ctrl) begin
      if SR_VDMP0_clk_ctrl'event and SR_VDMP0_clk_ctrl='1' then
	 SR_VDMP_q <= SR_VDMP_d;
      end if;
   end process;

   process (FB_REGDDR_0_clk_ctrl) begin
      if FB_REGDDR_0_clk_ctrl'event and FB_REGDDR_0_clk_ctrl='1' then
	 FB_REGDDR_q <= FB_REGDDR_d;
      end if;
   end process;

   process (DDR_SM_0_clk_ctrl) begin
      if DDR_SM_0_clk_ctrl'event and DDR_SM_0_clk_ctrl='1' then
	 DDR_SM_q <= DDR_SM_d;
      end if;
   end process;

   process (VA_P0_clk_ctrl) begin
      if VA_P0_clk_ctrl'event and VA_P0_clk_ctrl='1' then
	 VA_P_q <= VA_P_d;
      end if;
   end process;

   process (BA_P0_clk_ctrl) begin
      if BA_P0_clk_ctrl'event and BA_P0_clk_ctrl='1' then
	 BA_P_q <= BA_P_d;
      end if;
   end process;

   process (VA_S0_clk_ctrl) begin
      if VA_S0_clk_ctrl'event and VA_S0_clk_ctrl='1' then
	 VA_S_q <= VA_S_d;
      end if;
   end process;

   process (BA_S0_clk_ctrl) begin
      if BA_S0_clk_ctrl'event and BA_S0_clk_ctrl='1' then
	 BA_S_q <= BA_S_d;
      end if;
   end process;

   process (MCS0_clk_ctrl) begin
      if MCS0_clk_ctrl'event and MCS0_clk_ctrl='1' then
	 MCS_q <= MCS_d;
      end if;
   end process;

   process (CPU_DDR_SYNC_clk) begin
      if CPU_DDR_SYNC_clk'event and CPU_DDR_SYNC_clk='1' then
	 CPU_DDR_SYNC_q <= CPU_DDR_SYNC_d;
      end if;
   end process;

   process (DDR_CS_clk) begin
      if DDR_CS_clk'event and DDR_CS_clk='1' then
	 if DDR_CS_ena='1' then
	    DDR_CS_q <= DDR_CS_d;
	 end if;
      end if;
   end process;

   process (CPU_REQ_clk) begin
      if CPU_REQ_clk'event and CPU_REQ_clk='1' then
	 CPU_REQ_q <= CPU_REQ_d;
      end if;
   end process;

   process (CPU_AC_clk) begin
      if CPU_AC_clk'event and CPU_AC_clk='1' then
	 CPU_AC_q <= CPU_AC_d;
      end if;
   end process;

   process (BUS_CYC_clk) begin
      if BUS_CYC_clk'event and BUS_CYC_clk='1' then
	 BUS_CYC_q <= BUS_CYC_d;
      end if;
   end process;

   process (BLITTER_REQ_clk) begin
      if BLITTER_REQ_clk'event and BLITTER_REQ_clk='1' then
	 BLITTER_REQ_q <= BLITTER_REQ_d;
      end if;
   end process;

   process (BLITTER_AC_clk) begin
      if BLITTER_AC_clk'event and BLITTER_AC_clk='1' then
	 BLITTER_AC_q <= BLITTER_AC_d;
      end if;
   end process;

   process (FIFO_REQ_clk) begin
      if FIFO_REQ_clk'event and FIFO_REQ_clk='1' then
	 FIFO_REQ_q <= FIFO_REQ_d;
      end if;
   end process;

   process (FIFO_AC_clk) begin
      if FIFO_AC_clk'event and FIFO_AC_clk='1' then
	 FIFO_AC_q <= FIFO_AC_d;
      end if;
   end process;

   process (CLR_FIFO_SYNC_clk) begin
      if CLR_FIFO_SYNC_clk'event and CLR_FIFO_SYNC_clk='1' then
	 CLR_FIFO_SYNC_q <= CLR_FIFO_SYNC_d;
      end if;
   end process;

   process (CLEAR_FIFO_CNT_clk) begin
      if CLEAR_FIFO_CNT_clk'event and CLEAR_FIFO_CNT_clk='1' then
	 CLEAR_FIFO_CNT_q <= CLEAR_FIFO_CNT_d;
      end if;
   end process;

   process (STOP_clk) begin
      if STOP_clk'event and STOP_clk='1' then
	 STOP_q <= STOP_d;
      end if;
   end process;

   process (FIFO_BANK_OK_clk) begin
      if FIFO_BANK_OK_clk'event and FIFO_BANK_OK_clk='1' then
	 FIFO_BANK_OK_q <= FIFO_BANK_OK_d;
      end if;
   end process;

   process (DDR_REFRESH_CNT0_clk_ctrl) begin
      if DDR_REFRESH_CNT0_clk_ctrl'event and DDR_REFRESH_CNT0_clk_ctrl='1' then
	 DDR_REFRESH_CNT_q <= DDR_REFRESH_CNT_d;
      end if;
   end process;

   process (DDR_REFRESH_REQ_clk) begin
      if DDR_REFRESH_REQ_clk'event and DDR_REFRESH_REQ_clk='1' then
	 DDR_REFRESH_REQ_q <= DDR_REFRESH_REQ_d;
      end if;
   end process;

   process (DDR_REFRESH_SIG0_clk_ctrl) begin
      if DDR_REFRESH_SIG0_clk_ctrl'event and DDR_REFRESH_SIG0_clk_ctrl='1' then
	 if DDR_REFRESH_SIG0_ena_ctrl='1' then
	    DDR_REFRESH_SIG_q <= DDR_REFRESH_SIG_d;
	 end if;
      end if;
   end process;

   process (REFRESH_TIME_clk) begin
      if REFRESH_TIME_clk'event and REFRESH_TIME_clk='1' then
	 REFRESH_TIME_q <= REFRESH_TIME_d;
      end if;
   end process;

   process (VIDEO_BASE_L_D0_clk_ctrl) begin
      if VIDEO_BASE_L_D0_clk_ctrl'event and VIDEO_BASE_L_D0_clk_ctrl='1' then
	 if VIDEO_BASE_L_D0_ena_ctrl='1' then
	    VIDEO_BASE_L_D_q <= VIDEO_BASE_L_D_d;
	 end if;
      end if;
   end process;

   process (VIDEO_BASE_M_D0_clk_ctrl) begin
      if VIDEO_BASE_M_D0_clk_ctrl'event and VIDEO_BASE_M_D0_clk_ctrl='1' then
	 if VIDEO_BASE_M_D0_ena_ctrl='1' then
	    VIDEO_BASE_M_D_q <= VIDEO_BASE_M_D_d;
	 end if;
      end if;
   end process;

   process (VIDEO_BASE_H_D0_clk_ctrl) begin
      if VIDEO_BASE_H_D0_clk_ctrl'event and VIDEO_BASE_H_D0_clk_ctrl='1' then
	 if VIDEO_BASE_H_D0_ena_ctrl='1' then
	    VIDEO_BASE_H_D_q <= VIDEO_BASE_H_D_d;
	 end if;
      end if;
   end process;

   process (VIDEO_BASE_X_D0_clk_ctrl) begin
      if VIDEO_BASE_X_D0_clk_ctrl'event and VIDEO_BASE_X_D0_clk_ctrl='1' then
	 if VIDEO_BASE_X_D0_ena_ctrl='1' then
	    VIDEO_BASE_X_D_q <= VIDEO_BASE_X_D_d;
	 end if;
      end if;
   end process;

   process (VIDEO_ADR_CNT0_clk_ctrl) begin
      if VIDEO_ADR_CNT0_clk_ctrl'event and VIDEO_ADR_CNT0_clk_ctrl='1' then
	 if VIDEO_ADR_CNT0_ena_ctrl='1' then
	    VIDEO_ADR_CNT_q <= VIDEO_ADR_CNT_d;
	 end if;
      end if;
   end process;

-- Start of original equations
   LINE <= FB_SIZE0 and FB_SIZE1;

--  BYT SELECT
--  ADR==0
--  LONG UND LINE
   FB_B(0) <= to_std_logic(FB_ADR(1 downto 0) = "00") or (FB_SIZE1 and
	 FB_SIZE0) or ((not FB_SIZE1) and (not FB_SIZE0));

--  ADR==1
--  HIGH WORD
--  LONG UND LINE
   FB_B(1) <= to_std_logic(FB_ADR(1 downto 0) = "01") or (FB_SIZE1 and (not
	 FB_SIZE0) and (not FB_ADR(1))) or (FB_SIZE1 and FB_SIZE0) or ((not
	 FB_SIZE1) and (not FB_SIZE0));

--  ADR==2
--  LONG UND LINE
   FB_B(2) <= to_std_logic(FB_ADR(1 downto 0) = "10") or (FB_SIZE1 and
	 FB_SIZE0) or ((not FB_SIZE1) and (not FB_SIZE0));

--  ADR==3
--  LOW WORD
--  LONG UND LINE
   FB_B(3) <= to_std_logic(FB_ADR(1 downto 0) = "11") or (FB_SIZE1 and (not
	 FB_SIZE0) and FB_ADR(1)) or (FB_SIZE1 and FB_SIZE0) or ((not FB_SIZE1)
	 and (not FB_SIZE0));

--  CPU READ (REG DDR => CPU) AND WRITE (CPU => REG DDR)  --------------------------------------------------
   FB_REGDDR_0_clk_ctrl <= MAIN_CLK;


   process (FB_REGDDR_q, DDR_SEL, BUS_CYC_q, LINE, DDR_CS_q, nFB_OE, MAIN_CLK,
	 DDR_CONFIG, nFB_WR, vcc)
      variable stdVec3: std_logic_vector(2 downto 0);
   begin
      FB_REGDDR_d <= FB_REGDDR_q;
      (FB_VDOE(0), FB_VDOE(1)) <= std_logic_vector'("00");
      (FB_LE(0), FB_LE(1), FB_VDOE(2), FB_LE(2), FB_VDOE(3), FB_LE(3),
	    VIDEO_DDR_TA, BUS_CYC_END) <= std_logic_vector'("00000000");
      stdVec3 := FB_REGDDR_q;
      case stdVec3 is
      when "000" =>
	 FB_LE(0) <= not nFB_WR;

--  LOS WENN BEREIT ODER IMMER BEI LINE WRITE
	 if (BUS_CYC_q or (DDR_SEL and LINE and (not nFB_WR)))='1' then
	    FB_REGDDR_d <= "001";
	 else
	    FB_REGDDR_d <= "000";
	 end if;
      when "001" =>
	 if (DDR_CS_q)='1' then
	    FB_LE(0) <= not nFB_WR;
	    VIDEO_DDR_TA <= vcc;
	    if (LINE)='1' then
	       FB_VDOE(0) <= (not nFB_OE) and (not DDR_CONFIG);
	       FB_REGDDR_d <= "010";
	    else
	       BUS_CYC_END <= vcc;
	       FB_VDOE(0) <= (not nFB_OE) and (not MAIN_CLK) and (not
		     DDR_CONFIG);
	       FB_REGDDR_d <= "000";
	    end if;
	 else
	    FB_REGDDR_d <= "000";
	 end if;
      when "010" =>
	 if (DDR_CS_q)='1' then
	    FB_VDOE(1) <= (not nFB_OE) and (not DDR_CONFIG);
	    FB_LE(1) <= not nFB_WR;
	    VIDEO_DDR_TA <= vcc;
	    FB_REGDDR_d <= "011";
	 else
	    FB_REGDDR_d <= "000";
	 end if;
      when "011" =>
	 if (DDR_CS_q)='1' then
	    FB_VDOE(2) <= (not nFB_OE) and (not DDR_CONFIG);
	    FB_LE(2) <= not nFB_WR;

--  BEI LINE WRITE EVT. WARTEN
	    if ((not BUS_CYC_q) and LINE and (not nFB_WR))='1' then
	       FB_REGDDR_d <= "011";
	    else
	       VIDEO_DDR_TA <= vcc;
	       FB_REGDDR_d <= "100";
	    end if;
	 else
	    FB_REGDDR_d <= "000";
	 end if;
      when "100" =>
	 if (DDR_CS_q)='1' then
	    FB_VDOE(3) <= (not nFB_OE) and (not MAIN_CLK) and (not DDR_CONFIG);
	    FB_LE(3) <= not nFB_WR;
	    VIDEO_DDR_TA <= vcc;
	    BUS_CYC_END <= vcc;
	    FB_REGDDR_d <= "000";
	 else
	    FB_REGDDR_d <= "000";
	 end if;
      when others =>
      end case;
      stdVec3 := (others=>'0');  -- no storage needed
   end process;

--  DDR STEUERUNG -----------------------------------------------------
--  VIDEO RAM CONTROL REGISTER (IST IN VIDEO_MUX_CTR) $F0000400: BIT 0: VCKE; 1: !nVCS ;2:REFRESH ON , (0=FIFO UND CNT CLEAR); 3: CONFIG; 8: FIFO_ACTIVE;
   VCKE <= VIDEO_RAM_CTR(0);
   nVCS <= not VIDEO_RAM_CTR(1);
   DDR_REFRESH_ON <= VIDEO_RAM_CTR(2);
   DDR_CONFIG <= VIDEO_RAM_CTR(3);
   FIFO_ACTIVE <= VIDEO_RAM_CTR(8);

-- ------------------------------
   CPU_ROW_ADR <= FB_ADR(26 downto 14);
   CPU_BA <= FB_ADR(13 downto 12);
   CPU_COL_ADR <= FB_ADR(11 downto 2);
   nVRAS <= not VRAS;
   nVCAS <= not VCAS;
   nVWE <= not VWE;
   SR_DDR_WR_clk <= DDRCLK0;
   SR_DDRWR_D_SEL_clk <= DDRCLK0;
   SR_VDMP0_clk_ctrl <= DDRCLK0;
   SR_FIFO_WRE_clk <= DDRCLK0;
   CPU_AC_clk <= DDRCLK0;
   FIFO_AC_clk <= DDRCLK0;
   BLITTER_AC_clk <= DDRCLK0;
   DDRWR_D_SEL1 <= BLITTER_AC_q;

--  SELECT LOGIC
   DDR_SEL <= to_std_logic(FB_ALE='1' and FB_AD(31 downto 30) = "01");
   DDR_CS_clk <= MAIN_CLK;
   DDR_CS_ena <= FB_ALE;
   DDR_CS_d <= DDR_SEL;

--  WENN READ ODER WRITE B,W,L DDR SOFORT ANFORDERN, BEI WRITE LINE SPÄTER
--  NICHT LINE ODER READ SOFORT LOS WENN NICHT CONFIG
--  CONFIG SOFORT LOS
--  LINE WRITE SPÄTER
   CPU_SIG <= (DDR_SEL and (nFB_WR or (not LINE)) and (not DDR_CONFIG)) or
	 (DDR_SEL and DDR_CONFIG) or (to_std_logic(FB_REGDDR_q = "010") and
	 (not nFB_WR));
   CPU_REQ_clk <= DDR_SYNC_66M;

--  HALTEN BUS CYC BEGONNEN ODER FERTIG
   CPU_REQ_d <= CPU_SIG or (to_std_logic(CPU_REQ_q='1' and FB_REGDDR_q /= "010"
	 and FB_REGDDR_q /= "100") and (not BUS_CYC_END) and (not BUS_CYC_q));
   BUS_CYC_clk <= DDRCLK0;
   BUS_CYC_d_1 <= BUS_CYC_q and (not BUS_CYC_END);

--  STATE MACHINE SYNCHRONISIEREN -----------------
   MCS0_clk_ctrl <= DDRCLK0;
   MCS_d(0) <= MAIN_CLK;
   MCS_d(1) <= MCS_q(0);
   CPU_DDR_SYNC_clk <= DDRCLK0;

--  NUR 1 WENN EIN
   CPU_DDR_SYNC_d <= to_std_logic(MCS_q = "10") and VCKE and (not nVCS);

-- -------------------------------------------------
   VA_S0_clk_ctrl <= DDRCLK0;
   BA_S0_clk_ctrl <= DDRCLK0;
   (VA12_1, VA11_1, VA10_1, VA9_1, VA8_1, VA7_1, VA6_1, VA5_1, VA4_1, VA3_1,
	 VA2_1, VA1_1, VA0_1) <= VA_S_q;
   (BA1_1, BA0_1) <= BA_S_q;
   VA_P0_clk_ctrl <= DDRCLK0;
   BA_P0_clk_ctrl <= DDRCLK0;

--  DDR STATE MACHINE  -----------------------------------------------
   DDR_SM_0_clk_ctrl <= DDRCLK0;


   process (DDR_SM_q, DDR_REFRESH_REQ_q, CPU_DDR_SYNC_q, DDR_CONFIG,
	 CPU_ROW_ADR, FIFO_ROW_ADR, BLITTER_ROW_ADR, BLITTER_REQ_q, BLITTER_WR,
	 FIFO_AC_q, CPU_COL_ADR, BLITTER_COL_ADR, VA_S_q, CPU_BA, BLITTER_BA,
	 FB_B, CPU_AC_q, BLITTER_AC_q, FIFO_BANK_OK_q, FIFO_MW, FIFO_REQ_q,
	 VIDEO_ADR_CNT_q, FIFO_COL_ADR, gnd, DDR_SEL, LINE, FIFO_BA, VA_P_q,
	 BA_P_q, CPU_REQ_q, FB_AD, nFB_WR, FB_SIZE0, FB_SIZE1,
	 DDR_REFRESH_SIG_q, vcc)
      variable stdVec6: std_logic_vector(5 downto 0);
   begin
      DDR_SM_d <= DDR_SM_q;
      BA_S_d <= "00";
      VA_S_d <= "0000000000000";
      BA_P_d <= "00";
      (VA_P_d(9), VA_P_d(8), VA_P_d(7), VA_P_d(6), VA_P_d(5), VA_P_d(4),
	    VA_P_d(3), VA_P_d(2), VA_P_d(1), VA_P_d(0), VA_P_d(10)) <=
	    std_logic_vector'("00000000000");
      SR_VDMP_d <= "00000000";
      VA_P_d(12 downto 11) <= "00";
      (FIFO_BANK_OK_d_1, FIFO_AC_d, SR_DDR_FB, SR_BLITTER_DACK, BLITTER_AC_d,
	    SR_DDR_WR_d, SR_DDRWR_D_SEL_d, CPU_AC_d, VA12_2, VA11_2, VA9_2,
	    VA8_2, VA7_2, VA6_2, VA5_2, VA4_2, VA3_2, VA2_2, VA1_2, VA0_2,
	    BA1_2, BA0_2, SR_FIFO_WRE_d, BUS_CYC_d_2, VWE, VA10_2,
	    FIFO_BANK_NOT_OK, VCAS, VRAS) <=
	    std_logic_vector'("00000000000000000000000000000");
      stdVec6 := DDR_SM_q;
      case stdVec6 is
      when "000000" =>
	 if (DDR_REFRESH_REQ_q)='1' then
	    DDR_SM_d <= "011111";

--  SYNCHRON UND EIN?
	 elsif (CPU_DDR_SYNC_q)='1' then

--  JA
	    if (DDR_CONFIG)='1' then
	       DDR_SM_d <= "001000";

--  BEI WAIT UND LINE WRITE
	    elsif (CPU_REQ_q)='1' then
	       VA_S_d <= CPU_ROW_ADR;
	       BA_S_d <= CPU_BA;
	       CPU_AC_d <= vcc;
	       BUS_CYC_d_2 <= vcc;
	       DDR_SM_d <= "000010";
	    else

--  FIFO IST DEFAULT
	       if (FIFO_REQ_q or (not BLITTER_REQ_q))='1' then
		  VA_P_d <= FIFO_ROW_ADR;
		  BA_P_d <= FIFO_BA;

--  VORBESETZEN
		  FIFO_AC_d <= vcc;
	       else
		  VA_P_d <= BLITTER_ROW_ADR;
		  BA_P_d <= BLITTER_BA;

--  VORBESETZEN
		  BLITTER_AC_d <= vcc;
	       end if;
	       DDR_SM_d <= "000001";
	    end if;
	 else

--  NEIN ->SYNCHRONISIEREN
	    DDR_SM_d <= "000000";
	 end if;
      when "000001" =>

--  SCHNELLZUGRIFF *** HIER IST PAGE IMMER NOT OK ***
	 if (DDR_SEL and (nFB_WR or (not LINE)))='1' then
	    VRAS <= vcc;
	    (VA12_2, VA11_2, VA10_2, VA9_2, VA8_2, VA7_2, VA6_2, VA5_2, VA4_2,
		  VA3_2, VA2_2, VA1_2, VA0_2) <= FB_AD(26 downto 14);
	    (BA1_2, BA0_2) <= FB_AD(13 downto 12);

--  AUTO PRECHARGE DA NICHT FIFO PAGE
	    VA_S_d(10) <= vcc;
	    CPU_AC_d <= vcc;

--  BUS CYCLUS LOSTRETEN
	    BUS_CYC_d_2 <= vcc;
	 else
	    VRAS <= (FIFO_AC_q and FIFO_REQ_q) or (BLITTER_AC_q and
		  BLITTER_REQ_q);
	    (VA12_2, VA11_2, VA10_2, VA9_2, VA8_2, VA7_2, VA6_2, VA5_2, VA4_2,
		  VA3_2, VA2_2, VA1_2, VA0_2) <= VA_P_q;
	    (BA1_2, BA0_2) <= BA_P_q;
	    VA_S_d(10) <= not (FIFO_AC_q and FIFO_REQ_q);
	    FIFO_BANK_OK_d_1 <= FIFO_AC_q and FIFO_REQ_q;
	    FIFO_AC_d <= FIFO_AC_q and FIFO_REQ_q;
	    BLITTER_AC_d <= BLITTER_AC_q and BLITTER_REQ_q;
	 end if;
	 DDR_SM_d <= "000011";
      when "000010" =>
	 VRAS <= vcc;
	 FIFO_BANK_NOT_OK <= vcc;
	 CPU_AC_d <= vcc;

--  BUS CYCLUS LOSTRETEN
	 BUS_CYC_d_2 <= vcc;
	 DDR_SM_d <= "000011";
      when "000011" =>
	 CPU_AC_d <= CPU_AC_q;
	 FIFO_AC_d <= FIFO_AC_q;
	 BLITTER_AC_d <= BLITTER_AC_q;

--  AUTO PRECHARGE WENN NICHT FIFO PAGE
	 VA_S_d(10) <= VA_S_q(10);
	 if (((not nFB_WR) and CPU_AC_q) or (BLITTER_WR and BLITTER_AC_q))='1'
	       then
	    DDR_SM_d <= "010000";

--  CPU?
	 elsif (CPU_AC_q)='1' then
	    VA_S_d(9 downto 0) <= CPU_COL_ADR;
	    BA_S_d <= CPU_BA;
	    DDR_SM_d <= "001110";

--  FIFO?
	 elsif (FIFO_AC_q)='1' then
	    VA_S_d(9 downto 0) <= FIFO_COL_ADR;
	    BA_S_d <= FIFO_BA;
	    DDR_SM_d <= "010110";
	 elsif (BLITTER_AC_q)='1' then
	    VA_S_d(9 downto 0) <= BLITTER_COL_ADR;
	    BA_S_d <= BLITTER_BA;
	    DDR_SM_d <= "001110";
	 else

--  READ
	    DDR_SM_d <= "000111";
	 end if;
      when "001110" =>
	 CPU_AC_d <= CPU_AC_q;
	 BLITTER_AC_d <= BLITTER_AC_q;
	 VCAS <= vcc;

--  READ DATEN FÜR CPU
	 SR_DDR_FB <= CPU_AC_q;

--  BLITTER DACK AND BLITTER LATCH DATEN
	 SR_BLITTER_DACK <= BLITTER_AC_q;
	 DDR_SM_d <= "001111";
      when "001111" =>
	 CPU_AC_d <= CPU_AC_q;
	 BLITTER_AC_d <= BLITTER_AC_q;

--  FIFO READ EINSCHIEBEN WENN BANK OK
	 if (FIFO_REQ_q and FIFO_BANK_OK_q)='1' then
	    VA_S_d(9 downto 0) <= FIFO_COL_ADR;

--  MANUELL PRECHARGE
	    VA_S_d(10) <= gnd;
	    BA_S_d <= FIFO_BA;
	    DDR_SM_d <= "011000";
	 else

--  ALLE PAGES SCHLIESSEN
	    VA_S_d(10) <= vcc;

--  WRITE
	    DDR_SM_d <= "011101";
	 end if;
      when "010000" =>
	 CPU_AC_d <= CPU_AC_q;
	 BLITTER_AC_d <= BLITTER_AC_q;

--  BLITTER ACK AND BLITTER LATCH DATEN
	 SR_BLITTER_DACK <= BLITTER_AC_q;

--  AUTO PRECHARGE WENN NICHT FIFO PAGE
	 VA_S_d(10) <= VA_S_q(10);
	 DDR_SM_d <= "010001";
      when "010001" =>
	 CPU_AC_d <= CPU_AC_q;
	 BLITTER_AC_d <= BLITTER_AC_q;
	 VA_S_d(9 downto 0) <= (sizeIt(CPU_AC_q,10) and CPU_COL_ADR) or
	       (sizeIt(BLITTER_AC_q,10) and BLITTER_COL_ADR);

--  AUTO PRECHARGE WENN NICHT FIFO PAGE
	 VA_S_d(10) <= VA_S_q(10);
	 BA_S_d <= (std_logic_vector'(CPU_AC_q & CPU_AC_q) and CPU_BA) or
	       (std_logic_vector'(BLITTER_AC_q & BLITTER_AC_q) and BLITTER_BA);

--  BYTE ENABLE WRITE
	 SR_VDMP_d(7 downto 4) <= FB_B;

--  LINE ENABLE WRITE
	 SR_VDMP_d(3 downto 0) <= sizeIt(LINE,4) and "1111";
	 DDR_SM_d <= "010010";
      when "010010" =>
	 CPU_AC_d <= CPU_AC_q;
	 BLITTER_AC_d <= BLITTER_AC_q;
	 VCAS <= vcc;
	 VWE <= vcc;

--  WRITE COMMAND CPU UND BLITTER IF WRITER
	 SR_DDR_WR_d <= vcc;

--  2. HÄLFTE WRITE DATEN SELEKTIEREN
	 SR_DDRWR_D_SEL_d <= vcc;

--  WENN LINE DANN ACTIV
	 SR_VDMP_d <= sizeIt(LINE,8) and "11111111";
	 DDR_SM_d <= "010011";
      when "010011" =>
	 CPU_AC_d <= CPU_AC_q;
	 BLITTER_AC_d <= BLITTER_AC_q;

--  WRITE COMMAND CPU UND BLITTER IF WRITE
	 SR_DDR_WR_d <= vcc;

--  2. HÄLFTE WRITE DATEN SELEKTIEREN
	 SR_DDRWR_D_SEL_d <= vcc;
	 DDR_SM_d <= "010100";
      when "010100" =>
	 DDR_SM_d <= "010101";
      when "010101" =>
	 if (FIFO_REQ_q and FIFO_BANK_OK_q)='1' then
	    VA_S_d(9 downto 0) <= FIFO_COL_ADR;

--  NON AUTO PRECHARGE
	    VA_S_d(10) <= gnd;
	    BA_S_d <= FIFO_BA;
	    DDR_SM_d <= "011000";
	 else

--  ALLE PAGES SCHLIESSEN
	    VA_S_d(10) <= vcc;

--  FIFO READ
	    DDR_SM_d <= "011101";
	 end if;
      when "010110" =>
	 VCAS <= vcc;

--  DATEN WRITE FIFO
	 SR_FIFO_WRE_d <= vcc;
	 DDR_SM_d <= "010111";
      when "010111" =>
	 if (FIFO_REQ_q)='1' then

--  NEUE PAGE?
	    if VIDEO_ADR_CNT_q(7 downto 0) = "11111111" then

--  ALLE PAGES SCHLIESSEN
	       VA_S_d(10) <= vcc;

--  BANK SCHLIESSEN
	       DDR_SM_d <= "011101";
	    else
	       VA_S_d(9 downto 0) <= std_logic_vector'(unsigned(FIFO_COL_ADR) +
		     unsigned'("0000000100"));

--  NON AUTO PRECHARGE
	       VA_S_d(10) <= gnd;
	       BA_S_d <= FIFO_BA;
	       DDR_SM_d <= "011000";
	    end if;
	 else

--  ALLE PAGES SCHLIESSEN
	    VA_S_d(10) <= vcc;

--  NOCH OFFEN LASSEN
	    DDR_SM_d <= "011101";
	 end if;
      when "011000" =>
	 VCAS <= vcc;

--  DATEN WRITE FIFO
	 SR_FIFO_WRE_d <= vcc;
	 DDR_SM_d <= "011001";
      when "011001" =>
	 if CPU_REQ_q='1' and (unsigned(FIFO_MW) > unsigned'("000000000")) then

--  ALLE PAGES SCHLIESEN
	    VA_S_d(10) <= vcc;

--  BANK SCHLIESSEN
	    DDR_SM_d <= "011110";
	 elsif (FIFO_REQ_q)='1' then

--  NEUE PAGE?
	    if VIDEO_ADR_CNT_q(7 downto 0) = "11111111" then

--  ALLE PAGES SCHLIESSEN
	       VA_S_d(10) <= vcc;

--  BANK SCHLIESSEN
	       DDR_SM_d <= "011110";
	    else
	       VA_S_d(9 downto 0) <= std_logic_vector'(unsigned(FIFO_COL_ADR) +
		     unsigned'("0000000100"));

--  NON AUTO PRECHARGE
	       VA_S_d(10) <= gnd;
	       BA_S_d <= FIFO_BA;
	       DDR_SM_d <= "011010";
	    end if;
	 else

--  ALLE PAGES SCHLIESEN
	    VA_S_d(10) <= vcc;

--  BANK SCHLIESSEN
	    DDR_SM_d <= "011110";
	 end if;
      when "011010" =>
	 VCAS <= vcc;

--  DATEN WRITE FIFO
	 SR_FIFO_WRE_d <= vcc;

--  NOTFALL?
	 if (unsigned(FIFO_MW) < unsigned'("000000000")) then

--  JA->
	    DDR_SM_d <= "010111";
	 else
	    DDR_SM_d <= "011011";
	 end if;
      when "011011" =>
	 if (FIFO_REQ_q)='1' then

--  NEUE PAGE?
	    if VIDEO_ADR_CNT_q(7 downto 0) = "11111111" then

--  ALLE BANKS SCHLIESEN
	       VA_S_d(10) <= vcc;

--  BANK SCHLIESSEN
	       DDR_SM_d <= "011101";
	    else
	       VA_P_d(9 downto 0) <= std_logic_vector'(unsigned(FIFO_COL_ADR) +
		     unsigned'("0000000100"));

--  NON AUTO PRECHARGE
	       VA_P_d(10) <= gnd;
	       BA_P_d <= FIFO_BA;
	       DDR_SM_d <= "011100";
	    end if;
	 else

--  ALLE BANKS SCHLIESEN
	    VA_S_d(10) <= vcc;

--  BANK SCHLIESSEN
	    DDR_SM_d <= "011101";
	 end if;
      when "011100" =>
	 if (DDR_SEL and (nFB_WR or (not LINE)))='1' and FB_AD(13 downto 12) /=
	       FIFO_BA then
	    VRAS <= vcc;
	    (VA12_2, VA11_2, VA10_2, VA9_2, VA8_2, VA7_2, VA6_2, VA5_2, VA4_2,
		  VA3_2, VA2_2, VA1_2, VA0_2) <= FB_AD(26 downto 14);
	    (BA1_2, BA0_2) <= FB_AD(13 downto 12);
	    CPU_AC_d <= vcc;

--  BUS CYCLUS LOSTRETEN
	    BUS_CYC_d_2 <= vcc;

--  AUTO PRECHARGE DA NICHT FIFO BANK
	    VA_S_d(10) <= vcc;
	    DDR_SM_d <= "000011";
	 else
	    VCAS <= vcc;
	    (VA12_2, VA11_2, VA10_2, VA9_2, VA8_2, VA7_2, VA6_2, VA5_2, VA4_2,
		  VA3_2, VA2_2, VA1_2, VA0_2) <= VA_P_q;
	    (BA1_2, BA0_2) <= BA_P_q;

--  DATEN WRITE FIFO
	    SR_FIFO_WRE_d <= vcc;

--  CONFIG CYCLUS
	    DDR_SM_d <= "011001";
	 end if;
      when "001000" =>
	 DDR_SM_d <= "001001";
      when "001001" =>
	 BUS_CYC_d_2 <= CPU_REQ_q;
	 DDR_SM_d <= "001010";
      when "001010" =>
	 if (CPU_REQ_q)='1' then
	    DDR_SM_d <= "001011";
	 else
	    DDR_SM_d <= "000000";
	 end if;
      when "001011" =>
	 DDR_SM_d <= "001100";
      when "001100" =>
	 VA_S_d <= FB_AD(12 downto 0);
	 BA_S_d <= FB_AD(14 downto 13);
	 DDR_SM_d <= "001101";
      when "001101" =>

--  NUR BEI LONG WRITE
	 VRAS <= FB_AD(18) and (not nFB_WR) and (not FB_SIZE0) and (not
	       FB_SIZE1);

--  NUR BEI LONG WRITE
	 VCAS <= FB_AD(17) and (not nFB_WR) and (not FB_SIZE0) and (not
	       FB_SIZE1);

--  NUR BEI LONG WRITE
	 VWE <= FB_AD(16) and (not nFB_WR) and (not FB_SIZE0) and (not
	       FB_SIZE1);

--  CLOSE FIFO BANK
	 DDR_SM_d <= "000111";
      when "011101" =>

--  AUF NOT OK
	 FIFO_BANK_NOT_OK <= vcc;

--  BÄNKE SCHLIESSEN
	 VRAS <= vcc;
	 VWE <= vcc;
	 DDR_SM_d <= "000110";
      when "011110" =>

--  AUF NOT OK
	 FIFO_BANK_NOT_OK <= vcc;

--  BÄNKE SCHLIESSEN
	 VRAS <= vcc;
	 VWE <= vcc;

--  REFRESH 70NS = 10 ZYCLEN
	 DDR_SM_d <= "000000";
      when "011111" =>

--  EIN CYCLUS VORLAUF UM BANKS ZU SCHLIESSEN
	 if DDR_REFRESH_SIG_q = "1001" then

--  ALLE BANKS SCHLIESSEN
	    VRAS <= vcc;
	    VWE <= vcc;
	    VA10_2 <= vcc;
	    FIFO_BANK_NOT_OK <= vcc;
	    DDR_SM_d <= "100001";
	 else
	    VCAS <= vcc;
	    VRAS <= vcc;
	    DDR_SM_d <= "100000";
	 end if;
      when "100000" =>
	 DDR_SM_d <= "100001";
      when "100001" =>
	 DDR_SM_d <= "100010";
      when "100010" =>
	 DDR_SM_d <= "100011";
      when "100011" =>

--  LEERSCHLAUFE
	 DDR_SM_d <= "000100";
      when "000100" =>
	 DDR_SM_d <= "000101";
      when "000101" =>
	 DDR_SM_d <= "000110";
      when "000110" =>
	 DDR_SM_d <= "000111";
      when "000111" =>
	 DDR_SM_d <= "000000";
      when others =>
      end case;
      stdVec6 := (others=>'0');  -- no storage needed
   end process;

-- -------------------------------------------------------------
--  BLITTER ----------------------
-- ---------------------------------------
   BLITTER_REQ_clk <= DDRCLK0;
   BLITTER_REQ_d <= BLITTER_SIG and (not DDR_CONFIG) and VCKE and (not nVCS);
   BLITTER_ROW_ADR <= BLITTER_ADR(26 downto 14);
   BLITTER_BA(1) <= BLITTER_ADR(13);
   BLITTER_BA(0) <= BLITTER_ADR(12);
   BLITTER_COL_ADR <= BLITTER_ADR(11 downto 2);

-- ----------------------------------------------------------------------------
--  FIFO ---------------------------------
-- ------------------------------------------------------
   FIFO_REQ_clk <= DDRCLK0;
   FIFO_REQ_d <= (to_std_logic((unsigned(FIFO_MW) < unsigned'("011001000"))) or
	 (to_std_logic((unsigned(FIFO_MW) < unsigned'("111110100"))) and
	 FIFO_REQ_q)) and FIFO_ACTIVE and (not CLEAR_FIFO_CNT_q) and (not
	 STOP_q) and (not DDR_CONFIG) and VCKE and (not nVCS);
   FIFO_ROW_ADR <= VIDEO_ADR_CNT_q(22 downto 10);
   FIFO_BA(1) <= VIDEO_ADR_CNT_q(9);
   FIFO_BA(0) <= VIDEO_ADR_CNT_q(8);
   FIFO_COL_ADR <= std_logic_vector'(VIDEO_ADR_CNT_q(7) & VIDEO_ADR_CNT_q(6) &
	 VIDEO_ADR_CNT_q(5) & VIDEO_ADR_CNT_q(4) & VIDEO_ADR_CNT_q(3) &
	 VIDEO_ADR_CNT_q(2) & VIDEO_ADR_CNT_q(1) & VIDEO_ADR_CNT_q(0) & "00");
   FIFO_BANK_OK_clk <= DDRCLK0;
   FIFO_BANK_OK_d_2 <= FIFO_BANK_OK_q and (not FIFO_BANK_NOT_OK);

--  ZÄHLER RÜCKSETZEN WENN CLR FIFO ----------------
   CLR_FIFO_SYNC_clk <= DDRCLK0;

--  SYNCHRONISIEREN
   CLR_FIFO_SYNC_d <= CLR_FIFO;
   CLEAR_FIFO_CNT_clk <= DDRCLK0;
   CLEAR_FIFO_CNT_d <= CLR_FIFO_SYNC_q or (not FIFO_ACTIVE);
   STOP_clk <= DDRCLK0;
   STOP_d <= CLR_FIFO_SYNC_q or CLEAR_FIFO_CNT_q;

--  ZÄHLEN -----------------------------------------------
   VIDEO_ADR_CNT0_clk_ctrl <= DDRCLK0;
   VIDEO_ADR_CNT0_ena_ctrl <= SR_FIFO_WRE_q or CLEAR_FIFO_CNT_q;
   VIDEO_ADR_CNT_d <= (sizeIt(CLEAR_FIFO_CNT_q,23) and VIDEO_BASE_ADR) or
	 (sizeIt(not CLEAR_FIFO_CNT_q,23) and
	 (std_logic_vector'(unsigned(VIDEO_ADR_CNT_q) +
	 unsigned'("00000000000000000000001"))));
   VIDEO_BASE_ADR(22 downto 20) <= VIDEO_BASE_X_D_q;
   VIDEO_BASE_ADR(19 downto 12) <= VIDEO_BASE_H_D_q;
   VIDEO_BASE_ADR(11 downto 4) <= VIDEO_BASE_M_D_q;
   VIDEO_BASE_ADR(3 downto 0) <= VIDEO_BASE_L_D_q(7 downto 4);
   VDM_SEL <= VIDEO_BASE_L_D_q(3 downto 0);

--  AKTUELLE VIDEO ADRESSE
   VIDEO_ACT_ADR(26 downto 4) <= std_logic_vector'(unsigned(VIDEO_ADR_CNT_q) -
	 unsigned(std_logic_vector'("00000000000000" & FIFO_MW)));
   VIDEO_ACT_ADR(3 downto 0) <= VDM_SEL;

-- ---------------------------------------------------------------------------------------
--  REFRESH: IMMER 8 AUFS MAL, ANFORDERUNG ALLE 7.8us X 8 STCK. = 62.4us = 2059->2048 33MHz CLOCKS
-- ---------------------------------------------------------------------------------------
   DDR_REFRESH_CNT0_clk_ctrl <= CLK33M;

--  ZÄHLEN 0-2047
   DDR_REFRESH_CNT_d <= std_logic_vector'(unsigned(DDR_REFRESH_CNT_q) +
	 unsigned'("00000000001"));
   REFRESH_TIME_clk <= DDRCLK0;

--  SYNC
   REFRESH_TIME_d <= to_std_logic(DDR_REFRESH_CNT_q = "00000000000") and (not
	 MAIN_CLK);
   DDR_REFRESH_SIG0_clk_ctrl <= DDRCLK0;
   DDR_REFRESH_SIG0_ena_ctrl <= to_std_logic(REFRESH_TIME_q='1' or DDR_SM_q =
	 "100011");

--  9 STÜCK (8 REFRESH UND 1 ALS VORLAUF)
--  MINUS 1 WENN GEMACHT
   DDR_REFRESH_SIG_d <= (sizeIt(REFRESH_TIME_q,4) and "1001" and
	 sizeIt(DDR_REFRESH_ON,4) and sizeIt(not DDR_CONFIG,4)) or (sizeIt(not
	 REFRESH_TIME_q,4) and (std_logic_vector'(unsigned(DDR_REFRESH_SIG_q) -
	 unsigned'("0001"))) and sizeIt(DDR_REFRESH_ON,4) and sizeIt(not
	 DDR_CONFIG,4));
   DDR_REFRESH_REQ_clk <= DDRCLK0;
   DDR_REFRESH_REQ_d <= to_std_logic(DDR_REFRESH_SIG_q /= "0000") and
	 DDR_REFRESH_ON and (not REFRESH_TIME_q) and (not DDR_CONFIG);

-- ---------------------------------------------------------
--  VIDEO REGISTER -----------------------
-- -------------------------------------------------------------------------------------------------------------------
   VIDEO_BASE_L_D0_clk_ctrl <= MAIN_CLK;

--  820D/2
   VIDEO_BASE_L <= to_std_logic(((not nFB_CS1)='1') and FB_ADR(19 downto 1) =
	 "1111100000100000110");

--  SORRY, NUR 16 BYT GRENZEN
   VIDEO_BASE_L_D_d <= FB_AD(23 downto 16);
   VIDEO_BASE_L_D0_ena_ctrl <= (not nFB_WR) and VIDEO_BASE_L and FB_B(1);
   VIDEO_BASE_M_D0_clk_ctrl <= MAIN_CLK;

--  8203/2
   VIDEO_BASE_M <= to_std_logic(((not nFB_CS1)='1') and FB_ADR(19 downto 1) =
	 "1111100000100000001");
   VIDEO_BASE_M_D_d <= FB_AD(23 downto 16);
   VIDEO_BASE_M_D0_ena_ctrl <= (not nFB_WR) and VIDEO_BASE_M and FB_B(3);
   VIDEO_BASE_H_D0_clk_ctrl <= MAIN_CLK;

--  8200-1/2
   VIDEO_BASE_H <= to_std_logic(((not nFB_CS1)='1') and FB_ADR(19 downto 1) =
	 "1111100000100000000");
   VIDEO_BASE_H_D_d <= FB_AD(23 downto 16);
   VIDEO_BASE_H_D0_ena_ctrl <= (not nFB_WR) and VIDEO_BASE_H and FB_B(1);
   VIDEO_BASE_X_D0_clk_ctrl <= MAIN_CLK;
   VIDEO_BASE_X_D_d <= FB_AD(26 downto 24);
   VIDEO_BASE_X_D0_ena_ctrl <= (not nFB_WR) and VIDEO_BASE_H and FB_B(0);

--  8209/2
   VIDEO_CNT_L <= to_std_logic(((not nFB_CS1)='1') and FB_ADR(19 downto 1) =
	 "1111100000100000100");

--  8207/2
   VIDEO_CNT_M <= to_std_logic(((not nFB_CS1)='1') and FB_ADR(19 downto 1) =
	 "1111100000100000011");

--  8204,5/2
   VIDEO_CNT_H <= to_std_logic(((not nFB_CS1)='1') and FB_ADR(19 downto 1) =
	 "1111100000100000010");

--  FB_AD[31..24] = lpm_bustri_BYT(
--                         VIDEO_BASE_H  & (0, VIDEO_BASE_X_D[])
--                       # VIDEO_CNT_H   & (0, VIDEO_ACT_ADR[26..24]),
--                        (VIDEO_BASE_H # VIDEO_CNT_H) & !nFB_OE); 
   u0_data <= (sizeIt(VIDEO_BASE_L,8) and VIDEO_BASE_L_D_q) or
	 (sizeIt(VIDEO_BASE_M,8) and VIDEO_BASE_M_D_q) or
	 (sizeIt(VIDEO_BASE_H,8) and VIDEO_BASE_H_D_q) or
	 (sizeIt(VIDEO_CNT_L,8) and VIDEO_ACT_ADR(7 downto 0)) or
	 (sizeIt(VIDEO_CNT_M,8) and VIDEO_ACT_ADR(15 downto 8)) or
	 (sizeIt(VIDEO_CNT_H,8) and VIDEO_ACT_ADR(23 downto 16));
   u0_enabledt <= (VIDEO_BASE_L or VIDEO_BASE_M or VIDEO_BASE_H or VIDEO_CNT_L
	 or VIDEO_CNT_M or VIDEO_CNT_H) and (not nFB_OE);
   FB_AD(23 downto 16) <= u0_tridata;


-- Assignments added to explicitly combine the
-- effects of multiple drivers in the source
   FIFO_BANK_OK_d <= FIFO_BANK_OK_d_1 or FIFO_BANK_OK_d_2;
   BUS_CYC_d <= BUS_CYC_d_1 or BUS_CYC_d_2;
   BA(0) <= BA0_1 or BA0_2;
   BA(1) <= BA1_1 or BA1_2;
   VA(0) <= VA0_1 or VA0_2;
   VA(1) <= VA1_1 or VA1_2;
   VA(2) <= VA2_1 or VA2_2;
   VA(3) <= VA3_1 or VA3_2;
   VA(4) <= VA4_1 or VA4_2;
   VA(5) <= VA5_1 or VA5_2;
   VA(6) <= VA6_1 or VA6_2;
   VA(7) <= VA7_1 or VA7_2;
   VA(8) <= VA8_1 or VA8_2;
   VA(9) <= VA9_1 or VA9_2;
   VA(10) <= VA10_1 or VA10_2;
   VA(11) <= VA11_1 or VA11_2;
   VA(12) <= VA12_1 or VA12_2;

-- Define power signal(s)
   vcc <= '1';
   gnd <= '0';
end DDR_CTR_behav;