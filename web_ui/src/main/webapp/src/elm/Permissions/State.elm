module Permissions.State exposing (..)


import String
import Dict exposing (Dict)
import Platform.Cmd exposing (Cmd)
import Cmd.Extra
import Http
import Material
import Permissions.Types exposing (..)
import Utils exposing (..)
import Model
import Permission.Service


init : Model
init =
    { mdl = Material.model
    , selected = Dict.empty
    , permissions = Dict.empty
    , permissionName = Nothing
    , permissionToEdit = None
    , numToDelete = 0
    }


allSelected : Model -> Bool
allSelected model =
    Dict.size model.selected == Dict.size model.permissions


someSelected : Model -> Bool
someSelected model =
    Dict.size model.selected > 0


permissionListToDict : List Model.Permission -> Dict String Model.Permission
permissionListToDict permissions =
    Utils.dictifyEntities unwrapPermission Model.Permission permissions


unwrapPermission (Model.Permission permission) =
    permission



-- Validations on the model


checkPermissionNameExists : Model -> Bool
checkPermissionNameExists model =
    case model.permissionName of
        Nothing ->
            False

        Just permissionName ->
            String.length permissionName > 0


validateCreatePermission : Model -> Bool
validateCreatePermission =
    checkAll
        [ checkPermissionNameExists
        ]


validateEditAccount : Model -> Bool
validateEditAccount =
    checkAll
        [ checkPermissionNameExists
        ]


isChangePermissionName : Model -> Bool
isChangePermissionName model =
    case model.permissionToEdit of
        None ->
            False

        New ->
            False

        WithId _ (Model.Permission permission) ->
            permission.name /= model.permissionName


isEditedAndValid : Model -> Bool
isEditedAndValid model =
    (validateEditAccount model) && (isChangePermissionName model)



-- Permission REST API calls


permissionCallbacks : Permission.Service.Callbacks Model Msg
permissionCallbacks =
    let
        default =
            Permission.Service.callbacks
    in
        { default
            | findAll = permissionList
            , create = permissionCreate
            , update = permissionSaved
            , delete = permissionDelete
            , deleteError = permissionDeleteError
            , error = error
        }


permissionList : List Model.Permission -> Model -> ( Model, Cmd msg )
permissionList permissions model =
    ( { model | permissions = Utils.dictifyEntities unwrapPermission Model.Permission permissions }
    , Cmd.none
    )


permissionCreate : Model.Permission -> Model -> ( Model, Cmd Msg )
permissionCreate permission model =
    ( model, Cmd.Extra.message Init )


permissionSaved : Model.Permission -> model -> ( model, Cmd Msg )
permissionSaved permission model =
    ( model, Cmd.Extra.message Init )


permissionDelete : String -> Model -> ( Model, Cmd Msg )
permissionDelete id model =
    let
        newPermissions =
            Dict.remove id model.permissions

        numToDelete =
            model.numToDelete - 1
    in
        ( { model | permissions = newPermissions }
        , if numToDelete == 0 then
            Cmd.Extra.message Init
          else
            Cmd.none
        )


permissionDeleteError : Http.Error -> Model -> ( Model, Cmd Msg )
permissionDeleteError error model =
    let
        numToDelete =
            model.numToDelete - 1
    in
        ( { model | numToDelete = numToDelete }
        , if numToDelete == 0 then
            Cmd.Extra.message Init
          else
            Cmd.none
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case (Debug.log "permissions" action) of
        Mdl action' ->
            Material.update action' model

        PermissionApi action' ->
            Permission.Service.update permissionCallbacks action' model

        Init ->
            ( { model | permissionToEdit = None }
            , Cmd.batch
                [ Permission.Service.invokeFindAll PermissionApi
                , Permission.Service.invokeFindAll PermissionApi
                ]
            )

        ToggleAll ->
            updateToggleAll model

        Toggle id ->
            updateToggle id model

        UpdatePermissionName permissionName ->
            ( { model | permissionName = Utils.cleanString permissionName }, Cmd.none )

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
                model.permissions
    }
        ! []


updateToggle : String -> Model -> ( Model, Cmd Msg )
updateToggle id model =
    let
        item =
            Dict.get id model.permissions
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
    ( { model
        | permissionToEdit = New
        , permissionName = Nothing
      }
    , Cmd.none
    )


updateEdit : String -> Model -> ( Model, Cmd Msg )
updateEdit id model =
    let
        item =
            Dict.get id model.permissions
    in
        case item of
            Nothing ->
                ( model, Cmd.none )

            Just permissionRec ->
                let
                    (Model.Permission permission) =
                        permissionRec
                in
                    ( { model
                        | permissionName = permission.name
                        , permissionToEdit = WithId id permissionRec
                      }
                    , Cmd.none
                    )


updateConfirmDelete model =
    let
        toDelete =
            (Dict.keys <| Dict.intersect model.permissions model.selected)
    in
        ( { model
            | selected = Dict.empty
            , numToDelete = model.numToDelete + List.length toDelete
          }
        , List.map
            (\id ->
                Permission.Service.invokeDelete PermissionApi id
            )
            toDelete
            |> Cmd.batch
        )


updateSave model =
    case model.permissionToEdit of
        None ->
            ( model, Cmd.none )

        WithId id _ ->
            let
                modifiedPermission =
                    Model.Permission
                        { id = Just id
                        , name = model.permissionName
                        }
            in
                ( model
                , Permission.Service.invokeUpdate PermissionApi id modifiedPermission
                )

        New ->
            ( model
            , Permission.Service.invokeCreate PermissionApi
                (Model.Permission
                    { id = Nothing
                    , name = model.permissionName
                    }
                )
            )
