# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2014-2019, Lars Asplund lars.anders.asplund@gmail.com

from os.path import join, dirname
from vunit import VUnit

root = dirname(__file__)

ui = VUnit.from_argv()
ui.add_com();
ui.add_verification_components()

vc_foo_bar_lib = ui.add_library("vc_foo_bar_lib")
vc_foo_bar_lib.add_source_files(join(root, "src", "*.vhd"))
vc_foo_bar_lib.add_source_files(join(root, "test", "*.vhd"))

tb_compliance = vc_foo_bar_lib.test_bench("tb_compliance")
test = tb_compliance.test("Test that the actor can be customized")
test.set_generic("use_custom_actor", True)

test = tb_compliance.test("Test unexpected message handling")
for fail_on_unexpected_msg_type in [False, True]:
    test.add_config(name="fail_on_unexpected_msg_type=%s" % str(fail_on_unexpected_msg_type),
                    generics = dict(fail_on_unexpected_msg_type=fail_on_unexpected_msg_type, use_custom_actor=True))
                    
test = tb_compliance.test("Test that the logger can be customized")
test.set_generic("use_custom_actor", True)
test.set_generic("use_custom_logger", True)

test = tb_compliance.test("Test that the checker can be customized")
test.set_generic("use_custom_actor", True)
test.set_generic("use_custom_checker", True)

ui.main()
