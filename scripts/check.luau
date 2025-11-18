local Process = require("./util/Process")

Process.new("stylua")
    :argument("--respect-ignores")
    :argument("--check")
    :argument("lib/")
    :inherit_stdout()
    :run()

Process.new("selene"):argument("lib/"):inherit_stdout():run()

Process.new("zune")
    :argument("test")
    :argument("tests/suite")
    :inherit_stdout()
    :run()
