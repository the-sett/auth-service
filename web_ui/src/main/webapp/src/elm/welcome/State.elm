module Welcome.State exposing (init, update)

import Platform.Cmd exposing (Cmd)
import Material
import Material.Helpers exposing (lift)
import Welcome.Types exposing (..)


log =
    Debug.log "welcome"


init : Model
init =
    { mdl = Material.model
    , username = ""
    , password = ""
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        Mdl action' ->
            Material.update action' model

        GetStarted ->
            let
                d =
                    log "get started"
            in
                ( model, Cmd.none )

        Login ->
            let
                d =
                    log "log in"
            in
                ( model, Cmd.none )

        Cancel ->
            let
                d =
                    log "cancel"
            in
                ( model, Cmd.none )

        UpdateUsername str ->
            let
                d =
                    log "update username"
            in
                ( { model | username = str }, Cmd.none )

        UpdatePassword str ->
            let
                d =
                    log "update password"
            in
                ( { model | password = str }, Cmd.none )
