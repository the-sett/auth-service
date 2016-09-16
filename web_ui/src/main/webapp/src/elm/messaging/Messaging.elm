port module Messaging exposing (..)


port dispatch : String -> Cmd msg


port receive : (String -> msg) -> Sub msg
