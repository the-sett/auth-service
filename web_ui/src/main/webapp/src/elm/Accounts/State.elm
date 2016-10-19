module Accounts.State exposing (..)

import Log
import Set
import Dict exposing (Dict)
import Array
import Maybe
import String
import Platform.Cmd exposing (Cmd)
import Cmd.Extra
import Http
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
    , selected = Set.empty
    , accounts = Array.empty
    , accountToEdit = Nothing
    , viewState = ListView
    , roleLookup = Dict.empty
    , username = ""
    , password1 = ""
    , password2 = ""
    , selectedRoles = Dict.empty
    }


resetAccountForm : Model -> Model
resetAccountForm model =
    { model
        | username = ""
        , password1 = ""
        , password2 = ""
        , selectedRoles = Dict.empty
    }


key : Model.Account -> String
key (Model.Account account) =
    account.id


allSelected : Model -> Bool
allSelected model =
    Set.size model.selected == Array.length model.accounts


someSelected : Model -> Bool
someSelected model =
    Set.size model.selected > 0


roleDictFromAccount : Model.Account -> Dict String String
roleDictFromAccount (Model.Account account) =
    case account.roles of
        Nothing ->
            Dict.empty

        Just roles ->
            roleListToDict roles


roleListToDict : List Model.Role -> Dict String String
roleListToDict roles =
    List.map
        (\wrapper ->
            case wrapper of
                Model.Role role ->
                    ( role.id, role.name )
        )
        roles
        |> Dict.fromList


toRoleList : Dict String String -> List Model.Role
toRoleList dict =
    Dict.toList dict
        |> List.map
            (\( id, name ) ->
                Model.Role
                    { id = id
                    , name = name
                    , permissions = Nothing
                    }
            )



-- Validations on the model


checkPasswordMatch : Model -> Bool
checkPasswordMatch model =
    model.password1 == model.password2


checkUsernameExists : Model -> Bool
checkUsernameExists model =
    String.length model.username > 0


checkPasswordExists : Model -> Bool
checkPasswordExists model =
    String.length model.password1 > 0


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
            , error = error
        }


accountList : List Model.Account -> Model -> ( Model, Cmd msg )
accountList accounts model =
    ( { model | accounts = Array.fromList accounts }, Cmd.none )


accountCreate : Model.Account -> Model -> ( Model, Cmd Msg )
accountCreate account model =
    ( model, Cmd.Extra.message Init )


accountToEdit : Model.Account -> Model -> ( Model, Cmd msg )
accountToEdit account model =
    ( { model | viewState = EditView, accountToEdit = Just account }
    , Cmd.none
    )


accountSaved : Model.Account -> model -> ( model, Cmd Msg )
accountSaved account model =
    ( model, Cmd.Extra.message Init )


accountDelete : String -> Model -> ( Model, Cmd Msg )
accountDelete id model =
    let
        newAccounts =
            Array.filter (\(Model.Account account) -> not (account.id == id)) model.accounts
    in
        ( { model | accounts = newAccounts }, Cmd.none )



-- Role REST API calls


roleCallbacks : Role.Service.Callbacks Model Msg
roleCallbacks =
    let
        default =
            Role.Service.callbacks
    in
        { default
            | findAll = roleList
            , error = error
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
    case (Log.debug "accounts" action) of
        Mdl action' ->
            Material.update action' model

        AccountApi action' ->
            Account.Service.update accountCallbacks action' model

        RoleApi action' ->
            Role.Service.update roleCallbacks action' model

        Init ->
            updateInit model

        ToggleAll ->
            updateToggleAll model

        Toggle k ->
            updateToggle k model

        Add ->
            updateAdd model

        Delete ->
            ( model, Cmd.none )

        ConfirmDelete ->
            updateConfirmDelete model

        Edit idx ->
            updateEdit idx model

        UpdateUsername username ->
            ( { model | username = username }, Cmd.none )

        UpdatePassword1 password ->
            ( { model | password1 = password }, Cmd.none )

        UpdatePassword2 password ->
            ( { model | password2 = password }, Cmd.none )

        SelectChanged roles ->
            ( { model | selectedRoles = roles }, Cmd.none )

        Create ->
            updateCreate model

        Save ->
            updateSave model


updateInit : Model -> ( Model, Cmd Msg )
updateInit model =
    ( { model | selected = Set.empty, viewState = ListView }
    , Account.Service.invokeFindAll AccountApi
    )


updateToggleAll : Model -> ( Model, Cmd Msg )
updateToggleAll model =
    { model
        | selected =
            if allSelected model then
                Set.empty
            else
                Array.map key model.accounts
                    |> Array.toList
                    |> Set.fromList
    }
        ! []


updateToggle : String -> Model -> ( Model, Cmd Msg )
updateToggle k model =
    { model
        | selected =
            if Set.member k model.selected then
                Set.remove k model.selected
            else
                Set.insert k model.selected
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
        nonRootSelectedAccounts =
            Array.filter
                (\(Model.Account account) ->
                    (not account.root)
                        && (Set.member account.id model.selected)
                )
                model.accounts

        toDelete =
            Array.map
                (\(Model.Account account) ->
                    account.id
                )
                nonRootSelectedAccounts
                |> Array.toList
    in
        ( { model | selected = Set.empty }
        , List.map
            (\id ->
                Account.Service.invokeDelete AccountApi id
            )
            (toDelete)
            |> Cmd.batch
        )


updateEdit : Int -> Model -> ( Model, Cmd Msg )
updateEdit idx model =
    let
        item =
            Array.get idx model.accounts
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
                        [ Account.Service.invokeRetrieve AccountApi account.id
                        , Role.Service.invokeFindAll RoleApi
                        ]
                    )


updateCreate : Model -> ( Model, Cmd Msg )
updateCreate model =
    ( model
    , Account.Service.invokeCreate AccountApi
        (Model.Account
            { id = ""
            , username = model.username
            , password = model.password1
            , root = False
            , roles = Just <| toRoleList model.selectedRoles
            }
        )
    )


updateSave : Model -> ( Model, Cmd Msg )
updateSave model =
    case model.accountToEdit of
        Nothing ->
            ( model, Cmd.none )

        Just (Model.Account account) ->
            let
                id =
                    account.id

                modifiedAccount =
                    Model.Account
                        { id = id
                        , username = account.username
                        , password = model.password1
                        , root = False
                        , roles = Just <| toRoleList model.selectedRoles
                        }
            in
                ( model
                , Account.Service.invokeUpdate AccountApi id modifiedAccount
                )
