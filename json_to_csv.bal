const string DELIMITER = ";";
const string TERMINATOR = "#";

function toCsvData(anydata attribute) returns string|error {
    string data = "";
    if attribute is anydata[] {
        foreach int i in 0 ..< attribute.length() {
            data += check toCsvData(attribute[i]);
        }
    } else if attribute is map<anydata> {
        foreach anydata keyValue in attribute.keys() {
            data += check toCsvData(attribute[keyValue.toString()]);
        }
    } else {
        data += attribute.toString() + DELIMITER;
    }
    return data;
}
