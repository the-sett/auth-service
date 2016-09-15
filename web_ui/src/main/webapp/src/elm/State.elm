module Main.State exposing (init, update)

import Log
import Platform.Cmd exposing (..)
import Material
import Material.Helpers exposing (pure, lift, lift')
import Material.Layout as Layout
import Welcome.State
import Auth.State
import Layout.State
import Menu.State
import Accounts.State
import Roles.State
import Permissions.State
import Main.Types exposing (..)


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
        SelectTab k ->
            ( { model | selectedTab = k }, Cmd.none )

        ToggleHeader ->
            ( { model | transparentHeader = not model.transparentHeader }, Cmd.none )

        Mdl msg ->
            Material.update msg model

        WelcomeMsg a ->
            lift .welcome (\m x -> { m | welcome = x, auth = x.auth }) WelcomeMsg Welcome.State.update a model

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

        ToggleDebug ->
            ( { model | debugStylesheet = not model.debugStylesheet }, Cmd.none )
