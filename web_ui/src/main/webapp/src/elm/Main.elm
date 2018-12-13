module Main exposing (init, subscriptions, update, view)

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
import State exposing (Model, Msg(..), Page(..), Session(..))
import Structure exposing (Template(..))
import Task
import TheSett.Debug
import TheSett.Laf as Laf
import TheSett.Logo
import Update3
import Url


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
                |> Update3.evalMaybe (\status -> \nextModel -> ( { nextModel | session = authStatusToSession status }, Cmd.none )) Cmd.none

        ( Toggle state, _ ) ->
            ( { model | debug = state }, Cmd.none )

        ( SwitchTo page, _ ) ->
            --( { model | page = page }, Cmd.none )
            ( model, Cmd.none )

        ( WelcomeMsg welcomeMsg, Welcome welcomeModel ) ->
            Welcome.update welcomeMsg welcomeModel
                |> Update3.mapModel (\newWelcomeModel -> { model | page = Welcome newWelcomeModel })
                |> Update3.mapCmd WelcomeMsg
                |> Update3.eval (\authMsg newModel -> ( newModel, Cmd.map AuthMsg authMsg ))

        ( _, _ ) ->
            ( model, Cmd.none )


authStatusToSession : Auth.Status -> Session
authStatusToSession status =
    case status of
        Auth.LoggedOut ->
            LoggedOut

        Auth.Failed ->
            FailedAuth

        Auth.LoggedIn access ->
            LoggedIn access


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
            Layout.Initial.layout <| Body.view (pageView model)

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
