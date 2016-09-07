module Accounts.View exposing (root)

import Html exposing (..)
import Html.Attributes exposing (title)
import Html.App as App
import Platform.Cmd exposing (Cmd)
import String
import Material.Options as Options exposing (Style, css)
import Material.Color as Color
import Accounts.Types exposing (..)
import Material.Table as Table


type alias Data =
    { material : String
    , quantity : String
    , unitPrice : String
    }


data : List Data
data =
    [ { material = "Acrylic (Transparent)", quantity = "25", unitPrice = "$2.90" }
    , { material = "Plywood (Birch)", quantity = "50", unitPrice = "$1.25" }
    , { material = "Laminate (Gold on Blue)", quantity = "10", unitPrice = "$2.35" }
    ]


root : Model -> Html Msg
root model =
    Table.table []
        [ Table.thead []
            [ Table.tr []
                [ Table.th [] [ text "Material" ]
                , Table.th [] [ text "Quantity" ]
                , Table.th [] [ text "Unit Price" ]
                ]
            ]
        , Table.tbody []
            (data
                |> List.map
                    (\item ->
                        Table.tr []
                            [ Table.td [] [ text item.material ]
                            , Table.td [ Table.numeric ] [ text item.quantity ]
                            , Table.td [ Table.numeric ] [ text item.unitPrice ]
                            ]
                    )
            )
        ]
