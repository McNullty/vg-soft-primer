module ItemsHttpClientTest exposing (..)

import Dict exposing (Dict)
import Expect
import Http exposing (Metadata, Response(..))
import ItemsHttpClient exposing (FetchingResults(..))
import Json.Decode as Decode exposing (Error(..))
import Pages.Items.Item exposing (Item, ItemId(..))
import Pages.Items.ListItems as ListItems exposing (Msg(..), convertToMsg)
import RemoteData exposing (WebData)
import Test exposing (Test, describe, test)

suite : Test
suite =
    describe "Test suit for ItemsHttpClient"
        [ describe "Testing only body parser"
            [ test "when body is returned" <|
                \_ ->
                    let
                        body = createBody

                        result = Decode.decodeString ItemsHttpClient.itemsResponseDecoder body

                        expected = createExpectedResultBody
                    in
                        Expect.equal expected (result)
            ]
        , describe "Testing body and metadata parser"
            [ test "when body and metadata are returned with status 200" <|
                \_ ->
                    let
                        metadata = createMetadata
                        body = createBody

                        result = ItemsHttpClient.processMetadataAndBody metadata body

                        expected = createExpectedResult
                    in
                        Expect.equal expected (result)
            ]
        , describe "Testing customFromResult function"
            [ test "when body and metadata are returned with status 200" <|
                \_ ->
                    let
                        metadata = createMetadata
                        body = createBody


                        result =
                            GoodStatus_ metadata body
                                |> ItemsHttpClient.customResponseToResult
                                |> ItemsHttpClient.customResultToMessage convertToMsg

                        expected = createExpectedMsg
                    in
                        Expect.equal expected (result)
            ]
        ]

---- Util methods

createMetadata : Metadata
createMetadata =
    { url = "http://localhost:8080/api/items?page=0"
    , statusCode = 200
    , statusText = ""
    , headers = Dict.fromList
        [ ("cache-control","max-age=2592000")
        , ("connection","keep-alive")
        , ("content-type","application/hal+json")
        , ("date","Thu, 12 Mar 2020 10:09:35 GMT")
        , ("etag","\"dc8b09bc90ed194d61b3111aa371e9dc\"")
        , ("keep-alive","timeout=60")
        , ("transfer-encoding","chunked")] }

createExpectedResultBody : Result Decode.Error ItemsHttpClient.ItemsResponseBody
createExpectedResultBody =
    Result.Ok { items = [{ description = "Description for first item", id = ItemId "ddc56cf6-1736-4f8d-bfb0-8330cd3d3654", name = "TestItem1" },{ description = "Description for second item", id = ItemId "dacf77b6-5e70-439a-8e3b-d2da974d73ff", name = "TestItem2" },{ description = "Description for 3. item", id = ItemId "21fb97c7-53d4-4395-bc1e-d3e085f396a2", name = "TestItem3" },{ description = "Description for 4. item", id = ItemId "8146f000-ff27-40ed-865c-f58889a0f997", name = "TestItem4" },{ description = "Description for 5. item", id = ItemId "107d3693-0733-409c-9617-f50798cb4c4e", name = "TestItem5" },{ description = "Description for 6. item", id = ItemId "80e85bb1-0647-4445-b586-01900c0d5b34", name = "TestItem6" },{ description = "Description for 7. item", id = ItemId "6406e01b-d5c8-4c40-b551-cf49b3379599", name = "TestItem7" },{ description = "Description for 8. item", id = ItemId "b8c05299-2f0e-4acb-b6d3-27494fb4f404", name = "TestItem8" },{ description = "Description for 9. item", id = ItemId "54f3cc02-a7fd-4ca7-b732-e1f3e27c3984", name = "TestItem9" },{ description = "Description for 10. item", id = ItemId "4b66ed66-4610-4454-af38-a15bdd5c5844", name = "TestItem10" },{ description = "Description for 11. item", id = ItemId "461cfa07-f2c4-4d1e-ada9-5c592b461d17", name = "TestItem11" },{ description = "Description for 12. item", id = ItemId "00fadde0-8b5f-49d3-b6fd-d0f44cf065ed", name = "TestItem12" },{ description = "Description for 13. item", id = ItemId "de718ba8-520c-4199-a819-1674e5582bbe", name = "TestItem13" },{ description = "Description for 14. item", id = ItemId "b1e701fe-7188-47d2-8654-7808ced2f6a7", name = "TestItem14" },{ description = "Description for 15. item", id = ItemId "86aa8336-6bd0-440a-97fe-b51e1b9f6f9e", name = "TestItem15" },{ description = "Description for 16. item", id = ItemId "6d952799-5601-432a-9947-adad57bb54db", name = "TestItem16" },{ description = "Description for 17. item", id = ItemId "365aefff-1fb6-4b3e-84a9-18b1a256b76b", name = "TestItem17" },{ description = "Description for 18. item", id = ItemId "0353f12a-6100-49c4-9c13-262c6efe5019", name = "TestItem18" },{ description = "Description for 19. item", id = ItemId "00a9d79c-8642-4f3c-992c-5feff24da334", name = "TestItem19" },{ description = "Description for 20. item", id = ItemId "76cdfb25-3fd2-4f48-b16e-539968d22bba", name = "TestItem20" }]
              , page = { number = 0, size = 20, totalElements = 50, totalPages = 3 }
              }

