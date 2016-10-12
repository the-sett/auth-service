port module Listbox exposing (listbox, items, onSelectedChanged, setSelected)

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Encode as Encode
import Html exposing (Attribute, Html, text, button, span, div, ul, li)
import Html.Attributes exposing (attribute, class)
import Html.Events exposing (on, onClick)
import Html.App exposing (programWithFlags)


-- The exposed API


port setSelected : List ( String, String ) -> Cmd msg


listbox : List (Attribute msg) -> Html msg
listbox attrs =
    Html.node "wood-listbox" attrs []


items : Dict String String -> Attribute msg
items val =
    attribute "items" <| Encode.encode 0 (encodeItems (Dict.toList val))


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


init : { a | items : List ( String, String ) } -> ( Model, Cmd Msg )
init flags =
    ( { items = Dict.fromList flags.items
      , selectedItems = Dict.empty
      }
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    ul
        []
        (Dict.toList model.items |> List.map (itemsToList model))


itemsToList model ( idx, value ) =
    if Dict.member idx model.selectedItems then
        li [ Html.Attributes.value (toString idx), class "selected", Deselect idx |> onClick ] [ text value ]
    else
        li [ Html.Attributes.value (toString idx), Select idx |> onClick ] [ text value ]


type Msg
    = Select String
    | Deselect String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (Debug.log "Listbox" msg) of
        Select idx ->
            case (Dict.get idx model.items) of
                Just value ->
                    let
                        newSelection =
                            Dict.insert idx value model.selectedItems
                    in
                        ( { model | selectedItems = newSelection }
                        , Dict.toList newSelection |> setSelected
                        )

                Nothing ->
                    ( model, Cmd.none )

        Deselect idx ->
            let
                newSelection =
                    Dict.remove idx model.selectedItems
            in
                ( { model | selectedItems = newSelection }
                , Dict.toList newSelection |> setSelected
                )


main : Program { items : List ( String, String ) }
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
