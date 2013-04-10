require "maglev_record"
require "migration/operation_setup"
require "more_asserts"
require 'time'

################## make sure renamed classes can be migrated even if they are not yet existent
#
# TODO
#
# imagine a system with out a class A and the following migrations to be applied:
#
# rename A to B
# rename B to C
#
# this must work!
#
# 2) von rooted base nach base
#
# 3) fail silently vs. do not execute
#    3.1) Migration touches :ModelClass => not executed if not present
#    3.2) ModelClass contant returns Null Object that can be migrated but does nothing


