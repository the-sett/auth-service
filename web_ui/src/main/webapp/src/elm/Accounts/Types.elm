module Accounts.Types exposing (..)

import Material
import Set exposing (..)
import Dict exposing (Dict)
import Array exposing (Array)
import Maybe
import Model
import Account.Service
import Role.Service
import Auth


type ViewState
    = ListView
    | CreateView
    | EditView


type alias Model =
    { mdl : Material.Model
    , selected : Dict String Model.Account
    , accounts : Dict String Model.Account
    , accountToEdit : Maybe Model.Account
    , viewState : ViewState
    , username : Maybe String
    , password1 : Maybe String
    , password2 : Maybe String
    , roleLookup : Dict String Model.Role
    , selectedRoles : Dict String Model.Role
    , numToDelete : Int
    , moreStatus : Set String
    }


type Msg
    = Mdl (Material.Msg Msg)
    | AuthMsg Auth.AuthCmd
    | AccountApi Account.Service.Msg
    | RoleApi Role.Service.Msg
    | Init
    | Toggle String
    | ToggleAll
    | ToggleMore String
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
