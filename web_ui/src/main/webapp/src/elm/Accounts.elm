module Accounts
    exposing
        ( Model
        , Msg(..)
        , init
        , update
        , root
        , dialog
        )

import Account.Service
import Array
import Array exposing (Array)
import Auth
import Config exposing (Config)
import Dict
import Dict exposing (Dict)
import Dict.Extra
import Exts.Maybe exposing (catMaybes)
import Html.Attributes exposing (title, class, action, attribute, colspan)
import Html.Events exposing (on)
import Html exposing (Html, div, span, h4, text)
import Http
import Json.Decode as Decode
import Listbox exposing (listbox, onSelectedChanged, items, initiallySelected)
import List.Extra
import Material
import Material.Button as Button
import Material.Chip as Chip
import Material.Dialog as Dialog
import Material.Grid as Grid
import Material.Icon as Icon
import Material.Options as Options exposing (Style, cs, nop, disabled, css)
import Material.Table as Table
import Material.Textfield as Textfield
import Material.Toggles as Toggles
import Maybe
import Model
import Platform.Cmd exposing (Cmd)
import Role.Service
import Set
import Set as Set
import Set exposing (Set)
import String
import Utils exposing (error, checkAll, indexedFoldr)
import ViewUtils


-- Model and its manipulations


type ViewState
    = ListView
    | CreateView
    | EditView


type alias Model =
    { mdl : Material.Model
    , config : Config
    , selected : Dict String Model.Account
    , accounts : Dict String Model.Account
    , accountToEdit : Maybe Model.Account
    , viewState : ViewState
    , username : Maybe String
    , password1 : Maybe String
    , password2 : Maybe String
    , roleLookup : Dict String Model.Role
    , selectedRoles : Dict String Model.Role
    , numToDelete : Int
    , moreStatus : Set String
    }


type Msg
    = Mdl (Material.Msg Msg)
    | AuthMsg Auth.Msg
    | AccountApi Account.Service.Msg
    | RoleApi Role.Service.Msg
    | Init
    | Toggle String
    | ToggleAll
    | ToggleMore String
    | Add
    | Delete
    | ConfirmDelete
    | Edit String
    | UpdateUsername String
    | UpdatePassword1 String
    | UpdatePassword2 String
    | SelectChanged (Dict String String)
    | Save
    | Create


init : Config -> Model
init config =
    { mdl = Material.model
    , config = config
    , selected = Dict.empty
    , accounts = Dict.empty
    , accountToEdit = Nothing
    , viewState = ListView
    , username = Nothing
    , password1 = Nothing
    , password2 = Nothing
    , roleLookup = Dict.empty
    , selectedRoles = Dict.empty
    , numToDelete = 0
    , moreStatus = Set.empty
    }


resetAccountForm : Model -> Model
resetAccountForm model =
    { model
        | username = Nothing
        , password1 = Nothing
        , password2 = Nothing
        , selectedRoles = Dict.empty
    }


allSelected : Model -> Bool
allSelected model =
    Dict.size model.selected == Dict.size model.accounts


someSelected : Model -> Bool
someSelected model =
    Dict.size model.selected > 0


roleDictFromAccount : Model.Account -> Dict String Model.Role
roleDictFromAccount (Model.Account account) =
    case account.roles of
        Nothing ->
            Dict.empty

        Just roles ->
            roleListToDict roles


roleListToDict : List Model.Role -> Dict String Model.Role
roleListToDict roles =
    Utils.dictifyEntities unwrapRole Model.Role roles


isAccountRoot (Model.Account account) =
    case account.root of
        Nothing ->
            False

        Just root ->
            root


unwrapAccount (Model.Account account) =
    account


unwrapRole (Model.Role role) =
    role


unwrapPermission (Model.Permission permission) =
    permission


moreSelected : String -> Model -> Bool
moreSelected id model =
    Set.member id model.moreStatus


conflatePermissions : Model.Account -> List Model.Permission
conflatePermissions (Model.Account account) =
    let
        conflateRoles (Model.Role role) =
            case role.permissions of
                Nothing ->
                    []

                Just permissions ->
                    permissions
    in
        case account.roles of
            Nothing ->
                []

            Just roles ->
                List.concatMap conflateRoles roles
                    |> List.Extra.uniqueBy (unwrapPermission >> .id >> (Maybe.withDefault ""))



-- Validations on the model


checkPasswordMatch : Model -> Bool
checkPasswordMatch model =
    model.password1 == model.password2


