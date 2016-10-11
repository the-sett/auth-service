port module Listbox exposing (counter, initialCount, onCountChanged, setCount)

import Json.Decode as Decode
import Html exposing (Attribute, Html, text, button, span, div)
import Html.Attributes exposing (attribute)
import Html.Events exposing (on, onClick)
import Html.App exposing (programWithFlags)


-- The exposed API


port setCount : Int -> Cmd msg


counter : List (Attribute msg) -> Html msg
counter attrs =
    Html.node "wood-listbox" attrs []


initialCount : Int -> Attribute msg
initialCount val =
    attribute "initial-count" (toString val)


onCountChanged : (Int -> msg) -> Attribute msg
onCountChanged tagger =
    on "count-changed" <| Decode.map tagger detailCount


detailCount : Decode.Decoder Int
detailCount =
    Decode.at [ "detail", "value" ] Decode.int



-- The internals


type alias Model =
    Int


init : { a | count : Int } -> ( Model, Cmd Msg )
init flags =
    ( flags.count, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , span [] [ text <| toString model ]
        , button [ onClick Increment ] [ text "+" ]
        ]


type Msg
    = Increment
    | Decrement
    | Set Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (Debug.log "Listbox" msg) of
        Increment ->
            let
                new =
                    model + 1
            in
                ( new, setCount new )

        Decrement ->
            let
                new =
                    model - 1
            in
                ( new, setCount new )

        Set count ->
            ( count, setCount count )


main : Program { count : Int }
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
