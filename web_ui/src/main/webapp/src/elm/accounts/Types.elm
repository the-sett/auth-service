module Accounts.Types exposing (..)

import Material
import Set exposing (..)
import Model
import Http
import Account.Service


type alias Model =
    { mdl : Material.Model
    , selected : Set String
    , data : List Model.Account
    }


type Msg
    = Mdl (Material.Msg Msg)
    | AccountApi (Account.Service.Msg)
    | Init
    | Toggle (String)
    | ToggleAll
    | Add
    | Delete
    | ConfirmDelete
    | Edit
