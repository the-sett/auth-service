port module Auth.State exposing (init, isLoggedIn)

import Http
import Http.Decorators
import Auth.Types exposing (..)
import Task exposing (Task)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)


init : Model
init =
    { token = ""
    }


isLoggedIn : Model -> Bool
isLoggedIn model =
    if model.token == "" then
        False
    else
        True


api =
    "http://localhost:9070/auth"


routes =
    { loginUrl = api ++ "login"
    , logoutUrl = api ++ "logout"
    , refreshUrl = api ++ "refresh"
    }


authRequestEncoder : AuthRequest -> Encode.Value
authRequestEncoder model =
    Encode.object
        [ ( "username", Encode.string model.username )
        , ( "password", Encode.string model.password )
        ]


tokenDecoder : Decoder String
tokenDecoder =
    "id_token" := Decode.string


login : AuthRequest -> String -> Task Http.Error String
login model apiUrl =
    { verb = "POST"
    , headers = [ ( "Content-Type", "application/json" ) ]
    , url = apiUrl
    , body = Http.string <| Encode.encode 0 <| authRequestEncoder model
    }
        |> Http.send Http.defaultSettings
        |> Http.fromJson tokenDecoder


loginCmd : AuthRequest -> String -> Cmd Msg
loginCmd model apiUrl =
    Task.perform AuthError GetTokenSuccess <| login model routes.loginUrl


setStorageHelper : Model -> ( Model, Cmd Msg )
setStorageHelper model =
    ( model, setStorage model )


port setStorage : Model -> Cmd msg


port removeStorage : Model -> Cmd msg
