module Welcome.View exposing (root)

import Html exposing (..)
import Html.Lazy
import Html.Attributes exposing (title, class, href, src, action)
import Material.Options as Options exposing (Style, cs, when, nop, disabled)
import Material.Color as Color
import Material.Dialog as Dialog
import Material.Table as Table
import Material.Button as Button
import Material.Icon as Icon
import Material.Toggles as Toggles
import Material.Textfield as Textfield
import Welcome.Types exposing (..)
import Welcome.State exposing (..)


root : Model -> Html Msg
root =
    Html.Lazy.lazy root'


root' : Model -> Html Msg
root' model =
    div []
        [ div [ class "layout-fixed-width--one-card" ]
            [ div [ class "mdl-grid" ]
                [ div [ class "mdl-cell mdl-cell--12-col mdl-cell--8-col-tablet mdl-cell--4-col-phone mdl-card mdl-shadow--3dp" ]
                    [ div [ class "mdl-card__media" ]
                        [ img [ src "images/data_center-large.png" ]
                            []
                        ]
                    , div [ class "mdl-card__title" ]
                        [ h4 [ class "mdl-card__title-text" ]
                            [ text "Log In" ]
                        ]
                    , div [ class "mdl-card__supporting-text" ]
                        [ form [ action "#" ]
                            [ Textfield.render Mdl
                                [ 1, 1 ]
                                model.mdl
                                [ Textfield.label "Username"
                                , Textfield.floatingLabel
                                , Textfield.text'
                                , Textfield.onInput UpdateUsername
                                ]
                            , Textfield.render Mdl
                                [ 1, 2 ]
                                model.mdl
                                [ Textfield.label "Password"
                                , Textfield.floatingLabel
                                , Textfield.text'
                                , Textfield.password
                                , Textfield.onInput UpdatePassword
                                ]
                            ]
                        ]
                    , div [ class "mdl-card__actions" ]
                        [ div [ class "control-bar" ]
                            [ div [ class "control-bar__row" ]
                                [ div [ class "control-bar__left-0" ]
                                    [ Button.render Mdl
                                        [ 1, 2 ]
                                        model.mdl
                                        [ Button.colored
                                        , Button.onClick LogIn
                                        ]
                                        [ text "Log In"
                                        , Icon.i "chevron_right"
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
