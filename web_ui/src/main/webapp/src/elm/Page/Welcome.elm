module Page.Welcome exposing
    ( Model
    , Msg
    , init
    , initialView
    , loginView
    , notPermittedView
    , update
    )

import Auth
import Css
import Css.Global
import Grid as Grid
import Html.Styled exposing (div, form, h4, img, label, span, styled, text, toUnstyled)
import Html.Styled.Attributes exposing (for, name, src)
import Html.Styled.Events exposing (onClick, onInput)
import Html.Styled.Lazy exposing (lazy)
import Responsive exposing (ResponsiveStyle)
import Structure exposing (Template(..))
import Styles exposing (lg, md, sm, xl)
import Styling
import TheSett.Buttons as Buttons
import TheSett.Cards as Cards
import TheSett.Laf as Laf
import TheSett.Textfield as Textfield


type alias Model =
    { laf : Laf.Model
    , username : String
    , password : String
    }


type Msg
    = LafMsg Laf.Msg
    | LogIn
    | TryAgain
    | UpdateUsername String
    | UpdatePassword String


init : Model
init =
    { laf = Laf.init
    , username = ""
    , password = ""
    }


update : Msg -> Model -> ( Model, Cmd Msg, Cmd Auth.Msg )
update action model =
    case action of
        LafMsg lafMsg ->
            let
                ( newModel, lafCmds ) =
                    Laf.update LafMsg lafMsg model.laf
                        |> Tuple.mapFirst (\laf -> { model | laf = laf })
            in
            ( newModel, lafCmds, Cmd.none )

        LogIn ->
            ( model, Cmd.none, Auth.login { username = model.username, password = model.password } )

        TryAgain ->
            ( model, Cmd.none, Auth.unauthed )

        UpdateUsername str ->
            ( { model | username = str }, Cmd.none, Cmd.none )

        UpdatePassword str ->
            ( { model | password = str }, Cmd.none, Cmd.none )



-- View


initialView : Template msg model
initialView =
    (\devices ->
        [ card "images/data_center-large.png"
            "Attempting to Restore"
            [ text "Attempting to restore authentication using a local refresh token." ]
            []
            devices
        ]
            |> framing devices
    )
        |> lazy
        |> Static


loginView : Template Msg { a | laf : Laf.Model, password : String, username : String }
loginView =
    (\devices model ->
        [ card "images/data_center-large.png"
            "Log In"
            [ form []
                [ Textfield.text
                    LafMsg
                    [ 1 ]
                    model.laf
                    [ Textfield.value model.username ]
                    [ onInput UpdateUsername ]
                    [ text "Username" ]
                    devices
                , Textfield.text
                    LafMsg
                    [ 2 ]
                    model.laf
                    [ Textfield.disabled
                    , Textfield.value model.password
                    ]
                    [ onInput UpdatePassword ]
                    [ text "Password" ]
                    devices
                ]
            ]
            [ Buttons.button []
                [ onClick LogIn ]
                [ text "Log In" ]
                devices
            ]
            devices
        ]
            |> framing devices
    )
        |> Dynamic


notPermittedView : Template Msg { a | laf : Laf.Model, password : String, username : String }
notPermittedView =
    (\devices model ->
        [ card "images/data_center-large.png"
            "Not Authorized"
            [ form []
                [ Textfield.text
                    LafMsg
                    [ 1 ]
                    model.laf
                    [ Textfield.value model.username ]
                    []
                    [ text "Username" ]
                    devices
                , Textfield.text
                    LafMsg
                    [ 2 ]
                    model.laf
                    [ Textfield.disabled
                    , Textfield.value model.password
                    ]
                    []
                    [ text "Password" ]
                    devices
                ]
            ]
            [ Buttons.button [] [ onClick TryAgain ] [ text "Try Again" ] devices ]
            devices
        ]
            |> framing devices
    )
        |> Dynamic


framing : ResponsiveStyle -> List (Html.Styled.Html msg) -> Html.Styled.Html msg
framing devices innerHtml =
    styled div
        [ Responsive.deviceStyle devices
            (\device -> Css.marginTop <| Responsive.rhythmPx 3 device)
        ]
        []
        [ Grid.grid
            [ sm [ Grid.columns 12 ] ]
            []
            [ Grid.row
                [ sm [ Grid.center ] ]
                []
                [ Grid.col
                    []
                    []
                    innerHtml
                ]
            ]
            devices
        ]


card :
    String
    -> String
    -> List (Html.Styled.Html msg)
    -> List (Html.Styled.Html msg)
    -> Responsive.ResponsiveStyle
    -> Html.Styled.Html msg
card imageUrl title cardBody controls devices =
    Cards.card
        [ sm
            [ Styles.styles
                [ Css.maxWidth <| Css.vw 100
                , Css.minWidth <| Css.px 310
                , Css.backgroundColor <| Styling.paperWhite
                ]
            ]
        , md
            [ Styles.styles
                [ Css.maxWidth <| Css.px 420
                , Css.minWidth <| Css.px 400
                , Css.backgroundColor <| Styling.paperWhite
                ]
            ]
        ]
        []
        [ Cards.image
            [ Styles.height 6
            , sm [ Cards.src imageUrl ]
            ]
            []
            []
        , Cards.title title
        , Cards.body cardBody
        , Cards.controls controls
        ]
        devices
