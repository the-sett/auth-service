module Permissions.State exposing (init, update)

import Log
import Platform.Cmd exposing (Cmd)
import Material
import Permissions.Types exposing (..)


init : Model
init =
    { mdl = Material.model
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    update' (Log.debug "permissions" action) model


update' : Msg -> Model -> ( Model, Cmd Msg )
update' action model =
    case action of
        Mdl action' ->
            Material.update action' model
