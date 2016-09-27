module Main.State exposing (init, update)

import Log
import Array exposing (Array)
import Dict exposing (Dict)
import Navigation
import Cmd.Extra
import Platform.Cmd exposing (..)
import Material
import Material.Helpers exposing (pure, lift, lift')
import Material.Layout as Layout
import Welcome.State
import Welcome.Types
import Auth.State
import Auth.Types
import Auth
import Layout.State
import Menu.State
import Accounts.State
import Accounts.Types
import Roles.State
import Permissions.State
import Main.Types exposing (..)
import Main.View


init : Model
init =
    { welcome = Welcome.State.init
    , auth = Auth.State.init
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
    update' (Log.debug "top" action) model


update' : Msg -> Model -> ( Model, Cmd Msg )
update' action model =
    case action of
        Mdl msg ->
            Material.update msg model

        SelectLocation location ->
            let
                tabNo =
                    Dict.get location Main.View.urlTabs
                        |> Maybe.withDefault -1

                initCmd =
                    if not model.auth.authState.loggedIn then
                        if location == "welcome" then
                            Cmd.none
                        else
                            Navigation.newUrl "#welcome"
                    else
                        case location of
                            "" ->
                                Cmd.none

                            "accounts" ->
                                Cmd.Extra.message (AccountsMsg Accounts.Types.Init)

                            x ->
                                Cmd.none
            in
                ( { model | selectedTab = tabNo }, initCmd )

        SelectTab k ->
            ( model, urlOfTab k |> Navigation.newUrl )

        ToggleHeader ->
            ( { model | transparentHeader = not model.transparentHeader }, Cmd.none )

        ToggleDebug ->
            ( { model | debugStylesheet = not model.debugStylesheet }, Cmd.none )

        LogOut ->
            ( model, Auth.logout )

        AuthMsg a ->
            lift .auth (\m x -> { m | auth = x }) AuthMsg Auth.State.update a model

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
