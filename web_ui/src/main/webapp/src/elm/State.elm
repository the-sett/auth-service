module State exposing
    ( Model
    , Msg(..)
    , Page(..)
    , Session(..)
    )

import Auth
import Browser.Navigation as Navigation
import Page.Accounts
import Page.Welcome


{-| Keeping the update structure flat for this simple application.
-}
type Msg
    = AuthMsg Auth.Msg
    | Toggle Bool
    | SwitchTo String
    | WelcomeMsg Page.Welcome.Msg
    | AccountsMsg Page.Accounts.Msg
    | Noop


type Page
    = Welcome Page.Welcome.Model
    | Accounts Page.Accounts.Model


type alias Model =
    { navKey : Navigation.Key
    , auth : Auth.Model
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