createBody : String
createBody =
    "{\"_embedded\":{\"items\":[{\"id\":\"ddc56cf6-1736-4f8d-bfb0-8330cd3d3654\",\"name\":\"TestItem1\",\"description\":\"Description for first item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/ddc56cf6-1736-4f8d-bfb0-8330cd3d3654\"}}},{\"id\":\"dacf77b6-5e70-439a-8e3b-d2da974d73ff\",\"name\":\"TestItem2\",\"description\":\"Description for second item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/dacf77b6-5e70-439a-8e3b-d2da974d73ff\"}}},{\"id\":\"21fb97c7-53d4-4395-bc1e-d3e085f396a2\",\"name\":\"TestItem3\",\"description\":\"Description for 3. item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/21fb97c7-53d4-4395-bc1e-d3e085f396a2\"}}},{\"id\":\"8146f000-ff27-40ed-865c-f58889a0f997\",\"name\":\"TestItem4\",\"description\":\"Description for 4. item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/8146f000-ff27-40ed-865c-f58889a0f997\"}}},{\"id\":\"107d3693-0733-409c-9617-f50798cb4c4e\",\"name\":\"TestItem5\",\"description\":\"Description for 5. item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/107d3693-0733-409c-9617-f50798cb4c4e\"}}},{\"id\":\"80e85bb1-0647-4445-b586-01900c0d5b34\",\"name\":\"TestItem6\",\"description\":\"Description for 6. item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/80e85bb1-0647-4445-b586-01900c0d5b34\"}}},{\"id\":\"6406e01b-d5c8-4c40-b551-cf49b3379599\",\"name\":\"TestItem7\",\"description\":\"Description for 7. item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/6406e01b-d5c8-4c40-b551-cf49b3379599\"}}},{\"id\":\"b8c05299-2f0e-4acb-b6d3-27494fb4f404\",\"name\":\"TestItem8\",\"description\":\"Description for 8. item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/b8c05299-2f0e-4acb-b6d3-27494fb4f404\"}}},{\"id\":\"54f3cc02-a7fd-4ca7-b732-e1f3e27c3984\",\"name\":\"TestItem9\",\"description\":\"Description for 9. item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/54f3cc02-a7fd-4ca7-b732-e1f3e27c3984\"}}},{\"id\":\"4b66ed66-4610-4454-af38-a15bdd5c5844\",\"name\":\"TestItem10\",\"description\":\"Description for 10. item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/4b66ed66-4610-4454-af38-a15bdd5c5844\"}}},{\"id\":\"461cfa07-f2c4-4d1e-ada9-5c592b461d17\",\"name\":\"TestItem11\",\"description\":\"Description for 11. item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/461cfa07-f2c4-4d1e-ada9-5c592b461d17\"}}},{\"id\":\"00fadde0-8b5f-49d3-b6fd-d0f44cf065ed\",\"name\":\"TestItem12\",\"description\":\"Description for 12. item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/00fadde0-8b5f-49d3-b6fd-d0f44cf065ed\"}}},{\"id\":\"de718ba8-520c-4199-a819-1674e5582bbe\",\"name\":\"TestItem13\",\"description\":\"Description for 13. item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/de718ba8-520c-4199-a819-1674e5582bbe\"}}},{\"id\":\"b1e701fe-7188-47d2-8654-7808ced2f6a7\",\"name\":\"TestItem14\",\"description\":\"Description for 14. item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/b1e701fe-7188-47d2-8654-7808ced2f6a7\"}}},{\"id\":\"86aa8336-6bd0-440a-97fe-b51e1b9f6f9e\",\"name\":\"TestItem15\",\"description\":\"Description for 15. item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/86aa8336-6bd0-440a-97fe-b51e1b9f6f9e\"}}},{\"id\":\"6d952799-5601-432a-9947-adad57bb54db\",\"name\":\"TestItem16\",\"description\":\"Description for 16. item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/6d952799-5601-432a-9947-adad57bb54db\"}}},{\"id\":\"365aefff-1fb6-4b3e-84a9-18b1a256b76b\",\"name\":\"TestItem17\",\"description\":\"Description for 17. item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/365aefff-1fb6-4b3e-84a9-18b1a256b76b\"}}},{\"id\":\"0353f12a-6100-49c4-9c13-262c6efe5019\",\"name\":\"TestItem18\",\"description\":\"Description for 18. item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/0353f12a-6100-49c4-9c13-262c6efe5019\"}}},{\"id\":\"00a9d79c-8642-4f3c-992c-5feff24da334\",\"name\":\"TestItem19\",\"description\":\"Description for 19. item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/00a9d79c-8642-4f3c-992c-5feff24da334\"}}},{\"id\":\"76cdfb25-3fd2-4f48-b16e-539968d22bba\",\"name\":\"TestItem20\",\"description\":\"Description for 20. item\",\"_links\":{\"self\":{\"href\":\"http://localhost:8080/api/items/76cdfb25-3fd2-4f48-b16e-539968d22bba\"}}}]},\"_links\":{\"first\":{\"href\":\"http://localhost:8080/api/items?page=0&size=20\"},\"self\":{\"href\":\"http://localhost:8080/api/items?page=0&size=20\"},\"next\":{\"href\":\"http://localhost:8080/api/items?page=1&size=20\"},\"last\":{\"href\":\"http://localhost:8080/api/items?page=2&size=20\"}},\"page\":{\"size\":20,\"totalElements\":50,\"totalPages\":3,\"number\":0}}"


