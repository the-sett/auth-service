module Permissions exposing (Model, Msg(..), init, update, root, dialog)

import Auth
import Config exposing (Config)
import Dict exposing (Dict)
import Html.Attributes exposing (title, class, action, colspan)
import Html exposing (Html, div, text, span)
import Http
import Listbox exposing (listbox, onSelectedChanged, items, initiallySelected)
import Material
import Material.Button as Button
import Material.Chip as Chip
import Material.Dialog as Dialog
import Material.Grid as Grid
import Material.Icon as Icon
import Material.Options as Options exposing (Style, cs, css, nop, disabled, attribute)
import Material.Table as Table
import Material.Textfield as Textfield
import Material.Toggles as Toggles
import Model
import Permission.Service
import Platform.Cmd exposing (Cmd)
import Task.Extra exposing (message)
import Utils
    exposing
        ( error
        , checkAll
        , indexedFoldr
        , valOrEmpty
        , leftIntersect
        , cleanString
        , toggleSet
        , dictifyEntities
        , symDiff
        )
import ViewUtils


type ItemToEdit
    = None
    | WithId String Model.Permission
    | New


type alias Model =
    { mdl : Material.Model
    , config : Config
    , selected : Dict String Model.Permission
    , permissions : Dict String Model.Permission
    , permissionName : Maybe String
    , permissionToEdit : ItemToEdit
    , numToDelete : Int
    }


type Msg
    = Mdl (Material.Msg Msg)
    | AuthMsg Auth.Msg
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


init : Config -> Model
init config =
    { mdl = Material.model
    , config = config
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
    dictifyEntities unwrapPermission Model.Permission permissions


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
            , error = error AuthMsg
        }


permissionList : List Model.Permission -> Model -> ( Model, Cmd msg )
permissionList permissions model =
    ( { model | permissions = dictifyEntities unwrapPermission Model.Permission permissions }
    , Cmd.none
    )


permissionCreate : Model.Permission -> Model -> ( Model, Cmd Msg )
permissionCreate permission model =
    ( model, message Init )


permissionSaved : Model.Permission -> model -> ( model, Cmd Msg )
permissionSaved permission model =
    ( model, message Init )


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
            message Init
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
            message Init
          else
            Cmd.none
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case (Debug.log "permissions" action) of
        Mdl action_ ->
            Material.update Mdl action_ model

        AuthMsg authMsg ->
            ( model, Cmd.none )

        PermissionApi action_ ->
            Permission.Service.update permissionCallbacks action_ model

        Init ->
            ( { model | permissionToEdit = None }
            , Cmd.batch
                [ Permission.Service.invokeFindAll model.config.apiRoot PermissionApi
                , Permission.Service.invokeFindAll model.config.apiRoot PermissionApi
                ]
            )

        ToggleAll ->
            updateToggleAll model

        Toggle id ->
            updateToggle id model

        UpdatePermissionName permissionName ->
            ( { model | permissionName = cleanString permissionName }, Cmd.none )

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
                Permission.Service.invokeDelete model.config.apiRoot PermissionApi id
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
                , Permission.Service.invokeUpdate
                    model.config.apiRoot
                    PermissionApi
                    id
                    modifiedPermission
                )

        New ->
            ( model
            , Permission.Service.invokeCreate model.config.apiRoot
                PermissionApi
                (Model.Permission
                    { id = Nothing
                    , name = model.permissionName
                    }
                )
            )


root : Model -> Html Msg
root model =
    div [ class "layout-fixed-width" ]
        [ ViewUtils.rhythm1SpacerDiv
        , table model
        ]


table : Model -> Html Msg
table model =
    div [ class "data-table__apron mdl-shadow--2dp" ]
        [ Table.table [ cs "mdl-data-table mdl-js-data-table mdl-data-table--selectable" ]
            [ Table.thead [ cs "data-table__inactive-row" |> Options.when (model.permissionToEdit /= None) ]
                [ Table.tr []
                    [ Table.th []
                        [ Toggles.checkbox Mdl
                            [ -1 ]
                            model.mdl
                            [ Options.onClick ToggleAll
                            , Toggles.value (allSelected model)
                            , Toggles.disabled |> Options.when (model.permissionToEdit /= None)
                            ]
                            []
                        ]
                    , Table.th [ cs "mdl-data-table__cell--non-numeric" ] [ text "Permission" ]
                    , Table.th [ cs "mdl-data-table__cell--non-numeric" ] [ text "Actions" ]
                    ]
                ]
            , Table.tbody []
                (if model.permissionToEdit == New then
                    (indexedFoldr (permissionToRow model) [ addRow model ] model.permissions)
                 else
                    (indexedFoldr (permissionToRow model) [] model.permissions)
                )
            ]
        , controlBar model
        ]


