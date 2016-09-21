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
    (Decode.succeed (\n1 n2 -> NamedRef { name = n1, name2 = n2 }))
        |: ("name" := Decode.string)
        |: ("name2" := Decode.string)
