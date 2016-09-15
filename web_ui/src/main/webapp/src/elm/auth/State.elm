port module Auth.State exposing (update, init, isLoggedIn, loginCmd)

import Log
import Http
import Http.Decorators
import Auth.Types exposing (..)
import Task exposing (Task)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)


init : Model
init =
    { token = ""
    , errorMsg = ""
    }


isLoggedIn : Model -> Bool
isLoggedIn model =
    if model.token == "" then
        False
    else
        True


api =
    "/auth/"


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


login : AuthRequest -> Task Http.Error String
login model =
    { verb = "POST"
    , headers = [ ( "Content-Type", "application/json" ) ]
    , url = routes.loginUrl
    , body = Http.string <| Encode.encode 0 <| authRequestEncoder model
    }
        |> Http.send Http.defaultSettings
        |> Http.fromJson tokenDecoder


loginCmd : AuthRequest -> Cmd Msg
loginCmd model =
    Task.perform AuthError GetTokenSuccess <| login model


setStorageHelper : Model -> ( Model, Cmd Msg )
setStorageHelper model =
    ( model, setStorage model )


port setStorage : Model -> Cmd msg


port removeStorage : Model -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    update' (Log.debug "auth" action) model


update' : Msg -> Model -> ( Model, Cmd Msg )
update' msg model =
    case msg of
        HttpError _ ->
            ( model, Cmd.none )

        AuthError error ->
            ( { model | errorMsg = (toString error) }, Cmd.none )

        GetTokenSuccess newToken ->
            setStorageHelper { model | token = newToken }

        LogIn authRequest ->
            ( model, loginCmd authRequest )

        LogOut ->
            ( { model | token = "" }, removeStorage model )
