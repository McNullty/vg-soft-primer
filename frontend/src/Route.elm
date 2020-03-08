module Route exposing (Route(..), parseUrl, routeParser, pushUrl, decode)

import Browser.Navigation as Nav
import Pages.Items.Item as Item exposing (ItemId)
import Url exposing (Url)
import Url.Parser as UrlParser exposing (..)

type Route
    = NotFound
    | Greeting
    | Items
    | NewItem
    | Item ItemId
    | About

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
        , UrlParser.map Items (s "items")
        , UrlParser.map NewItem (s "items" </> s "new")
        , UrlParser.map Item (s "items" </> Item.idParser)
        ]


decode : Url -> Maybe Route
decode url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
    |> UrlParser.parse routeParser



pushUrl : Route -> Nav.Key -> Cmd msg
pushUrl route navKey =
    routeToString route
        |> Nav.pushUrl navKey


routeToString : Route -> String
routeToString route =
    case route of
        NotFound ->
            "#not-found"

        Greeting ->
            "#greeting"

        Items ->
            "#items"

        NewItem ->
            "#items/new"

        Item itemId ->
            "#items/" ++ (Item.idToString itemId)

        About ->
            "#about"
