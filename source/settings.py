from PySide6.QtCore import QSettings, QObject, Signal, Slot, Property

import global_constants

class Settings(QObject):
    autoConnectionChanged = Signal()
    lightModeChanged = Signal()

    def __init__(self):
        super().__init__()
        self.settings = QSettings("Secure-Transact", "Application")
        self._auto_connection = True if self.get_option(global_constants.AUTO_CONNECTION_STRING) == "True" else False
        self._light_mode = True if self.get_option(global_constants.LIGHT_MODE_STRING) == "True" else False

    @Slot(str, str)
    def set_option(self, key, value):
        self.settings.setValue(key, value)

    @Slot(str, str, result=str)
    def get_option(self, key, default_value=None):
        return self.settings.value(key, default_value)

    @Property(bool, notify=autoConnectionChanged)
    def auto_connection(self):
        return self._auto_connection

    @auto_connection.setter
    def auto_connection(self, new_val):
        if self._auto_connection != new_val:
            self.set_option(global_constants.AUTO_CONNECTION_STRING, str(new_val))
            self._auto_connection = new_val
            self.autoConnectionChanged.emit()

    @Property(bool, notify=lightModeChanged)
    def light_mode(self):
        return self._light_mode

    @light_mode.setter
    def light_mode(self, new_val):
        if self._light_mode != new_val:
            self.set_option(global_constants.LIGHT_MODE_STRING, str(new_val))
            self._light_mode = new_val
            self.lightModeChanged.emit()
