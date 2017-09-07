module Welcome.State exposing (init, update)

import Platform.Cmd exposing (Cmd)
import Material
import Welcome.Types exposing (..)
import Auth


init : Model
init =
    { mdl = Material.model
    , username = ""
    , password = ""
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    update_ (Debug.log "welcome" action) model


update_ : Msg -> Model -> ( Model, Cmd Msg )
update_ action model =
    case action of
        Mdl action_ ->
            Material.update Mdl action_ model

        AuthMsg authMsg ->
            ( model, Cmd.none )

        GetStarted ->
            ( model, Cmd.none )

        LogIn ->
            update_ (AuthMsg (Auth.login { username = model.username, password = model.password })) model

        TryAgain ->
            update_ (AuthMsg Auth.unauthed) model

        Cancel ->
            ( model, Cmd.none )

        UpdateUsername str ->
            ( { model | username = str }, Cmd.none )

        UpdatePassword str ->
            ( { model | password = str }, Cmd.none )