checkUsernameExists : Model -> Bool
checkUsernameExists model =
    case model.username of
        Nothing ->
            False

        Just username ->
            String.length username > 0


checkPasswordExists : Model -> Bool
checkPasswordExists model =
    case model.password1 of
        Nothing ->
            False

        Just password ->
            String.length password > 0


checkAtLeastOneRole : Model -> Bool
checkAtLeastOneRole model =
    not (Dict.isEmpty model.selectedRoles)


validateCreateAccount : Model -> Bool
validateCreateAccount =
    checkAll
        [ checkUsernameExists
        , checkPasswordExists
        , checkPasswordMatch
        , checkAtLeastOneRole
        ]


validateEditAccount : Model -> Bool
validateEditAccount =
    checkAll
        [ checkPasswordMatch
        , checkAtLeastOneRole
        ]


isChangePassword : Model -> Bool
isChangePassword =
    checkAll
        [ checkPasswordExists
        , checkPasswordMatch
        ]


isChangeRoles : Model -> Bool
isChangeRoles model =
    case model.accountToEdit of
        Nothing ->
            False

        Just account ->
            not (Dict.isEmpty (Utils.symDiff (roleDictFromAccount account) (model.selectedRoles)))


isEditedAndValid : Model -> Bool
isEditedAndValid model =
    (validateEditAccount model)
        && ((isChangePassword model) || (isChangeRoles model))



-- Account REST API calls


accountCallbacks : Account.Service.Callbacks Model Msg
accountCallbacks =
    let
        default =
            Account.Service.callbacks
    in
        { default
            | findAll = accountList
            , findByExample = accountList
            , create = accountCreate
            , retrieve = accountToEdit
            , update = accountSaved
            , delete = accountDelete
            , deleteError = accountDeleteError
            , error = error AuthMsg
        }


accountList : List Model.Account -> Model -> ( Model, Cmd msg )
accountList accounts model =
    ( { model | accounts = Utils.dictifyEntities unwrapAccount Model.Account accounts }
    , Cmd.none
    )


accountCreate : Model.Account -> Model -> ( Model, Cmd Msg )
accountCreate account model =
    ( model, Utils.message Init )


accountToEdit : Model.Account -> Model -> ( Model, Cmd msg )
accountToEdit account model =
    ( { model | viewState = EditView, accountToEdit = Just account }
    , Cmd.none
    )


accountSaved : Model.Account -> model -> ( model, Cmd Msg )
accountSaved account model =
    ( model, Utils.message Init )


accountDelete : String -> Model -> ( Model, Cmd Msg )
accountDelete id model =
    let
        newAccounts =
            Dict.remove id model.accounts

        numToDelete =
            model.numToDelete - 1
    in
        ( { model | accounts = newAccounts, numToDelete = numToDelete }
        , if numToDelete == 0 then
            Utils.message Init
          else
            Cmd.none
        )


accountDeleteError : Http.Error -> Model -> ( Model, Cmd Msg )
accountDeleteError error model =
    let
        numToDelete =
            model.numToDelete - 1
    in
        ( { model | numToDelete = numToDelete }
        , if numToDelete == 0 then
            Utils.message Init
          else
            Cmd.none
        )



-- Role REST API calls


roleCallbacks : Role.Service.Callbacks Model Msg
roleCallbacks =
    let
        default =
            Role.Service.callbacks
    in
        { default
            | findAll = roleList
            , error = error AuthMsg
        }


