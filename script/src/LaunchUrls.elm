module LaunchUrls exposing (run)

import BackendTask exposing (BackendTask)
import Cli.Option as Option
import Cli.OptionsParser as OptionsParser
import Cli.Program as Program
import FatalError exposing (FatalError)
import Pages.Script as Script exposing (Script)


programConfig : Program.Config (List String)
programConfig =
    Program.config
        |> Program.add
            (OptionsParser.build identity
                |> OptionsParser.withRestArgs (Option.restArgs "urls")
            )


run : Script
run =
    Script.withCliOptions programConfig script


script : List String -> BackendTask FatalError ()
script urls =
    Script.log (String.join "\n" urls)