createExpectedResult : Result Decode.Error ItemsHttpClient.ItemsResponse
createExpectedResult =
    Result.Ok { body = { items = [{ description = "Description for first item", id = ItemId "ddc56cf6-1736-4f8d-bfb0-8330cd3d3654", name = "TestItem1" },{ description = "Description for second item", id = ItemId "dacf77b6-5e70-439a-8e3b-d2da974d73ff", name = "TestItem2" },{ description = "Description for 3. item", id = ItemId "21fb97c7-53d4-4395-bc1e-d3e085f396a2", name = "TestItem3" },{ description = "Description for 4. item", id = ItemId "8146f000-ff27-40ed-865c-f58889a0f997", name = "TestItem4" },{ description = "Description for 5. item", id = ItemId "107d3693-0733-409c-9617-f50798cb4c4e", name = "TestItem5" },{ description = "Description for 6. item", id = ItemId "80e85bb1-0647-4445-b586-01900c0d5b34", name = "TestItem6" },{ description = "Description for 7. item", id = ItemId "6406e01b-d5c8-4c40-b551-cf49b3379599", name = "TestItem7" },{ description = "Description for 8. item", id = ItemId "b8c05299-2f0e-4acb-b6d3-27494fb4f404", name = "TestItem8" },{ description = "Description for 9. item", id = ItemId "54f3cc02-a7fd-4ca7-b732-e1f3e27c3984", name = "TestItem9" },{ description = "Description for 10. item", id = ItemId "4b66ed66-4610-4454-af38-a15bdd5c5844", name = "TestItem10" },{ description = "Description for 11. item", id = ItemId "461cfa07-f2c4-4d1e-ada9-5c592b461d17", name = "TestItem11" },{ description = "Description for 12. item", id = ItemId "00fadde0-8b5f-49d3-b6fd-d0f44cf065ed", name = "TestItem12" },{ description = "Description for 13. item", id = ItemId "de718ba8-520c-4199-a819-1674e5582bbe", name = "TestItem13" },{ description = "Description for 14. item", id = ItemId "b1e701fe-7188-47d2-8654-7808ced2f6a7", name = "TestItem14" },{ description = "Description for 15. item", id = ItemId "86aa8336-6bd0-440a-97fe-b51e1b9f6f9e", name = "TestItem15" },{ description = "Description for 16. item", id = ItemId "6d952799-5601-432a-9947-adad57bb54db", name = "TestItem16" },{ description = "Description for 17. item", id = ItemId "365aefff-1fb6-4b3e-84a9-18b1a256b76b", name = "TestItem17" },{ description = "Description for 18. item", id = ItemId "0353f12a-6100-49c4-9c13-262c6efe5019", name = "TestItem18" },{ description = "Description for 19. item", id = ItemId "00a9d79c-8642-4f3c-992c-5feff24da334", name = "TestItem19" },{ description = "Description for 20. item", id = ItemId "76cdfb25-3fd2-4f48-b16e-539968d22bba", name = "TestItem20" }]
                       , page = { number = 0, size = 20, totalElements = 50, totalPages = 3 }
                       }
              , etag = Just "\"dc8b09bc90ed194d61b3111aa371e9dc\""
              }

itemsResponseFromResult : (Result Decode.Error ItemsHttpClient.ItemsResponse) -> ItemsHttpClient.ItemsResponse
itemsResponseFromResult result =
    case result of
        Result.Ok value -> value
        _ -> { body = { items = []
                      , page = { number = 0, size = 20, totalElements = 50, totalPages = 3 }
                      }
             , etag = Nothing
             }

createExpectedMsg : ListItems.Msg
createExpectedMsg =
    itemsResponseFromResult createExpectedResult
        |> RemoteData.Success
        |> ItemsReceived
        |> ResponseReceived