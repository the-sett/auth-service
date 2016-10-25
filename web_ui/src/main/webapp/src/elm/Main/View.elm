module Main.View exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (href, class, style, id)
import Html.Lazy
import Html.App as App
import Material.Layout as Layout
import Material.Options as Options exposing (css, when)
import Material.Toggles as Toggles
import Material.Typography as Typography
import Material.Button as Button
import Utils exposing (..)
import Layout.Types
import Accounts.View
import Roles.View
import Permissions.View
import Welcome.View
import Auth.Types
import Main.Types exposing (..)


view : Auth.Types.AuthState -> Model -> Html Msg
view =
    Html.Lazy.lazy2 view'


view' : Auth.Types.AuthState -> Model -> Html Msg
view' authState model =
    if authState.loggedIn then
        app authState model
    else
        welcome authState model


layoutOptions : Model -> List (Layout.Property Msg)
layoutOptions model =
    [ Layout.selectedTab model.selectedTab
    , Layout.onSelectTab SelectTab
    , Layout.fixedHeader `when` model.layout.fixedHeader
    , Layout.fixedDrawer `when` model.layout.fixedDrawer
    , Layout.fixedTabs `when` model.layout.fixedTabs
    , (case model.layout.header of
        Layout.Types.Waterfall x ->
            Layout.waterfall x

        Layout.Types.Seamed ->
            Layout.seamed

        Layout.Types.Standard ->
            Options.nop

        Layout.Types.Scrolling ->
            Layout.scrolling
      )
        `when` model.layout.withHeader
    , if model.transparentHeader then
        Layout.transparentHeader
      else
        Options.nop
    ]


framing : Model -> Html Msg -> Html Msg
framing model contents =
    div []
        [ if model.debugStylesheet then
            Html.node "link"
                [ Html.Attributes.attribute "rel" "stylesheet"
                , Html.Attributes.attribute "href" "styles/debug.css"
                ]
                []
          else
            div [] []
        , contents
          {-
             Dialogs need to be pulled up here to make the dialog
             polyfill work on some browsers.
          -}
        , case nth model.selectedTab tabs of
            Just ( "Accounts", _, _ ) ->
                App.map AccountsMsg (Accounts.View.dialog model.accounts)

            Just ( "Roles", _, _ ) ->
                App.map RolesMsg (Roles.View.dialog model.roles)

            _ ->
                div [] []
        ]


appTop : Model -> Html Msg
appTop model =
    (Array.get model.selectedTab tabViews |> Maybe.withDefault e404) model


app : Auth.Types.AuthState -> Model -> Html Msg
app authState model =
    Layout.render Mdl
        model.mdl
        (layoutOptions model)
        { header = header authState model
        , drawer = []
        , tabs =
            ( tabTitles
            , []
            )
        , main = [ appTop model ]
        }
        |> framing model


welcome : Auth.Types.AuthState -> Model -> Html Msg
welcome authState model =
    Layout.render Mdl
        model.mdl
        (layoutOptions model)
        { header = header authState model
        , drawer = []
        , tabs =
            ( []
            , []
            )
        , main = [ welcomeView model ]
        }
        |> framing model


header : Auth.Types.AuthState -> Model -> List (Html Msg)
header authState model =
    if model.layout.withHeader then
        [ Layout.row
            []
            [ a
                [ Html.Attributes.id "thesett-logo"
                , href "http://"
                ]
                []
            , Layout.spacer
            , if authState.loggedIn then
                div []
                    [ Button.render Mdl
                        [ 1, 2 ]
                        model.mdl
                        [ Button.colored
                        , Button.onClick LogOut
                        ]
                        [ text "Log Out"
                        ]
                    ]
              else
                div [] []
            , div [ id "debug-box" ]
                [ Toggles.switch Mdl
                    [ 0 ]
                    model.mdl
                    [ Toggles.ripple
                    , Toggles.value model.debugStylesheet
                    , Toggles.onClick ToggleDebug
                    ]
                    [ text "Debug Style" ]
                ]
            ]
        ]
    else
        []


welcomeView : Model -> Html Msg
welcomeView =
    .welcome >> Welcome.View.root >> App.map WelcomeMsg


tabs : List ( String, String, Model -> Html Msg )
tabs =
    [ ( "Accounts", "accounts", .accounts >> Accounts.View.root >> App.map AccountsMsg )
    , ( "Roles", "roles", .roles >> Roles.View.root >> App.map RolesMsg )
    , ( "Permissions", "permissions", .permissions >> Permissions.View.root >> App.map PermissionsMsg )
    ]


tabTitles : List (Html a)
tabTitles =
    List.map (\( x, _, _ ) -> text x) tabs


tabViews : Array (Model -> Html Msg)
tabViews =
    List.map (\( _, _, v ) -> v) tabs |> Array.fromList


tabUrls : Array String
tabUrls =
    List.map (\( _, x, _ ) -> x) tabs |> Array.fromList


urlTabs : Dict String Int
urlTabs =
    List.indexedMap (\idx ( _, x, _ ) -> ( x, idx )) tabs |> Dict.fromList


e404 : Model -> Html Msg
e404 _ =
    div
        []
        [ Options.styled Html.h1
            [ Options.cs "mdl-typography--display-4"
            , Typography.center
            ]
            [ text "404" ]
        ]
