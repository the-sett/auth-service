module Main.State exposing (init, update)

import Array exposing (Array)
import Dict exposing (Dict)
import Navigation
import Maybe exposing (Maybe)
import Exts.Maybe exposing (catMaybes)
import Platform.Cmd exposing (..)
import Material
import Material.Helpers exposing (pure, lift, lift_)
import Material.Layout as Layout
import Utils exposing (..)
import Welcome.Welcome
import AuthController
import Auth
import Layout.State
import Menu.State
import Accounts.State
import Accounts.Types
import Roles.State
import Roles.Types
import Permissions.State
import Permissions.Types
import Main.Types exposing (..)
import Main.View
import Config exposing (Config)
import OutMessage


init : Config -> Model
init config =
    { welcome = Welcome.Welcome.init
    , auth =
        AuthController.init
            { logoutLocation = "#welcome"
            , forwardLocation = "#accounts"
            , authApiRoot = config.authRoot
            }
    , mdl = Layout.setTabsWidth 1384 Material.model
    , accounts = Accounts.State.init config
    , roles = Roles.State.init config
    , permissions = Permissions.State.init config
    , layout = Layout.State.init
    , menus = Menu.State.init
    , selectedTab = 0
    , transparentHeader = False
    , debugStylesheet = False
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    update_ (Debug.log "top" action) model


update_ : Msg -> Model -> ( Model, Cmd Msg )
update_ action model =
    case action of
        Mdl msg ->
            Material.update Mdl msg model

        AuthMsg a ->
            lift .auth (\m x -> { m | auth = x }) AuthMsg AuthController.update a model

        AuthCmdMsg a ->
            AuthController.updateFromAuthCmd a model.auth
                |> Tuple.mapFirst (\auth -> { model | auth = auth })
                |> Tuple.mapSecond (Cmd.map AuthMsg)

        SelectLocation location ->
            selectLocation model location

        SelectTab k ->
            ( { model | selectedTab = k }, urlOfTab k |> Navigation.newUrl )

        ToggleHeader ->
            ( { model | transparentHeader = not model.transparentHeader }, Cmd.none )

        ToggleDebug ->
            ( { model | debugStylesheet = not model.debugStylesheet }, Cmd.none )

        LogOut ->
            --( model, Auth.logout )
            ( model, Cmd.none )

        WelcomeMsg a ->
            let
                interpretOutMsg : Welcome.Welcome.OutMsg -> Model -> ( Model, Cmd Msg )
                interpretOutMsg (Welcome.Welcome.AuthMsg outMsg) model =
                    ( model, AuthCmdMsg outMsg |> Utils.message )
            in
                Welcome.Welcome.update a model.welcome
                    |> OutMessage.mapComponent (\welcome -> { model | welcome = welcome })
                    |> OutMessage.mapCmd WelcomeMsg
                    |> OutMessage.evaluateMaybe interpretOutMsg Cmd.none

        --lift .welcome (\m x -> { m | welcome = x }) WelcomeMsg
        AccountsMsg a ->
            lift .accounts (\m x -> { m | accounts = x }) AccountsMsg Accounts.State.update a model

        RolesMsg a ->
            lift .roles (\m x -> { m | roles = x }) RolesMsg Roles.State.update a model

        PermissionsMsg a ->
            lift .permissions (\m x -> { m | permissions = x }) PermissionsMsg Permissions.State.update a model

        LayoutMsg a ->
            lift .layout (\m x -> { m | layout = x }) LayoutMsg Layout.State.update a model

        MenusMsg a ->
            lift .menus (\m x -> { m | menus = x }) MenusMsg Menu.State.update a model


urlOfTab : Int -> String
urlOfTab tabNo =
    "#" ++ (Array.get tabNo Main.View.tabUrls |> Maybe.withDefault "")



{-
   This is the main router for the application, invoked on all url location changes.

   When not logged in and not already on the welcome page, this will forward to the welcome
   page to log in. The location being requested will be saved in the auth forward location, so
   that it can be forwarded to upon succesfull login.

   When forwarding to a location with an _Init_ event available, this will be triggered
   in order that a particular location can initialize itself.
-}


selectLocation : Model -> String -> ( Model, Cmd Msg )
selectLocation model location =
    let
        authenticated =
            AuthController.extractAuthState model.auth |> Auth.isLoggedIn

        hasPermission =
            AuthController.extractAuthState model.auth |> Auth.hasPermission "auth-admin"

        -- Flag indicating whether the welcome location should be navigated to.
        jumpToWelcome =
            ((not authenticated) || (not hasPermission)) && location /= "welcome"

        -- Maybe a command to jump to the welcome location.
        jumpToWelcomeCmd =
            if jumpToWelcome then
                Navigation.newUrl "#welcome" |> Just
            else
                Nothing

        -- Saves the location as the current forward location on the auth state.
        forwardLocation =
            "#" ++ location |> AuthController.updateForwardLocation

        -- When not on the welcome location, the current location is saved as the
        -- current auth forwarding location, so that it can be restored after a
        -- login.
        jumpToWelcomeModel =
            if location /= "welcome" then
                { model | auth = forwardLocation model.auth }
            else
                model

        -- Choses which tab is currently active.
        tabNo =
            Dict.get location Main.View.urlTabs
                |> Maybe.withDefault -1

        -- Maybe a command to trigger the _Init_ event when navigating to a location
        -- with such an event.
        initCmd =
            if not jumpToWelcome then
                case location of
                    "accounts" ->
                        Utils.message (AccountsMsg Accounts.Types.Init) |> Just

                    "roles" ->
                        Utils.message (RolesMsg Roles.Types.Init) |> Just

                    "permissions" ->
                        Utils.message (PermissionsMsg Permissions.Types.Init) |> Just

                    _ ->
                        Nothing
            else
                Nothing

        -- The model updated with the currently selected tab.
        selectTabModel =
            { jumpToWelcomeModel | selectedTab = tabNo }
    in
        ( selectTabModel, Cmd.batch (catMaybes [ jumpToWelcomeCmd, initCmd ]) )
