module Welcome.Types exposing (..)

import Material


type alias Model =
    { mdl : Material.Model
    , username : String
    , password : String
    }


type Msg
    = Mdl (Material.Msg Msg)
    | GetStarted
    | LogIn
    | TryAgain
    | Cancel
    | UpdateUsername String
    | UpdatePassword String
