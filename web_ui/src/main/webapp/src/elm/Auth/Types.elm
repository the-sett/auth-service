module Auth.Types exposing (..)

import Http
import Model
import Auth.Service


type alias Credentials =
    { username : String
    , password : String
    }


type Msg
    = AuthApi (Auth.Service.Msg)
    | LogIn Credentials
    | LogOut
    | NotAuthed


type alias AuthState =
    { loggedIn : Bool
    , permissions : List String
    }


type alias Model =
    { token : String
    , errorMsg : String
    , authState : AuthState
    , forwardLocation : String
    , logoutLocation : String
    }
