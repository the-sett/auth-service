module Utils exposing (..)

import Dict exposing (Dict)
import Http
import Auth


{-
   Combines a list of unary tests on some model into a single unary test on the
   model with the result being the conjunction all of the individual tests.
-}


checkAll : List (model -> Bool) -> model -> Bool
checkAll checks model =
    List.map (\check -> check model) checks |> List.foldl (&&) True



{-
   A defalt HTTP error handler that maps:
   401 UNAUTHED -> Auth.unauthed
-}


error : Http.Error -> model -> ( model, Cmd msg )
error httpError model =
    case httpError of
        Http.BadResponse 401 message ->
            ( model, Auth.unauthed )

        _ ->
            ( model, Cmd.none )



{-
   Finds the nth element of a list.
-}


nth : Int -> List a -> Maybe a
nth k xs =
    List.drop k xs |> List.head



{-
   Computes the symetric difference of two dictionaries. The result contains items
   appearing only in one or other of the inputs.
-}


symDiff : Dict comparable a -> Dict comparable a -> Dict comparable a
symDiff dict1 dict2 =
    let
        insertNeither _ _ _ dict =
            dict
    in
        Dict.merge Dict.insert insertNeither Dict.insert dict1 dict2 Dict.empty
