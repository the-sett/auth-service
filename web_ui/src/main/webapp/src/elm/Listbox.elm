port module Listbox exposing (listbox, items, initiallySelected, onSelectedChanged)

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Encode as Encode
import Html exposing (Attribute, Html, text, button, span, div, node, program)
import Html.Attributes exposing (attribute, class, property)
import Html.Events exposing (on, onClick, onMouseOver, onMouseOut)
import Material
import Material.Toggles as Toggles


-- The exposed API


listbox : List (Attribute msg) -> Html msg
listbox attrs =
    Html.node "wood-listbox" attrs []


items : Dict String String -> Attribute msg
items val =
    property "items" <| (encodeItems (Dict.toList val))


initiallySelected : Dict String String -> Attribute msg
initiallySelected val =
    property "initiallySelected" <| (encodeItems (Dict.toList val))


onItemArrayChanged : String -> (Dict String String -> msg) -> Attribute msg
onItemArrayChanged propname tagger =
    on propname <| Decode.map tagger <| Decode.map Dict.fromList decodeItems


onSelectedChanged : (Dict String String -> msg) -> Attribute msg
onSelectedChanged tagger =
    onItemArrayChanged "selected-changed" tagger


onItemsChanged : (Dict String String -> msg) -> Attribute msg
onItemsChanged tagger =
    onItemArrayChanged "items-changed" tagger


encodeItems : List ( String, String ) -> Encode.Value
encodeItems items =
    Encode.list
        (List.map (\( idx, val ) -> Encode.list [ Encode.string idx, Encode.string val ]) items)


decodeItems : Decode.Decoder (List ( String, String ))
decodeItems =
    Decode.at [ "detail", "value" ] <|
        Decode.list <|
            Decode.map2 (,) (Decode.index 0 Decode.string) (Decode.index 1 Decode.string)



-- The internals


port setSelected : List ( String, String ) -> Cmd msg


port itemsChanged : (List ( String, String ) -> msg) -> Sub msg


port initiallySelectedChanged : (List ( String, String ) -> msg) -> Sub msg


type alias Model =
    { mdl : Material.Model
    , items : Dict String String
    , selectedItems : Dict String String
    , hoverItem : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( { mdl = Material.model
      , items = Dict.empty
      , selectedItems = Dict.empty
      , hoverItem = Nothing
      }
    , Cmd.none
    )


woodItem : List (Attribute msg) -> List (Html msg) -> Html msg
woodItem attrs inner =
    node "wood-item" attrs inner


view : Model -> Html Msg
view model =
    div
        []
        (Dict.toList model.items |> List.indexedMap (itemsToList model))


isHover : String -> Model -> Bool
isHover idx model =
    model.hoverItem == Just idx


isSelected : String -> Model -> Bool
isSelected idx model =
    Dict.member idx model.selectedItems


itemsToList model listIdx ( idx, value ) =
    let
        hover =
            isHover idx model

        selected =
            isSelected idx model

        attrs =
            [ onMouseOver <| MouseOver idx
            , onMouseOut <| MouseOut idx
            , Html.Attributes.value (toString idx)
            ]

        selectAttrs =
            if selected then
                (onClick <| Deselect idx) :: attrs
            else
                (onClick <| Select idx) :: attrs

        styleAttrs =
            if hover && selected then
                class "wood-selected wood-highlight" :: selectAttrs
            else if hover && not selected then
                class "wood-highlight" :: selectAttrs
            else if not hover && selected then
                class "wood-selected" :: selectAttrs
            else
                selectAttrs
    in
        woodItem
            styleAttrs
            [ Toggles.checkbox Mdl
                [ listIdx ]
                model.mdl
                [ Toggles.ripple
                , Toggles.value selected
                ]
                [ text value ]
            ]


type Msg
    = Mdl (Material.Msg Msg)
    | ItemsChanged (List ( String, String ))
    | InitiallySelectedChanged (List ( String, String ))
    | Select String
    | Deselect String
    | MouseOver String
    | MouseOut String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl action_ ->
            Material.update Mdl action_ model

        ItemsChanged items ->
            ( { model | items = Dict.fromList items }, Cmd.none )

        InitiallySelectedChanged items ->
            ( { model | selectedItems = Dict.fromList items }, Cmd.none )

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

        MouseOver idx ->
            ( { model | hoverItem = Just idx }, Cmd.none )

        MouseOut idx ->
            ( { model | hoverItem = Nothing }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ itemsChanged ItemsChanged
        , initiallySelectedChanged InitiallySelectedChanged
        ]


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
