module Accounts.Types exposing (..)

import Material
import Set exposing (..)
import Array exposing (Array)
import Maybe
import Model
import Http
import Account.Service


type ViewState
    = ListView
    | CreateView
    | EditView


type alias Model =
    { mdl : Material.Model
    , selected : Set String
    , data : Array Model.Account
    , accountToEdit : Maybe Model.Account
    , viewState : ViewState
    , username : String
    , password1 : String
    , password2 : String
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
    | Edit Int
    | UpdateUsername String
    | UpdatePassword1 String
    | UpdatePassword2 String
