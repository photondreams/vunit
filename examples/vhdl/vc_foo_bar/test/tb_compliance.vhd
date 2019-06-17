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

entity tb_compliance is
  generic(
    use_custom_logger : boolean := false;
    use_custom_actor : boolean := false;
    use_custom_checker : boolean := false;
    fail_on_unexpected_msg_type : boolean := true;
    runner_cfg : string
  );
end entity;

architecture tb of tb_compliance is
  constant custom_actor : actor_t := new_actor("foo_bar", inbox_size => 1);
  constant custom_logger : logger_t := get_logger("custom logger");
  constant custom_checker : checker_t := new_checker("custom checker");

  impure function create_handle return foo_bar_handle_t is
    variable logger : logger_t;
    variable actor : actor_t;
    variable checker : checker_t;
  begin
    logger := custom_logger when use_custom_logger else null_logger;
    actor := custom_actor when use_custom_actor else null_actor;
    checker := custom_checker when use_custom_checker else null_checker;

    return new_foo_bar(
      logger => logger,
      actor => actor,
      checker => checker,
      fail_on_unexpected_msg_type => fail_on_unexpected_msg_type);
  end;

  constant foo_bar_h : foo_bar_handle_t := create_handle;
  constant unexpected_msg : msg_type_t := new_msg_type("unexpected msg");

  signal foo_clk : std_logic;
  signal foo_output_on_dut : std_logic;
begin
  main : process
    variable t_start : time;
    variable msg : msg_t;
    constant default_logger : logger_t := get_logger("foo_bar");
  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop

      if run("Test that the sync interface is supported") then
        t_start := now;
        wait_for_time(net, as_sync(foo_bar_h), 1 ns);
        wait_for_time(net, as_sync(foo_bar_h), 2 ns);
        wait_for_time(net, as_sync(foo_bar_h), 3 ns);
        check_equal(now - t_start, 0 ns);
        t_start := now;
        wait_until_idle(net, as_sync(foo_bar_h));
        check_equal(now - t_start, 6 ns);
      elsif run("Test that the actor can be customized") then
        t_start := now;
        wait_for_time(net, as_sync(foo_bar_h), 1 ns);
        wait_for_time(net, as_sync(foo_bar_h), 2 ns);
        check_equal(now - t_start, 0 ns);
        wait_for_time(net, as_sync(foo_bar_h), 3 ns);
        check_equal(now - t_start, 1 ns);
        wait_until_idle(net, as_sync(foo_bar_h));
        check_equal(now - t_start, 6 ns);
      elsif run("Test unexpected message handling") then
        mock(default_logger);
        msg := new_msg(unexpected_msg);
        send(net, custom_actor, msg);
        wait for 1 ns;
        if fail_on_unexpected_msg_type then
          check_only_log(default_logger, "Got unexpected message unexpected msg", failure);
        else
          check_no_log;
        end if;
        unmock(default_logger);
      elsif run("Test that the logger can be customized") then
        mock(custom_logger);
        msg := new_msg(unexpected_msg);
        send(net, custom_actor, msg);
        wait for 1 ns;
        check_only_log(custom_logger, "Got unexpected message unexpected msg", failure);
        unmock(custom_logger);
      elsif run("Test that the checker can be customized") then
        mock(get_logger(custom_checker));
        msg := new_msg(unexpected_msg);
        send(net, custom_actor, msg);
        wait for 1 ns;
        check_only_log(get_logger(custom_checker), "Got unexpected message unexpected msg", failure);
        unmock(get_logger(custom_checker));
      end if;
    end loop;

    test_runner_cleanup(runner);
  end process;

  vc_foo_bar : entity vc_foo_bar_lib.foo_bar
    generic map(
      foo_bar_h => foo_bar_h
    )
    port map(
      foo_clk => foo_clk,
      foo_input_on_dut => open,
      foo_output_on_dut => foo_output_on_dut
    );
end architecture;
