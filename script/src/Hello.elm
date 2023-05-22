module Hello exposing (run)

import BackendTask
import BackendTask.Http
import FatalError exposing (FatalError)
import Json.Decode exposing (Decoder)
import Pages.Script as Script exposing (Script)


packageDescriptionDecoder : Decoder String
packageDescriptionDecoder =
    Json.Decode.field "summary" Json.Decode.string


getPackageDescription : String -> BackendTask.BackendTask FatalError String
getPackageDescription packageName =
    BackendTask.Http.getJson
        ("https://package.elm-lang.org/packages/" ++ packageName ++ "/latest/elm.json")
        packageDescriptionDecoder
        |> BackendTask.allowFatal


run : Script
run =
    Script.withoutCliOptions
        (getPackageDescription "elm/html"
            |> BackendTask.andThen (\s -> Script.log s)
        )
