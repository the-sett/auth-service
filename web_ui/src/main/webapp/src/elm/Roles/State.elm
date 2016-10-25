module Roles.State exposing (..)

import Log
import Dict exposing (Dict)
import Platform.Cmd exposing (Cmd)
import Cmd.Extra
import Material
import Roles.Types exposing (..)
import Utils exposing (..)
import Model
import Role.Service
import Permission.Service


init : Model
init =
    { mdl = Material.model
    , selected = Dict.empty
    , roles = Dict.empty
    , roleName = Nothing
    , permissionLookup = Dict.empty
    , selectedPermissions = Dict.empty
    , roleToEdit = None
    }


allSelected : Model -> Bool
allSelected model =
    Dict.size model.selected == Dict.size model.roles


someSelected : Model -> Bool
someSelected model =
    Dict.size model.selected > 0


permissionDictFromRole : Model.Role -> Dict String Model.Permission
permissionDictFromRole (Model.Role role) =
    case role.permissions of
        Nothing ->
            Dict.empty

        Just permissions ->
            permissionListToDict permissions


permissionListToDict : List Model.Permission -> Dict String Model.Permission
permissionListToDict permissions =
    Utils.dictifyEntities unwrapPermission Model.Permission permissions


unwrapRole (Model.Role role) =
    role


unwrapPermission (Model.Permission permission) =
    permission



-- Role REST API calls


roleCallbacks : Role.Service.Callbacks Model Msg
roleCallbacks =
    let
        default =
            Role.Service.callbacks
    in
        { default
            | findAll = roleList
            , create = roleCreate
            , update = roleSaved
            , delete = roleDelete
            , error = error
        }


roleList : List Model.Role -> Model -> ( Model, Cmd msg )
roleList roles model =
    ( { model | roles = Utils.dictifyEntities unwrapRole Model.Role roles }
    , Cmd.none
    )


roleCreate : Model.Role -> Model -> ( Model, Cmd Msg )
roleCreate role model =
    ( model, Cmd.Extra.message Init )


roleSaved : Model.Role -> model -> ( model, Cmd Msg )
roleSaved role model =
    ( model, Cmd.Extra.message Init )


roleDelete : String -> Model -> ( Model, Cmd Msg )
roleDelete id model =
    let
        newRoles =
            Dict.remove id model.roles
    in
        ( { model | roles = newRoles }, Cmd.none )



-- Permission REST API calls


permissionCallbacks : Permission.Service.Callbacks Model Msg
permissionCallbacks =
    let
        default =
            Permission.Service.callbacks
    in
        { default
            | findAll = permissionList
            , error = error
        }


permissionList : List Model.Permission -> Model -> ( Model, Cmd msg )
permissionList permissions model =
    ( { model
        | permissionLookup = permissionListToDict permissions
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case (Log.debug "permissions" action) of
        Mdl action' ->
            Material.update action' model

        RoleApi action' ->
            Role.Service.update roleCallbacks action' model

        PermissionApi action' ->
            Permission.Service.update permissionCallbacks action' model

        Init ->
            ( { model | roleToEdit = None }
            , Cmd.batch
                [ Role.Service.invokeFindAll RoleApi
                , Permission.Service.invokeFindAll PermissionApi
                ]
            )

        ToggleAll ->
            updateToggleAll model

        Toggle id ->
            updateToggle id model

        UpdateRoleName roleName ->
            ( { model | roleName = Utils.cleanString roleName }, Cmd.none )

        Add ->
            updateAdd model

        Edit id ->
            updateEdit id model

        Delete ->
            ( model, Cmd.none )

        ConfirmDelete ->
            updateConfirmDelete model

        Save ->
            updateSave model


updateToggleAll : Model -> ( Model, Cmd Msg )
updateToggleAll model =
    { model
        | selected =
            if allSelected model then
                Dict.empty
            else
                model.roles
    }
        ! []


updateToggle : String -> Model -> ( Model, Cmd Msg )
updateToggle id model =
    let
        item =
            Dict.get id model.roles
    in
        case item of
            Nothing ->
                ( model, Cmd.none )

            Just item ->
                { model
                    | selected =
                        if Dict.member id model.selected then
                            Dict.remove id model.selected
                        else
                            Dict.insert id item model.selected
                }
                    ! []


updateAdd model =
    ( { model | roleToEdit = New }, Cmd.none )


updateEdit : String -> Model -> ( Model, Cmd Msg )
updateEdit id model =
    let
        item =
            Dict.get id model.roles
    in
        case item of
            Nothing ->
                ( model, Cmd.none )

            Just roleRec ->
                let
                    (Model.Role role) =
                        roleRec

                    selectedPermissions =
                        permissionDictFromRole roleRec
                in
                    ( { model
                        | roleName = role.name
                        , selectedPermissions = selectedPermissions
                        , roleToEdit = WithId id
                      }
                    , Cmd.none
                    )


updateConfirmDelete model =
    ( { model | selected = Dict.empty }
    , List.map
        (\id ->
            Role.Service.invokeDelete RoleApi id
        )
        (Dict.keys <| Dict.intersect model.roles model.selected)
        |> Cmd.batch
    )


updateSave model =
    case model.roleToEdit of
        None ->
            ( model, Cmd.none )

        WithId id ->
            let
                modifiedRole =
                    Model.Role
                        { id = Just id
                        , name = model.roleName
                        , permissions = Just <| Dict.values model.selectedPermissions
                        }
            in
                ( model
                , Role.Service.invokeUpdate RoleApi id modifiedRole
                )

        New ->
            ( model
            , Role.Service.invokeCreate RoleApi
                (Model.Role
                    { id = Nothing
                    , name = model.roleName
                    , permissions = Just <| Dict.values model.selectedPermissions
                    }
                )
            )
