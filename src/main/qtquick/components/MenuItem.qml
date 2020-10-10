import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 200
    height: 50
    radius: 10
    color: "transparent"

    property string highlightColor: "red"
    property bool highlighted: false
    property bool highlightable: true
    property alias text: label.text
    property alias source: svg.source
    property string textColor: "#000000"

    signal click()
    

    Rectangle {
        id: highlighter
        width: (highlighted) ? parent.width : 0
        height: parent.height
        color: highlightColor
        radius: root.radius
    }

    Image {
        id: image
        x: 10
        width: 15
        height: 15
        anchors.verticalCenterOffset: 0
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: svg.uri
    }

    Svg{
        id: svg
        color: (highlighted) ? "#ffffff":textColor
    }

    Label {
        id: label
        y: 15
        height: 33
        font.pixelSize: 12
        verticalAlignment: Text.AlignVCenter
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 46
        anchors.verticalCenter: parent.verticalCenter
        color: (highlighted) ? "#ffffff":textColor

    }
    
    
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: false
        onClicked: click()
    }
    
}

/*##^##
Designer {
    D{i:3;anchors_width:146;anchors_x:46}
}
##^##*/
