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
    | Login
    | Cancel
    | UpdateUsername String
    | UpdatePassword String
