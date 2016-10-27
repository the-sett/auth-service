module Permissions.View exposing (root, dialog)

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
import Permissions.Types exposing (..)
import Permissions.State exposing (..)
import Model
import Listbox exposing (listbox, onSelectedChanged, items, initiallySelected)


root : Model -> Html Msg
root model =
    div [ class "layout-fixed-width" ]
        [ table model ]


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
                            , Toggles.disabled `when` (model.permissionToEdit /= None)
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
                , Textfield.text'
                , Textfield.onInput UpdatePermissionName
                , Textfield.value <| Utils.valOrEmpty model.permissionName
                ]
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
        [ Html.td [ colspan 4, class "mdl-data-table__cell--non-numeric" ]
            [ permissionForm model (validateCreatePermission model) "Create"
            ]
        ]


editRow : Model -> Int -> String -> Model.Permission -> Html Msg
editRow model idx id (Model.Permission permission) =
    Table.tr []
        [ Html.td [ colspan 4, class "mdl-data-table__cell--non-numeric" ]
            [ permissionForm model (isEditedAndValid model) "Save"
            ]
        ]


viewRow : Model -> Int -> String -> Model.Permission -> Html Msg
viewRow model idx id (Model.Permission permission) =
    (Table.tr
        [ Table.selected `when` Dict.member id model.selected ]
        [ Table.td []
            [ Toggles.checkbox Mdl
                [ idx ]
                model.mdl
                [ Toggles.onClick (Toggle id)
                , Toggles.value <| Dict.member id model.selected
                , Toggles.disabled `when` (model.permissionToEdit /= None)
                ]
                []
            ]
        , Table.td [ cs "mdl-data-table__cell--non-numeric" ] [ text <| Utils.valOrEmpty permission.name ]
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
                , Button.onClick (Edit id)
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
        [ text <| Utils.valOrEmpty permission.name ]
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
                    , Button.onClick Add
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
                    , Button.onClick Delete
                    , Dialog.openOn "click"
                    ]
                    [ text "Delete" ]
                ]
            ]
        ]


dialog model =
    ViewUtils.confirmDialog model "Delete" Mdl ConfirmDelete
