module Accounts.State exposing (init, update, allSelected, someSelected, key)

import Platform.Cmd exposing (Cmd)
import Material
import Material.Helpers exposing (lift)
import Accounts.Types exposing (..)
import Log
import Set as Set
import Model
import Account.Service
import Task


init : Model
init =
    { mdl = Material.model
    , selected = Set.empty
    , data =
        [ Model.Account { id = "1", username = "admin", password = "", roles = [] }
        ]
    }


key : Model.Account -> String
key (Model.Account account) =
    account.id


allSelected : Model -> Bool
allSelected model =
    Set.size model.selected == List.length model.data


someSelected : Model -> Bool
someSelected model =
    Set.size model.selected > 0


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    update' (Log.debug "accounts" action) model


update' : Msg -> Model -> ( Model, Cmd Msg )
update' action model =
    case action of
        Mdl action' ->
            Material.update action' model

        ToggleAll ->
            { model
                | selected =
                    if allSelected model then
                        Set.empty
                    else
                        List.map key model.data |> Set.fromList
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
            ( model, Cmd.none )

        Delete ->
            ( model, Cmd.none )

        ConfirmDelete ->
            ( model, Cmd.none )

        Edit ->
            ( model, Cmd.none )
