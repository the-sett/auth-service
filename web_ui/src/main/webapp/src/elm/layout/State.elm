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
    , withDrawer = True
    , withHeader = True
    , withTabs = True
    , primary = Color.Teal
    , accent = Color.Red
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        TemplateMsg ->
            ( model, Cmd.none )

        Update f ->
            ( f model, Cmd.none )

        Mdl action' ->
            Material.update action' model
