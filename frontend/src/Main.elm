module Main exposing (..)

import Bootstrap.Navbar as NavBar
import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import EditItem
import Html exposing (Html, div, h1, h3, text)
import Html.Attributes exposing (href)
import Item
import Items
import NewItem
import Route exposing (Route)
import Greeting
import Url exposing (Url)
import Url.Parser as UrlParser exposing ((</>), Parser, s, top)

type alias Model =
    { route : Route
    , page : Page
    , navKey : Nav.Key
    , navState : NavBar.State
    }


type Page
    = NotFoundPage
    | GreetingPage Greeting.Model
    | ItemsPage Items.Model
    | NewItemPage NewItem.Model
    | ItemPage EditItem.Model
    | AboutPage



type Msg
    = GreetingMsg Greeting.Msg
    | ItemsMsg Items.Msg
    | NewItemPageMsg NewItem.Msg
    | ItemPageMsg EditItem.Msg
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



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ NavBar.subscriptions model.navState NavMsg
        ]


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    let
        ( navState, navCmd ) =
            NavBar.initialState NavMsg

        ( model, urlCmd ) =
            urlUpdate url
                { route = Route.parseUrl url
                , page = NotFoundPage
                , navKey = navKey
                , navState = navState
                }
    in
    initCurrentPage ( model, Cmd.batch [ urlCmd, navCmd ] )

routeParser : Parser (Route -> a) a
routeParser =
    UrlParser.oneOf
        [ UrlParser.map Route.Greeting top
        , UrlParser.map Route.About (s "about")
        , UrlParser.map Route.Items (s "items")
        , UrlParser.map Route.NewItem (s "items" </> s "new")
        , UrlParser.map Route.Item (s "items" </> Item.idParser)
        ]


urlUpdate : Url -> Model -> ( Model, Cmd Msg )
urlUpdate url model =
    case decode url of
        Nothing ->
            ( { model | page = NotFoundPage }, Cmd.none )

        Just route ->
            case route of
                Route.Greeting ->
                    let
                        ( pageModel, pageCmds ) =
                            Greeting.init
                    in
                    ( { model | page = (GreetingPage pageModel) }, Cmd.map GreetingMsg pageCmds)

                Route.About ->
                    ( { model | page = AboutPage }, Cmd.none)

                Route.Items ->
                    let
                        ( pageModel, pageCmds ) =
                            Items.init
                    in
                    ( { model | page = (ItemsPage pageModel) }, Cmd.map ItemsMsg pageCmds)

                Route.NewItem ->
                    let
                        ( pageModel, pageCmds ) =
                            NewItem.init model.navKey
                    in
                    ( { model | page = (NewItemPage pageModel) }, Cmd.map NewItemPageMsg pageCmds )

                Route.Item itemId ->
                    let
                        ( pageModel, pageCmds ) =
                            EditItem.init itemId model.navKey
                    in
                    ( { model | page = (ItemPage pageModel) }, Cmd.map ItemPageMsg pageCmds )

                _ ->
                    (model, Cmd.none)


decode : Url -> Maybe Route
decode url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
    |> UrlParser.parse routeParser



initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, existingCmds ) =
    let
        ( currentPage, mappedPageCmds ) =
            case model.route of
                Route.NotFound ->
                    ( NotFoundPage, Cmd.none )

                Route.Greeting ->
                    let
                        ( pageModel, pageCmds ) =
                            Greeting.init
                    in
                    ( GreetingPage pageModel, Cmd.map GreetingMsg pageCmds )

                Route.Items ->
                    let
                        ( pageModel, pageCmds ) =
                            Items.init
                    in
                    ( ItemsPage pageModel, Cmd.map ItemsMsg pageCmds )

                Route.NewItem ->
                    let
                        ( pageModel, pageCmds ) =
                            NewItem.init model.navKey
                    in
                    ( NewItemPage pageModel, Cmd.map NewItemPageMsg pageCmds )

                Route.Item itemId ->
                    let
                        ( pageModel, pageCmds ) =
                            EditItem.init itemId model.navKey
                    in
                    ( ItemPage pageModel, Cmd.map ItemPageMsg pageCmds)

                Route.About ->
                    ( AboutPage, Cmd.none )

    in
    ( { model | page = currentPage }
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        --TODO: remove logging in production
        _ = Debug.log "MAIN update Msg: " msg
        _ = Debug.log "MAIN update Model: " model
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

        ( NavMsg state, _) ->
            ( { model | navState = state }
            , Cmd.none
            )

        ( GreetingMsg subMsg, GreetingPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    Greeting.update subMsg pageModel
            in
            ( { model | page = GreetingPage updatedPageModel }
            , Cmd.map GreetingMsg updatedCmd
            )

        ( ItemsMsg subMsg, ItemsPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    Items.update subMsg pageModel
            in
            ( { model | page = ItemsPage updatedPageModel }
            , Cmd.map ItemsMsg updatedCmd
            )

        ( NewItemPageMsg subMsg, NewItemPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    NewItem.update subMsg pageModel
            in
            ( { model | page = NewItemPage updatedPageModel }
            , Cmd.map NewItemPageMsg updatedCmd
            )

        ( ItemPageMsg subMsg, ItemPage pageModel) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    EditItem.update subMsg pageModel
            in
            ( { model | page = ItemPage updatedPageModel }
            , Cmd.map ItemPageMsg updatedCmd
            )

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
            , currentView model ]
        ]
    }

menu : Model -> Html Msg
menu model =
    NavBar.config NavMsg
        |> NavBar.withAnimation
        |> NavBar.container
        |> NavBar.brand [ href "#" ] [ text "Elm Stopwatch" ]
        |> NavBar.items
            [ NavBar.itemLink [ href "#items" ] [ text "Items" ]
            , NavBar.itemLink [ href "#about" ] [ text "About" ]
            ]
        |> NavBar.view model.navState

currentView : Model -> Html Msg
currentView model =
    case model.page of
        NotFoundPage ->
            notFoundView

        GreetingPage pageModel ->
            Greeting.view pageModel
                |> Html.map GreetingMsg

        AboutPage ->
            aboutView

        ItemsPage itemsModel ->
            Items.view itemsModel
                |> Html.map ItemsMsg

        NewItemPage itemsModel ->
            NewItem.view itemsModel
                |> Html.map NewItemPageMsg

        ItemPage itemsModel ->
            EditItem.view itemsModel
                |> Html.map ItemPageMsg

notFoundView : Html msg
notFoundView =
    h3 [] [ text "Oops! The page you requested was not found!" ]

aboutView : Html Msg
aboutView  =
    div []
        [ h1 [] [ text "About" ]
        , text "TODO: About VG soft and link to repo"
        ]