module Accounts.State exposing (..)

import Set
import Dict exposing (Dict)
import Dict.Extra
import Array
import Maybe
import String
import Platform.Cmd exposing (Cmd)
import List.Extra
import Http
import Exts.Maybe exposing (catMaybes)
import Material
import Utils exposing (..)
import Accounts.Types exposing (..)
import Model
import Account.Service
import Role.Service


-- Model and its manipulations


init : Model
init =
    { mdl = Material.model
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
    , Account.Service.invokeFindAll AccountApi
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
        , Role.Service.invokeFindAll RoleApi
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
                Account.Service.invokeDelete AccountApi id
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
                        [ Account.Service.invokeRetrieve AccountApi id
                        , Role.Service.invokeFindAll RoleApi
                        ]
                    )


updateCreate : Model -> ( Model, Cmd Msg )
updateCreate model =
    ( model
    , Account.Service.invokeCreate AccountApi
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
                        , Account.Service.invokeUpdate AccountApi id modifiedAccount
                        )
