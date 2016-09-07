module Accounts.View exposing (root)

import Html exposing (..)
import Html.Attributes exposing (title)
import Html.App as App
import Platform.Cmd exposing (Cmd)
import String
import Material.Options as Options exposing (Style, css)
import Material.Color as Color
import Accounts.Types exposing (..)


root : Model -> Html Msg
root model =
    text "accounts"
