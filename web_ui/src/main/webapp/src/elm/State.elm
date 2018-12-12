module State exposing
    ( Model
    , Msg(..)
    , Page(..)
    , Session(..)
    )

import Auth
import Page.Accounts
import Page.Welcome


{-| Keeping the update structure flat for this simple application.
-}
type Msg
    = AuthMsg Auth.Msg
    | Toggle Bool
    | SwitchTo String
    | WelcomeMsg Page.Welcome.Msg


type Page
    = Welcome Page.Welcome.Model
    | Accounts Page.Accounts.Model


type alias Model =
    { auth : Auth.Model
    , debug : Bool
    , page : Page
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
