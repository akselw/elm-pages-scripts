module Hello exposing (run)

import Pages.Script as Script exposing (Script)

run : Script
run =
    Script.withoutCliOptions (Script.log "Hello, Elm-faggruppa!")
