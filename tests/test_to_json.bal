import ballerina/http;
import ballerina/io;
import ballerina/test;

@test:Config {
    dataProvider: recordDataProvider
}
function testJson(string definitionFile, string csvData, string expectedValueFile) returns error? {
    return validateJsonConversion(definitionFile, csvData, expectedValueFile);
}

function recordDataProvider() returns [string, string, string][] {
    return [
        ["definition_1.json", "1;2;3;4;5;6;7;8;9;10;11;12;13;", "values_1.json"],
        ["definition_2.json", "1;2;3;4;5;6;7;8;9;10;11;12;1;14;15;16;17;18;19;20;21;22;23;24", "values_2.json"],
        ["definition_3.json", "1;2;3;4;5;6;7;8;9;10;11;12;13", "values_3.json"],
        ["definition_4.json", "1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28;29;30;31;32;33;34;35;36;37;38", "values_4.json"],
        ["definition_5.json", "1;2;3;4;5;6;7;1;1;1;11;12;13;14;15;16;17;18;19;20;21", "values_5.json"],
        ["definition_6.json", "1;2;3;4;5;6;7;1;1;1;11;12;1;1;1;16;17;18;19;20;21;22;23;24", "values_6.json"],
        ["definition_7.json", "1;2;3;4;5;6;7", "values_7.json"],
        ["definition_8.json", "1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28;29;30;31;32;33;34;35;36;37;38;39;", "values_8.json"],
        ["definition_9.json", "1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;1;1;1;1;1;1;23;24;25;1;1;1;1;1;31;32;33;34;35", "values_9.json"]
    ];
}

function validateJsonConversion(string definitionFile, string csvData, string expectedValueFile) returns error? {
    json[] definitions = 
        check (check io:fileReadJson(string `tests/resources/definitions/${definitionFile}`)).ensureType();
    http:Client httpClient = check new (url = "localhost:9090");
    json jsonData = check httpClient->/toJson.post({
        definitions: definitions,
        csvContent: csvData
    });
    json expectedJsonData = check io:fileReadJson(string `tests/resources/values/${expectedValueFile}`);
    test:assertEquals(jsonData, expectedJsonData);
}
