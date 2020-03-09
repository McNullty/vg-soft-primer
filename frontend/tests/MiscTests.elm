module MiscTests exposing (..)

import Expect
import Pages.Items.ListItems exposing (pagingData)
import Test exposing (Test, describe, test)

suite : Test
suite =
    describe "Miscellaneous tests"
        [ describe "Testing function pagingData"
            [ test "when empty string" <|
                \_ ->
                    let
                        expected = [ 1, 2, 3, 4 ]
                        numberOfPages = 4
                    in
                        Expect.equal  expected (pagingData numberOfPages)
            ]
        ]
