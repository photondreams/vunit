-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2017, Lars Asplund lars.anders.asplund@gmail.com

context work.vunit_context;
use work.com_types_pkg.all;

package com_support_pkg is
  procedure check (
    expr      : boolean;
    err       : com_status_t;
    msg       : string  := "";
    line_num  : natural := 0;
    file_name : string  := "");
  procedure check_failed (
    err       : com_error_t;
    msg       : string  := "";
    line_num  : natural := 0;
    file_name : string  := "");
  impure function check (
    expr      : boolean;
    err       : com_status_t;
    msg       : string  := "";
    line_num  : natural := 0;
    file_name : string  := "") return boolean;
end package com_support_pkg;

package body com_support_pkg is

  constant logger : logger_t := get_logger("vunit_lib:com");

  procedure check_failed (
    err       : com_error_t;
    msg       : string  := "";
    line_num  : natural := 0;
    file_name : string  := "") is
    constant err_msg             : string := replace(com_error_t'image(err), '_', ' ');
    alias err_msg_aligned        : string(1 to err_msg'length) is err_msg;
    constant err_msg_capitalized : string := upper(err_msg_aligned) & ".";
  begin
    if msg /= "" then
      failure(logger, err_msg_capitalized & " " & msg, line_num => line_num, file_name => file_name);
    else
      failure(logger, err_msg_capitalized, line_num => line_num, file_name => file_name);
    end if;
  end;

  procedure check (
    expr      : boolean;
    err       : com_status_t;
    msg       : string  := "";
    line_num  : natural := 0;
    file_name : string  := "") is
  begin
    if not expr then
      check_failed(err, msg, line_num => line_num, file_name => file_name);
    end if;
  end;

  impure function check (
    expr      : boolean;
    err       : com_status_t;
    msg       : string  := "";
    line_num  : natural := 0;
    file_name : string  := "") return boolean is
  begin
    check(expr, err, msg, line_num => line_num, file_name => file_name);
    return expr;
  end;
end package body com_support_pkg;