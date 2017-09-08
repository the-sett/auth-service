module Main.State exposing (Model, Msg(..), init, update, view, tabUrls)

import Accounts.State
import Array exposing (Array)
import Auth
import AuthController
import Config exposing (Config)
import Dict exposing (Dict)
import Exts.Maybe exposing (catMaybes)
import Html as App
import Html.Attributes exposing (href, class, style, id)
import Html exposing (..)
import Html.Lazy
import Layout.State
import Material
import Material.Button as Button
import Material.Helpers exposing (pure, lift, lift_)
import Material.Layout as Layout
import Material.Options as Options exposing (css)
import Material.Toggles as Toggles
import Material.Typography as Typography
import Maybe exposing (Maybe)
import Menu.State
import Navigation
import OutMessage
import Permissions.State
import Permissions.Types
import Permissions.View
import Platform.Cmd exposing (..)
import Roles.State
import Roles.Types
import Roles.View
import Utils exposing (..)
import ViewUtils
import Welcome.Welcome


type alias Model =
    { welcome : Welcome.Welcome.Model
    , auth : AuthController.Model
    , mdl : Material.Model
    , accounts : Accounts.State.Model
    , roles : Roles.Types.Model
    , permissions : Permissions.Types.Model
    , layout : Layout.State.Model
    , menus : Menu.State.Model
    , selectedTab : Int
    , transparentHeader : Bool
    , debugStylesheet : Bool
    }


type Msg
    = Mdl (Material.Msg Msg)
    | AuthCmdMsg Auth.AuthCmd
    | AuthMsg AuthController.Msg
    | SelectTab Int
    | SelectLocation String
    | WelcomeMsg Welcome.Welcome.Msg
    | AccountsMsg Accounts.State.Msg
    | RolesMsg Roles.Types.Msg
    | PermissionsMsg Permissions.Types.Msg
    | LayoutMsg Layout.State.Msg
    | MenusMsg Menu.State.Msg
    | ToggleHeader
    | ToggleDebug
    | LogOut


