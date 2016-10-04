module Utils exposing (..)

import Http
import Auth


checkAll : List (model -> Bool) -> model -> Bool
checkAll checks model =
    List.map (\check -> check model) checks |> List.foldl (&&) True


error : Http.Error -> model -> ( model, Cmd msg )
error httpError model =
    case httpError of
        Http.BadResponse 401 message ->
            ( model, Auth.logout )

        _ ->
            ( model, Cmd.none )


nth : Int -> List a -> Maybe a
nth k xs =
    List.drop k xs |> List.head
