module Roles.Types exposing (..)

import Material
import Dict exposing (Dict)
import Maybe
import Model
import Role.Service
import Permission.Service


type alias Model =
    { mdl : Material.Model
    , selected : Dict String Model.Role
    , roles : Dict String Model.Role
    , roleName : Maybe String
    , permissionLookup : Dict String Model.Permission
    , selectedPermissions : Dict String Model.Permission
    , roleIdToEdit : Maybe String
    }


type Msg
    = Mdl (Material.Msg Msg)
    | RoleApi (Role.Service.Msg)
    | PermissionApi (Permission.Service.Msg)
    | Init
    | Toggle (String)
    | ToggleAll
    | UpdateRoleName String
    | Add
    | Delete
    | ConfirmDelete
    | Save
    | Create
