import hashlib
import json

from PySide6.QtCore import QObject

class Block(QObject):
    def __init__(self, index, data, digitalEncryption, hostVerifier, portVerifier, publicKeyVerifier, lastDigitalEncryption):
        """
        Creates new Block object
        :param index: Which block in blockchain it is
        :param data: Data stored in the block
        :param powval: Calculated value of the power
        :param lastHash: Hash value from previous block
        :param hash: Hash value in created block
        """
        self.index = index
        self.data = data
        self.digitalEncryption = digitalEncryption
        self.hostVerifier = hostVerifier
        self.portVerifier = portVerifier
        self.publicKeyVerifier = publicKeyVerifier
        self.lastDigitalEncryption = lastDigitalEncryption

    def __str__(self):
        """ String representation of the block.
            Does NOT include the current hash!
            (Intended to be called from the hasher function.)
        """
        return json.dumps({"index": self.index,
                           "data": self.data,
                           "digitalEncryption": self.digitalEncryption,
                           "hostVerifier": self.hostVerifier,
                           "portVerifier": self.portVerifier,
                           "publicKeyVerifier": self.publicKeyVerifier,
                           "lastDigitalEncryption": self.lastDigitalEncryption})

    def hashme(self):
        """
        Calculates hash for the block
        :return: Hash
        """
        sha256 = hashlib.sha256()
        sha256.update(str(self).encode("utf-8"))

        return sha256.hexdigest()

    def dictrep(self):
        """
        Creates JSON formatted string
        :return: JSON formatted string
        """
        return {"index": self.index,
                "data": self.data,
                "digitalEncryption": self.digitalEncryption,
                "hostVerifier": self.hostVerifier,
                "portVerifier": self.portVerifier,
                "publicKeyVerifier": self.publicKeyVerifier,
                "lastDigitalEncryption": self.lastDigitalEncryption}

class Blockchain(QObject):
    def __init__(self, blocks=[]):
        """
        Creates blockchain
        :param blocks: List of blocks in created blockchain
        """
        super().__init__()

        self.blocks = blocks

    def genesis(self):
        """
        Sets first block in blockchain
        :return:
        """
        self.blocks = [Block(0, ["Opening block"], "", "",0, "", "")]

    def add_signature_block(self, data, digitalEncryption, hostVerifier, portVerifier, publicKeyVerifier):
        last = self.blocks[-1]
        currentBlock = Block(last.index + 1, data, digitalEncryption, hostVerifier, portVerifier, publicKeyVerifier, last.digitalEncryption)
        self.blocks.append(currentBlock)

    def verify(self) -> bool:
        """
        Verifies if all blocks in blockchain are valid
        Checks if block's lastHash value equals to the hash value of the previous block
        :return: bool
        """
        return True

    def consensus(self, other) -> bool:
        """
        Checks the correctness of the chain
        :param other: Blockchain from the second device
        :return: bool
        """

        "Gets the current consensus. If it's our chain, returns True."
        if not Blockchain.verify(other):
            return True

        if not self.verify():
            self.blocks = other.blocks
            return False

        if len(other.blocks) > len(self.blocks):
            self.blocks = other.blocks
            return False #Keep valid chain with most blocks

        return True

    def jsonrep(self):
        """
        Converts blockchain into a JSON formatted string
        :return: JSON formatted string
        """
        return json.dumps([block.dictrep() for block in self.blocks])

    def fromjson(self, message):
        """
        Converting a JSON string into a Blockchain class object
        :return: Blockchain
        """
        jblocks = json.loads(message)
        chain = []

        for jblock in jblocks:
            chain.append(Block(jblock["index"], jblock["data"],
                               jblock["digitalEncryption"], jblock["hostVerifier"], jblock["portVerifier"],
                               jblock["publicKeyVerifier"], jblock["lastDigitalEncryption"]))

        return Blockchain(chain)
