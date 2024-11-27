import hashlib
from PySide6.QtCore import QObject

class PowLib(QObject):
    def __init__(self):
        super().__init__()

    def check(self, incrementer):
        """
        Checks if given number is a valid hash
        :param incrementer: Value of which hash is to be check
        :return: bool
        """
        sha256 = hashlib.sha256()
        sha256.update(str(incrementer).encode("utf-8"))

        return sha256.hexdigest().startswith("d3c0d3")

    def compute(self, previous):
        """
        Calculates hash
        :param previous:
        :return:
        """
        incrementer = previous + 1

        while not self.check(incrementer):
            incrementer += 1

        return incrementer
