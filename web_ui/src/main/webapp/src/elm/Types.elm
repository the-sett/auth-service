module Main.Types exposing (..)

import Material
import Layout.Types
import Menu.Types
import DataModeller.Types


type alias Model =
    { mdl : Material.Model
    , datamodeller : DataModeller.Types.Model
    , layout : Layout.Types.Model
    , menus : Menu.Types.Model
    , selectedTab : Int
    , transparentHeader : Bool
    }


type Msg
    = SelectTab Int
    | Mdl (Material.Msg Msg)
    | DataModellerMsg DataModeller.Types.Msg
    | LayoutMsg Layout.Types.Msg
    | MenusMsg Menu.Types.Msg
    | ToggleHeader