roleList : List Model.Role -> Model -> ( Model, Cmd msg )
roleList roles model =
    ( { model
        | roleLookup = roleListToDict roles
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case (Debug.log "accounts" action) of
        Mdl action_ ->
            Material.update Mdl action_ model

        AuthMsg authMsg ->
            ( model, Cmd.none )

        AccountApi action_ ->
            Account.Service.update accountCallbacks action_ model

        RoleApi action_ ->
            Role.Service.update roleCallbacks action_ model

        Init ->
            updateInit model

        ToggleAll ->
            updateToggleAll model

        Toggle k ->
            updateToggle k model

        ToggleMore id ->
            ( { model | moreStatus = Utils.toggleSet id model.moreStatus }, Cmd.none )

        Add ->
            updateAdd model

        Delete ->
            ( model, Cmd.none )

        ConfirmDelete ->
            updateConfirmDelete model

        Edit id ->
            updateEdit id model

        UpdateUsername username ->
            ( { model | username = Utils.cleanString username }, Cmd.none )

        UpdatePassword1 password ->
            ( { model | password1 = Utils.cleanString password }, Cmd.none )

        UpdatePassword2 password ->
            ( { model | password2 = Utils.cleanString password }, Cmd.none )

        SelectChanged roles ->
            ( { model | selectedRoles = Utils.leftIntersect model.roleLookup roles }, Cmd.none )

        Create ->
            updateCreate model

        Save ->
            updateSave model


updateInit : Model -> ( Model, Cmd Msg )
updateInit model =
    ( { model
        | selected = Dict.empty
        , viewState = ListView
        , accountToEdit = Nothing
        , moreStatus = Set.empty
      }
    , Account.Service.invokeFindAll model.config.apiRoot AccountApi
    )


updateToggleAll : Model -> ( Model, Cmd Msg )
updateToggleAll model =
    { model
        | selected =
            if allSelected model then
                Dict.empty
            else
                model.accounts
    }
        ! []


updateToggle : String -> Model -> ( Model, Cmd Msg )
updateToggle k model =
    let
        item =
            Dict.get k model.accounts
    in
        case item of
            Nothing ->
                ( model, Cmd.none )

            Just item ->
                { model
                    | selected =
                        if Dict.member k model.selected then
                            Dict.remove k model.selected
                        else
                            Dict.insert k item model.selected
                }
                    ! []


updateAdd : Model -> ( Model, Cmd Msg )
updateAdd model =
    let
        resetModel =
            resetAccountForm model
    in
        ( { resetModel | viewState = CreateView }
        , Role.Service.invokeFindAll model.config.apiRoot RoleApi
        )


updateConfirmDelete : Model -> ( Model, Cmd Msg )
updateConfirmDelete model =
    let
        nonRootFilter =
            \account -> not (isAccountRoot account)

        selectedAccounts =
            Dict.intersect model.accounts model.selected

        toDelete =
            Dict.filter (\_ -> nonRootFilter) selectedAccounts
                |> Dict.keys
    in
        ( { model
            | selected = Dict.empty
            , numToDelete = model.numToDelete + List.length toDelete
          }
        , List.map
            (\id ->
                Account.Service.invokeDelete model.config.apiRoot AccountApi id
            )
            (toDelete)
            |> Cmd.batch
        )


updateEdit : String -> Model -> ( Model, Cmd Msg )
updateEdit id model =
    let
        item =
            Dict.get id model.accounts
    in
        case item of
            Nothing ->
                ( model, Cmd.none )

            Just accountRec ->
                let
                    (Model.Account account) =
                        accountRec

                    resetModel =
                        resetAccountForm model

                    selectedRoles =
                        roleDictFromAccount accountRec
                in
                    ( { resetModel
                        | username = account.username
                        , selectedRoles = selectedRoles
                      }
                    , Cmd.batch
                        [ Account.Service.invokeRetrieve model.config.apiRoot AccountApi id
                        , Role.Service.invokeFindAll model.config.apiRoot RoleApi
                        ]
                    )


updateCreate : Model -> ( Model, Cmd Msg )
updateCreate model =
    ( model
    , Account.Service.invokeCreate model.config.apiRoot
        AccountApi
        (Model.Account
            { id = Nothing
            , username = model.username
            , password = model.password1
            , root = Just False
            , roles = Just <| Dict.values model.selectedRoles
            , salt = Nothing
            }
        )
    )


updateSave : Model -> ( Model, Cmd Msg )
updateSave model =
    case model.accountToEdit of
        Nothing ->
            ( model, Cmd.none )

        Just (Model.Account account) ->
            case account.id of
                Nothing ->
                    ( model, Cmd.none )

                Just id ->
                    let
                        modifiedAccount =
                            Model.Account
                                { id = Just id
                                , username = account.username
                                , password = model.password1
                                , root = Just False
                                , roles = Just <| Dict.values model.selectedRoles
                                , salt = Nothing
                                }
                    in
                        ( model
                        , Account.Service.invokeUpdate
                            model.config.apiRoot
                            AccountApi
                            id
                            modifiedAccount
                        )



-- Views


root : Model -> Html Msg
root model =
    div [ class "layout-fixed-width" ]
        [ ViewUtils.rhythm1SpacerDiv
        , case model.viewState of
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
                            [ Options.onClick ToggleAll
                            , Toggles.value (allSelected model)
                            ]
                            []
                        ]
                    , Table.th [ cs "mdl-data-table__cell--non-numeric" ] [ text "Username" ]
                    , Table.th [ cs "mdl-data-table__cell--non-numeric" ] [ text "Roles" ]
                    , Table.th [ cs "mdl-data-table__cell--non-numeric" ] [ text "Actions" ]
                    ]
                ]
            , Table.tbody []
                (indexedFoldr (accountToRow model) [] model.accounts)
            ]
        , controlBar model
        ]


