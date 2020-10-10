import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.11
import QtQuick.Dialogs 1.0
import QtMultimedia 5.15

import "./components" as Ui
import QtGraphicalEffects 1.13
import Qt.labs.settings 1.0

ApplicationWindow {
    id: appwindow
    visible: true
    width: 1100
    height: 700
    flags: Qt.Window | Qt.FramelessWindowHint
    color: "#f8f9fb"
    font.family: "Poppins"

    property string elevationColor: "#33bdbdbd"
    property string accent: "#5860ff"
    property bool scanning // if mediaManager is scanning; updated in load_bar_:Connections
    
    readonly property string conffile: ".config.ini"

    function feedPlaylist(sources){
        sources.forEach(element => {
           playlist.addItem("file://"+element);
        });
    }

    function updatePlaylist(){
        playlist.clear();
        meta.resetParams();

        if (settings.sessiontype==="*"){
            let sources = mediaManager.getAllAudioSources();
            feedPlaylist(sources);
        }
    }

    function shorten(string, max){
        if (string.length > max){
            string = string.slice(0, max);
            string = string+"...";
        }
        return string;
    }

    function isNone(object){
        return (object === null) || (object === undefined) || (object === "");
    }
    
    function twoDigitString(number){
        if (number < 10){
            number = "0"+number;
        }
        return number;
    }
    
    function timeFromDuration(duration){
        let dur = new Date(duration);
        let hour = dur.getUTCHours();
        let minute = dur.getUTCMinutes();
        let seconds = dur.getUTCSeconds();

        let time = "";
        if (hour > 0){
            time += twoDigitString(hour)+":";
        }

        time += twoDigitString(minute)+":";
        time += twoDigitString(seconds);

        return time;
    }

    Component.onCompleted: {
        mediaManager.scan();
    }

    Connections {
        target: mediaManager
        
        function onScanStarted() {
            load_bar_.visible = true;
            scanning = true;
        }

        function onScanComplete() {
            load_bar_.visible = false;
            scanning = false;
            updatePlaylist();
        }
    }


    // QObjects
    Settings{
        id: settings
        category: "audio"
        fileName: conffile
        property alias volume: vol_slider.value

        // what source am i reading from
        // * : all. get all sources from music folders
        // $playlistname : get all sources from <playlistname>
        // %albumname : get all source from <albumname>
        // &artistname : get all sources from <artistname>
        property string sessiontype: "*"

        onSessiontypeChanged: updatePlaylist()
    }

    QtObject {
        id: meta
        property string title
        property string artist
        property string albumart
        property string duration: "00:00"
        property real ms_duration

        function resetParams(){
            this.title = "";
            this.artist = "";
            this.albumart = "";
            this.duration = "";
            this.ms_duration = 0.0;
        }
    }

    Audio{
        id: player
        volume: vol_slider.value

        property bool isPLaying: playbackState == Audio.PlayingState

        playlist: Playlist{
            id: playlist
        }

        onStatusChanged:{
            if (status === Audio.Buffered){
                let path = playlist.currentItemSource.toString();
                
                if (path.length > 1){
                    let meta_ = mediaManager.getMetaData(path);
                    
                    meta.artist = isNone(meta_.artist) ? "Unknown" : meta_.artist;
                    meta.title  = isNone(meta_.title) ? "Unknown": meta_.title;
                    meta.albumart  = isNone(meta_.coverImage) ? "" : meta_.coverImage;
                    meta.ms_duration = meta_.duration;
                    meta.duration = timeFromDuration(meta_.duration);
                }
            }
        }
    }

    FileDialog{
        id: addmusicfolder
        selectFolder: true
        onAccepted: {
            let folder = fileUrl;
            mediaManager.addMusicFolder(folder)
        }
    }

    // Window Manager
    Rectangle {
        id: header
        height: 50
        width: parent.width
        color: "#f8f9fb"

        MouseArea {
            anchors.fill: parent

            property int prevX
            property int prevY
            property bool moving: false
            property bool maximized: false

            onPressed: {
                prevX = mouseX;
                prevY = mouseY;
                moving = true;
            }
            onReleased: {
                moving = false
            }
            onMouseXChanged: {
                if (moving && !maximized){
                    var dx = mouseX-prevX
                    appwindow.setX(appwindow.x+dx)
                }
            }
            onMouseYChanged:{
                if (moving && !maximized){
                    var dy = mouseY-prevY
                    appwindow.setY(appwindow.y+dy)
                }
            }
            onDoubleClicked: {
                if(maximized){
                    appwindow.showNormal()
                }else{
                    appwindow.showMaximized()
                }
                maximized = !maximized;
            }
        }

        TextField {
            id: searchField
            x: 263
            width: 296
            height: 36
            anchors.verticalCenterOffset: 0
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
            placeholderText: qsTr("Type Song or Artist...")
            selectByMouse: true
            mouseSelectionMode: TextInput.SelectCharacters
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 0
                radius: 20
                spread: 0
                color: elevationColor
            }
            background: Rectangle{
                color: "#ffffff"
                radius: height/2
            }
        }

        Label {
            id: page_title
            x: 20
            y: 8
            width: 150
            height: 34
            color: "#26282a"
            text: qsTr("All Songs")
            font.weight: Font.Medium
            font.pixelSize: 16
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        Ui.IconButton {
            id: close_btn
            x: 1008
            y: 8
            width: 30
            height: 30
            padding: 15
            anchors.right: parent.right
            anchors.rightMargin: 20
            source: '<svg viewBox="0 0 16 16" class="bi bi-x-circle-fill" fill="black" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zm-4.146-3.146a.5.5 0 0 0-.708-.708L8 7.293 4.854 4.146a.5.5 0 1 0-.708.708L7.293 8l-3.147 3.146a.5.5 0 0 0 .708.708L8 8.707l3.146 3.147a.5.5 0 0 0 .708-.708L8.707 8l3.147-3.146z"/></svg>'
            radius: 15
            accent: appwindow.accent
            color: "transparent"

            onClick: {
                Qt.quit();
            }
        }
    }

    Rectangle {
        id: footer
        y: 618
        height: 70
        color: "#ffffff"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: -5
            radius: 20
            spread: 0
            color: elevationColor
        }

        Ui.RoundImage {
            x: 20
            id: albumart
            radius: 15
            anchors.verticalCenterOffset: 0
            anchors.verticalCenter: parent.verticalCenter
            width: 55
            height: 55
            source: meta.albumart
            fillMode: Image.PreserveAspectFit
        }

        ColumnLayout {
            x: 88
            y: 8
            width: 200
            height: 54

            Label {
                id: song_artist
                text: shorten(meta.artist, 24)
                font.weight: Font.Medium
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            Label {
                id: song_title
                text: shorten(meta.title, 24)
                font.pixelSize: 11
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }

        RowLayout {
            x: 300
            y: 146
            width: 139
            height: 56
            anchors.verticalCenterOffset: 0
            anchors.verticalCenter: parent.verticalCenter

            Ui.IconButton{
                id: prev_btn
                accent: "#c8c8c8"
                padding: 15
                width: 30
                height: 30
                radius: width/2
                source: '<svg viewBox="0 0 15 15" class="bi bi-skip-start-fill" fill="black" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M4.5 3.5A.5.5 0 0 0 4 4v8a.5.5 0 0 0 1 0V4a.5.5 0 0 0-.5-.5z"/><path d="M4.903 8.697l6.364 3.692c.54.313 1.232-.066 1.232-.697V4.308c0-.63-.692-1.01-1.232-.696L4.903 7.304a.802.802 0 0 0 0 1.393z"/></svg>'

                onClick: playlist.previous()
            }

            Ui.IconButton{
                id: pplay_btn
                color: appwindow.accent
                padding: 15
                width: 30
                height: 30
                radius: width/2
                accent: "#ffffff"

                property string playsource: '<svg viewBox="0 0 15 15" class="bi bi-play-fill" fill="black" xmlns="http://www.w3.org/2000/svg"><path d="M11.596 8.697l-6.363 3.692c-.54.313-1.233-.066-1.233-.697V4.308c0-.63.692-1.01 1.233-.696l6.363 3.692a.802.802 0 0 1 0 1.393z"/></svg>'
                property string pausesource: '<svg viewBox="0 0 15 15" class="bi bi-pause-fill" fill="black" xmlns="http://www.w3.org/2000/svg"><path d="M5.5 3.5A1.5 1.5 0 0 1 7 5v6a1.5 1.5 0 0 1-3 0V5a1.5 1.5 0 0 1 1.5-1.5zm5 0A1.5 1.5 0 0 1 12 5v6a1.5 1.5 0 0 1-3 0V5a1.5 1.5 0 0 1 1.5-1.5z"/></svg>'
                source: player.isPLaying ? pausesource : playsource
                onClick: {
                    if (!player.isPLaying) {
                        player.play();
                    } else {
                        player.pause();
                    }
                }
            }

            Ui.IconButton{
                id: forw_btn
                accent: "#c8c8c8"
                padding: 15
                width: 30
                height: 30
                radius: width/2
                source: '<svg viewBox="0 0 15 15" class="bi bi-skip-end-fill" fill="black" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M12 3.5a.5.5 0 0 1 .5.5v8a.5.5 0 0 1-1 0V4a.5.5 0 0 1 .5-.5z"/><path d="M11.596 8.697l-6.363 3.692c-.54.313-1.233-.066-1.233-.697V4.308c0-.63.692-1.01 1.233-.696l6.363 3.692a.802.802 0 0 1 0 1.393z"/></svg>'

                onClick: playlist.next()
            }
        }

        RowLayout {
            y: 0
            height: 56
            anchors.left: parent.left
            anchors.leftMargin: 481
            anchors.right: parent.right
            anchors.rightMargin: 344
            anchors.verticalCenterOffset: 0
            anchors.verticalCenter: parent.verticalCenter

            Label {
                id: currentTime
                text: timeFromDuration(player.position)
                font.pixelSize: 12
                verticalAlignment: Text.AlignVCenter
                Layout.fillHeight: true
            }

            Ui.SlideBar {
                id: seeker
                width: 343
                height: 40
                value: (player.position/player.duration)*this.to
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: accent
                stepSize: 0.1
                to: 100
                from: 0
                hintColor: "#ededed"
                enabled: player.seekable

                onMoved: {
                    player.seek(
                        (this.value/this.to)*player.duration
                    );
                }
            }

            Label {
                id: duration
                text: meta.duration
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 12
                Layout.fillHeight: true
            }
        }

        RowLayout {
            x: 953
            width: 127
            height: 54
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 20

            Image {
                id: __vlm_icon
                width: 12
                height: 12
                fillMode: Image.PreserveAspectFit
                source: __volume_icon.uri
            }

            Ui.SlideBar {
                id: vol_slider
                Layout.fillWidth: true
                color: accent
                to: 1
                stepSize: 0.1
                from: 0
                live: true
                hintColor: "#ededed"
            }

            Ui.Svg{
                id: __volume_icon

                readonly property string volume_quiet: '<svg viewBox="0 0 15 15" class="bi bi-volume-down-fill" fill="black" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M8.717 3.55A.5.5 0 0 1 9 4v8a.5.5 0 0 1-.812.39L5.825 10.5H3.5A.5.5 0 0 1 3 10V6a.5.5 0 0 1 .5-.5h2.325l2.363-1.89a.5.5 0 0 1 .529-.06z"/><path d="M10.707 11.182A4.486 4.486 0 0 0 12.025 8a4.486 4.486 0 0 0-1.318-3.182L10 5.525A3.489 3.489 0 0 1 11.025 8c0 .966-.392 1.841-1.025 2.475l.707.707z"/></svg>'
                readonly property string volume_loud: '<svg viewBox="0 0 15 15" class="bi bi-volume-up-fill" fill="black" xmlns="http://www.w3.org/2000/svg"><path d="M11.536 14.01A8.473 8.473 0 0 0 14.026 8a8.473 8.473 0 0 0-2.49-6.01l-.708.707A7.476 7.476 0 0 1 13.025 8c0 2.071-.84 3.946-2.197 5.303l.708.707z"/><path d="M10.121 12.596A6.48 6.48 0 0 0 12.025 8a6.48 6.48 0 0 0-1.904-4.596l-.707.707A5.483 5.483 0 0 1 11.025 8a5.483 5.483 0 0 1-1.61 3.89l.706.706z"/><path d="M8.707 11.182A4.486 4.486 0 0 0 10.025 8a4.486 4.486 0 0 0-1.318-3.182L8 5.525A3.489 3.489 0 0 1 9.025 8 3.49 3.49 0 0 1 8 10.475l.707.707z"/><path fill-rule="evenodd" d="M6.717 3.55A.5.5 0 0 1 7 4v8a.5.5 0 0 1-.812.39L3.825 10.5H1.5A.5.5 0 0 1 1 10V6a.5.5 0 0 1 .5-.5h2.325l2.363-1.89a.5.5 0 0 1 .529-.06z"/></svg>'
                readonly property string volume_off: '<svg viewBox="0 0 15 15" class="bi bi-volume-off-fill" fill="black" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M10.717 3.55A.5.5 0 0 1 11 4v8a.5.5 0 0 1-.812.39L7.825 10.5H5.5A.5.5 0 0 1 5 10V6a.5.5 0 0 1 .5-.5h2.325l2.363-1.89a.5.5 0 0 1 .529-.06z"/></svg>'

                source: (vol_slider.value > 50) ? volume_loud : (vol_slider.value > 0) ? volume_quiet : volume_off
                color: "#c8c8c8"
            }

        }

        ProgressBar{
            id: load_bar_
            indeterminate: true
            anchors.bottom: parent.bottom
            height: 3
            width: parent.width
            enabled: visible
            visible: false
        }
    }

    Ui.Box {
        id: side
        x: 10
        width: 240
        color: "transparent"
        anchors.bottom: footer.top
        anchors.bottomMargin: 10
        anchors.top: header.bottom
        anchors.topMargin: 10
        strokeRight: 1
        strokecolor: "#ededed"

        ColumnLayout {
            id: menu
            y: 0
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 10

            property int current: 0

            Ui.MenuItem{
                highlightColor: accent
                text: "Box"
                highlighted: menu.current==0
                Layout.fillWidth: true
                textColor: "#cacad2"
                source: '<svg viewBox="0 0 16 16" class="bi bi-file-music-fill" fill="black" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M12 1H4a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2V3a2 2 0 0 0-2-2zM8.725 3.793A1 1 0 0 0 8 4.754V10.2a2.52 2.52 0 0 0-1-.2c-1.105 0-2 .672-2 1.5S5.895 13 7 13s2-.672 2-1.5V6.714L11.5 6V4.326a1 1 0 0 0-1.275-.962l-1.5.429z"/></svg>'
                onClick: menu.current=0
            }

            Ui.MenuItem{
                highlightColor: accent
                text: "Music Folders"
                Layout.fillWidth: true
                textColor: "#cacad2"
                source: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="M18 21C19.1046 21 20 20.1046 20 19H21C22.1046 19 23 18.1046 23 17V7C23 5.89543 22.1046 5 21 5H20C20 3.89543 19.1046 3 18 3H6C4.89543 3 4 3.89543 4 5H3C1.89543 5 1 5.89543 1 7V17C1 18.1046 1.89543 19 3 19H4C4 20.1046 4.89543 21 6 21H18ZM18 5V19H6V5H18ZM12 12.1405V7.13148L16.5547 10.1679L15.4453 11.8321L14 10.8685V14.5C14 15.9534 12.6046 17 11 17C9.39543 17 8 15.9534 8 14.5C8 13.0466 9.39543 12 11 12C11.3471 12 11.6845 12.049 12 12.1405ZM3 7H4V17H3V7ZM20 17H21V7H20V17ZM12 14.5C12 14.7034 11.6046 15 11 15C10.3954 15 10 14.7034 10 14.5C10 14.2966 10.3954 14 11 14C11.6046 14 12 14.2966 12 14.5Z" fill="black"/></svg>'
                highlighted: menu.current==1
                onClick: menu.current=1
            }
        }

        Ui.MenuItem{
            highlightColor: accent
            text: "Settings"
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            Layout.fillWidth: true
            highlightable: false
            textColor: "#cacad2"
            source: '<svg viewBox="0 0 16 16" class="bi bi-toggles" fill="black" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M4.5 9a3.5 3.5 0 1 0 0 7h7a3.5 3.5 0 1 0 0-7h-7zm7 6a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5zm-7-14a2.5 2.5 0 1 0 0 5 2.5 2.5 0 0 0 0-5zm2.45 0A3.49 3.49 0 0 1 8 3.5 3.49 3.49 0 0 1 6.95 6h4.55a2.5 2.5 0 0 0 0-5H6.95zM4.5 0h7a3.5 3.5 0 1 1 0 7h-7a3.5 3.5 0 1 1 0-7z"/></svg>'
        }
    }

    StackLayout {
        id: stack
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        anchors.top: header.bottom
        anchors.right: parent.right
        anchors.bottom: footer.top
        anchors.left: side.right
        anchors.topMargin: 10
        currentIndex: menu.current

        Page {
            id: boxpage
            Layout.fillHeight: true
            Layout.fillWidth: true
            background: Rectangle{color:"transparent"}

            StackLayout{
                currentIndex: Number(mediaManager.folderCount>0)
                anchors.fill: parent
                

                Page{
                    // no media
                    background: Rectangle{color:"transparent"}
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    

                    ColumnLayout{
                        anchors.centerIn: parent
                        
                        Label{
                            text: "No Music Folder to scan through"
                        }
                    }
                }

                Page{
                    background: Rectangle{color:"transparent"}
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                }
            }
        }

        Page {
            id: musicfolderpage
            Layout.fillHeight: true
            Layout.fillWidth: true
            background: Rectangle{color:"transparent"}

            Rectangle {
                id: hea__der
                height: 40
                color: "transparent"
                width: parent.width * 0.5
                anchors.horizontalCenter: parent.horizontalCenter
                
                Label{
                    x: 10
                    text: qsTr("Music Folders")
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }

                Ui.IconButton{
                    source: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="M13 11H22V13H13V22H11V13H2V11H11V2H13V11Z" fill="black"/></svg>'
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    width: 20
                    height: 20
                    padding: 8
                    color: "transparent"
                    accent: appwindow.accent
                    enabled: !scanning
                    onClick: addmusicfolder.open()
                }
            }
            
            ListView {
                width: parent.width * 0.5
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: hea__der.bottom
                
                model: mediaManager.folders
                delegate: Ui.MusicFolderItem{
                    width: parent.width
                    folderName: modelData.name

                    onRemoveRequested: {
                        mediaManager.removeMusicFolder(modelData.path);
                    }
                }
            }
        }
    }

}
