import eyed3
from io import BytesIO
from PySide2 import QtCore
from base64 import b64encode
from services import extcrawler

class Music:
    def __init__(self, path:str):
        self.meta = dict(
            source=path,
            title=None,
            artist=None,
            album=None,
            coverImage="",
            duration=0
        )

        audio = eyed3.load(path)
        if audio:
            self.meta["duration"] = audio.info.time_secs*1000

            tag = audio.tag
            if tag:
                self.meta["title"] = tag.title
                self.meta["artist"] = tag.artist

                # extract image
                if len(tag.images) > 0:
                    img = tag.images[0]
                    buffer = BytesIO()
                    buffer.write(img.image_data)
                    uri = b64encode(buffer.getvalue()).decode("ascii")
                    self.meta["coverImage"] = f"data:{img.mime_type};base64,{uri}" 

class MediaScanner(QtCore.QRunnable):
    RUNNING = False

    def __init__(self, directories:list, container:dict, ondone:QtCore.Signal, onerror:QtCore.Signal, callback=None):
        super(MediaScanner, self).__init__()
        self.container = container
        self.onDone = ondone
        self.onError = onerror
        self.directories = directories
        self.callback = callback

    @QtCore.Slot()
    def run(self):
        if MediaScanner.RUNNING: return
        MediaScanner.RUNNING = True

        audio_file_names = extcrawler.scan_audio_files(self.directories)
        
        for path in audio_file_names:
            if not path in self.container:
                self.container[path] = Music(path).meta
        
        if self.callback:
            self.callback()
        
        self.onDone.emit()
        MediaScanner.RUNNING = False