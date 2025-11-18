local Process = require("./util/Process")

Process.new("rojo")
    :argument("build")
    :argument("default.project.json")
    :argument("-o")
    :argument("hammer.rbxm")
    :inherit_stdout()
    :run()
