module Page.Roles exposing (Model, Msg(..), dialog, init, root, update)

import Auth
import Config exposing (Config)
import Dict exposing (Dict)
import Html exposing (Html, div, h4, span, text)
import Html.Attributes exposing (action, class, colspan, title)
import Http
import Model
import Permission.Service
import Platform.Cmd exposing (Cmd)
import Role.Service
import Task.Extra exposing (message)
import Utils
    exposing
        ( checkAll
        , cleanString
        , dictifyEntities
        , error
        , indexedFoldr
        , leftIntersect
        , symDiff
        , toggleSet
        , valOrEmpty
        )


type ItemToEdit
    = None
    | WithId String Model.Role
    | New


type alias Model =
    { config : Config
    , selected : Dict String Model.Role
    , roles : Dict String Model.Role
    , roleName : Maybe String
    , permissionLookup : Dict String Model.Permission
    , selectedPermissions : Dict String Model.Permission
    , roleToEdit : ItemToEdit
    , numToDelete : Int
    }


type Msg
    = AuthMsg Auth.Msg
    | RoleApi Role.Service.Msg
    | PermissionApi Permission.Service.Msg
    | Init
    | Toggle String
    | ToggleAll
    | UpdateRoleName String
    | SelectChanged (Dict String String)
    | Add
    | Edit String
    | Delete
    | ConfirmDelete
    | Save


init : Config -> Model
init config =
    { config = config
    , selected = Dict.empty
    , roles = Dict.empty
    , roleName = Nothing
    , permissionLookup = Dict.empty
    , selectedPermissions = Dict.empty
    , roleToEdit = None
    , numToDelete = 0
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
    dictifyEntities unwrapPermission Model.Permission permissions


unwrapRole (Model.Role role) =
    role


unwrapPermission (Model.Permission permission) =
    permission



-- Validations on the model


checkRoleNameExists : Model -> Bool
checkRoleNameExists model =
    case model.roleName of
        Nothing ->
            False

        Just roleName ->
            String.length roleName > 0


checkAtLeastOnePermission : Model -> Bool
checkAtLeastOnePermission model =
    not (Dict.isEmpty model.selectedPermissions)


validateCreateRole : Model -> Bool
validateCreateRole =
    checkAll
        [ checkRoleNameExists
        , checkAtLeastOnePermission
        ]


validateEditAccount : Model -> Bool
validateEditAccount =
    checkAll
        [ checkRoleNameExists
        , checkAtLeastOnePermission
        ]


isChangeRoleName : Model -> Bool
isChangeRoleName model =
    case model.roleToEdit of
        None ->
            False

        New ->
            False

        WithId _ (Model.Role role) ->
            role.name /= model.roleName


isChangePermissions : Model -> Bool
isChangePermissions model =
    case model.roleToEdit of
        None ->
            False

        New ->
            False

        WithId _ role ->
            not (Dict.isEmpty (symDiff (permissionDictFromRole role) model.selectedPermissions))


isEditedAndValid : Model -> Bool
isEditedAndValid model =
    validateEditAccount model
        && (isChangeRoleName model || isChangePermissions model)



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
        , deleteError = roleDeleteError
        , error = error AuthMsg
    }


roleList : List Model.Role -> Model -> ( Model, Cmd msg )
roleList roles model =
    ( { model | roles = dictifyEntities unwrapRole Model.Role roles }
    , Cmd.none
    )


roleCreate : Model.Role -> Model -> ( Model, Cmd Msg )
roleCreate role model =
    ( model, message Init )


roleSaved : Model.Role -> model -> ( model, Cmd Msg )
roleSaved role model =
    ( model, message Init )


roleDelete : String -> Model -> ( Model, Cmd Msg )
roleDelete id model =
    let
        newRoles =
            Dict.remove id model.roles

        numToDelete =
            model.numToDelete - 1
    in
    ( { model | roles = newRoles }
    , if numToDelete == 0 then
        message Init

      else
        Cmd.none
    )


