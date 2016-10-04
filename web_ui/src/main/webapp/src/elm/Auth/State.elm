port module Auth.State exposing (update, subscriptions, init)

import Log
import Navigation
import Http
import Utils exposing (..)
import Auth.Types exposing (..)
import Task exposing (Task)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Auth.Service
import Model


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


port setStorage : Model -> Cmd msg


port removeStorage : Model -> Cmd msg


port receiveLogin : (Credentials -> msg) -> Sub msg


port receiveLogout : (() -> msg) -> Sub msg


port receiveUnauthed : (() -> msg) -> Sub msg


callbacks : Auth.Service.Callbacks Model Msg
callbacks =
    { login = login
    , refresh = refresh
    , logout = logout
    , error = error
    }



--login : Model.AuthResponse -> model -> ( model, Cmd msg )


login (Model.AuthResponse response) model =
    let
        model' =
            { model | token = response.token, authState = authStateFromToken response.token }
    in
        ( model'
        , Cmd.batch [ setStorage model', Navigation.newUrl model.forwardLocation ]
        )



--refresh : Model.AuthResponse -> model -> ( model, Cmd msg )


refresh response model =
    ( model, Cmd.none )



--logout : Http.Response -> model -> ( model, Cmd msg )


logout response model =
    ( { model | token = "", authState = authStateFromToken "" }
    , Cmd.batch [ removeStorage model, Navigation.newUrl model.logoutLocation ]
    )


authStateFromToken : String -> AuthState
authStateFromToken token =
    if token == "" then
        { loggedIn = False, permissions = [] }
    else
        { loggedIn = True, permissions = [] }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    update' (Log.debug "auth" action) model


authRequestFromCredentials credentials =
    Model.AuthRequest { username = credentials.username, password = credentials.password }


update' : Msg -> Model -> ( Model, Cmd Msg )
update' msg model =
    case msg of
        AuthApi action' ->
            Auth.Service.update callbacks action' model

        LogIn credentials ->
            ( model, Auth.Service.invokeLogin AuthApi (authRequestFromCredentials credentials) )

        LogOut ->
            ( model, Auth.Service.invokeLogout AuthApi )

        NotAuthed ->
            ( { model | token = "", authState = authStateFromToken "" }
            , Cmd.batch [ removeStorage model, Navigation.newUrl model.logoutLocation ]
            )
