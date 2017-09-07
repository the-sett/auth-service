module Welcome.Types exposing (..)

import Material
import Auth


type alias Model =
    { mdl : Material.Model
    , username : String
    , password : String
    }


type Msg
    = Mdl (Material.Msg Msg)
    | AuthMsg Auth.AuthCmd
    | GetStarted
    | LogIn
    | TryAgain
    | Cancel
    | UpdateUsername String
    | UpdatePassword String
