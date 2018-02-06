module Top
    exposing
        ( Model
        , Msg
        , init
        , subscriptions
        , update
        , view
        , delta2url
        , location2messages
        )

import Accounts
import Array exposing (Array)
import Auth
import Config exposing (config)
import Config exposing (Config)
import Dict exposing (Dict)
import Exts.Maybe exposing (catMaybes)
import Html as App
import Html.Attributes exposing (href, class, style, id)
import Html exposing (Html, div, text, a)
import Html.Lazy
import Material
import Material.Button as Button
import Material.Layout
import Material.Menu
import Material.Options as Options exposing (css)
import Material.Toggles as Toggles
import Material.Typography as Typography
import Maybe exposing (Maybe)
import Navigation
import OutMessage
import Permissions
import Roles
import RouteUrl as Routing
import String
import Utils exposing (nth, lift)
import ViewUtils
import Welcome
import Material.Color as Color


type alias Model =
    { welcome : Welcome.Model
    , auth : Auth.Model
    , mdl : Material.Model
    , accounts : Accounts.Model
    , roles : Roles.Model
    , permissions : Permissions.Model
    , selectedTab : Int
    , transparentHeader : Bool
    , debugStylesheet : Bool
    , forwardLocation : String
    , layout : Layout
    }


type alias Layout =
    { fixedHeader : Bool
    , fixedDrawer : Bool
    , fixedTabs : Bool
    , header : HeaderType
    , withHeader : Bool
    }


type HeaderType
    = Waterfall Bool
    | Seamed
    | Standard
    | Scrolling


type Msg
    = Mdl (Material.Msg Msg)
    | AuthMsg Auth.Msg
    | WelcomeMsg Welcome.Msg
    | AccountsMsg Accounts.Msg
    | RolesMsg Roles.Msg
    | PermissionsMsg Permissions.Msg
    | SelectLocation String
    | SelectTab Int
    | ToggleHeader
    | ToggleDebug
    | LogOut


init : Config -> ( Model, Cmd Msg )
init config =
    ( { welcome = Welcome.init
      , auth = Auth.init { authApiRoot = config.authRoot }
      , mdl = Material.Layout.setTabsWidth 1384 Material.model
      , accounts = Accounts.init config
      , roles = Roles.init config
      , permissions = Permissions.init config
      , selectedTab = 0
      , transparentHeader = False
      , debugStylesheet = False
      , forwardLocation = ""
      , layout = layout
      }
    , Cmd.batch
        [ Material.Layout.sub0 Mdl

        --, Auth.refresh
        ]
    )


layout : Layout
layout =
    { fixedHeader = True
    , fixedTabs = False
    , fixedDrawer = False
    , header = Standard
    , withHeader = True
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Material.Layout.subs Mdl model.mdl ]


noop model =
    ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case (Debug.log "Main.update" action) of
        Mdl msg ->
            Material.update Mdl msg model

        AuthMsg msg ->
            lift .auth (\x m -> { m | auth = x }) AuthMsg Auth.update msg model

        WelcomeMsg a ->
            let
                interpretOutMsg : Cmd Auth.Msg -> Model -> ( Model, Cmd Msg )
                interpretOutMsg outMsg model =
                    ( model, outMsg |> Cmd.map AuthMsg )
            in
                Welcome.update a model.welcome
                    |> OutMessage.mapComponent (\welcome -> { model | welcome = welcome })
                    |> OutMessage.mapCmd WelcomeMsg
                    |> OutMessage.evaluate interpretOutMsg

        AccountsMsg a ->
            lift .accounts (\x m -> { m | accounts = x }) AccountsMsg Accounts.update a model

        RolesMsg a ->
            lift .roles (\x m -> { m | roles = x }) RolesMsg Roles.update a model

        PermissionsMsg a ->
            lift .permissions (\x m -> { m | permissions = x }) PermissionsMsg Permissions.update a model

        SelectLocation location ->
            selectLocation model location

        SelectTab k ->
            ( { model | selectedTab = k }, urlOfTab k |> Navigation.newUrl )

        ToggleHeader ->
            ( { model | transparentHeader = not model.transparentHeader }, Cmd.none )

        ToggleDebug ->
            ( { model | debugStylesheet = not model.debugStylesheet }, Cmd.none )

        LogOut ->
            ( model, Auth.logout |> Cmd.map AuthMsg )


urlOfTab : Int -> String
urlOfTab tabNo =
    "#" ++ (Array.get tabNo tabUrls |> Maybe.withDefault "")


