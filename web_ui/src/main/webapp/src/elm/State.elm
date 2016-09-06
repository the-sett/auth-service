module Main.State exposing (init, update)

import Platform.Cmd exposing (..)
import Material
import Material.Helpers exposing (pure, lift, lift')
import Layout.State
import Menu.State
import DataModeller.State
import Main.Types exposing (..)


init : Model
init =
    { mdl = Material.model
    , datamodeller = DataModeller.State.init
    , layout = Layout.State.init
    , menus = Menu.State.init
    , selectedTab = 0
    , transparentHeader = False
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        SelectTab k ->
            ( { model | selectedTab = k }, Cmd.none )

        ToggleHeader ->
            ( { model | transparentHeader = not model.transparentHeader }, Cmd.none )

        Mdl msg ->
            Material.update msg model

        DataModellerMsg a ->
            lift .datamodeller (\m x -> { m | datamodeller = x }) DataModellerMsg DataModeller.State.update a model

        LayoutMsg a ->
            lift .layout (\m x -> { m | layout = x }) LayoutMsg Layout.State.update a model

        MenusMsg a ->
            lift .menus (\m x -> { m | menus = x }) MenusMsg Menu.State.update a model
