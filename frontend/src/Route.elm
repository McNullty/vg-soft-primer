module Route exposing (Route(..), parseUrl, pushUrl)

import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Parser exposing (..)

type Route
    = NotFound
    | Greeting
    | Items
    | NewItem
    | About

parseUrl : Url -> Route
parseUrl url =
    case parse matchRoute url of
        Just route ->
            route

        Nothing ->
            NotFound

matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map Greeting top
        ]


-- TODO: Fix this method, remove it or use it
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

        About ->
            "#about"
