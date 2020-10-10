import QtQuick 2.15
import QtQuick.Controls 2.15

Slider {
    id: root
    
    property string color: "#000000"
    property string hintColor: "#bdbdbd"

    background: Rectangle {
         x: root.leftPadding
         y: root.topPadding + root.availableHeight / 2 - height / 2
         implicitWidth: 200
         implicitHeight: 4
         width: root.availableWidth
         height: implicitHeight
         radius: 2
         color: root.hintColor

         Rectangle {
             width: root.visualPosition * parent.width
             height: parent.height
             color: root.color
             radius: 2
         }
     }

     handle: Rectangle {
         x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
         y: root.topPadding + root.availableHeight / 2 - height / 2
         implicitWidth: 20
         implicitHeight: 20
         radius: width/2
         color: root.pressed ? "#f0f0f0" : root.color

         Rectangle{
             color: "#ffffff"
             width: parent.width-8
             height: parent.height-8
             radius: width/2
             anchors.centerIn: parent
             
         }
     }
}
