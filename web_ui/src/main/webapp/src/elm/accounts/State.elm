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
        [ { material = "Acrylic (Transparent)", quantity = "25", unitPrice = "$2.90" }
        , { material = "Plywood (Birch)", quantity = "50", unitPrice = "$1.25" }
        , { material = "Laminate (Gold on Blue)", quantity = "10", unitPrice = "$2.35" }
        ]
    }


key : Data -> String
key =
    .material


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

        Add account ->
            ( model, createCmd account )

        Error msg ->
            ( model, Cmd.none )

        Done account ->
            ( model, Cmd.none )

        Delete ->
            ( model, Cmd.none )

        ConfirmDelete ->
            ( model, Cmd.none )

        Edit ->
            ( model, Cmd.none )


createCmd : Model.Account -> Cmd Msg
createCmd model =
    Task.perform Error Done <| Account.Service.create model
