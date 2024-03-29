module LaunchUrls exposing (run)

import BackendTask exposing (BackendTask)
import BackendTask.Custom
import Cli.Option as Option
import Cli.OptionsParser as OptionsParser
import Cli.Program as Program
import FatalError exposing (FatalError)
import Json.Decode
import Json.Encode
import Pages.Script as Script exposing (Script)
import Url exposing (Url)


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


parseUrl : String -> BackendTask FatalError Url
parseUrl string =
    string
        |> Url.fromString
        |> Maybe.map BackendTask.succeed
        |> Maybe.withDefault (BackendTask.fail (FatalError.fromString ("'" ++ string ++ "' er ikke en gyldig url")))


type alias UrlData =
    { stageDomain : String
    , prodDomain : String
    , path : String
    }


parse urlStrings =
    urlStrings
        |> List.map parseUrl
        |> BackendTask.combine
        |> BackendTask.andThen createUrlDatas


norwegianStageDomain =
    "digitalekanaler-web.vydev.io"


swedishStageDomain =
    "se.digitalekanaler-web.vydev.io"


createUrlDatas : List Url -> BackendTask FatalError (List UrlData)
createUrlDatas urls =
    urls
        |> List.map createUrlData
        |> BackendTask.combine


createUrlData : Url -> BackendTask FatalError UrlData
createUrlData url =
    if url.host == norwegianStageDomain then
        BackendTask.succeed
            { stageDomain = norwegianStageDomain
            , prodDomain = "www.vy.no"
            , path = url.path
            }

    else if url.host == swedishStageDomain then
        BackendTask.succeed
            { stageDomain = swedishStageDomain
            , prodDomain = "www.vy.se"
            , path = url.path
            }

    else
        BackendTask.fail (FatalError.fromString ("'" ++ Url.toString url ++ "' har ikke et gyldig domene"))


printJsCode : List UrlData -> BackendTask FatalError ()
printJsCode urlData =
    let
        jsCode =
            urlData
                |> List.map .path
                |> List.map (\path -> "'" ++ path ++ "',")
                |> String.join "\n"
    in
    Script.log ("\n\nJavaScript-kode:\n" ++ jsCode ++ "\n\n")


stageUrl : UrlData -> String
stageUrl { stageDomain, path } =
    "https://" ++ stageDomain ++ path


prodUrl : UrlData -> String
prodUrl { prodDomain, path } =
    "https://" ++ prodDomain ++ path


openUrls : List String -> BackendTask FatalError ()
openUrls urls =
    case urls of
        first :: rest ->
            BackendTask.Custom.run "openChrome"
                (Json.Encode.string first)
                (Json.Decode.succeed ())
                |> BackendTask.allowFatal
                |> BackendTask.andThen (\_ -> openUrls rest)

        [] ->
            BackendTask.succeed ()


printCodeAndOpenTabs : List UrlData -> BackendTask FatalError ()
printCodeAndOpenTabs urlData =
    let
        stageUrls =
            urlData
                |> List.map stageUrl

        prodUrls =
            urlData
                |> List.map prodUrl
    in
    openUrls stageUrls
        |> BackendTask.andThen (\_ -> openUrls prodUrls)
        |> BackendTask.andThen (\_ -> printJsCode urlData)


script : List String -> BackendTask FatalError ()
script urls =
    urls
        |> parse
        |> BackendTask.andThen printCodeAndOpenTabs
