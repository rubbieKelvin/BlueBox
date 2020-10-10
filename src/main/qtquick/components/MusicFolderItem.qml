import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.11

Box {
    id: root
    width: 400
    height: 60
    color: "transparent"
    strokecolor: "#77cacad2"
    strokeTop: 1

    property alias folderName: name__.text
    property alias folderDescription: description__.text

    signal removeRequested()

    Image {
        x: 10
        y: 8
        width: 40
        height: 40
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: '../../assets/icons/musicfolder.svg'
    }

    ColumnLayout {
        x: 66
        y: 8
        width: 224
        height: 44

        Label {
            id: name__
            text: qsTr("Name")
            font.pixelSize: 12
            verticalAlignment: Text.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Label {
            id: description__
            color: "#cacad2"
            text: qsTr("Label")
            Layout.fillHeight: true
            Layout.fillWidth: true
            verticalAlignment: Text.AlignVCenter
        }
    }

    RowLayout {
        id: rowLayout
        x: 306
        width: 84
        height: 43
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10

        IconButton {
            id: play
            width: 25
            height: 25
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            source: '<svg viewBox="0 0 15 15" class="bi bi-play-fill" fill="black" xmlns="http://www.w3.org/2000/svg"><path d="M11.596 8.697l-6.363 3.692c-.54.313-1.233-.066-1.233-.697V4.308c0-.63.692-1.01 1.233-.696l6.363 3.692a.802.802 0 0 1 0 1.393z"/></svg>'
            accent: "#cacad2"
            color: "transparent"
            padding: 10
        }

        IconButton {
            id: remove
            width: 25
            height: 25
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            source: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="M12 23C5.92487 23 1 18.0751 1 12C1 5.92487 5.92487 1 12 1C18.0751 1 23 5.92487 23 12C23 18.0751 18.0751 23 12 23ZM12 21C16.9706 21 21 16.9706 21 12C21 7.02944 16.9706 3 12 3C7.02944 3 3 7.02944 3 12C3 16.9706 7.02944 21 12 21ZM7 11V13H17V11H7Z" fill="black"/></svg>'
            accent: "#cacad2"
            color: "transparent"
            padding: 10

            onClick: removeRequested()
        }

    }
}