roleDeleteError : Http.Error -> Model -> ( Model, Cmd Msg )
roleDeleteError error model =
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



-- Permission REST API calls


permissionCallbacks : Permission.Service.Callbacks Model Msg
permissionCallbacks =
    let
        default =
            Permission.Service.callbacks
    in
    { default
        | findAll = permissionList
        , error = error AuthMsg
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
    case Debug.log "permissions" action of
        AuthMsg authMsg ->
            ( model, Cmd.none )

        RoleApi action_ ->
            Role.Service.update roleCallbacks action_ model

        PermissionApi action_ ->
            Permission.Service.update permissionCallbacks action_ model

        Init ->
            ( { model | roleToEdit = None }
            , Cmd.batch
                [ Role.Service.invokeFindAll model.config.apiRoot RoleApi
                , Permission.Service.invokeFindAll model.config.apiRoot PermissionApi
                ]
            )

        ToggleAll ->
            updateToggleAll model

        Toggle id ->
            updateToggle id model

        UpdateRoleName roleName ->
            ( { model | roleName = cleanString roleName }, Cmd.none )

        SelectChanged permissions ->
            ( { model | selectedPermissions = leftIntersect model.permissionLookup permissions }, Cmd.none )

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
    ( { model
        | roleToEdit = New
        , roleName = Nothing
        , selectedPermissions = Dict.empty
      }
    , Cmd.none
    )


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
                , roleToEdit = WithId id roleRec
              }
            , Cmd.none
            )


updateConfirmDelete model =
    let
        toDelete =
            Dict.keys <| Dict.intersect model.roles model.selected
    in
    ( { model
        | selected = Dict.empty
        , numToDelete = model.numToDelete + List.length toDelete
      }
    , List.map
        (\id ->
            Role.Service.invokeDelete model.config.apiRoot RoleApi id
        )
        toDelete
        |> Cmd.batch
    )


