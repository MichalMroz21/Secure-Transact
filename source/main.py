import sys

from settings import Settings
from user import User
from networking import Networking
from encryption import Encryption

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

import global_constants


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    encryption = Encryption()
    settings = Settings()
    user = User(encryption, settings)
    network = Networking(user)
    threads = network.start()
    pk = user.public_key_to_pem()

    #Give variables to QML
    engine.rootContext().setContextProperty("user", user)
    engine.rootContext().setContextProperty("pk", pk)
    engine.rootContext().setContextProperty("settings", settings)

    engine.load(global_constants.MAIN_QML_PATH)

    app.exec()
