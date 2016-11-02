port module Auth.State exposing (update, subscriptions, init)

import Log
import Navigation
import Http
import Json.Decode as Decode exposing (Decoder, (:=))
import Json.Decode.Extra exposing ((|:), withDefault, maybeNull)
import Jwt
import Utils exposing (..)
import Auth.Types exposing (..)
import Auth.Service
import Model


init : Model
init =
    { token = Nothing
    , decodedToken = Nothing
    , errorMsg = ""
    , authState =
        { loggedIn = False
        , permissions = []
        }
    , forwardLocation = ""
    , logoutLocation = ""
    }


tokenDecoder : Decoder Token
tokenDecoder =
    (Decode.succeed
        (\sub iss aud exp iat jti scopes ->
            { sub = sub
            , iss = iss
            , aud = aud
            , exp = exp
            , iat = iat
            , jti = jti
            , scopes = scopes
            }
        )
    )
        |: ("sub" := Decode.string)
        |: Decode.maybe ("iss" := Decode.string)
        |: Decode.maybe ("aud" := Decode.string)
        |: Decode.maybe ("exp" := Decode.string)
        |: Decode.maybe ("iat" := Decode.string)
        |: Decode.maybe ("jti" := Decode.string)
        |: ("scopes" := Decode.list Decode.string)



-- Private interface for authentication functions, and storage of auth state.


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



-- Auth REST API calls.


callbacks : Auth.Service.Callbacks Model Msg
callbacks =
    { login = login
    , refresh = refresh
    , logout = logout
    , error = error
    }


login : Model.AuthResponse -> Model -> ( Model, Cmd Msg )
login (Model.AuthResponse response) model =
    let
        model' =
            { model | token = response.token, authState = authStateFromToken response.token }
    in
        ( model'
        , Cmd.batch [ setStorage model', Navigation.newUrl model.forwardLocation ]
        )


refresh : Model.AuthResponse -> Model -> ( Model, Cmd Msg )
refresh response model =
    ( model, Cmd.none )


logout : Http.Response -> Model -> ( Model, Cmd Msg )
logout response model =
    ( { model | token = Nothing, authState = authStateFromToken Nothing }
    , Cmd.batch [ removeStorage model, Navigation.newUrl model.logoutLocation ]
    )


authStateFromToken : Maybe String -> AuthState
authStateFromToken maybeToken =
    case maybeToken of
        Nothing ->
            { loggedIn = False, permissions = [] }

        Just token ->
            let
                decodedToken =
                    Jwt.decodeToken tokenDecoder token

                d =
                    Log.debug "auth" decodedToken
            in
                { loggedIn = True, permissions = [] }


authRequestFromCredentials : Credentials -> Model.AuthRequest
authRequestFromCredentials credentials =
    Model.AuthRequest
        { username = Just credentials.username
        , password = Just credentials.password
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    update' (Log.debug "auth" action) model


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
            ( { model | token = Nothing, authState = authStateFromToken Nothing }
            , Cmd.batch [ removeStorage model, Navigation.newUrl model.logoutLocation ]
            )
