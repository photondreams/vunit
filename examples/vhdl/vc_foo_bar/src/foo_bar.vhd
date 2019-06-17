-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2014-2019, Lars Asplund lars.anders.asplund@gmail.com

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;
context vunit_lib.vc_context;

library ieee;
use ieee.std_logic_1164.all;

use work.foo_bar_pkg.all;

-- foo_bar is a verification component (VC). foo is often an interface and bar a
-- domain specific actor on such an interface. For example wishbone_master and
-- avalon_source
entity foo_bar is
  generic(
    foo_bar_h : foo_bar_handle_t -- foo_bar_h is the handle unique to every instance
                                 -- of foo_bar
  );
  port(
    -- Signals to connect to the foo interface. The clock is often generated
    -- externally (hence an input rather than an output)
    foo_clk : in std_logic;
    foo_input_on_dut : out std_logic;
    foo_output_on_dut : in std_logic
  );
end entity;

architecture a of foo_bar is
  procedure transaction_1(arg_1 : integer; arg_2 : boolean) is
  begin
    -- Do some pin wiggling
  end;

  procedure transaction_2(arg_1 : integer; arg_2 : boolean) is
  begin
    -- Do some pin wiggling
  end;
begin

  controller : process
    variable msg : msg_t;
    variable msg_type : msg_type_t;
  begin
    receive(net, foo_bar_h.p_actor, msg);

    msg_type := message_type(msg);

    -- The sync VCI is useful for any VC
    handle_sync_message(net, msg_type, msg);

    if msg_type = transaction_1_msg then
      transaction_1(pop_integer(msg), pop_boolean(msg));

    elsif msg_type = transaction_2_msg then
      transaction_2(pop_integer(msg), pop_boolean(msg));

    elsif foo_bar_h.p_fail_on_unexpected_msg_type then
      unexpected_msg_type(msg_type, get_logger(foo_bar_h.p_checker));
    end if;
  end process;
end architecture;