init : Config -> Model
init config =
    { welcome = Welcome.Welcome.init
    , auth =
        AuthController.init
            { logoutLocation = "#welcome"
            , forwardLocation = "#accounts"
            , authApiRoot = config.authRoot
            }
    , mdl = Layout.setTabsWidth 1384 Material.model
    , accounts = Accounts.State.init config
    , roles = Roles.State.init config
    , permissions = Permissions.State.init config
    , layout = Layout.State.init
    , menus = Menu.State.init
    , selectedTab = 0
    , transparentHeader = False
    , debugStylesheet = False
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    update_ (Debug.log "top" action) model


update_ : Msg -> Model -> ( Model, Cmd Msg )
update_ action model =
    case action of
        Mdl msg ->
            Material.update Mdl msg model

        AuthMsg a ->
            lift .auth (\m x -> { m | auth = x }) AuthMsg AuthController.update a model

        AuthCmdMsg a ->
            AuthController.updateFromAuthCmd a model.auth
                |> Tuple.mapFirst (\auth -> { model | auth = auth })
                |> Tuple.mapSecond (Cmd.map AuthMsg)

        SelectLocation location ->
            selectLocation model location

        SelectTab k ->
            ( { model | selectedTab = k }, urlOfTab k |> Navigation.newUrl )

        ToggleHeader ->
            ( { model | transparentHeader = not model.transparentHeader }, Cmd.none )

        ToggleDebug ->
            ( { model | debugStylesheet = not model.debugStylesheet }, Cmd.none )

        LogOut ->
            ( model, Auth.logout |> AuthCmdMsg |> Utils.message )

        WelcomeMsg a ->
            let
                interpretOutMsg : Welcome.Welcome.OutMsg -> Model -> ( Model, Cmd Msg )
                interpretOutMsg (Welcome.Welcome.AuthMsg outMsg) model =
                    ( model, AuthCmdMsg outMsg |> Utils.message )
            in
                Welcome.Welcome.update a model.welcome
                    |> OutMessage.mapComponent (\welcome -> { model | welcome = welcome })
                    |> OutMessage.mapCmd WelcomeMsg
                    |> OutMessage.evaluateMaybe interpretOutMsg Cmd.none

        AccountsMsg a ->
            lift .accounts (\m x -> { m | accounts = x }) AccountsMsg Accounts.State.update a model

        RolesMsg a ->
            lift .roles (\m x -> { m | roles = x }) RolesMsg Roles.State.update a model

        PermissionsMsg a ->
            lift .permissions (\m x -> { m | permissions = x }) PermissionsMsg Permissions.State.update a model

        LayoutMsg a ->
            lift .layout (\m x -> { m | layout = x }) LayoutMsg Layout.State.update a model

        MenusMsg a ->
            lift .menus (\m x -> { m | menus = x }) MenusMsg Menu.State.update a model


urlOfTab : Int -> String
urlOfTab tabNo =
    "#" ++ (Array.get tabNo tabUrls |> Maybe.withDefault "")



{-
   This is the main router for the application, invoked on all url location changes.

   When not logged in and not already on the welcome page, this will forward to the welcome
   page to log in. The location being requested will be saved in the auth forward location, so
   that it can be forwarded to upon succesfull login.

   When forwarding to a location with an _Init_ event available, this will be triggered
   in order that a particular location can initialize itself.
-}


selectLocation : Model -> String -> ( Model, Cmd Msg )
selectLocation model location =
    let
        authenticated =
            AuthController.extractAuthState model.auth |> Auth.isLoggedIn

        hasPermission =
            AuthController.extractAuthState model.auth |> Auth.hasPermission "auth-admin"

        -- Flag indicating whether the welcome location should be navigated to.
        jumpToWelcome =
            ((not authenticated) || (not hasPermission)) && location /= "welcome"

        -- Maybe a command to jump to the welcome location.
        jumpToWelcomeCmd =
            if jumpToWelcome then
                Navigation.newUrl "#welcome" |> Just
            else
                Nothing

        -- Saves the location as the current forward location on the auth state.
        forwardLocation =
            "#" ++ location |> AuthController.updateForwardLocation

        -- When not on the welcome location, the current location is saved as the
        -- current auth forwarding location, so that it can be restored after a
        -- login.
        jumpToWelcomeModel =
            if location /= "welcome" then
                { model | auth = forwardLocation model.auth }
            else
                model

        -- Choses which tab is currently active.
        tabNo =
            Dict.get location urlTabs
                |> Maybe.withDefault -1

        -- Maybe a command to trigger the _Init_ event when navigating to a location
        -- with such an event.
        initCmd =
            if not jumpToWelcome then
                case location of
                    "accounts" ->
                        Utils.message (AccountsMsg Accounts.State.Init) |> Just

                    "roles" ->
                        Utils.message (RolesMsg Roles.Types.Init) |> Just

                    "permissions" ->
                        Utils.message (PermissionsMsg Permissions.Types.Init) |> Just

                    _ ->
                        Nothing
            else
                Nothing

        -- The model updated with the currently selected tab.
        selectTabModel =
            { jumpToWelcomeModel | selectedTab = tabNo }
    in
        ( selectTabModel, Cmd.batch (catMaybes [ jumpToWelcomeCmd, initCmd ]) )



-- Views


view : Auth.AuthState -> Model -> Html Msg
view =
    Html.Lazy.lazy2 view_


view_ : Auth.AuthState -> Model -> Html Msg
view_ authState model =
    let
        authenticated =
            Auth.isLoggedIn authState

        logonAttempted =
            AuthController.logonAttempted model.auth

        hasPermission =
            Auth.hasPermission "auth-admin" authState
    in
        if authenticated && hasPermission then
            app model
        else if authenticated && not hasPermission then
            notPermitted model
        else if not authenticated && logonAttempted then
            notPermitted model
        else
            welcome model


layoutOptions : Model -> List (Layout.Property Msg)
layoutOptions model =
    [ Layout.selectedTab model.selectedTab
    , Layout.onSelectTab SelectTab
    , Layout.fixedHeader |> Options.when model.layout.fixedHeader
    , Layout.fixedDrawer |> Options.when model.layout.fixedDrawer
    , Layout.fixedTabs |> Options.when model.layout.fixedTabs
    , (case model.layout.header of
        Layout.State.Waterfall x ->
            Layout.waterfall x

        Layout.State.Seamed ->
            Layout.seamed

        Layout.State.Standard ->
            Options.nop

        Layout.State.Scrolling ->
            Layout.scrolling
      )
        |> Options.when model.layout.withHeader
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
                App.map AccountsMsg (Accounts.State.dialog model.accounts)

            Just ( "Roles", _, _ ) ->
                App.map RolesMsg (Roles.View.dialog model.roles)

            Just ( "Permissions", _, _ ) ->
                App.map PermissionsMsg (Permissions.View.dialog model.permissions)

            _ ->
                div [] []
        ]


appTop : Model -> Html Msg
appTop model =
    (Array.get model.selectedTab tabViews |> Maybe.withDefault e404) model


app : Model -> Html Msg
app model =
    Layout.render Mdl
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
    Layout.render Mdl
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
    Layout.render Mdl
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
        [ Layout.row
            []
            [ a
                [ Html.Attributes.id "thesett-logo"
                , href "http://"
                ]
                []
            , Layout.spacer
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
    .welcome >> Welcome.Welcome.root >> App.map WelcomeMsg


notPermittedView : Model -> Html Msg
notPermittedView =
    .welcome >> Welcome.Welcome.notPermitted >> App.map WelcomeMsg


tabs : List ( String, String, Model -> Html Msg )
tabs =
    [ ( "Accounts", "accounts", .accounts >> Accounts.State.root >> App.map AccountsMsg )
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
