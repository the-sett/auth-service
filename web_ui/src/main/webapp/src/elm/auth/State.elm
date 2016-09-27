port module Auth.State exposing (update, subscriptions, init)

import Log
import Navigation
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
    , authState =
        { loggedIn = False
        , permissions = []
        }
    , forwardLocation = ""
    , logoutLocation = ""
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ receiveLogin LogIn
        , receiveLogout (\_ -> LogOut)
        , receiveUnauthed (\_ -> NotAuthed)
        ]


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
    "token" := Decode.string


loginRequest : AuthRequest -> Task Http.Error String
loginRequest model =
    { verb = "POST"
    , headers = [ ( "Content-Type", "application/json" ) ]
    , url = routes.loginUrl
    , body = Http.string <| Encode.encode 0 <| authRequestEncoder model
    }
        |> Http.send Http.defaultSettings
        |> Http.fromJson tokenDecoder


loginCmd : AuthRequest -> Cmd Msg
loginCmd model =
    Task.perform AuthError GetTokenSuccess <| loginRequest model


port setStorage : Model -> Cmd msg


port removeStorage : Model -> Cmd msg


port receiveLogin : (AuthRequest -> msg) -> Sub msg


port receiveLogout : (() -> msg) -> Sub msg


port receiveUnauthed : (() -> msg) -> Sub msg



-- This is where the token gets decoded and checked.


authStateFromToken : String -> AuthState
authStateFromToken token =
    if token == "" then
        { loggedIn = False, permissions = [] }
    else
        { loggedIn = True, permissions = [] }


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
            let
                model' =
                    { model | token = newToken, authState = authStateFromToken newToken }
            in
                ( model', setStorage model' )

        LogIn authRequest ->
            ( model, loginCmd authRequest )

        LogOut ->
            ( { model | token = "", authState = authStateFromToken "" }
            , Cmd.batch [ removeStorage model, Navigation.newUrl model.logoutLocation ]
            )

        NotAuthed ->
            ( model, Cmd.none )
