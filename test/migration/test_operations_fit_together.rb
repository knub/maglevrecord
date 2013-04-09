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


