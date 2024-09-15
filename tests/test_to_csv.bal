import ballerina/http;
import ballerina/test;
import ballerina/io;

@test:Config {
    dataProvider: valueProvider
}
function testJsonToCsv(string fileName, string expectedValue) returns error? {
    return validateCsvConversion(fileName, expectedValue);
}

function valueProvider() returns [string, string][] {
    return [
        ["values_1.json", "8;9;10;11;12;13;#"],
        ["values_2.json", "11;12;1;14;15;16;17;18;19;20;21;22;23;24;#"],
        ["values_5.json", "1;2;3;4;5;7;6;1;1;1;11;12;13;14;15;16;17;18;19;20;21;#"],
        ["values_8.json", "7;8;9;10;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28;29;30;#"]
    ];
}

function validateCsvConversion(string fileName, string expectedValue) returns error? {
    json value = check (check io:fileReadJson(string `tests/resources/values/${fileName}`)).ensureType();
    http:Client httpClient = check new ("localhost:9090");
    string csvValue = check httpClient->/fromJson.post(value);
    test:assertEquals(csvValue, expectedValue);
}
