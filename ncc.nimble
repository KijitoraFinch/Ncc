# Package

version       = "0.1.0"
author        = "Kaoru Kawabata / KijiroraFinch"
description   = "WIP"
license       = "MIT"
srcDir        = "src"
bin           = @["ncc"]


# Dependencies

requires "nim >= 2.0.8"

task makeTest, "execute test.sh":
  exec("./test.sh")

task makeClean, "Remove tmp*":
  exec("rm -f tmp*")