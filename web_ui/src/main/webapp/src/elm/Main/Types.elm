module Main.Types exposing (..)

import Material
import Welcome.Welcome
import Layout.State
import Menu.Types
import Accounts.State
import Roles.Types
import Permissions.Types
import AuthController
import Auth


type alias Model =
    { welcome : Welcome.Welcome.Model
    , auth : AuthController.Model
    , mdl : Material.Model
    , accounts : Accounts.State.Model
    , roles : Roles.Types.Model
    , permissions : Permissions.Types.Model
    , layout : Layout.State.Model
    , menus : Menu.Types.Model
    , selectedTab : Int
    , transparentHeader : Bool
    , debugStylesheet : Bool
    }


type Msg
    = Mdl (Material.Msg Msg)
    | AuthCmdMsg Auth.AuthCmd
    | AuthMsg AuthController.Msg
    | SelectTab Int
    | SelectLocation String
    | WelcomeMsg Welcome.Welcome.Msg
    | AccountsMsg Accounts.State.Msg
    | RolesMsg Roles.Types.Msg
    | PermissionsMsg Permissions.Types.Msg
    | LayoutMsg Layout.State.Msg
    | MenusMsg Menu.Types.Msg
    | ToggleHeader
    | ToggleDebug
    | LogOut
