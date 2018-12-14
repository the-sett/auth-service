module Main exposing (Model, Msg(..), init, subscriptions, update, view)

import Auth
import Body
import Browser
import Browser.Dom exposing (getViewportOf, setViewportOf)
import Browser.Navigation as Navigation
import Config exposing (config)
import Css.Global
import Html
import Html.Styled exposing (div, input, text, toUnstyled)
import Html.Styled.Attributes exposing (checked, type_)
import Html.Styled.Events exposing (onCheck)
import Layout.Application
import Layout.Initial
import Page.Accounts as Accounts
import Page.Welcome as Welcome
import Routes exposing (Route(..))
import Structure exposing (Layout, Template(..))
import Task
import TheSett.Debug
import TheSett.Laf as Laf
import TheSett.Logo
import Update3
import Url


{-| Keeping the update structure flat for this simple application.
-}
type Msg
    = AuthMsg Auth.Msg
    | Toggle Bool
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | WelcomeMsg Welcome.Msg
    | AccountsMsg Accounts.Msg


type Page
    = Welcome Welcome.Model
    | Accounts Accounts.Model


type alias Model =
    { navKey : Navigation.Key
    , auth : Auth.Model
    , debug : Bool
    , page : Page
    , session : Session
    }


type Session
    = Initial
    | LoggedOut
    | FailedAuth
    | LoggedIn
        { scopes : List String
        , subject : String
        }


init : () -> Url.Url -> Navigation.Key -> ( Model, Cmd Msg )
init () url key =
    ( { navKey = key
      , auth = Auth.init { authApiRoot = config.authRoot }
      , debug = False
      , page = Welcome Welcome.init
      , session = Initial
      }
    , Auth.refresh |> Cmd.map AuthMsg
    )


subscriptions _ =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    update_ (Debug.log "msg" msg) model
        |> Debug.log "result"


update_ : Msg -> Model -> ( Model, Cmd Msg )
update_ msg model =
    case ( msg, model.page ) of
        ( AuthMsg innerMsg, _ ) ->
            Update3.lift .auth (\x m -> { m | auth = x }) AuthMsg Auth.update innerMsg model
                |> Update3.evalMaybe updateOnAuthStatus Cmd.none

        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Navigation.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Navigation.load href
                    )

        ( UrlChanged url, _ ) ->
            updateUrl url model

        ( Toggle state, _ ) ->
            ( { model | debug = state }, Cmd.none )

        ( WelcomeMsg welcomeMsg, Welcome welcomeModel ) ->
            Welcome.update welcomeMsg welcomeModel
                |> Update3.mapModel (\newWelcomeModel -> { model | page = Welcome newWelcomeModel })
                |> Update3.mapCmd WelcomeMsg
                |> Update3.eval (\authMsg newModel -> ( newModel, Cmd.map AuthMsg authMsg ))

        ( _, _ ) ->
            ( model, Cmd.none )


{-| Navigates to #acounts on log in, and to #welcome on log out.
The model is also updated to retain the new authentication status.
-}
updateOnAuthStatus : Auth.Status -> Model -> ( Model, Cmd Msg )
updateOnAuthStatus status model =
    case status of
        Auth.LoggedOut ->
            ( { model | session = authStatusToSession status }
            , Routes.replaceUrl model.navKey WelcomeRoute
            )

        Auth.LoggedIn access ->
            if List.member "auth-admin" access.scopes then
                ( { model | session = authStatusToSession status }
                , Routes.replaceUrl model.navKey AccountsRoute
                )

            else
                ( { model | session = authStatusToSession Auth.Failed }
                , Routes.replaceUrl model.navKey WelcomeRoute
                )

        _ ->
            ( { model | session = authStatusToSession status }
            , Cmd.none
            )


authStatusToSession : Auth.Status -> Session
authStatusToSession status =
    case status of
        Auth.LoggedOut ->
            LoggedOut

        Auth.Failed ->
            FailedAuth

        Auth.LoggedIn access ->
            LoggedIn access



-- Router


updateUrl : Url.Url -> Model -> ( Model, Cmd Msg )
updateUrl url model =
    case ( model.session, Routes.fromUrl url ) of
        ( _, Nothing ) ->
            ( model, Cmd.none )

        ( _, Just Routes.WelcomeRoute ) ->
            ( { model | page = Welcome Welcome.init }, Cmd.none )

        ( LoggedIn scope, Just Routes.AccountsRoute ) ->
            ( { model | page = Accounts <| Accounts.init config }, Cmd.none )

        ( _, _ ) ->
            --( { model | page = Welcome Welcome.init }, State.replaceUrl model.navKey State.WelcomeRoute )
            ( model, Cmd.none )


{-| Top level view function.
-}
view : Model -> Browser.Document Msg
view model =
    { title = "Auth Service"
    , body = [ body model ]
    }


body : Model -> Html.Html Msg
body model =
    styledBody model
        |> toUnstyled


styledBody : Model -> Html.Styled.Html Msg
styledBody model =
    let
        { template, global } =
            layoutForPage model.page <| Body.view (pageView model)

        innerView =
            [ Laf.responsiveMeta
            , Laf.fonts
            , Laf.style Laf.devices
            , Css.Global.global <| global Laf.devices
            , case
                template
              of
                Dynamic fn ->
                    fn Laf.devices model

                Static fn ->
                    Html.Styled.map never <| fn Laf.devices
            ]

        debugStyle =
            Css.Global.global <|
                TheSett.Debug.global Laf.devices
    in
    case model.debug of
        True ->
            div [] (debugStyle :: innerView)

        False ->
            div [] innerView


layoutForPage : Page -> Layout Msg Model
layoutForPage page =
    case page of
        Welcome _ ->
            Layout.Initial.layout

        Accounts _ ->
            Layout.Application.layout


pageView : Model -> Template Msg Model
pageView model =
    let
        empty =
            (\_ -> div [] [])
                |> Static
    in
    case ( model.session, model.page ) of
        ( Initial, Welcome welcomeModel ) ->
            Welcome.initialView

        ( LoggedOut, Welcome welcomeModel ) ->
            Structure.lift WelcomeMsg (always welcomeModel) Welcome.loginView

        ( FailedAuth, Welcome welcomeModel ) ->
            Structure.lift WelcomeMsg (always welcomeModel) Welcome.notPermittedView

        ( LoggedIn scopes, page ) ->
            case page of
                Accounts accountsModel ->
                    Structure.lift AccountsMsg (always accountsModel) Accounts.view

                _ ->
                    empty

        ( _, _ ) ->
            empty
