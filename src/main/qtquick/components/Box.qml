import QtQuick 2.15

Rectangle {
    id: root

    property string strokecolor: "#000000"
    property int strokeTop: 0
    property int strokeBottom: 0
    property int strokeLeft: 0
    property int strokeRight: 0

    Rectangle {
        id: _top
        height: strokeTop
        color: strokecolor
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
    }

    Rectangle {
        id: _bottom
        height: strokeBottom
        color: strokecolor
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
    }

    Rectangle {
        id: _left
        width: strokeLeft
        color: strokecolor
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
    }

    Rectangle {
        id: _right
        width: strokeRight
        color: strokecolor
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
    }   
}
