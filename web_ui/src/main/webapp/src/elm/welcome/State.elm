module Welcome.State exposing (init, update)

import Log
import Platform.Cmd exposing (Cmd)
import Material
import Material.Helpers exposing (lift)
import Welcome.Types exposing (..)


init : Model
init =
    { mdl = Material.model
    , username = ""
    , password = ""
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    update' (Log.debug "welcome" action) model


update' : Msg -> Model -> ( Model, Cmd Msg )
update' action model =
    case action of
        Mdl action' ->
            Material.update action' model

        GetStarted ->
            ( model, Cmd.none )

        Login ->
            ( model, Cmd.none )

        Cancel ->
            ( model, Cmd.none )

        UpdateUsername str ->
            ( { model | username = str }, Cmd.none )

        UpdatePassword str ->
            ( { model | password = str }, Cmd.none )
