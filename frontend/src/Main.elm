module Main exposing (..)

import Bootstrap.Navbar as NavBar
import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Html exposing (Html, div, h1, h3, text)
import Html.Attributes exposing (href)
import Items
import Route exposing (Route)
import Greeting
import Url exposing (Url)
import Url.Parser as UrlParser exposing ((</>), Parser, s, top)


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

notFoundView : Html msg
notFoundView =
    h3 [] [ text "Oops! The page you requested was not found!" ]

aboutView : Html Msg
aboutView  =
    div []
        [ h1 [] [ text "About" ]
        , text "TODO: About VG soft and link to repo"
        ]

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
    | AboutPage



type Msg
    = GreetingMsg Greeting.Msg
    | ItemsMsg Items.Msg
    | LinkClicked UrlRequest
    | UrlChanged Url
    | NavMsg NavBar.State


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

                -- TODO: Add other routes
                Route.About ->
                    ( { model | page = AboutPage }, Cmd.none)

                Route.Items ->
                    let
                        ( itemsModel, itemsCmds ) =
                            Items.init
                    in
                    ( { model | page = (ItemsPage itemsModel) }, Cmd.map ItemsMsg itemsCmds)

                _ ->
                    (model, Cmd.none)

decode : Url -> Maybe Route
decode url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
    |> UrlParser.parse routeParser


routeParser : Parser (Route -> a) a
routeParser =
    UrlParser.oneOf
        [ UrlParser.map Route.Greeting top
        , UrlParser.map Route.About (s "about")
        , UrlParser.map Route.Items (s "items")
        ]

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

                Route.About ->
                    ( AboutPage, Cmd.none )

    in
    ( { model | page = currentPage }
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ = Debug.log "Msg: " msg
        _ = Debug.log "Model: " model
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

        ( _, _ ) ->
            ( model, Cmd.none )