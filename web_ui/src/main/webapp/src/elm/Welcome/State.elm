module Welcome.State exposing (init, update)

import Log
import Platform.Cmd exposing (Cmd)
import Material
import Welcome.Types exposing (..)
import Auth


init : Model
init =
    { mdl = Material.model
    , username = ""
    , password = ""
    , logonAttempted = False
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

        LogIn ->
            ( { model | logonAttempted = True }
            , Cmd.batch
                [ Auth.login { username = model.username, password = model.password }
                ]
            )

        TryAgain ->
            ( { model | logonAttempted = False }
            , Cmd.batch
                [ Auth.unauthed
                ]
            )

        Cancel ->
            ( model, Cmd.none )

        UpdateUsername str ->
            ( { model | username = str }, Cmd.none )

        UpdatePassword str ->
            ( { model | password = str }, Cmd.none )
