module Roles.View exposing (root, dialog)

import Dict
import Html exposing (..)
import Html.Attributes exposing (title, class, action, colspan)
import Platform.Cmd exposing (Cmd)
import String
import Material.Options as Options exposing (Style, cs, css, when, nop, disabled, attribute)
import Material.Dialog as Dialog
import Material.Table as Table
import Material.Button as Button
import Material.Icon as Icon
import Material.Toggles as Toggles
import Material.Textfield as Textfield
import Material.Grid as Grid
import Material.Chip as Chip
import Utils exposing (..)
import ViewUtils
import Roles.Types exposing (..)
import Roles.State exposing (..)
import Model
import Listbox exposing (listbox, onSelectedChanged, items, initiallySelected)


root : Model -> Html Msg
root model =
    div [ class "layout-fixed-width" ]
        [ h4 [] [ text "Roles" ]
        , table model
        ]


table : Model -> Html Msg
table model =
    div [ class "data-table__apron mdl-shadow--2dp" ]
        [ Table.table [ cs "mdl-data-table mdl-js-data-table mdl-data-table--selectable" ]
            [ Table.thead []
                [ Table.tr []
                    [ Table.th []
                        [ Toggles.checkbox Mdl
                            [ -1 ]
                            model.mdl
                            [ Toggles.onClick ToggleAll
                            , Toggles.value (allSelected model)
                            , Toggles.disabled `when` (model.roleToEdit /= None)
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
                    (indexedFoldr (roleToRow model) [ addRow model ] model.roles)
                 else
                    (indexedFoldr (roleToRow model) [] model.roles)
                )
            ]
        , controlBar model
        ]


permissionLookup : Model -> List (Html Msg)
permissionLookup model =
    [ h4 [] [ text "Permissions" ]
    , listbox
        [ items <| Dict.map (\id -> \(Model.Permission permission) -> Utils.valOrEmpty permission.name) model.permissionLookup
        , initiallySelected <| Dict.map (\id -> \(Model.Permission permission) -> Utils.valOrEmpty permission.name) model.selectedPermissions
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
                , Textfield.text'
                , Textfield.onInput UpdateRoleName
                , Textfield.value <| Utils.valOrEmpty model.roleName
                ]
            ]
        , ViewUtils.column644 (permissionLookup model)
        , ViewUtils.columnAll12
            [ ViewUtils.okCancelControlBar
                model.mdl
                Mdl
                (ViewUtils.completeButton model.mdl Mdl completeText (isValid) Save)
                (ViewUtils.cancelButton model.mdl Mdl "Cancel" Cancel)
            ]
        ]


addRow : Model -> Html Msg
addRow model =
    Table.tr []
        [ Html.td [ colspan 4, class "mdl-data-table__cell--non-numeric" ]
            [ roleForm model (validateCreateRole model) "Create"
            ]
        ]


editRow : Model -> Int -> String -> Model.Role -> Html Msg
editRow model idx id (Model.Role role) =
    Table.tr []
        [ Html.td [ colspan 4, class "mdl-data-table__cell--non-numeric" ]
            [ roleForm model (isEditedAndValid model) "Save"
            ]
        ]


viewRow : Model -> Int -> String -> Model.Role -> Html Msg
viewRow model idx id (Model.Role role) =
    (Table.tr
        [ Table.selected `when` Dict.member id model.selected ]
        [ Table.td []
            [ Toggles.checkbox Mdl
                [ idx ]
                model.mdl
                [ Toggles.onClick (Toggle id)
                , Toggles.value <| Dict.member id model.selected
                , Toggles.disabled `when` (model.roleToEdit /= None)
                ]
                []
            ]
        , Table.td [ cs "mdl-data-table__cell--non-numeric" ] [ text <| Utils.valOrEmpty role.name ]
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
                , Button.onClick (Edit id)
                ]
                [ text "Edit" ]
            ]
        ]
    )


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
        [ text <| Utils.valOrEmpty permission.name ]
    )
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
                    , Button.onClick Add
                    ]
                    [ Icon.i "add" ]
                ]
            , div [ class "control-bar__right-0" ]
                [ Button.render Mdl
                    [ 1, 1 ]
                    model.mdl
                    [ cs "mdl-button--warn"
                    , if someSelected model then
                        Button.ripple
                      else
                        Button.disabled
                    , Button.onClick Delete
                    , Dialog.openOn "click"
                    ]
                    [ text "Delete" ]
                ]
            ]
        ]


dialog model =
    ViewUtils.confirmDialog model "Delete" Mdl ConfirmDelete
