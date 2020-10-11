import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.11
import QtMultimedia 5.15

Rectangle {
    id: root
    width: 200
    height: 600
    color: "transparent"

    property int fontSize: 12
    property alias model: listView.model

    
}
