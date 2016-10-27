module Accounts.View exposing (root, dialog)

import Set as Set
import Array
import Dict
import Html exposing (..)
import Html.Attributes exposing (title, class, action, attribute)
import Html.Events exposing (on)
import Json.Decode as Decode
import Material
import Material.Options as Options exposing (Style, cs, when, nop, disabled, css)
import Material.Dialog as Dialog
import Material.Table as Table
import Material.Button as Button
import Material.Icon as Icon
import Material.Toggles as Toggles
import Material.Textfield as Textfield
import Material.Grid as Grid
import Material.Chip as Chip
import Utils exposing (..)
import Accounts.Types exposing (..)
import Accounts.State exposing (..)
import Model
import Listbox exposing (listbox, onSelectedChanged, items, initiallySelected)
import ViewUtils


root : Model -> Html Msg
root model =
    div [ class "layout-fixed-width" ]
        [ case model.viewState of
            ListView ->
                table model

            CreateView ->
                createAccountForm model

            EditView ->
                editAccountForm model
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
                            ]
                            []
                        ]
                    , Table.th [ cs "mdl-data-table__cell--non-numeric" ] [ text "Username" ]
                    , Table.th [ cs "mdl-data-table__cell--non-numeric" ] [ text "Actions" ]
                    ]
                ]
            , Table.tbody []
                (indexedFoldr (accountToRow model) [] model.accounts)
            ]
        , controlBar model
        ]


accountToRow : Model -> Int -> String -> Model.Account -> List (Html Msg) -> List (Html Msg)
accountToRow model idx id account items =
    let
        (Model.Account accountRec) =
            account
    in
        (Table.tr
            [ Table.selected `when` Dict.member id model.selected ]
            [ Table.td []
                [ Toggles.checkbox Mdl
                    [ idx ]
                    model.mdl
                    [ Toggles.onClick (Toggle id)
                    , Toggles.value <| Dict.member id model.selected
                    ]
                    []
                ]
            , Table.td [ cs "mdl-data-table__cell--non-numeric" ] [ text <| Utils.valOrEmpty accountRec.username ]
            , Table.td
                [ cs "mdl-data-table__cell--non-numeric"
                , css "width" "20%"
                ]
                [ Button.render Mdl
                    [ 0, idx ]
                    model.mdl
                    [ Button.accent
                    , Button.ripple
                    , Button.onClick (Edit id)
                    ]
                    [ text "Edit" ]
                , Button.render Mdl
                    [ 0, 1, idx ]
                    model.mdl
                    [ --Button.colored
                      Button.ripple
                      --, Button.onClick (Edit id)
                    ]
                    [ Icon.i "expand_more" ]
                ]
            ]
        )
            :: items


controlBar : Model -> Html Msg
controlBar model =
    div [ class "control-bar" ]
        [ div [ class "control-bar__row" ]
            [ div [ class "control-bar__left-0" ]
                [ span [ class "mdl-chip mdl-chip__text" ]
                    [ text (toString (Dict.size model.accounts) ++ " items") ]
                ]
            , div [ class "control-bar__right-0" ]
                [ Button.render Mdl
                    [ 1, 0 ]
                    model.mdl
                    [ Button.fab
                    , Button.colored
                    , Button.ripple
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


createAccountForm : Model -> Html Msg
createAccountForm model =
    Grid.grid []
        [ ViewUtils.column644
            [ Textfield.render Mdl
                [ 1 ]
                model.mdl
                [ Textfield.label "Username"
                , Textfield.floatingLabel
                , Textfield.text'
                , Textfield.onInput UpdateUsername
                , Textfield.value <| Utils.valOrEmpty model.username
                ]
            , password1Field model
            , password2Field model
            ]
        , ViewUtils.column644 (roleLookup model)
        , ViewUtils.columnAll12
            [ ViewUtils.okCancelControlBar
                model.mdl
                Mdl
                (ViewUtils.completeButton model.mdl Mdl "Create" (validateCreateAccount model) Create)
                (ViewUtils.cancelButton model.mdl Mdl "Back" Init)
            ]
        ]


editAccountForm : Model -> Html Msg
editAccountForm model =
    Grid.grid []
        [ ViewUtils.column644
            [ Textfield.render Mdl
                [ 1 ]
                model.mdl
                [ Textfield.label "Username"
                , Textfield.floatingLabel
                , Textfield.text'
                , Textfield.disabled
                , Textfield.value <| Utils.valOrEmpty model.username
                ]
            , password1Field model
            , password2Field model
            ]
        , ViewUtils.column644 (roleLookup model)
        , ViewUtils.columnAll12
            [ ViewUtils.okCancelControlBar
                model.mdl
                Mdl
                (ViewUtils.completeButton model.mdl Mdl "Save" (isEditedAndValid model) Save)
                (ViewUtils.cancelButton model.mdl Mdl "Back" Init)
            ]
        ]


password1Field : Model -> Html Msg
password1Field model =
    Textfield.render
        Mdl
        [ 2 ]
        model.mdl
        [ Textfield.label "Password"
        , Textfield.floatingLabel
        , Textfield.password
        , Textfield.onInput UpdatePassword1
        , Textfield.value <| Utils.valOrEmpty model.password1
        ]


password2Field : Model -> Html Msg
password2Field model =
    Textfield.render
        Mdl
        [ 3 ]
        model.mdl
        [ Textfield.label "Repeat Password"
        , Textfield.floatingLabel
        , Textfield.password
        , Textfield.onInput UpdatePassword2
        , Textfield.value <| Utils.valOrEmpty model.password2
        , if checkPasswordMatch model then
            Options.nop
          else
            Textfield.error <| "Passwords do not match."
        ]


roleLookup : Model -> List (Html Msg)
roleLookup model =
    [ h4 [] [ text "Roles" ]
    , listbox
        [ items <| Dict.map (\id -> \(Model.Role role) -> Utils.valOrEmpty role.name) model.roleLookup
        , initiallySelected <| Dict.map (\id -> \(Model.Role role) -> Utils.valOrEmpty role.name) model.selectedRoles
        , onSelectedChanged SelectChanged
        ]
    ]
