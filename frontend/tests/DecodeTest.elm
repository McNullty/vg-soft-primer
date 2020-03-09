module DecodeTest exposing (..)

import Expect exposing (Expectation)
import Pages.Items.Item as Item exposing (ItemId)
import Route exposing (Route(..), decode)
import Test exposing (..)
import Url exposing (Protocol(..), Url)

createUrl : String -> Url
createUrl path =
    { protocol = Http
    , host = "localhost"
    , port_ = Just 8000
    , path = path
    , query = Nothing
    , fragment = Nothing
    }

createUrlWithQuery : String -> String -> Url
createUrlWithQuery path query =
    { protocol = Http
    , host = "localhost"
    , port_ = Just 8000
    , path = path
    , query = Just query
    , fragment = Nothing
    }

suite : Test
suite =
    describe "Testing decode function"
        [ test "when empty string" <|
            \_ ->
                let
                    url = ""
                in
                Expect.equal (Just Greeting) <|
                   decode (createUrl url)
        , test "when path is 'items-new'" <|
            \_ ->
                let
                    url = "/items-new"
                in
                Expect.equal (Just NewItem) <|
                    decode (createUrl url)
        , test "when path is 'items'" <|
            \_ ->
                let
                    url = "/items"
                in
                Expect.equal (Just (Items Nothing)) <|
                    decode (createUrl url)
        , test "when path is 'items?page=1'" <|
            \_ ->
                let
                    url = "/items"
                    query = "page=1"
                in
                Expect.equal (Just (Items (Just 1))) <|
                    decode (createUrlWithQuery url query)
        , test "when path is 'items/bd7edd3c-802f-4e79-9377-b0ef0bb1a208'" <|
            \_ ->
                let
                    url = "/items/bd7edd3c-802f-4e79-9377-b0ef0bb1a208"
                in
                Expect.equal (Just (Item (Item.ItemId "bd7edd3c-802f-4e79-9377-b0ef0bb1a208"))) <|
                    decode (createUrl url)

        ]