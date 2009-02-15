require "minitest/unit"
$LOAD_PATH << "../lib"

Dir.glob("**/test_*.rb"){|f| require(f)}
MiniTest::Unit.autorun
