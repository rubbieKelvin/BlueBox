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

    Svg{id: svg}

    Image{
        anchors.centerIn: parent
        height: root.width-padding
        width: root.width-padding
        source: svg.uri
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        hoverEnabled: root.enabled
        onEntered: {}
        onExited: {}
        onWheel: {}
        onClicked: click()
    }
}


