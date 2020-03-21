module Route exposing (Route(..), decode, parseUrl, pushUrl, routeParser)

import Browser.Navigation as Nav
import Pages.Items.Item as Item exposing (ItemId)
import Url exposing (Url)
import Url.Parser as UrlParser exposing (..)
import Url.Parser.Query as Query


type Route
    = NotFound
    | Greeting
    | Items (Maybe Int)
    | NewItem
    | Item ItemId
    | About
    | Login


parseUrl : Url -> Route
parseUrl url =
    case parse routeParser url of
        Just route ->
            route

        Nothing ->
            NotFound


routeParser : Parser (Route -> a) a
routeParser =
    UrlParser.oneOf
        [ UrlParser.map Greeting top
        , UrlParser.map About (s "about")
        , UrlParser.map Login (s "login")
        , UrlParser.map Items (s "items" <?> Query.int "page")
        , UrlParser.map NewItem (s "items-new")
        , UrlParser.map Item (s "items" </> Item.idParser)
        ]


decode : Url -> Maybe Route
decode url =
    UrlParser.parse routeParser url


pushUrl : Route -> Nav.Key -> Cmd msg
pushUrl route navKey =
    routeToString route
        |> Nav.pushUrl navKey


routeToString : Route -> String
routeToString route =
    let
        _ =
            Debug.log "Route.routeToString" route
    in
    case route of
        NotFound ->
            "/not-found"

        Greeting ->
            "/greeting"

        Items page ->
            case page of
                Just pageNumber ->
                    "/items?page=" ++ String.fromInt pageNumber

                Nothing ->
                    "/items"

        NewItem ->
            "/items-new"

        Item itemId ->
            "/items/" ++ Item.idToString itemId

        About ->
            "/about"

        Login ->
            "/login"
