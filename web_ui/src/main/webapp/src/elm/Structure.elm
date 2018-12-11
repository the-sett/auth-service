module Structure exposing (Layout, Template(..), lift)

{-| Defines the structure of a reactive application as layouts applied to templates.

The device specification is always given as a parameter, from which device dependant
styling can be applied.

-}

import Css.Global
import Html.Styled exposing (Html)
import Responsive exposing (ResponsiveStyle)


{-| Defines the type of a template. A template takes a link builder, an editor and
some content and produces Html.
-}
type Template msg model
    = Dynamic (ResponsiveStyle -> model -> Html msg)
    | Static (ResponsiveStyle -> Html Never)


{-| A responsive snippet is a CSS global snippet that is device responsive.
-}
type alias ResponsiveSnippet =
    ResponsiveStyle -> List Css.Global.Snippet


{-| Defines the type of a layout. A layout is a higher level template; it takes a
template as input and produces a template as output.

A layout also produces a responsive CSS snippet for the layout to further customize
its style.

-}
type alias Layout msg model =
    Template msg model
    ->
        { template : Template msg model
        , global : ResponsiveSnippet
        }


{-| Lifts a template into another template.
-}
lift : (a -> msg) -> (model -> b) -> Template a b -> Template msg model
lift msgFn modelFn template =
    case template of
        Dynamic fn ->
            Dynamic
                (\devices model -> fn devices (modelFn model) |> Html.Styled.map msgFn)

        Static fn ->
            Static fn
