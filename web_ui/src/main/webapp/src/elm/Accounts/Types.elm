module Accounts.Types exposing (..)

import Material
import Set exposing (..)
import Dict exposing (Dict)
import Array exposing (Array)
import Maybe
import Model
import Account.Service
import Role.Service


type ViewState
    = ListView
    | CreateView
    | EditView


type alias Model =
    { mdl : Material.Model
    , selected : Set String
    , accounts : Array Model.Account
    , roles : Array Model.Role
    , accountToEdit : Maybe Model.Account
    , viewState : ViewState
    , username : String
    , password1 : String
    , password2 : String
    , roleLookup : Dict String String
    , selectedRoles : Dict String String
    }


type Msg
    = Mdl (Material.Msg Msg)
    | AccountApi (Account.Service.Msg)
    | RoleApi (Role.Service.Msg)
    | Init
    | Toggle (String)
    | ToggleAll
    | Add
    | Delete
    | ConfirmDelete
    | Edit Int
    | UpdateUsername String
    | UpdatePassword1 String
    | UpdatePassword2 String
    | SelectChanged (Dict String String)
    | Save
