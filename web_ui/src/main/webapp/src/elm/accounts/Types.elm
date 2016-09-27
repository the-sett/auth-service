module Accounts.Types exposing (..)

import Material
import Set exposing (..)
import Model
import Http


type alias Model =
    { mdl : Material.Model
    , selected : Set String
    , data : List Model.Account
    }


type Msg
    = Mdl (Material.Msg Msg)
    | Init
    | Toggle (String)
    | ToggleAll
    | Add
    | Delete
    | ConfirmDelete
    | Edit
