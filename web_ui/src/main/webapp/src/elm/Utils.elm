module Utils exposing (..)

import Dict exposing (Dict)
import Set exposing (Set)
import List
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



{-
   Tranforms a list of entities (records with a String id), into a Dict, with the ids
   as keys.
-}


dictifyEntities : (b -> { a | id : String }) -> ({ a | id : String } -> b) -> List b -> Dict String b
dictifyEntities unwrapper wrapper entities =
    Dict.fromList <| List.map (\rec -> ( rec.id, wrapper rec )) <| List.map unwrapper entities



{-
   Extracts the key set from a dict.
-}


keySet : Dict comparable v -> Set comparable
keySet dict =
    Dict.keys dict |> Set.fromList


enumList list =
    indexedFoldr (\idx -> \key -> \item -> \items -> ( idx, item ) :: items) [] list


indexedFoldr : (number -> comparable -> v -> b -> b) -> b -> Dict comparable v -> b
indexedFoldr fun acc list =
    let
        ( highest, result ) =
            Dict.foldr (\key -> \item -> \( idx, items ) -> ( idx + 1, fun idx key item items )) ( 0, acc ) list
    in
        result
