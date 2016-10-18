module Utils exposing (..)

import Dict exposing (Dict)
import Http
import Auth


checkAll : List (model -> Bool) -> model -> Bool
checkAll checks model =
    List.map (\check -> check model) checks |> List.foldl (&&) True


error : Http.Error -> model -> ( model, Cmd msg )
error httpError model =
    case httpError of
        Http.BadResponse 401 message ->
            ( model, Auth.unauthed )

        _ ->
            ( model, Cmd.none )


nth : Int -> List a -> Maybe a
nth k xs =
    List.drop k xs |> List.head


symDiff : Dict comparable a -> Dict comparable a -> Dict comparable a
symDiff dict1 dict2 =
    let
        insertNeither _ _ _ dict =
            dict
    in
        Dict.merge Dict.insert insertNeither Dict.insert dict1 dict2 Dict.empty
