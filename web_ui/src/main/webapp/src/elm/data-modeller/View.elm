module DataModeller.View exposing (root)

import Html exposing (..)
import Html.Attributes exposing (title)
import Html.App as App
import Platform.Cmd exposing (Cmd)
import String
import Material.Options as Options exposing (Style, css)
import Material.Color as Color
import DataModeller.Types exposing (..)


boxed : List (Options.Property a b)
boxed =
    [ css "margin" "auto"
    , css "padding-left" "8%"
    , css "padding-right" "8%"
    ]


title : String -> Html a
title t =
    Options.styled Html.h1
        [ Color.text Color.primary ]
        [ text t ]


body1 : List (Html a) -> Html a
body1 demo =
    Options.div
        boxed
        [ Options.div
            [ css "margin-bottom" "48px"
            ]
            demo
        ]


root : Model -> Html Msg
root model =
    body1
        []
