import ballerina/http;
import ballerina/lang.regexp;

type InputData record {|
    json[] definitions;
    string csvContent;
|};

service / on new http:Listener(9090) {
    resource function post toJson(InputData input) returns json|error {
        string[] csvArray = from string item in regexp:split(re `;`, input.csvContent) select item.trim();
        Field result = check generateValues(input.definitions, csvArray, 0);
        return result.value.toJson();
    }

    resource function post fromJson(map<anydata> input) returns string|error {
        return check toCsvData(input) + TERMINATOR;
    }
}
