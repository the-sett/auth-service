module Auth.State exposing (init)

import Auth.Types exposing (..)


init : Model
init =
    { token = ""
    }
