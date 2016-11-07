port module Auth.State
    exposing
        ( update
        , subscriptions
        , init
        , fromSavedModel
        , isLoggedIn
        , logonAttempted
        , hasPermission
        )

import Log
import Date
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
    , logonAttempted = False
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
        |: Decode.maybe
            (Decode.map
                (Date.fromTime << toFloat << ((*) 1000))
                ("exp" := Decode.int)
            )
        |: Decode.maybe
            (Decode.map
                (Date.fromTime << toFloat << ((*) 1000))
                ("iat" := Decode.int)
            )
        |: Decode.maybe ("jti" := Decode.string)
        |: ("scopes" := Decode.list Decode.string)


toSavedModel : Model -> SavedModel
toSavedModel model =
    { token = model.token
    }


fromSavedModel : SavedModel -> Model -> Model
fromSavedModel saved model =
    { model
        | token = saved.token
        , authState = authStateFromToken saved.token
    }


authStateFromToken : Maybe String -> AuthState
authStateFromToken maybeToken =
    case maybeToken of
        Nothing ->
            { loggedIn = False
            , permissions = []
            }

        Just token ->
            let
                tokenDecodeResult =
                    Jwt.decodeToken tokenDecoder token

                d =
                    Log.debug "auth" tokenDecodeResult
            in
                case tokenDecodeResult of
                    Err _ ->
                        { loggedIn = False
                        , permissions = []
                        }

                    Ok decodedToken ->
                        { loggedIn = True
                        , permissions = decodedToken.scopes
                        }


isLoggedIn : AuthState -> Bool
isLoggedIn authState =
    authState.loggedIn


logonAttempted : Model -> Bool
logonAttempted model =
    model.logonAttempted


hasPermission : String -> AuthState -> Bool
hasPermission permission authState =
    List.member permission authState.permissions



-- Private interface for authentication functions, and storage of auth state.


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ receiveLogin LogIn
        , receiveLogout (\_ -> LogOut)
        , receiveUnauthed (\_ -> NotAuthed)
        ]


port setStorage : SavedModel -> Cmd msg


port removeStorage : () -> Cmd msg


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
        , Cmd.batch [ setStorage <| toSavedModel model', Navigation.newUrl model.forwardLocation ]
        )


refresh : Model.AuthResponse -> Model -> ( Model, Cmd Msg )
refresh response model =
    ( model, Cmd.none )


logout : Http.Response -> Model -> ( Model, Cmd Msg )
logout response model =
    ( { model | token = Nothing, authState = authStateFromToken Nothing }
    , Cmd.batch [ removeStorage (), Navigation.newUrl model.logoutLocation ]
    )


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
            ( { model
                | token = Nothing
                , authState = authStateFromToken Nothing
                , logonAttempted = True
              }
            , Auth.Service.invokeLogin AuthApi (authRequestFromCredentials credentials)
            )

        LogOut ->
            ( model, Auth.Service.invokeLogout AuthApi )

        NotAuthed ->
            ( { model | token = Nothing, authState = authStateFromToken Nothing }
            , Cmd.batch [ removeStorage (), Navigation.newUrl model.logoutLocation ]
            )
