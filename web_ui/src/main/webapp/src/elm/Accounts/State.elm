module Accounts.State exposing (init, update, allSelected, someSelected, key, checkPasswordMatch)

import Log
import Set
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
    }


checkPasswordMatch : { b | password1 : a, password2 : a } -> Bool
checkPasswordMatch model =
    model.password1 /= model.password2


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
    { findAll = accountList
    , findByExample = accountList
    , create = \account -> \model -> ( model, Cmd.none )
    , retrieve = accountToEdit
    , update = \account -> \model -> ( model, Cmd.none )
    , delete = \response -> \model -> ( model, Cmd.none )
    , error = error
    }


accountList : List Model.Account -> Model -> ( Model, Cmd msg )
accountList accounts model =
    ( { model | accounts = Array.fromList accounts }, Cmd.none )


accountToEdit : Model.Account -> Model -> ( Model, Cmd msg )
accountToEdit account model =
    ( { model | viewState = EditView, accountToEdit = Just account }, Cmd.none )


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
            ( { model | viewState = CreateView }, Cmd.none )

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
                        ( model, Account.Service.invokeRetrieve AccountApi account.id )

        UpdateUsername username ->
            ( { model | username = username }, Cmd.none )

        UpdatePassword1 password ->
            ( { model | password1 = password }, Cmd.none )

        UpdatePassword2 password ->
            ( { model | password2 = password }, Cmd.none )
