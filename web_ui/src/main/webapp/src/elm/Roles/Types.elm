module Roles.Types exposing (..)

import Material
import Dict exposing (Dict)
import Maybe
import Model
import Role.Service
import Permission.Service


type ItemToEdit
    = None
    | WithId String (Model.Role)
    | New


type alias Model =
    { mdl : Material.Model
    , selected : Dict String Model.Role
    , roles : Dict String Model.Role
    , roleName : Maybe String
    , permissionLookup : Dict String Model.Permission
    , selectedPermissions : Dict String Model.Permission
    , roleToEdit : ItemToEdit
    }


type Msg
    = Mdl (Material.Msg Msg)
    | RoleApi (Role.Service.Msg)
    | PermissionApi (Permission.Service.Msg)
    | Init
    | Toggle (String)
    | ToggleAll
    | UpdateRoleName String
    | SelectChanged (Dict String String)
    | Add
    | Edit String
    | Delete
    | ConfirmDelete
    | Save
