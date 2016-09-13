module Auth.Types exposing (..)

import Http


type Msg
    = HttpError Http.Error
    | AuthError Http.Error
    | SetUsername String
    | SetPassword String
    | ClickLogIn
    | GetTokenSuccess String
    | LogOut


type alias Model =
    { token : String
    }
