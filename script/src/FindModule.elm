module FindModule exposing (run)

import BackendTask exposing (BackendTask)
import BackendTask.File
import BackendTask.Http
import Cli.Option as Option
import Cli.OptionsParser as OptionsParser
import Cli.Program as Program
import Dict exposing (Dict)
import FatalError exposing (FatalError)
import Json.Decode exposing (Decoder)
import List.Extra
import Pages.Script as Script exposing (Script)


type alias PackageDescription =
    { name : String
    , exposedModules : List String
    }


packageDescriptionDecoder : Decoder PackageDescription
packageDescriptionDecoder =
    Json.Decode.map2 PackageDescription
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "exposed-modules" exposedModulesDecoder)


exposedModulesDecoder : Decoder (List String)
exposedModulesDecoder =
    Json.Decode.oneOf
        [ Json.Decode.list Json.Decode.string
        , Json.Decode.dict (Json.Decode.list Json.Decode.string)
            |> Json.Decode.map Dict.values
            |> Json.Decode.map List.concat
        ]


programConfig : Program.Config String
programConfig =
    Program.config
        |> Program.add
            (OptionsParser.build identity
                |> OptionsParser.with (Option.requiredPositionalArg "Module.Name")
            )


getPackageDescription : String -> BackendTask.BackendTask FatalError PackageDescription
getPackageDescription packageName =
    BackendTask.Http.getJson
        ("https://package.elm-lang.org/packages/" ++ packageName ++ "/elm.json")
        packageDescriptionDecoder
        |> BackendTask.allowFatal


readDependencies : BackendTask FatalError (Dict String String)
readDependencies =
    BackendTask.File.jsonFile
        (Json.Decode.at [ "dependencies", "direct" ]
            (Json.Decode.dict Json.Decode.string)
        )
        "elm.json"
        |> BackendTask.allowFatal


findDependencyExposingModule : String -> List PackageDescription -> Maybe PackageDescription
findDependencyExposingModule moduleName packageDescriptions =
    List.Extra.find (\packageDescription -> List.member moduleName packageDescription.exposedModules) packageDescriptions


createPrintStatement : String -> Maybe PackageDescription -> String
createPrintStatement moduleName maybePackageDescription =
    case maybePackageDescription of
        Just packageDescription ->
            "\nPakken som exposer modulen `" ++ moduleName ++ "` er:\n\n    " ++ packageDescription.name

        Nothing ->
            "\nFant ingen dependencies i elm.json som exposer modulen `" ++ moduleName ++ "`"


run : Script
run =
    Script.withCliOptions programConfig
        (\moduleName ->
            readDependencies
                |> BackendTask.andThen
                    (\dependencyDict ->
                        Dict.toList dependencyDict
                            |> List.map (\( key, value ) -> getPackageDescription (key ++ "/" ++ value))
                            |> BackendTask.combine
                    )
                |> BackendTask.map (findDependencyExposingModule moduleName)
                |> BackendTask.map (createPrintStatement moduleName)
                |> BackendTask.andThen (\printStatement -> Script.log printStatement)
        )
