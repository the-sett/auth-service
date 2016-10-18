module ViewUtils exposing (..)

import Html exposing (..)
import Html.Attributes exposing (title, class, action, attribute)
import Material
import Material.Options as Options exposing (Style, cs, when, nop, disabled)
import Material.Button as Button
import Material.Icon as Icon


{-
   Builds a ripple effect button used for completing some user input.
   - The button displays the specified label.
   - The button is disabled when the isValid indicator is false.
   - The specified msg is triggered when the button is clicked.
-}


completeButton : Material.Model -> (Material.Msg msg -> msg) -> String -> Bool -> msg -> Html msg
completeButton model mdl label isValid msg =
    Button.render mdl
        [ 0 ]
        model
        [ Button.ripple
        , if isValid then
            Button.colored
          else
            Button.disabled
        , Button.onClick msg
        ]
        [ text label ]



{-
   Builds a control bar with 'ok' and 'cancel' actions.
    - The ok action is specified as button.
    - The cancel action is specified as a msg to trigger on the cancel button
      click.
-}


okCancelControlBar : Material.Model -> (Material.Msg msg -> msg) -> Html msg -> msg -> Html msg
okCancelControlBar model mdl button cancelMsg =
    div [ class "control-bar" ]
        [ div [ class "control-bar__row" ]
            [ div [ class "control-bar__left-0" ]
                [ Button.render mdl
                    [ 0 ]
                    model
                    [ Button.ripple
                    , Button.accent
                    , Button.onClick cancelMsg
                    ]
                    [ Icon.i "chevron_left"
                    , text "Back"
                    ]
                ]
            , div [ class "control-bar__right-0" ]
                [ button ]
            ]
        ]
