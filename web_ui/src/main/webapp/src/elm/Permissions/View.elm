module Permissions.View exposing (root)

import Html exposing (..)
import Html.Attributes exposing (title)
import Html.App as App
import Platform.Cmd exposing (Cmd)
import String
import Material.Options as Options exposing (Style, css)
import Material.Color as Color
import Permissions.Types exposing (..)


root : Model -> Html Msg
root model =
    text "permissions"
