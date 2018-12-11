module Layout.Initial exposing (global, layout)

import Css
import Css.Global
import Grid
import Html.Styled exposing (Html, a, button, div, input, li, nav, node, styled, text, ul)
import Html.Styled.Attributes exposing (attribute, checked, class, href, id, type_)
import Html.Styled.Events exposing (onClick)
import Responsive exposing (ResponsiveStyle)
import Structure exposing (Layout, Template(..))
import Styles exposing (md, sm)
import Svg.Styled
import TheSett.Laf as Laf exposing (wrapper)
import TheSett.Logo as Logo


layout : Layout msg model
layout template =
    { template = pageBody template
    , global = global
    }


global : ResponsiveStyle -> List Css.Global.Snippet
global devices =
    [ Css.Global.each
        [ Css.Global.html ]
        [ Css.height <| Css.pct 100
        , Responsive.deviceStyle devices
            (\device ->
                let
                    headerPx =
                        Responsive.rhythm 12.5 device
                in
                Css.property "background" <|
                    "linear-gradient(rgb(120, 116, 120) 0%, "
                        ++ String.fromFloat headerPx
                        ++ "px, rgb(225, 212, 214) 0px, rgb(208, 212, 214) 100%)"
            )
        ]
    ]


pageBody : Template msg model -> Template msg model
pageBody template =
    (\devices model ->
        div
            []
            [ case template of
                Dynamic fn ->
                    fn devices model

                Static fn ->
                    Html.Styled.map never <| fn devices
            ]
    )
        |> Dynamic
