module Welcome.Welcome exposing (init, update, root, notPermitted, Model, Msg)

import Platform.Cmd exposing (Cmd)
import Material
import Auth
import Html exposing (..)
import Html.Lazy
import Html.Attributes exposing (title, class, href, src, action)
import Material.Button as Button
import Material.Icon as Icon
import Material.Textfield as Textfield
import Material.Options as Options
import ViewUtils


type alias Model =
    { mdl : Material.Model
    , username : String
    , password : String
    }


type Msg
    = Mdl (Material.Msg Msg)
    | AuthMsg Auth.AuthCmd
    | GetStarted
    | LogIn
    | TryAgain
    | Cancel
    | UpdateUsername String
    | UpdatePassword String


init : Model
init =
    { mdl = Material.model
    , username = ""
    , password = ""
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    update_ (Debug.log "welcome" action) model


update_ : Msg -> Model -> ( Model, Cmd Msg )
update_ action model =
    case action of
        Mdl action_ ->
            Material.update Mdl action_ model

        AuthMsg authMsg ->
            ( model, Cmd.none )

        GetStarted ->
            ( model, Cmd.none )

        LogIn ->
            update_ (AuthMsg (Auth.login { username = model.username, password = model.password })) model

        TryAgain ->
            update_ (AuthMsg Auth.unauthed) model

        Cancel ->
            ( model, Cmd.none )

        UpdateUsername str ->
            ( { model | username = str }, Cmd.none )

        UpdatePassword str ->
            ( { model | password = str }, Cmd.none )


root : Model -> Html Msg
root model =
    div []
        [ div [ class "layout-fixed-width--one-card" ]
            [ ViewUtils.rhythm1SpacerDiv
            , div [ class "mdl-grid" ]
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
                                , Textfield.text_
                                , Options.onInput UpdateUsername
                                ]
                                []
                            , Textfield.render Mdl
                                [ 1, 2 ]
                                model.mdl
                                [ Textfield.label "Password"
                                , Textfield.floatingLabel
                                , Textfield.text_
                                , Textfield.password
                                , Options.onInput UpdatePassword
                                ]
                                []
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
                                        , Options.onClick LogIn
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


notPermitted : Model -> Html Msg
notPermitted model =
    div []
        [ div [ class "layout-fixed-width--one-card" ]
            [ ViewUtils.rhythm1SpacerDiv
            , div [ class "mdl-grid" ]
                [ div [ class "mdl-cell mdl-cell--12-col mdl-cell--8-col-tablet mdl-cell--4-col-phone mdl-card mdl-shadow--3dp" ]
                    [ div [ class "mdl-card__media" ]
                        [ img [ src "images/data_center-large.png" ]
                            []
                        ]
                    , div [ class "mdl-card__title" ]
                        [ h4 [ class "mdl-card__title-text" ]
                            [ text "Not Authorized" ]
                        ]
                    , div [ class "mdl-card__supporting-text" ]
                        [ form [ action "#" ]
                            [ Textfield.render Mdl
                                [ 1, 1 ]
                                model.mdl
                                [ Textfield.label "Username"
                                , Textfield.floatingLabel
                                , Textfield.text_
                                , Textfield.disabled
                                ]
                                []
                            , Textfield.render Mdl
                                [ 1, 2 ]
                                model.mdl
                                [ Textfield.label "Password"
                                , Textfield.floatingLabel
                                , Textfield.text_
                                , Textfield.password
                                , Textfield.disabled
                                ]
                                []
                            ]
                        ]
                    , div [ class "mdl-card__actions" ]
                        [ div [ class "control-bar" ]
                            [ div [ class "control-bar__row" ]
                                [ div [ class "control-bar__left-0" ]
                                    [ Button.render Mdl
                                        [ 2, 1 ]
                                        model.mdl
                                        [ Button.colored
                                        , Options.onClick TryAgain
                                        ]
                                        [ Icon.i "chevron_left"
                                        , text "Try Again"
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
