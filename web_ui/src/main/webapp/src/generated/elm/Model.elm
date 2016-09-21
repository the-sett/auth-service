module Model exposing (..)

import Set exposing (Set)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing ((|:))
import Json.Encode as Encode exposing (..)


type NamedRef
    = NamedRef
        { name : String
        , name2 : String
        }


namedRefEncoder : NamedRef -> Encode.Value
namedRefEncoder (NamedRef model) =
    Encode.object
        [ ( "name", Encode.string model.name )
        ]


namedRefDecoder : Decoder NamedRef
namedRefDecoder =
    (Decode.succeed
        (\name name2 ->
            NamedRef
                { name = name
                , name2 = name2
                }
        )
    )
        |: ("name" := Decode.string)
        |: ("name2" := Decode.string)
