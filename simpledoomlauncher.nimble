# Package

version       = "1.01"
author        = "much obliged"
description   = "Just a simple Doom launcher"
license       = "MIT"
srcDir        = "src"
backend       = "cpp"
bin           = @["SimpleDoomLauncher"]
binDir        = "build"

# Dependencies

requires "nim >= 2.2.10", "nimgl >= 1.3.2", "tinydialogs >= 1.1.2"
