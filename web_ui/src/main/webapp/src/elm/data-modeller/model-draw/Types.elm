module ModelDraw.Types exposing (..)

import Mouse exposing (Position)


type alias LineStyle =
    { width : Int
    }


type alias Point =
    { x : Int
    , y : Int
    }


type alias Box =
    { topLeft : Point
    , bottomRight : Point
    , lineStyle : LineStyle
    }


type alias Model =
    { shapes : List Box
    }


type Msg
    = Click Position
    | Move Position
    | Down Position
    | Up Position