{-| This is the main router for the application, invoked on all url location changes.

When not logged in and not already on the welcome page, this will forward to the welcome
page to log in. The location being requested will be saved in the auth forward location, so
that it can be forwarded to upon succesfull login.

When forwarding to a location with an *Init* event available, this will be triggered
in order that a particular location can initialize itself.

-}
selectLocation : Model -> String -> ( Model, Cmd Msg )
selectLocation model location =
    case (Debug.log "selectLocation" Auth.getStatus model.auth) of
        Auth.LoggedOut ->
            ( { model | forwardLocation = "#" ++ location }
            , if location /= "welcome" then
                Navigation.newUrl "#welcome"
              else
                Cmd.none
            )

        Auth.Failed ->
            noop model

        Auth.LoggedIn _ ->
            ( { model
                | selectedTab =
                    Dict.get location urlTabs
                        |> Maybe.withDefault -1
              }
            , case location of
                "accounts" ->
                    Utils.message (AccountsMsg Accounts.Init)

                "roles" ->
                    Utils.message (RolesMsg Roles.Init)

                "permissions" ->
                    Utils.message (PermissionsMsg Permissions.Init)

                _ ->
                    Cmd.none
            )



-- Views


view : Model -> Html Msg
view model =
    case Auth.getStatus model.auth of
        Auth.LoggedOut ->
            welcome model

        Auth.Failed ->
            notPermitted model

        Auth.LoggedIn state ->
            app model


layoutOptions : Model -> List (Material.Layout.Property Msg)
layoutOptions model =
    [ Material.Layout.selectedTab model.selectedTab
    , Material.Layout.onSelectTab SelectTab
    , Material.Layout.fixedHeader |> Options.when model.layout.fixedHeader
    , Material.Layout.fixedDrawer |> Options.when model.layout.fixedDrawer
    , Material.Layout.fixedTabs |> Options.when model.layout.fixedTabs
    , (case model.layout.header of
        Waterfall x ->
            Material.Layout.waterfall x

        Seamed ->
            Material.Layout.seamed

        Standard ->
            Options.nop

        Scrolling ->
            Material.Layout.scrolling
      )
        |> Options.when model.layout.withHeader
    , if model.transparentHeader then
        Material.Layout.transparentHeader
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
                App.map AccountsMsg (Accounts.dialog model.accounts)

            Just ( "Roles", _, _ ) ->
                App.map RolesMsg (Roles.dialog model.roles)

            Just ( "Permissions", _, _ ) ->
                App.map PermissionsMsg (Permissions.dialog model.permissions)

            _ ->
                div [] []
        ]


appTop : Model -> Html Msg
appTop model =
    (Array.get model.selectedTab tabViews |> Maybe.withDefault e404) model


app : Model -> Html Msg
app model =
    Material.Layout.render Mdl
        model.mdl
        (layoutOptions model)
        { header = header True model
        , drawer = []
        , tabs =
            ( tabTitles
            , []
            )
        , main = [ appTop model ]
        }
        |> framing model


welcome : Model -> Html Msg
welcome model =
    Material.Layout.render Mdl
        model.mdl
        (layoutOptions model)
        { header = header False model
        , drawer = []
        , tabs =
            ( []
            , []
            )
        , main = [ welcomeView model ]
        }
        |> framing model


notPermitted : Model -> Html Msg
notPermitted model =
    Material.Layout.render Mdl
        model.mdl
        (layoutOptions model)
        { header = header False model
        , drawer = []
        , tabs =
            ( []
            , []
            )
        , main = [ notPermittedView model ]
        }
        |> framing model


header : Bool -> Model -> List (Html Msg)
header authenticated model =
    if model.layout.withHeader then
        [ Material.Layout.row
            []
            [ a
                [ Html.Attributes.id "thesett-logo"
                , href "http://"
                ]
                []
            , Material.Layout.spacer
            , if authenticated then
                div []
                    [ Button.render Mdl
                        [ 1, 2 ]
                        model.mdl
                        [ Button.colored
                        , Options.onClick LogOut
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
                    , Options.onClick ToggleDebug
                    ]
                    [ text "Debug Style" ]
                ]
            ]
        ]
    else
        []


welcomeView : Model -> Html Msg
welcomeView =
    .welcome >> Welcome.root >> App.map WelcomeMsg


notPermittedView : Model -> Html Msg
notPermittedView =
    .welcome >> Welcome.notPermitted >> App.map WelcomeMsg


tabs : List ( String, String, Model -> Html Msg )
tabs =
    [ ( "Accounts", "accounts", .accounts >> Accounts.root >> App.map AccountsMsg )
    , ( "Roles", "roles", .roles >> Roles.root >> App.map RolesMsg )
    , ( "Permissions", "permissions", .permissions >> Permissions.root >> App.map PermissionsMsg )
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


log : a -> a
log =
    Debug.log "top"



-- ROUTING


urlOf : Model -> String
urlOf model =
    "#" ++ (Array.get model.selectedTab tabUrls |> Maybe.withDefault "")


delta2url : Model -> Model -> Maybe Routing.UrlChange
delta2url model1 model2 =
    if model1.selectedTab /= model2.selectedTab then
        { entry = Routing.NewEntry
        , url = urlOf model2
        }
            |> Just
    else
        Nothing


location2messages : Navigation.Location -> List Msg
location2messages location =
    [ String.dropLeft 1 location.hash |> SelectLocation ]
