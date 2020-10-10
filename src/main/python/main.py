import os
import sys

from PySide2 import QtQml
from PySide2 import QtCore
from PySide2 import QtQuickControls2

from utils import organizer
from fbs_runtime.application_context.PySide2 import ApplicationContext

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__),".."))
QTQUICK_DIR = os.path.join(ROOT, "qtquick")

if __name__ == '__main__':

    appctxt = ApplicationContext()
    organizer_ = organizer.Organizer()

    QtQuickControls2.QQuickStyle.setStyle("Fusion")
    QtCore.QCoreApplication.setApplicationName("BlueBox")
    QtCore.QCoreApplication.setOrganizationName("stuffsbyrubbie")
    QtCore.QCoreApplication.setOrganizationDomain("com.rubbiekelvin.bluebox")

    engine = QtQml.QQmlApplicationEngine()

    engine.rootContext().setContextProperty("mediaManager", organizer_)

    engine.load(os.path.join(QTQUICK_DIR, "main.qml"))

    exit_code = appctxt.app.exec_()
    sys.exit(exit_code)