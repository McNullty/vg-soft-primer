module Main exposing (..)

import Bootstrap.Navbar as NavBar
import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Html exposing (Html, div, h1, h3, text)
import Html.Attributes exposing (href)
import Pages.Greeting.Greeting as Greeting
import Pages.Items.EditItem as EditItem
import Pages.Items.ListItems as Items
import Pages.Items.NewItem as NewItem
import Pages.Login.Login as Login
import Route exposing (Route, decode)
import Url exposing (Url)
import Util exposing (getActiveItemsPage)


type alias Model =
    { route : Route
    , page : Page
    , navKey : Nav.Key
    , navState : NavBar.State
    , activeItemsPage : Maybe Int
    }


{-| This is Type with all pages. Every new page should be added here.
-}
type Page
    = NotFoundPage
    | AboutPage
    | GreetingPage Greeting.Model
    | ListItemsPage Items.Model
    | NewItemPage NewItem.Model
    | ItemPage EditItem.Model
    | LoginPage Login.Model


{-| This is Type with all messages for every page. Every new page message should be added here.
-}
type Msg
    = GreetingPageMsg Greeting.Msg
    | ListItemsPageMsg Items.Msg
    | NewItemPageMsg NewItem.Msg
    | ItemPageMsg EditItem.Msg
    | LoginPageMsg Login.Msg
      --------------
    | LinkClicked UrlRequest
    | UrlChanged Url
    | NavMsg NavBar.State


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


{-| Subscription method. Here I will add timer that will send Msg that will trigger checking commands results.
-}
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ NavBar.subscriptions model.navState NavMsg
        ]


{-| Main init method that calls init methods of specific views
-}
init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    let
        _ =
            Debug.log "Test Version" 3

        ( navState, navCmd ) =
            NavBar.initialState NavMsg

        ( model, urlCmd ) =
            urlUpdate url
                { route = Route.parseUrl url
                , page = NotFoundPage
                , navKey = navKey
                , navState = navState
                , activeItemsPage = Nothing
                }
    in
    initCurrentPage url ( model, Cmd.batch [ urlCmd, navCmd ] )


{-| Helper function that calls init function for every view. For every new view init method should be added to
theirs function.
This function sets model.page to right Page Type.
-}
initCurrentPage : Url -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage url ( model, existingCommands ) =
    let
        ( currentPage, activeItemsPage, mappedPageCommands ) =
            case model.route of
                Route.NotFound ->
                    ( NotFoundPage, Nothing, Cmd.none )

                Route.Greeting ->
                    let
                        ( pageModel, pageCommands ) =
                            Greeting.init
                    in
                    ( GreetingPage pageModel, Nothing, Cmd.map GreetingPageMsg pageCommands )

                Route.Items page ->
                    let
                        pageNumber =
                            case page of
                                Just pageNum ->
                                    pageNum

                                Nothing ->
                                    0

                        ( pageModel, pageCommands ) =
                            Items.init pageNumber
                    in
                    ( ListItemsPage pageModel, Just pageNumber, Cmd.map ListItemsPageMsg pageCommands )

                Route.NewItem ->
                    let
                        ( pageModel, pageCommands ) =
                            NewItem.init model.navKey (getActiveItemsPage model.activeItemsPage)
                    in
                    ( NewItemPage pageModel, model.activeItemsPage, Cmd.map NewItemPageMsg pageCommands )

                Route.Item itemId ->
                    let
                        ( pageModel, pageCommands ) =
                            EditItem.init itemId model.navKey (getActiveItemsPage model.activeItemsPage)
                    in
                    ( ItemPage pageModel, model.activeItemsPage, Cmd.map ItemPageMsg pageCommands )

                Route.About ->
                    ( AboutPage, Nothing, Cmd.none )

                Route.Login ->
                    let
                        ( pageModel, pageCommands ) =
                            Login.init model.navKey url
                    in
                    ( LoginPage pageModel, Nothing, Cmd.map LoginPageMsg pageCommands )
    in
    ( { model | page = currentPage, activeItemsPage = activeItemsPage }
    , Cmd.batch [ existingCommands, mappedPageCommands ]
    )


