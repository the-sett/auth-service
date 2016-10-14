module Accounts.State exposing (init, update, allSelected, someSelected, key, checkPasswordMatch)

import Log
import Set
import Dict exposing (Dict)
import Array
import Maybe
import Platform.Cmd exposing (Cmd)
import Material
import Utils exposing (..)
import Accounts.Types exposing (..)
import Model
import Account.Service
import Role.Service


init : Model
init =
    { mdl = Material.model
    , selected = Set.empty
    , accounts = Array.empty
    , roles = Array.empty
    , accountToEdit = Nothing
    , viewState = ListView
    , username = ""
    , password1 = ""
    , password2 = ""
    , roleLookup = Dict.empty
    , selectedRoles = Dict.empty
    }


checkPasswordMatch : { b | password1 : a, password2 : a } -> Bool
checkPasswordMatch model =
    model.password1 == model.password2


key : Model.Account -> String
key (Model.Account account) =
    account.id


allSelected : Model -> Bool
allSelected model =
    Set.size model.selected == Array.length model.accounts


someSelected : Model -> Bool
someSelected model =
    Set.size model.selected > 0


accountCallbacks : Account.Service.Callbacks Model Msg
accountCallbacks =
    let
        default =
            Account.Service.callbacks
    in
        { default
            | findAll = accountList
            , findByExample = accountList
            , retrieve = accountToEdit
            , error = error
        }


accountList : List Model.Account -> Model -> ( Model, Cmd msg )
accountList accounts model =
    ( { model | accounts = Array.fromList accounts }, Cmd.none )


accountToEdit : Model.Account -> Model -> ( Model, Cmd msg )
accountToEdit account model =
    ( { model | viewState = EditView, accountToEdit = Just account }, Cmd.none )


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
    ( { model | roles = Array.fromList roles, roleLookup = roleListToDict roles }, Cmd.none )


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
                        Array.map key model.accounts |> Array.toList |> Set.fromList
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
            ( { model | viewState = CreateView }, Role.Service.invokeFindAll RoleApi )

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

                    Just (Model.Account account) ->
                        ( model
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
