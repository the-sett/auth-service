module Accounts.State exposing (init, update, allSelected, someSelected, key)

import Platform.Cmd exposing (Cmd)
import Cmd.Extra
import Http
import Material
import Material.Helpers exposing (lift)
import Accounts.Types exposing (..)
import Log
import Set
import Array
import Maybe
import Model
import Account.Service
import Task
import Auth


init : Model
init =
    { mdl = Material.model
    , selected = Set.empty
    , data =
        [ Model.Account { id = "1", username = "admin", password = "", roles = Just [] }
        ]
            |> Array.fromList
    , accountToEdit = Nothing
    , viewState = ListView
    }


key : Model.Account -> String
key (Model.Account account) =
    account.id


allSelected : Model -> Bool
allSelected model =
    Set.size model.selected == Array.length model.data


someSelected : Model -> Bool
someSelected model =
    Set.size model.selected > 0


callbacks : Account.Service.Callbacks Model Msg
callbacks =
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
    ( { model | data = Array.fromList accounts }, Cmd.none )


accountToEdit : Model.Account -> Model -> ( Model, Cmd msg )
accountToEdit account model =
    ( { model | viewState = EditView, accountToEdit = Just account }, Cmd.none )


error : Http.Error -> model -> ( model, Cmd msg )
error httpError model =
    case httpError of
        Http.BadResponse 401 message ->
            ( model, Auth.logout )

        _ ->
            ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    update' (Log.debug "accounts" action) model


update' : Msg -> Model -> ( Model, Cmd Msg )
update' action model =
    case action of
        Mdl action' ->
            Material.update action' model

        AccountApi action' ->
            Account.Service.update callbacks action' model

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
                        Array.map key model.data |> Array.toList |> Set.fromList
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
                    Array.get idx model.data
            in
                case item of
                    Nothing ->
                        ( model, Cmd.none )

                    Just (Model.Account account) ->
                        ( model, Account.Service.invokeRetrieve AccountApi account.id )
