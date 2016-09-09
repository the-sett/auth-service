module Main.State exposing (init, update)

import Platform.Cmd exposing (..)
import Material
import Material.Helpers exposing (pure, lift, lift')
import Layout.State
import Menu.State
import Accounts.State
import Roles.State
import Permissions.State
import Main.Types exposing (..)


log =
    Debug.log "top"


init : Model
init =
    { mdl = Material.model
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
    case action of
        SelectTab k ->
            ( { model | selectedTab = k }, Cmd.none )

        ToggleHeader ->
            ( { model | transparentHeader = not model.transparentHeader }, Cmd.none )

        Mdl msg ->
            Material.update msg model

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
            let
                d =
                    log "toggle debug"
            in
                ( { model | debugStylesheet = not model.debugStylesheet }, Cmd.none )