permissionForm : Model -> Bool -> String -> Html Msg
permissionForm model isValid completeText =
    Grid.grid []
        [ ViewUtils.column644
            [ Textfield.render Mdl
                [ 1 ]
                model.mdl
                [ Textfield.label "Permission"
                , Textfield.floatingLabel
                , Textfield.text_
                , Options.onInput UpdatePermissionName
                , Textfield.value <| valOrEmpty model.permissionName
                ]
                []
            ]
        , ViewUtils.columnAll12
            [ ViewUtils.okCancelControlBar
                model.mdl
                Mdl
                (ViewUtils.completeButton model.mdl Mdl completeText (isValid) Save)
                (ViewUtils.cancelButton model.mdl Mdl "Cancel" Init)
            ]
        ]


addRow : Model -> Html Msg
addRow model =
    Table.tr []
        [ Html.td [ colspan 4, class "mdl-data-table__cell--non-numeric data-table__active-row" ]
            [ permissionForm model (validateCreatePermission model) "Create"
            ]
        ]


editRow : Model -> Int -> String -> Model.Permission -> Html Msg
editRow model idx id (Model.Permission permission) =
    Table.tr []
        [ Html.td [ colspan 4, class "mdl-data-table__cell--non-numeric data-table__active-row" ]
            [ permissionForm model (isEditedAndValid model) "Save"
            ]
        ]


viewRow : Model -> Int -> String -> Model.Permission -> Html Msg
viewRow model idx id (Model.Permission permission) =
    (Table.tr
        [ Table.selected |> Options.when (Dict.member id model.selected)
        , cs "data-table__inactive-row" |> Options.when (model.permissionToEdit /= None)
        ]
        [ Table.td []
            [ Toggles.checkbox Mdl
                [ idx ]
                model.mdl
                [ Options.onClick (Toggle id)
                , Toggles.value <| Dict.member id model.selected
                , Toggles.disabled |> Options.when (model.permissionToEdit /= None)
                ]
                []
            ]
        , Table.td [ cs "mdl-data-table__cell--non-numeric" ] [ text <| valOrEmpty permission.name ]
        , Table.td
            [ cs "mdl-data-table__cell--non-numeric"
            , css "width" "20%"
            ]
            [ Button.render Mdl
                [ 0, idx ]
                model.mdl
                [ Button.accent
                , if model.permissionToEdit /= None then
                    Button.disabled
                  else
                    Button.ripple
                , Options.onClick (Edit id)
                ]
                [ text "Edit" ]
            ]
        ]
    )


permissionToRow : Model -> Int -> String -> Model.Permission -> List (Html Msg) -> List (Html Msg)
permissionToRow model idx id permission items =
    let
        showAsEdit =
            editRow model idx id permission

        showAsView =
            viewRow model idx id permission
    in
        (case model.permissionToEdit of
            WithId editId _ ->
                if (editId == id) then
                    showAsEdit
                else
                    showAsView

            New ->
                showAsView

            None ->
                showAsView
        )
            :: items


permissionToChip : Model.Permission -> List (Html Msg) -> List (Html Msg)
permissionToChip (Model.Permission permission) items =
    (span [ class "mdl-chip mdl-chip__text" ]
        [ text <| valOrEmpty permission.name ]
    )
        :: items


controlBar : Model -> Html Msg
controlBar model =
    div [ class "control-bar" ]
        [ div [ class "control-bar__row" ]
            [ div [ class "control-bar__left-0" ]
                [ span [ class "mdl-chip mdl-chip__text" ]
                    [ text (toString (Dict.size model.permissions) ++ " items") ]
                ]
            , div [ class "control-bar__right-0" ]
                [ Button.render Mdl
                    [ 1, 0 ]
                    model.mdl
                    [ Button.fab
                    , Button.colored
                    , if model.permissionToEdit /= None then
                        Button.disabled
                      else
                        Button.ripple
                    , Options.onClick Add
                    ]
                    [ Icon.i "add" ]
                ]
            , div [ class "control-bar__right-0" ]
                [ Button.render Mdl
                    [ 1, 1 ]
                    model.mdl
                    [ cs "mdl-button--warn"
                    , if (someSelected model) && (model.permissionToEdit == None) then
                        Button.ripple
                      else
                        Button.disabled
                    , Options.onClick Delete
                    , Dialog.openOn "click"
                    ]
                    [ text "Delete" ]
                ]
            ]
        ]


dialog model =
    ViewUtils.confirmDialog model "Delete" Mdl ConfirmDelete
