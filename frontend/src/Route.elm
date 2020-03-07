module Route exposing (Route(..), parseUrl, pushUrl)

import Browser.Navigation as Nav
import Pages.Items.Item as Item exposing (ItemId)
import Url exposing (Url)
import Url.Parser exposing (..)

type Route
    = NotFound
    | Greeting
    | Items
    | NewItem
    | Item ItemId
    | About

parseUrl : Url -> Route
parseUrl url =
    case parse matchRoute url of
        Just route ->
            route

        Nothing ->
            NotFound

-- TODO: Check if this method is duplicate of Main.routeParser
matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map Greeting top
        ]


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
