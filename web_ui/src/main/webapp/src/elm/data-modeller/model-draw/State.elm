module ModelDraw.State exposing (init, update, subscriptions)

import Platform.Cmd exposing (Cmd)
import ModelDraw.Types exposing (..)
import Mouse


init : Model
init =
    { shapes = []
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        Click position ->
            ( model, Cmd.none )

        Move position ->
            ( model, Cmd.none )

        Down position ->
            ( model, Cmd.none )

        Up position ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
