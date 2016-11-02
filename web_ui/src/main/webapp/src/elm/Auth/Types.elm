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
    { token : Maybe String
    , decodedToken : Maybe Token
    , errorMsg : String
    , authState : AuthState
    , forwardLocation : String
    , logoutLocation : String
    }


type alias Token =
    { sub : String
    , iss : Maybe String
    , aud : Maybe String
    , exp : Maybe String
    , iat : Maybe String
    , jti : Maybe String
    , permissions : List String
    }
