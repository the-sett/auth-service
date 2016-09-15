module Auth.Types exposing (..)

import Http


type Msg
    = HttpError Http.Error
    | AuthError Http.Error
    | GetTokenSuccess String
    | LogIn AuthRequest
    | LogOut


type alias AuthRequest =
    { username : String
    , password : String
    }


type alias Model =
    { token : String
    , errorMsg : String
    }
