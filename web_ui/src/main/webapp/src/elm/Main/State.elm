module Main.State exposing (init, update)

import Array exposing (Array)
import Dict exposing (Dict)
import Navigation
import Maybe exposing (Maybe)
import Exts.Maybe exposing (catMaybes)
import Platform.Cmd exposing (..)
import Material
import Material.Helpers exposing (pure, lift, lift')
import Material.Layout as Layout
import Utils exposing (..)
import Welcome.State
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


init : Model
init =
    { welcome = Welcome.State.init
    , auth = setLoginLocations AuthController.init
    , mdl = Layout.setTabsWidth 1384 Material.model
    , accounts = Accounts.State.init
    , roles = Roles.State.init
    , permissions = Permissions.State.init
    , layout = Layout.State.init
    , menus = Menu.State.init
    , selectedTab = 0
    , transparentHeader = False
    , debugStylesheet = False
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    update' (Debug.log "top" action) model


update' : Msg -> Model -> ( Model, Cmd Msg )
update' action model =
    case action of
        Mdl msg ->
            Material.update msg model

        SelectLocation location ->
            selectLocation model location

        SelectTab k ->
            ( { model | selectedTab = k }, urlOfTab k |> Navigation.newUrl )

        ToggleHeader ->
            ( { model | transparentHeader = not model.transparentHeader }, Cmd.none )

        ToggleDebug ->
            ( { model | debugStylesheet = not model.debugStylesheet }, Cmd.none )

        LogOut ->
            ( model, Auth.logout )

        AuthMsg a ->
            lift .auth (\m x -> { m | auth = x }) AuthMsg AuthController.update a model

        WelcomeMsg a ->
            lift .welcome (\m x -> { m | welcome = x }) WelcomeMsg Welcome.State.update a model

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


setLoginLocations authState =
    { authState | logoutLocation = "#welcome", forwardLocation = "#accounts" }



{-
   This is the main router for the application, invoked on all url location changes.

   When not logged in and not already on the welcome page, this will forward to the welcome
   page to log in. The location being requested will be saved in the auth forward location, so
   that it can be forwarded to upon succesfull login.

   When forwarding to a location with an 'Init' event available, this will be triggered
   in order that a particular location can initialize itself.
-}


selectLocation : Model -> String -> ( Model, Cmd Msg )
selectLocation model location =
    let
        authenticated =
            AuthController.isLoggedIn model.auth.authState

        hasPermission =
            AuthController.hasPermission "auth-admin" model.auth.authState

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
        forwardLocation authState =
            { authState | forwardLocation = "#" ++ location }

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

        -- Maybe a command to trigger the 'Init' event when navigating to a location
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