{-| This method decodes URL and initializes view depending on URL. This is basically frontend routing.
This function sets model.page to right Page Type.
-}
urlUpdate : Url -> Model -> ( Model, Cmd Msg )
urlUpdate url model =
    let
        --TODO: remove logging in production
        _ =
            Debug.log "MAIN urlUpdate URL" url

        _ =
            Debug.log "MAIN urlUpdate Decoding Url" (decode url)
    in
    case decode url of
        Nothing ->
            ( { model | page = NotFoundPage }, Cmd.none )

        Just route ->
            case route of
                Route.Greeting ->
                    let
                        ( pageModel, pageCommands ) =
                            Greeting.init
                    in
                    ( { model | page = GreetingPage pageModel }, Cmd.map GreetingPageMsg pageCommands )

                Route.About ->
                    ( { model | page = AboutPage }, Cmd.none )

                Route.Items page ->
                    let
                        pageNumber =
                            case page of
                                Just pageNum ->
                                    pageNum

                                Nothing ->
                                    0

                        ( pageModel, pageCommands ) =
                            Items.init pageNumber

                        _ =
                            Debug.log "Items page number: " pageNumber
                    in
                    ( { model
                        | page = ListItemsPage pageModel
                        , activeItemsPage = Just pageNumber
                      }
                    , Cmd.map ListItemsPageMsg pageCommands
                    )

                Route.NewItem ->
                    let
                        ( pageModel, pageCommands ) =
                            NewItem.init model.navKey (getActiveItemsPage model.activeItemsPage)
                    in
                    ( { model | page = NewItemPage pageModel }, Cmd.map NewItemPageMsg pageCommands )

                Route.Item itemId ->
                    let
                        ( pageModel, pageCommands ) =
                            EditItem.init itemId model.navKey (getActiveItemsPage model.activeItemsPage)
                    in
                    ( { model | page = ItemPage pageModel }, Cmd.map ItemPageMsg pageCommands )

                Route.Login ->
                    let
                        ( pageModel, pageCommands ) =
                            Login.init model.navKey url
                    in
                    ( { model | page = LoginPage pageModel }, Cmd.map LoginPageMsg pageCommands )

                _ ->
                    ( model, Cmd.none )


{-| This function handles every change in model and calls appropriate update function of current page.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        --TODO: remove logging in production
        _ =
            Debug.log "MAIN update Msg" msg

        _ =
            Debug.log "MAIN update Model" model
    in
    case ( msg, model.page ) of
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        ( UrlChanged url, _ ) ->
            urlUpdate url model

        ( NavMsg state, _ ) ->
            ( { model | navState = state }
            , Cmd.none
            )

        ------- Page specific update functions
        ( GreetingPageMsg subMsg, GreetingPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    Greeting.update subMsg pageModel
            in
            ( { model | page = GreetingPage updatedPageModel }
            , Cmd.map GreetingPageMsg updatedCmd
            )

        ( ListItemsPageMsg subMsg, ListItemsPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    Items.update subMsg pageModel
            in
            ( { model | page = ListItemsPage updatedPageModel }
            , Cmd.map ListItemsPageMsg updatedCmd
            )

        ( NewItemPageMsg subMsg, NewItemPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    NewItem.update subMsg pageModel
            in
            ( { model | page = NewItemPage updatedPageModel }
            , Cmd.map NewItemPageMsg updatedCmd
            )

        ( ItemPageMsg subMsg, ItemPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    EditItem.update subMsg pageModel
            in
            ( { model | page = ItemPage updatedPageModel }
            , Cmd.map ItemPageMsg updatedCmd
            )

        ( LoginPageMsg subMsg, LoginPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    Login.update subMsg pageModel
            in
            ( { model | page = LoginPage updatedPageModel }
            , Cmd.map LoginPageMsg updatedCmd
            )

        -- This branch handles all combinations of Msg and Page type that are not possible
        ( _, _ ) ->
            ( model, Cmd.none )



--    __      _______ ________          __
--    \ \    / /_   _|  ____\ \        / /
--     \ \  / /  | | | |__   \ \  /\  / /
--      \ \/ /   | | |  __|   \ \/  \/ /
--       \  /   _| |_| |____   \  /\  /
--        \/   |_____|______|   \/  \/
--


view : Model -> Document Msg
view model =
    { title = "VG Primer App"
    , body =
        [ div []
            [ menu model
            , currentView model
            ]
        ]
    }


menu : Model -> Html Msg
menu model =
    NavBar.config NavMsg
        |> NavBar.withAnimation
        |> NavBar.container
        |> NavBar.brand [ href "/" ] [ text "Elm Stopwatch" ]
        |> NavBar.items
            [ NavBar.itemLink [ href "/items" ] [ text "Items" ]
            , NavBar.itemLink [ href "/about" ] [ text "About" ]
            , NavBar.itemLink [ href "/login" ] [ text "Login" ]
            ]
        |> NavBar.view model.navState


currentView : Model -> Html Msg
currentView model =
    case model.page of
        NotFoundPage ->
            notFoundView

        GreetingPage pageModel ->
            Greeting.view pageModel
                |> Html.map GreetingPageMsg

        AboutPage ->
            aboutView

        ListItemsPage itemsModel ->
            Items.view itemsModel
                |> Html.map ListItemsPageMsg

        NewItemPage itemsModel ->
            NewItem.view itemsModel
                |> Html.map NewItemPageMsg

        ItemPage itemsModel ->
            EditItem.view itemsModel
                |> Html.map ItemPageMsg

        LoginPage loginModel ->
            Login.view loginModel
                |> Html.map LoginPageMsg


notFoundView : Html msg
notFoundView =
    h3 [] [ text "Oops! The page you requested was not found!" ]


aboutView : Html Msg
aboutView =
    div []
        [ h1 [] [ text "About" ]
        , text "TODO: About VG soft and link to repo"
        ]