updateSave model =
    case model.roleToEdit of
        None ->
            ( model, Cmd.none )

        WithId id _ ->
            let
                modifiedRole =
                    Model.Role
                        { id = Just id
                        , name = model.roleName
                        , permissions = Just <| Dict.values model.selectedPermissions
                        }
            in
            ( model
            , Role.Service.invokeUpdate model.config.apiRoot RoleApi id modifiedRole
            )

        New ->
            ( model
            , Role.Service.invokeCreate model.config.apiRoot
                RoleApi
                (Model.Role
                    { id = Nothing
                    , name = model.roleName
                    , permissions = Just <| Dict.values model.selectedPermissions
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
            [ Table.thead []
                [ Table.tr [ cs "data-table__inactive-row" |> Options.when (model.roleToEdit /= None) ]
                    [ Table.th []
                        [ Toggles.checkbox Mdl
                            [ -1 ]
                            model.mdl
                            [ Options.onClick ToggleAll
                            , Toggles.value (allSelected model)
                            , Toggles.disabled |> Options.when (model.roleToEdit /= None)
                            ]
                            []
                        ]
                    , Table.th [ cs "mdl-data-table__cell--non-numeric" ] [ text "Role" ]
                    , Table.th [ cs "mdl-data-table__cell--non-numeric" ] [ text "Permissions" ]
                    , Table.th [ cs "mdl-data-table__cell--non-numeric" ] [ text "Actions" ]
                    ]
                ]
            , Table.tbody []
                (if model.roleToEdit == New then
                    indexedFoldr (roleToRow model) [ addRow model ] model.roles

                 else
                    indexedFoldr (roleToRow model) [] model.roles
                )
            ]
        , controlBar model
        ]


permissionLookup : Model -> List (Html Msg)
permissionLookup model =
    [ h4 [] [ text "Permissions" ]
    , listbox
        [ items <| Dict.map (\id -> \(Model.Permission permission) -> valOrEmpty permission.name) model.permissionLookup
        , initiallySelected <| Dict.map (\id -> \(Model.Permission permission) -> valOrEmpty permission.name) model.selectedPermissions
        , onSelectedChanged SelectChanged
        ]
    ]


roleForm : Model -> Bool -> String -> Html Msg
roleForm model isValid completeText =
    Grid.grid []
        [ ViewUtils.column644
            [ Textfield.render Mdl
                [ 1 ]
                model.mdl
                [ Textfield.label "Role"
                , Textfield.floatingLabel
                , Textfield.text_
                , Options.onInput UpdateRoleName
                , Textfield.value <| valOrEmpty model.roleName
                ]
                []
            ]
        , ViewUtils.column644 (permissionLookup model)
        , ViewUtils.columnAll12
            [ ViewUtils.okCancelControlBar
                model.mdl
                Mdl
                (ViewUtils.completeButton model.mdl Mdl completeText isValid Save)
                (ViewUtils.cancelButton model.mdl Mdl "Cancel" Init)
            ]
        ]


addRow : Model -> Html Msg
addRow model =
    Table.tr []
        [ Html.td [ colspan 4, class "mdl-data-table__cell--non-numeric data-table__active-row" ]
            [ roleForm model (validateCreateRole model) "Create"
            ]
        ]


editRow : Model -> Int -> String -> Model.Role -> Html Msg
editRow model idx id (Model.Role role) =
    Table.tr []
        [ Html.td [ colspan 4, class "mdl-data-table__cell--non-numeric data-table__active-row" ]
            [ roleForm model (isEditedAndValid model) "Save"
            ]
        ]


viewRow : Model -> Int -> String -> Model.Role -> Html Msg
viewRow model idx id (Model.Role role) =
    Table.tr
        [ Table.selected |> Options.when (Dict.member id model.selected)
        , cs "data-table__inactive-row" |> Options.when (model.roleToEdit /= None)
        ]
        [ Table.td []
            [ Toggles.checkbox Mdl
                [ idx ]
                model.mdl
                [ Options.onClick (Toggle id)
                , Toggles.value <| Dict.member id model.selected
                , Toggles.disabled |> Options.when (model.roleToEdit /= None)
                ]
                []
            ]
        , Table.td [ cs "mdl-data-table__cell--non-numeric" ] [ text <| valOrEmpty role.name ]
        , Table.td [ cs "mdl-data-table__cell--non-numeric" ]
            (List.foldr permissionToChip [] <| Maybe.withDefault [] role.permissions)
        , Table.td
            [ cs "mdl-data-table__cell--non-numeric"
            , css "width" "20%"
            ]
            [ Button.render Mdl
                [ 0, idx ]
                model.mdl
                [ Button.accent
                , if model.roleToEdit /= None then
                    Button.disabled

                  else
                    Button.ripple
                , Options.onClick (Edit id)
                ]
                [ text "Edit" ]
            ]
        ]


roleToRow : Model -> Int -> String -> Model.Role -> List (Html Msg) -> List (Html Msg)
roleToRow model idx id role items =
    let
        showAsEdit =
            editRow model idx id role

        showAsView =
            viewRow model idx id role
    in
    (case model.roleToEdit of
        WithId editId _ ->
            if editId == id then
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
    span [ class "mdl-chip mdl-chip__text" ]
        [ text <| valOrEmpty permission.name ]
        :: items


controlBar : Model -> Html Msg
controlBar model =
    div [ class "control-bar" ]
        [ div [ class "control-bar__row" ]
            [ div [ class "control-bar__left-0" ]
                [ span [ class "mdl-chip mdl-chip__text" ]
                    [ text (toString (Dict.size model.roles) ++ " items") ]
                ]
            , div [ class "control-bar__right-0" ]
                [ Button.render Mdl
                    [ 1, 0 ]
                    model.mdl
                    [ Button.fab
                    , Button.colored
                    , if model.roleToEdit /= None then
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
                    , if someSelected model && (model.roleToEdit == None) then
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
