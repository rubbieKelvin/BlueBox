import json, os

from PySide2 import QtCore
from workers import scanner

from services.extcrawler import path_from_url

class Organizer(QtCore.QObject):
    PATH = ".data.json"

    def __init__(self):
        super(Organizer, self).__init__()
        self.threadpool = QtCore.QThreadPool()
        self.load()

    scanStarted = QtCore.Signal()
    scanError   = QtCore.Signal()
    scanComplete = QtCore.Signal()
    folderCountChanged = QtCore.Signal(int)

    musicFolderUpdated = QtCore.Signal("QVariantList")
    
    def parsefolderModel(self, path) -> dict:
        return dict(
            path=path,
            name=os.path.split(path)[-1]
        )

    def load(self):
        self.data = dict(
            playlists=[],
            musicfolders=[],
            audiofiles=dict()
        )
        if os.path.isfile(self.PATH):
            with open(self.PATH) as file:
                self.data.update(json.load(file))

    def save(self):
        with open(self.PATH, "w") as file:
            json.dump(self.data, file)

    @QtCore.Slot()
    def scan(self):
        self.scanStarted.emit()
        worker = scanner.MediaScanner(
            directories=self.data.get("musicfolders"),
            container=self.data.get("audiofiles"),
            ondone=self.scanComplete,
            onerror=self.scanError,
            callback=self.save
        )

        self.threadpool.start(worker)

    @QtCore.Property("QVariantList", notify=musicFolderUpdated)
    def folders(self):
        return [self.parsefolderModel(path) for path in self.data.get("musicfolders")]

    @QtCore.Slot(str)
    def addMusicFolder(self, path):
        path = path_from_url(path)
        self.data["musicfolders"].append(path)
        self.musicFolderUpdated.emit(self.folders)
        self.folderCountChanged.emit(self.folderCount)
        self.save()
        self.scan()

    @QtCore.Slot(str)
    def removeMusicFolder(self, path):
        self.data["musicfolders"] = list(
            filter(lambda x:x!=path, self.data["musicfolders"])
        )

        # also remove songs under this folder
        keys = list(self.data["audiofiles"].keys())
        for k in keys:
            if os.path.split(k)[0].startswith(path):
                del self.data["audiofiles"][k]

        self.musicFolderUpdated.emit(self.folders)
        self.folderCountChanged.emit(self.folderCount)
        self.save()

    @QtCore.Slot(result="QVariantList")
    def getAllAudioSources(self):
        return list(self.data["audiofiles"].keys())

    @QtCore.Slot(str, result="QVariant")
    def getMetaData(self, path):
        path = path_from_url(path)
        return self.data["audiofiles"].get(path, {})

    @QtCore.Property(int, notify=folderCountChanged)
    def folderCount(self):
        return len(self.data.get("musicfolders"))