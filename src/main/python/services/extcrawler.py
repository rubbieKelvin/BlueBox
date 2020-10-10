import os
import json
import eyed3

from io import BytesIO
from base64 import b64encode
from urllib.parse import unquote

EXTENSIONS = [".mp3", ".ogg", ".wav", ".flac", ".m4a"]


def path_from_url(path:str) -> str:
    if path.startswith("file://"):
        path = path[7:]
        path = unquote(path)
    return path


def scan_audio_files(directories:list) -> list:
    files = []
    for path in directories:
        if os.path.isdir(path):
            __scan_audio_files(path, files)
    files.sort()
    return files


def __scan_audio_files(path, container:list) -> None:

    cont = os.listdir(path)

    for item in cont:
        relpath = os.path.join(path, item)
        if os.path.isdir(relpath):
            __scan_audio_files(relpath, container)
        elif os.path.isfile(relpath):
            if os.path.splitext(relpath)[-1] in EXTENSIONS:
                container.append(relpath)

def get_album_art(path:str) -> str:
    path = path_from_url(path)

    audiofile = eyed3.load(path)
    
    if not audiofile: return ""
    tag = audiofile.tag
    if not tag: return ""

    # extract image
    if len(tag.images) > 0:
        img = tag.images[0]
        buffer = BytesIO()
        buffer.write(img.image_data)
        uri = b64encode(buffer.getvalue()).decode("ascii")
        uri = f"data:{img.mime_type};base64,{uri}"

        return uri

    else:
        return ""

    
if __name__ == "__main__":
    dirs = ["/home/rubbiekelvin/Music"]
    songs = scan_audio_files(dirs)

    first = songs[0]

    art = get_album_art(first)

    with open("albumart.test.html", "w") as file:
        file.write(f'<img src="{art}"/>')
