module Menu exposing (Model, Msg(..), init, update)

import Platform.Cmd exposing (Cmd)
import Material
import Material.Menu as Menu


type alias Mdl =
    Material.Model


type alias Model =
    { mdl : Material.Model
    , selected : Maybe String
    , icon : String
    }


type Msg
    = MenuMsg Int Menu.Msg
    | Mdl (Material.Msg Msg)
    | Select String
    | SetIcon String


init : Model
init =
    { mdl = Material.model
    , selected = Nothing
    , icon = "more_vert"
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        Mdl action_ ->
            Material.update Mdl action_ model

        MenuMsg idx action ->
            ( model, Cmd.none )

        Select n ->
            ( { model | selected = Just n }
            , Cmd.none
            )

        SetIcon s ->
            ( { model | icon = s }
            , Cmd.none
            )
