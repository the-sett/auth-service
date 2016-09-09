module Main.Types exposing (..)

import Material
import Layout.Types
import Menu.Types
import Accounts.Types
import Roles.Types
import Permissions.Types


type alias Model =
    { mdl : Material.Model
    , accounts : Accounts.Types.Model
    , roles : Roles.Types.Model
    , permissions : Permissions.Types.Model
    , layout : Layout.Types.Model
    , menus : Menu.Types.Model
    , selectedTab : Int
    , transparentHeader : Bool
    , debugStylesheet : Bool
    }


type Msg
    = SelectTab Int
    | Mdl (Material.Msg Msg)
    | AccountsMsg Accounts.Types.Msg
    | RolesMsg Roles.Types.Msg
    | PermissionsMsg Permissions.Types.Msg
    | LayoutMsg Layout.Types.Msg
    | MenusMsg Menu.Types.Msg
    | ToggleHeader
    | ToggleDebug
