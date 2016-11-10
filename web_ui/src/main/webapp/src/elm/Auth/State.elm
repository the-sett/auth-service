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
import Date exposing (Date)
import Time
import Maybe.Extra
import Task exposing (andThen)
import Process
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
    , refreshToken = Nothing
    , refreshFrom = Nothing
    , errorMsg = ""
    , authState = notAuthedState
    , forwardLocation = ""
    , logoutLocation = ""
    , logonAttempted = False
    }


notAuthedState =
    { loggedIn = False
    , permissions = []
    , expiresAt = Nothing
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
    let
        decodedToken =
            decodeToken saved.token
    in
        { model
            | token = saved.token
            , decodedToken = decodedToken
            , authState = authStateFromToken decodedToken
        }


decodeToken : Maybe String -> Maybe Token
decodeToken maybeToken =
    case maybeToken of
        Nothing ->
            Nothing

        Just token ->
            Result.toMaybe <| Jwt.decodeToken tokenDecoder token


refreshTimeFromToken : Maybe Token -> Maybe Date
refreshTimeFromToken maybeToken =
    let
        maybeDate =
            Maybe.map (\token -> token.exp) maybeToken |> Maybe.Extra.join
    in
        Maybe.map (\date -> (Date.toTime date) - 30 * Time.second |> Date.fromTime) maybeDate


authStateFromToken : Maybe Token -> AuthState
authStateFromToken maybeToken =
    case maybeToken of
        Nothing ->
            notAuthedState

        Just token ->
            { loggedIn = True
            , permissions = token.scopes
            , expiresAt = token.exp
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
    , error = \_ -> \model -> ( model, Cmd.none )
    }


login : Model.AuthResponse -> Model -> ( Model, Cmd Msg )
login (Model.AuthResponse response) model =
    let
        decodedToken =
            decodeToken response.token

        model' =
            { model
                | token = response.token
                , refreshToken = response.refreshToken
                , refreshFrom = refreshTimeFromToken decodedToken
                , decodedToken = decodedToken
                , authState = authStateFromToken decodedToken
            }
    in
        ( model'
        , Cmd.batch
            [ setStorage <| toSavedModel model'
            , Navigation.newUrl model.forwardLocation
            , refreshCmd model'
            ]
        )


refresh : Model.AuthResponse -> Model -> ( Model, Cmd Msg )
refresh (Model.AuthResponse response) model =
    let
        decodedToken =
            decodeToken response.token

        model' =
            { model
                | token = response.token
                , refreshToken = response.refreshToken
                , refreshFrom = refreshTimeFromToken decodedToken
                , decodedToken = decodedToken
                , authState = authStateFromToken decodedToken
            }
    in
        ( model'
        , Cmd.batch
            [ setStorage <| toSavedModel model'
            , refreshCmd model'
            ]
        )


logout : Http.Response -> Model -> ( Model, Cmd Msg )
logout response model =
    ( { model | token = Nothing, authState = authStateFromToken Nothing }
    , Cmd.batch [ removeStorage (), Navigation.newUrl model.logoutLocation ]
    )


refreshCmd : Model -> Cmd Msg
refreshCmd model =
    let
        refreshRequest =
            Model.RefreshRequest { refreshToken = model.refreshToken }
    in
        case model.refreshFrom of
            Nothing ->
                Cmd.none

            Just refreshDate ->
                tokenExpiryTask refreshDate refreshRequest
                    |> Task.perform (\error -> Refresh (Result.Err error)) (\result -> Refresh (Result.Ok result))


tokenExpiryTask : Date -> Model.RefreshRequest -> Task.Task Http.Error Model.AuthResponse
tokenExpiryTask refreshDate refreshRequest =
    let
        delay refreshDate now =
            max 0 ((Date.toTime refreshDate) - now)
    in
        Time.now
            `andThen` (\now -> Process.sleep <| delay refreshDate now)
            `andThen` (\_ -> Auth.Service.refreshTask refreshRequest)


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
            ( { model | logonAttempted = False }, Auth.Service.invokeLogout AuthApi )

        NotAuthed ->
            ( { model
                | token = Nothing
                , authState = authStateFromToken Nothing
                , logonAttempted = False
              }
            , Cmd.batch [ removeStorage (), Navigation.newUrl model.logoutLocation ]
            )

        Refresh result ->
            case result of
                Err _ ->
                    ( model, Cmd.none )

                Ok authResponse ->
                    refresh authResponse model
