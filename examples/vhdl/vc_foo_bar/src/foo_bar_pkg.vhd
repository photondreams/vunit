-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2014-2019, Lars Asplund lars.anders.asplund@gmail.com

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;
context vunit_lib.vc_context;

-- foo_bar_pkg defines the verification component interface (VCI)
package foo_bar_pkg is
  -- The type of a VC instance handle. It contains the properties that can be
  -- configured when a new instance is created. p_* means that the content of
  -- the record is private and the user is not supposed to access these fields
  -- directly. It should be possible jto change the contents of the record
  -- without breaking backward compatibility.
  type foo_bar_handle_t is record
    p_actor : actor_t;
    p_logger : logger_t;
    p_checker : checker_t;
    p_fail_on_unexpected_msg_type : boolean;
  end record;

  -- Transaction messages used to control the VC. Not used directly by a user of the VC.
  -- Someone writing another VC reusing this VCI would know about these messages.
  constant transaction_1_msg : msg_type_t := new_msg_type("transaction 1");
  constant transaction_2_msg : msg_type_t := new_msg_type("transaction 2");

  -- Creates a new VC instance handle
  impure function new_foo_bar(
    logger : logger_t := null_logger;
    actor : actor_t := null_actor;
    checker : checker_t := null_checker;
    fail_on_unexpected_msg_type : boolean := true
  ) return foo_bar_handle_t;

  procedure transaction_1(
    signal net : inout network_t;
    foo_bar_h : foo_bar_handle_t;
    arg_1 : integer;
    arg_2 : boolean
  );

  procedure transaction_2(
    signal net : inout network_t;
    foo_bar_h : foo_bar_handle_t;
    arg_1 : integer;
    arg_2 : boolean
  );

  impure function as_sync(
    foo_bar_h : foo_bar_handle_t
  ) return sync_handle_t;

end package;

package body foo_bar_pkg is
  impure function new_foo_bar(
    logger : logger_t := null_logger; -- Enables full control of reporting
    actor : actor_t := null_actor; -- Enables full control over messaging
    checker : checker_t := null_checker; -- Enables separation between error reporting and other reporting
    fail_on_unexpected_msg_type : boolean := true -- The presence of unexpected messages depends on the VC
                                                  -- context so whether or not this is an error must be under user control.
  ) return foo_bar_handle_t is
    variable p_logger : logger_t := logger;
    variable p_actor : actor_t := actor;
    variable p_checker : checker_t := checker;
  begin
    if logger = null_logger then
      p_logger := get_logger("foo_bar");
    end if;

    if actor = null_actor then
      p_actor := new_actor;
    end if;

    if checker = null_checker then
      if logger = null_logger then
        p_checker := new_checker(p_logger);
      else
        p_checker := new_checker(logger);
      end if;
    end if;

    return (
      p_logger => p_logger,
      p_actor => p_actor,
      p_checker => p_checker,
      p_fail_on_unexpected_msg_type => fail_on_unexpected_msg_type
    );
  end;

  procedure transaction_1(
    signal net : inout network_t;
    foo_bar_h : foo_bar_handle_t;
    arg_1 : integer;
    arg_2 : boolean
  ) is
    variable msg : msg_t;
  begin
    msg := new_msg(transaction_1_msg);
    push(msg, arg_1);
    push(msg, arg_2);
    send(net, foo_bar_h.p_actor, msg);
  end procedure;

  procedure transaction_2(
    signal net : inout network_t;
    foo_bar_h : foo_bar_handle_t;
    arg_1 : integer;
    arg_2 : boolean
  ) is
    variable msg : msg_t;
  begin
    msg := new_msg(transaction_2_msg);
    push(msg, arg_1);
    push(msg, arg_2);
    send(net, foo_bar_h.p_actor, msg);
  end procedure;

  impure function as_sync(foo_bar_h : foo_bar_handle_t) return sync_handle_t is
  begin
    return foo_bar_h.p_actor;
  end;

end package body;

