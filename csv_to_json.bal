import ballerina/lang.regexp;

type Field record {
    int index;
    string fieldName;
    anydata value;
};

function generateValues(json[] definitions, string[] csvData, int index) returns Field|error {
    int id = index;
    map<anydata> valueMap = {};
    foreach json fieldValue in definitions {
        if fieldValue == "" {
            id += 1;
            continue;
        }
        Field fieldData = fieldValue is string ? check handleAttribute(valueMap, fieldValue, csvData[id].trim(), id) 
            : check handleArray(fieldValue, csvData, id, valueMap);
        id = fieldValue is string ? fieldData.index + 1 : fieldData.index;
        valueMap[fieldData.fieldName] = fieldData.value;
    }
    return {fieldName: "data", value: valueMap, index: id};
}

function handleArray(anydata fieldValue, string[] csvData,
                     int index, map<anydata> valueMap) returns Field|error {
    int id = index;
    anydata[] elements = [];
    record {} fieldData = check fieldValue.ensureType();
    int size;
    do {
        size = fieldData.hasKey("size") ? check int:fromString(fieldData["size"].toString()) : (<json[]>fieldData["definitions"]).length();
    } on fail {
        size = check int:fromString(valueMap[fieldData["size"].toString()].toString());
    }
    foreach int i in 0 ..< size {
        Field element = check generateValues(<json[]>fieldData["definitions"], csvData, id);
        elements[i] = element.value;
        id = element.index;
    }
    return handleAttribute(valueMap, fieldData.get("name").toString(), elements, id);
}

function handleAttribute(map<anydata> valueMap, string fieldValue,
                         anydata data, int index) returns Field|error {
    string[] fieldHierarchy = regexp:split(re `\.`, fieldValue);
    if fieldHierarchy.length() == 1 {
        return {index: index, fieldName: fieldValue, value: data};
    }
    Field attribute = check handleFieldHierarchy(fieldHierarchy, valueMap, data, index);
    return {index: index, fieldName: attribute.fieldName, value: (<map<anydata>>attribute.value)[attribute.fieldName]};
}

function handleFieldHierarchy(string[] fieldHierarchy, map<anydata> valueMap, 
                              anydata data, int index) returns Field|error {
    if valueMap.hasKey(fieldHierarchy[0]) {
        return {index: index, fieldName: fieldHierarchy[0], value: handleExistingKeys(fieldHierarchy, valueMap, valueMap, data, 0)};
    }
    return {index: index, fieldName: fieldHierarchy[0], value: getNestedFields(fieldHierarchy, {}, data, 0)};
}

function handleExistingKeys(string[] hierarchy, map<anydata> currentMap, map<anydata> valueMap,
                            anydata value, int i) returns map<anydata> {
    if currentMap.hasKey(hierarchy[i]) && currentMap.get(hierarchy[i]) is map<anydata> {
        currentMap[hierarchy[i]] = handleExistingKeys(hierarchy, <map<anydata>>currentMap[hierarchy[i]], valueMap, value, i + 1);
    } else {
        map<anydata> nestedFields = getNestedFields(hierarchy.slice(i, hierarchy.length()), {}, value, 0);
        foreach anydata item in nestedFields.keys() { //combine map values
            currentMap[item] = nestedFields[item];
        }
    }
    return currentMap;
}

function getNestedFields(string[] fieldHierarchy, map<anydata> nestedFields,
                         anydata data, int index) returns map<anydata> {
    nestedFields[fieldHierarchy[index]] = index == fieldHierarchy.length() - 1 ? data 
        : getNestedFields(fieldHierarchy, {}, data, index + 1);
    return nestedFields;
}

json[] definitions = [
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "context.status", // 00
    "dispense.active", // O
    "dispense.nbMotifs", // 26
    {
        "name": "libelles", 
        "size": "30",
        "definitions": [
            "libelle", // Je suis couvert par une garantie individuelle
            "codeMotif", // AAAAAA
            "nbType", // 01
            {
                "name": "type",
                "size": "2",
                "definitions": [
                    "code", // D911
                    "periodiciteTypeDispense", // empty
                    "nbJustificatifs", // 01
                    {
                    "name": "libelleJustificatif", // field in json 
                    "size": "4", // repeat 
                    "definitions": [
                        "libelle",  // -est quentin affichage de la demande de justif sur mev dsofjqifjqf
                        "typeCode", // DECL
                        "periodiciteTypeDispense",
                        "presenceCompagnie",
                        "presenceContrat",
                        "presenceDateEcheance",
                        "presenceAnienneSociete"
                    ]
                }
                ] // ignore the additional values        
            }
        ]
    }
];
