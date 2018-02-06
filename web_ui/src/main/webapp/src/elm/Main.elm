module Main exposing (main)

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
import Layout
import Material
import Material.Button as Button
import Material.Layout
import Material.Menu
import Material.Options as Options exposing (css)
import Material.Toggles as Toggles
import Material.Typography as Typography
import Maybe exposing (Maybe)
import Menu
import Navigation
import OutMessage
import Permissions
import Roles
import RouteUrl as Routing
import String
import Utils exposing (nth, lift)
import ViewUtils
import Welcome


type alias Model =
    { welcome : Welcome.Model
    , auth : Auth.Model
    , mdl : Material.Model
    , accounts : Accounts.Model
    , roles : Roles.Model
    , permissions : Permissions.Model
    , layout : Layout.Model
    , menus : Menu.Model
    , selectedTab : Int
    , transparentHeader : Bool
    , debugStylesheet : Bool
    , forwardLocation : String
    }


type Msg
    = Mdl (Material.Msg Msg)
    | AuthMsg Auth.Msg
    | WelcomeMsg Welcome.Msg
    | AccountsMsg Accounts.Msg
    | RolesMsg Roles.Msg
    | PermissionsMsg Permissions.Msg
    | LayoutMsg Layout.Msg
    | MenusMsg Menu.Msg
    | SelectLocation String
    | SelectTab Int
    | ToggleHeader
    | ToggleDebug
    | LogOut


init : Config -> Model
init config =
    { welcome = Welcome.init
    , auth = Auth.init { authApiRoot = config.authRoot }
    , mdl = Material.Layout.setTabsWidth 1384 Material.model
    , accounts = Accounts.init config
    , roles = Roles.init config
    , permissions = Permissions.init config
    , layout = Layout.init
    , menus = Menu.init
    , selectedTab = 0
    , transparentHeader = False
    , debugStylesheet = False
    , forwardLocation = ""
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
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

        LayoutMsg a ->
            lift .layout (\x m -> { m | layout = x }) LayoutMsg Layout.update a model

        MenusMsg a ->
            lift .menus (\x m -> { m | menus = x }) MenusMsg Menu.update a model

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
        -- A command to jump to the welcome location.
        jumpToWelcomeCmd =
            Navigation.newUrl "#welcome"

        -- Saves the location as the current forward location on the model.
        forwardLocation =
            { model | forwardLocation = "#" ++ location }

        -- Choses which tab is currently active.
        tabNo =
            Dict.get location urlTabs
                |> Maybe.withDefault -1

        -- The authentication status.
        status =
            Auth.getStatus model.auth

        noop =
            ( model, Cmd.none )
    in
        case (Debug.log "selectLocation" status) of
            Auth.LoggedOut ->
                noop

            Auth.Failed ->
                noop

            Auth.LoggedIn _ ->
                noop



--     -- Flag indicating whether the welcome location should be navigated to.
--     jumpToWelcome =
--         ((not authenticated) || (not hasPermission)) && location /= "welcome"
--
--     -- When not on the welcome location, the current location is saved as the
--     -- current auth forwarding location, so that it can be restored after a
--     -- login.
--     jumpToWelcomeModel =
--         if location /= "welcome" then
--             { model | auth = forwardLocation model.auth }
--         else
--             model
--
--     -- Maybe a command to trigger the _Init_ event when navigating to a location
--     -- with such an event.
--     initCmd =
--         if not jumpToWelcome then
--             case location of
--                 "accounts" ->
--                     Utils.message (AccountsMsg Accounts.Init) |> Just
--
--                 "roles" ->
--                     Utils.message (RolesMsg Roles.Init) |> Just
--
--                 "permissions" ->
--                     Utils.message (PermissionsMsg Permissions.Init) |> Just
--
--                 _ ->
--                     Nothing
--         else
--             Nothing
--
--     -- The model updated with the currently selected tab.
--     selectTabModel =
--         { jumpToWelcomeModel | selectedTab = tabNo }
-- in
--     ( selectTabModel, Cmd.batch (catMaybes [ jumpToWelcomeCmd, initCmd ]) )
-- Views


view : Auth.Status -> Model -> Html Msg
view =
    Html.Lazy.lazy2 view_


view_ : Auth.Status -> Model -> Html Msg
view_ authState model =
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
        Layout.Waterfall x ->
            Material.Layout.waterfall x

        Layout.Seamed ->
            Material.Layout.seamed

        Layout.Standard ->
            Options.nop

        Layout.Scrolling ->
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



-- Entry point


main : Routing.RouteUrlProgram Never Model Msg
main =
    Routing.program
        { delta2url = delta2url
        , location2messages = location2messages
        , init = init_
        , view = \model -> view (Auth.getStatus model.auth) model
        , subscriptions =
            \init ->
                Sub.batch
                    [ Sub.map MenusMsg (Material.Menu.subs Menu.Mdl init.menus.mdl)
                    , Material.Layout.subs Mdl init.mdl
                    ]
        , update = update
        }


init_ : ( Model, Cmd Msg )
init_ =
    ( init config
    , Cmd.batch
        [ Material.Layout.sub0 Mdl

        --, Auth.refresh
        ]
    )



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
