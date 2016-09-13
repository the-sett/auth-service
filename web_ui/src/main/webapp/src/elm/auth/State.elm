module Auth.State exposing (init)

import Http
import Http.Decorators
import Auth.Types exposing (..)


init : Model
init =
    { token = ""
    }


api =
    "http://localhost:9070/auth"


routes =
    { loginUrl = api ++ "login"
    , logoutUrl = api ++ "logout"
    , refreshUrl = api ++ "refresh"
    }
