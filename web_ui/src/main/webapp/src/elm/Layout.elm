module Layout exposing (Model, Msg, HeaderType(..), init, update)

import Material
import Material.Color as Color
import Platform.Cmd exposing (Cmd, none)


type alias Mdl =
    Material.Model


type HeaderType
    = Waterfall Bool
    | Seamed
    | Standard
    | Scrolling


type alias Model =
    { mdl : Material.Model
    , fixedHeader : Bool
    , fixedDrawer : Bool
    , fixedTabs : Bool
    , header : HeaderType
    , rippleTabs : Bool
    , transparentHeader : Bool
    , withDrawer : Bool
    , withHeader : Bool
    , withTabs : Bool
    , primary : Color.Hue
    , accent : Color.Hue
    }


type Msg
    = TemplateMsg
    | Update (Model -> Model)
    | Mdl (Material.Msg Msg)


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