roleToChip : Model.Role -> List (Html Msg) -> List (Html Msg)
roleToChip (Model.Role role) items =
    (span [ class "mdl-chip mdl-chip__text" ]
        [ text <| Utils.valOrEmpty role.name ]
    )
        :: items


permissionToChip : Model.Permission -> List (Html Msg) -> List (Html Msg)
permissionToChip (Model.Permission permission) items =
    (span [ class "mdl-chip mdl-chip__text" ]
        [ text <| Utils.valOrEmpty permission.name ]
    )
        :: items


viewRow : Model -> Int -> String -> Model.Account -> Html Msg
viewRow model idx id (Model.Account account) =
    (Table.tr
        [ Table.selected |> Options.when (Dict.member id model.selected) ]
        [ Table.td []
            [ Toggles.checkbox Mdl
                [ idx ]
                model.mdl
                [ Options.onClick (Toggle id)
                , Toggles.value <| Dict.member id model.selected
                ]
                []
            ]
        , Table.td [ cs "mdl-data-table__cell--non-numeric" ] [ text <| Utils.valOrEmpty account.username ]
        , Table.td [ cs "mdl-data-table__cell--non-numeric" ]
            (List.foldr roleToChip [] <| Maybe.withDefault [] account.roles)
        , Table.td
            [ cs "mdl-data-table__cell--non-numeric"
            , css "width" "20%"
            ]
            [ Button.render Mdl
                [ 0, idx ]
                model.mdl
                [ Button.accent
                , Button.ripple
                , Options.onClick (Edit id)
                ]
                [ text "Edit" ]
            , Button.render Mdl
                [ 0, 1, idx ]
                model.mdl
                [ Button.ripple
                , Options.onClick (ToggleMore id)
                ]
                [ if moreSelected id model then
                    Icon.i "expand_less"
                  else
                    Icon.i "expand_more"
                ]
            ]
        ]
    )


moreRow : Model -> Int -> String -> Model.Account -> Html Msg
moreRow model idx id (Model.Account account) =
    Table.tr []
        [ Html.td [ colspan 4, class "mdl-data-table__cell--non-numeric data-table__active-row" ]
            ((text "Permissions: ")
                :: (List.foldr permissionToChip [] <| conflatePermissions (Model.Account account))
            )
        ]


accountToRow : Model -> Int -> String -> Model.Account -> List (Html Msg) -> List (Html Msg)
accountToRow model idx id account items =
    let
        more =
            moreRow model idx id account
    in
        if moreSelected id model then
            (viewRow model idx id account)
                :: more
                :: items
        else
            (viewRow model idx id account)
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
                    , Options.onClick Add
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
                    , Options.onClick Delete
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
                , Textfield.text_
                , Options.onInput UpdateUsername
                , Textfield.value <| Utils.valOrEmpty model.username
                ]
                []
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
                , Textfield.text_
                , Textfield.disabled
                , Textfield.value <| Utils.valOrEmpty model.username
                ]
                []
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
        , Options.onInput UpdatePassword1
        , Textfield.value <| Utils.valOrEmpty model.password1
        ]
        []


password2Field : Model -> Html Msg
password2Field model =
    Textfield.render
        Mdl
        [ 3 ]
        model.mdl
        [ Textfield.label "Repeat Password"
        , Textfield.floatingLabel
        , Textfield.password
        , Options.onInput UpdatePassword2
        , Textfield.value <| Utils.valOrEmpty model.password2
        , if checkPasswordMatch model then
            Options.nop
          else
            Textfield.error <| "Passwords do not match."
        ]
        []


roleLookup : Model -> List (Html Msg)
roleLookup model =
    [ h4 [] [ text "Roles" ]
    , listbox
        [ items <| Dict.map (\id -> \(Model.Role role) -> Utils.valOrEmpty role.name) model.roleLookup
        , initiallySelected <| Dict.map (\id -> \(Model.Role role) -> Utils.valOrEmpty role.name) model.selectedRoles
        , onSelectedChanged SelectChanged
        ]
    ]
