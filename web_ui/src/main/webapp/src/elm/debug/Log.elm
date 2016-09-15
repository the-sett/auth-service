module Log exposing (debug)


debug : String -> a -> a
debug path a =
    Debug.log path a
