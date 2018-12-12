module State exposing
    ( Model
    , Msg(..)
    , Page(..)
    , Session(..)
    )

import Auth
import Page.Welcome


{-| Keeping the update structure flat for this simple application.
-}
type Msg
    = AuthMsg Auth.Msg
    | Toggle Bool
    | SwitchTo Page
    | WelcomeMsg Page.Welcome.Msg


type Page
    = Welcome Page.Welcome.Model
    | Accounts


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
