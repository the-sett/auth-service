module Accounts.State exposing (..)

import Log
import Set
import Dict exposing (Dict)
import Array
import Maybe
import String
import Platform.Cmd exposing (Cmd)
import Cmd.Extra
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
    , roles = Array.empty
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


validateCreateAccount : Model -> Bool
validateCreateAccount =
    checkAll
        [ checkUsernameExists
        , checkPasswordExists
        , checkPasswordMatch
        ]


validateEditAccount : Model -> Bool
validateEditAccount =
    checkAll
        [ checkPasswordMatch ]


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
            , error = error
        }


accountCreate : Model.Account -> Model -> ( Model, Cmd Msg )
accountCreate account model =
    ( model, Cmd.Extra.message Init )


accountList : List Model.Account -> Model -> ( Model, Cmd msg )
accountList accounts model =
    ( { model | accounts = Array.fromList accounts }, Cmd.none )


accountToEdit : Model.Account -> Model -> ( Model, Cmd msg )
accountToEdit account model =
    ( { model | viewState = EditView, accountToEdit = Just account }
    , Cmd.none
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
            , error = error
        }


roleList : List Model.Role -> Model -> ( Model, Cmd msg )
roleList roles model =
    ( { model
        | roles = Array.fromList roles
        , roleLookup = roleListToDict roles
      }
    , Cmd.none
    )


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
                    , accounts = Nothing
                    , permissions = Nothing
                    }
            )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    update' (Log.debug "accounts" action) model


update' : Msg -> Model -> ( Model, Cmd Msg )
update' action model =
    case action of
        Mdl action' ->
            Material.update action' model

        AccountApi action' ->
            Account.Service.update accountCallbacks action' model

        RoleApi action' ->
            Role.Service.update roleCallbacks action' model

        Init ->
            ( { model | selected = Set.empty, viewState = ListView }
            , Account.Service.invokeFindAll AccountApi
            )

        ToggleAll ->
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

        Toggle k ->
            { model
                | selected =
                    if Set.member k model.selected then
                        Set.remove k model.selected
                    else
                        Set.insert k model.selected
            }
                ! []

        Add ->
            let
                resetModel =
                    resetAccountForm model
            in
                ( { resetModel | viewState = CreateView }
                , Role.Service.invokeFindAll RoleApi
                )

        Delete ->
            ( model, Cmd.none )

        ConfirmDelete ->
            ( model, Cmd.none )

        Edit idx ->
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

        UpdateUsername username ->
            ( { model | username = username }, Cmd.none )

        UpdatePassword1 password ->
            ( { model | password1 = password }, Cmd.none )

        UpdatePassword2 password ->
            ( { model | password2 = password }, Cmd.none )

        SelectChanged roles ->
            ( { model | selectedRoles = roles }, Cmd.none )

        Create ->
            ( model
            , Account.Service.invokeCreate AccountApi
                (Model.Account
                    { id = ""
                    , username = model.username
                    , password = model.password1
                    , roles = Just <| toRoleList model.selectedRoles
                    }
                )
            )

        Save ->
            ( model, Cmd.none )
