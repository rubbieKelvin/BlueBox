import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.11

Rectangle {
    id: root
    width: 25
    height: 25

    property alias source: svg.source
    property int padding: 5
    property alias accent: svg.color
    
    signal click()

    Image{
        id: img
        anchors.centerIn: parent
        height: root.width-padding
        width: root.width-padding
        source: svg.uri
    }

    Svg{
        id: svg
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: {}
        onExited: {}
        onWheel: {}
        onClicked: click()
    }
}


