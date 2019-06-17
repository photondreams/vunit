-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2014-2019, Lars Asplund lars.anders.asplund@gmail.com

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.vc_context;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;

library vc_foo_bar_lib;
use vc_foo_bar_lib.foo_bar_pkg.all;

entity tb_foo_bar is
  generic(
    runner_cfg : string
  );
end entity;

architecture tb of tb_foo_bar is
  constant clk_period : time := 10 ns;

  constant foo_bar_h : foo_bar_handle_t := new_foo_bar;

  signal foo_clk : std_logic := '0';
  signal foo_input_on_dut : std_logic;
  signal foo_output_on_dut : std_logic;
begin
  main : process
  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      if run("Test command transaction") then
        error("Not implemented");
      elsif run("Test blocking transaction with response") then
        error("Not implemented");
      elsif run("Test non-blocking transaction with response") then
        error("Not implemented");
      end if;
    end loop;

    test_runner_cleanup(runner);
  end process;

  foo_clk <= foo_clk after clk_period / 2;

  vc_foo_bar : entity vc_foo_bar_lib.foo_bar
    generic map(
      foo_bar_h => foo_bar_h
    )
    port map(
      foo_clk => foo_clk,
      foo_input_on_dut => foo_input_on_dut,
      foo_output_on_dut => foo_output_on_dut
    );

  dut : process
  begin
    wait until rising_edge(foo_clk);
    foo_output_on_dut <= foo_input_on_dut;
  end process;
end architecture;
