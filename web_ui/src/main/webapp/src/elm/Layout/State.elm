module Layout.State exposing (..)

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
    update_ (Debug.log "layout" action) model


update_ : Msg -> Model -> ( Model, Cmd Msg )
update_ action model =
    case action of
        TemplateMsg ->
            ( model, Cmd.none )

        Update f ->
            ( f model, Cmd.none )

        Mdl action_ ->
            Material.update Mdl action_ model
