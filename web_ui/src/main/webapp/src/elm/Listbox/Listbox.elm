port module Listbox exposing (listbox, initialItems, onSelectedChanged, setSelected)

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Encode as Encode
import Html exposing (Attribute, Html, text, button, span, div)
import Html.Attributes exposing (attribute, class)
import Html.Events exposing (on, onClick)
import Html.App exposing (programWithFlags)


-- The exposed API


port setSelected : List ( String, String ) -> Cmd msg


listbox : List (Attribute msg) -> Html msg
listbox attrs =
    Html.node "wood-listbox" attrs []


initialItems : Dict String String -> Attribute msg
initialItems val =
    attribute "initial-items" <| Encode.encode 0 (encodeItems (Dict.toList val))


onSelectedChanged : (Dict String String -> msg) -> Attribute msg
onSelectedChanged tagger =
    on "selected-changed" <| Decode.map tagger <| Decode.map Dict.fromList decodeItems


encodeItems : List ( String, String ) -> Encode.Value
encodeItems items =
    Encode.list
        (List.map (\( idx, val ) -> Encode.list [ Encode.string idx, Encode.string val ]) items)


decodeItems : Decode.Decoder (List ( String, String ))
decodeItems =
    Decode.at [ "detail", "value" ] <| Decode.list <| Decode.tuple2 (,) Decode.string Decode.string



-- The internals


type alias Model =
    { items : Dict String String
    , selectedItems : Dict String String
    }


init : { a | initialItems : List ( String, String ) } -> ( Model, Cmd Msg )
init flags =
    ( { items = Dict.fromList flags.initialItems
      , selectedItems = Dict.empty
      }
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    div
        []
        (Dict.toList model.items |> List.map (itemsToList model))


itemsToList model ( idx, value ) =
    if Dict.member idx model.selectedItems then
        span [ Html.Attributes.value (toString idx), class "selected", Deselect idx |> onClick ] [ text value ]
    else
        span [ Html.Attributes.value (toString idx), Select idx |> onClick ] [ text value ]


type Msg
    = Select String
    | Deselect String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (Debug.log "Listbox" msg) of
        Select idx ->
            case (Dict.get idx model.items) of
                Just value ->
                    ( { model | selectedItems = Dict.insert idx value model.selectedItems }
                    , Dict.toList model.selectedItems |> setSelected
                    )

                Nothing ->
                    ( model, Cmd.none )

        Deselect idx ->
            ( { model | selectedItems = Dict.remove idx model.selectedItems }
            , Dict.toList model.selectedItems |> setSelected
            )


main : Program { initialItems : List ( String, String ) }
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
