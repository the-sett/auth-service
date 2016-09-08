module Accounts.View exposing (root)

import Html exposing (..)
import Html.Attributes exposing (title, class)
import Html.App as App
import Platform.Cmd exposing (Cmd)
import String
import Material.Options as Options exposing (Style, cs)
import Material.Color as Color
import Accounts.Types exposing (..)
import Material.Table as Table
import Material.Button as Button
import Material.Icon as Icon


type alias Data =
    { material : String
    , quantity : String
    , unitPrice : String
    }


data : List Data
data =
    [ { material = "Acrylic (Transparent)", quantity = "25", unitPrice = "$2.90" }
    , { material = "Plywood (Birch)", quantity = "50", unitPrice = "$1.25" }
    , { material = "Laminate (Gold on Blue)", quantity = "10", unitPrice = "$2.35" }
    ]


root : Model -> Html Msg
root model =
    div [ class "layout-fixed-width" ]
        [ table model ]


table : Model -> Html Msg
table model =
    div [ class "data-table__apron mdl-shadow--2dp" ]
        [ Table.table [ cs "mdl-data-table mdl-js-data-table mdl-data-table--selectable" ]
            [ Table.thead []
                [ Table.tr []
                    [ Table.th [ cs "mdl-data-table__cell--non-numeric" ] [ text "Material" ]
                    , Table.th [] [ text "Quantity" ]
                    , Table.th [] [ text "Unit Price" ]
                    , Table.th [ cs "mdl-data-table__cell--non-numeric" ] [ text "Actions" ]
                    ]
                ]
            , Table.tbody []
                (data
                    |> List.indexedMap
                        (\idx item ->
                            Table.tr []
                                [ Table.td [ cs "mdl-data-table__cell--non-numeric" ] [ text item.material ]
                                , Table.td [ Table.numeric ] [ text item.quantity ]
                                , Table.td [ Table.numeric ] [ text item.unitPrice ]
                                , Table.td [ cs "mdl-data-table__cell--non-numeric" ]
                                    [ Button.render Mdl
                                        [ 0, idx ]
                                        model.mdl
                                        [ Button.accent
                                        , Button.ripple
                                          -- , Button.onClick MyClickMsg
                                        ]
                                        [ text "Edit" ]
                                    ]
                                ]
                        )
                )
            ]
        , controlBar model
        ]


controlBar : Model -> Html Msg
controlBar model =
    div [ class "control-bar" ]
        [ div [ class "control-bar__row" ]
            [ div [ class "control-bar__left-0" ]
                [ span [ class "mdl-chip mdl-chip__text" ]
                    [ text "3 items" ]
                ]
            , div [ class "control-bar__left-3" ]
                [ p []
                    [ text "Some text" ]
                ]
            , div [ class "control-bar__right-0" ]
                [ Button.render Mdl
                    [ 1 ]
                    model.mdl
                    [ Button.fab
                    , Button.colored
                    , Button.ripple
                      -- , Button.onClick MyClickMsg
                    ]
                    [ Icon.i "add" ]
                ]
            , div [ class "control-bar__right-0" ]
                [ button [ class "mdl-button mdl-js-button mdl-button--primary" ]
                    [ text "Button" ]
                ]
            ]
        ]
