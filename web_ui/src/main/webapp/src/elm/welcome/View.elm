module Welcome.View exposing (root)

import Html exposing (..)
import Html.Attributes exposing (title, class)
import Material.Options as Options exposing (Style, cs, when, nop, disabled)
import Material.Color as Color
import Material.Dialog as Dialog
import Material.Table as Table
import Material.Button as Button
import Material.Icon as Icon
import Material.Toggles as Toggles
import Welcome.Types exposing (..)
import Welcome.State exposing (..)


root : Model -> Html Msg
root model =
    div [ class "layout-fixed-width" ]
        [ h4 [] [ text "Welcome" ]
        ]
