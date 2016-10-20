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
    , accounts : Dict String Model.Account
    , accountToEdit : Maybe Model.Account
    , viewState : ViewState
    , username : String
    , password1 : String
    , password2 : String
    , roleLookup : Dict String Model.Role
    , selectedRoles : Dict String Model.Role
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
    | Edit String
    | UpdateUsername String
    | UpdatePassword1 String
    | UpdatePassword2 String
    | SelectChanged (Dict String String)
    | Save
    | Create
