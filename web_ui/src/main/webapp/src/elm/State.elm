module State exposing
    ( Model
    , Msg(..)
    , Page(..)
    , Session(..)
    )

import Auth


{-| Keeping the update structure flat for this simple application.
-}
type Msg
    = Toggle Bool
    | SwitchTo Page


type Page
    = Welcome
    | Accounts


type alias Model =
    { debug : Bool
    , page : Page
    , auth : Auth.Model
    , session : Session
    }


type Session
    = Initial
    | LoggedOut
    | FailedAuth
    | LoggedIn
        { scopes : List String
        , subject : String
        }
