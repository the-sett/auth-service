module Layout.State exposing (..)

import Log
import Platform.Cmd exposing (Cmd, none)
import Material
import Material.Color as Color
import Layout.Types exposing (..)


init : Model
init =
    { mdl = Material.model
    , fixedHeader = True
    , fixedTabs = False
    , fixedDrawer = False
    , header = Standard
    , rippleTabs = True
    , transparentHeader = False
    , withDrawer = False
    , withHeader = True
    , withTabs = True
    , primary = Color.Green
    , accent = Color.Indigo
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    update' (Log.debug "layout" action) model


update' : Msg -> Model -> ( Model, Cmd Msg )
update' action model =
    case action of
        TemplateMsg ->
            ( model, Cmd.none )

        Update f ->
            ( f model, Cmd.none )

        Mdl action' ->
            Material.update action' model
