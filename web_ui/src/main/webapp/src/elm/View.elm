module Main.View exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (href, class, style, id)
import Html.Lazy
import Html.App as App
import Material.Color as Color
import Material.Layout as Layout
import Material.Options as Options exposing (css, when)
import Material.Scheme as Scheme
import Material.Icon as Icon
import Material.Toggles as Toggles
import Material.Typography as Typography
import Layout.Types
import Accounts.View
import Roles.View
import Permissions.View
import Main.Types exposing (..)


nth : Int -> List a -> Maybe a
nth k xs =
    List.drop k xs |> List.head


view : Model -> Html Msg
view =
    Html.Lazy.lazy view'


view' : Model -> Html Msg
view' model =
    let
        top =
            (Array.get model.selectedTab tabViews |> Maybe.withDefault e404) model
    in
        Layout.render Mdl
            model.mdl
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
            { header = header model
            , drawer = []
            , tabs =
                ( tabTitles
                , []
                )
            , main = [ top ]
            }
            |> (\contents ->
                    div []
                        [ if model.debugStylesheet then
                            Html.node "link"
                                [ Html.Attributes.attribute "rel" "stylesheet"
                                , Html.Attributes.attribute "href" "http://localhost:9072/thesett-laf/styles/debug.css"
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

                            _ ->
                                div [] []
                        ]
               )


header : Model -> List (Html Msg)
header model =
    if model.layout.withHeader then
        [ Layout.row
            []
            [ a
                [ Html.Attributes.id "thesett-logo"
                , href "http://"
                ]
                []
            , Layout.spacer
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



-- Old stuff


drawer : Model -> List (Html Msg)
drawer model =
    [ Layout.title [] [ text "ToolBox" ]
    , Toggles.switch Mdl
        [ 0 ]
        model.mdl
        [ Toggles.ripple
        , Toggles.value model.debugStylesheet
        , Toggles.onClick ToggleDebug
        ]
        [ text "Debug" ]
    ]


stylesheet : Html a
stylesheet =
    Options.stylesheet """
  .mdl-layout__header--transparent {
    background: url('https://getmdl.io/assets/demos/transparent.jpg') center / cover;
  }
"""
