module Permissions.Types exposing (..)

import Material
import Dict exposing (Dict)
import Maybe
import Model
import Permission.Service


type ItemToEdit
    = None
    | WithId String Model.Permission
    | New


type alias Model =
    { mdl : Material.Model
    , selected : Dict String Model.Permission
    , permissions : Dict String Model.Permission
    , permissionName : Maybe String
    , permissionToEdit : ItemToEdit
    , numToDelete : Int
    }


type Msg
    = Mdl (Material.Msg Msg)
    | PermissionApi Permission.Service.Msg
    | Init
    | Toggle String
    | ToggleAll
    | UpdatePermissionName String
    | Add
    | Edit String
    | Delete
    | ConfirmDelete
    | Save
