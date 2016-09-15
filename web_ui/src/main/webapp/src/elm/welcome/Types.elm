module Welcome.Types exposing (..)

import Material
import Auth.Types


type alias Model =
    { mdl : Material.Model
    , username : String
    , password : String
    , auth : Auth.Types.Model
    }


type Msg
    = Mdl (Material.Msg Msg)
    | AuthMsg Auth.Types.Msg
    | GetStarted
    | Login
    | Cancel
    | UpdateUsername String
    | UpdatePassword String
