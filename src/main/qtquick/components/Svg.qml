import QtQuick 2.15


QtObject {
    id: root
    property string color: "#000000"
    property string source: "<svg></svg>"
    property string uri: ""

    
    readonly property string placeholder: "black"

    function _replacestring(string, value, replacement){
        while (true) {
            if (string.search(value) !== -1){
                string = string.replace(value, replacement);
            }else {
                break
            }
        }
        return string;
    }
    
    onSourceChanged: {
        let source_clone = source;
        source_clone = _replacestring(source_clone, placeholder, color)
        uri = "data:image/svg+xml;utf8, "+source_clone
    }

    onColorChanged: {
        let source_clone = source;
        source_clone = _replacestring(source_clone, placeholder, color)
        uri = "data:image/svg+xml;utf8, "+source_clone
    }
    
}
