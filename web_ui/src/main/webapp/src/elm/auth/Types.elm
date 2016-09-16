module Auth.Types exposing (..)

import Http


type alias AuthRequest =
    { username : String
    , password : String
    }


type Msg
    = HttpError Http.Error
    | AuthError Http.Error
    | GetTokenSuccess String
    | LogIn AuthRequest
    | LogOut String
    | NotAuthed String


type alias Model =
    { token : String
    , errorMsg : String
    }
