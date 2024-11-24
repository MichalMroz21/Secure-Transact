import base64
import hashlib
import os
import socket
import time
import requests
import random
import string

import global_constants

from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from http import HTTPStatus

from blockchain import Blockchain

from PySide6.QtCore import QObject, Signal, Slot, Property


class User(QObject):
    peersChanged = Signal() #Emit if peers are in any way changed
    hostChanged = Signal()
    portChanged = Signal()
    messagesChanged = Signal()
    groupChanged = Signal()
    nicknameChanged = Signal()

    def __init__(self, powlib, encryption):
        super().__init__()
        """
        Creates a user
        :param port: Host machine port
        """
        if "TITLE" in os.environ:
            self.stake = global_constants.INITIAL_CURRENCY * int(os.environ["TITLE"])       # currency
        else:
            self.stake = global_constants.INITIAL_CURRENCY

        self.private_key = rsa.generate_private_key(
            public_exponent=global_constants.PRIVATE_KEY_PUBLIC_EXPONENT,
            key_size=global_constants.PRIVATE_KEY_SIZE,
            backend=default_backend()
        )

        self.powlib = powlib
        self.encryption = encryption

        #Connections with other devices
        self.chain = Blockchain(self.powlib)  # copy of blockchain
        self.chain.genesis()  # initiating first block of blockchain
        self.staging = []  # staging data to add to block

        #Socket stuff
        self._port = self.get_port()
        self._host = self.ip()

        #User Variables
        self._messages = {}
        self.indexes = []
        self._group = []
        self._peers = []
        self._nickname = self.generate_random_string(global_constants.MAX_NICKNAME_LENGTH)

        self.public_key = self.private_key.public_key()
        self.random_key = os.urandom(global_constants.RANDOM_KEY_SIZE)
        self.useful_key = os.urandom(global_constants.USEFUL_KEY_SIZE)

        self.update_encrypted_string(self.public_key, self.random_key)

        self.drawString = ""

    #QVariantMap is for Dictionaries and keys must be strings
    @Property("QVariantMap", notify=messagesChanged)
    def messages(self):
        return self._messages

    #QVariantList is for Lists
    @Property("QVariantList", notify=groupChanged)
    def group(self):
        return self._group

    @Property("QVariantList", notify=peersChanged)
    def peers(self):
        return self._peers

    @Property(int, notify=portChanged)
    def port(self):
        return self._port

    @Property(str, notify=hostChanged)
    def host(self):
        return self._host

    @Property(str, notify=nicknameChanged)
    def nickname(self):
        return self._nickname

    @host.setter
    def host(self, new_val):
        if self._host != new_val:
            self._host = new_val
            self.hostChanged.emit()

    @port.setter
    def port(self, new_val):
        if self._port != new_val:
            self._port = new_val
            self.portChanged.emit()

    @nickname.setter
    def nickname(self, new_val):
        if self._nickname != new_val:
            self._nickname = new_val
            self.nicknameChanged.emit()

    @Slot(result=list)
    def getConversation(self):
        group_str = self.group_to_string(self.group)

        if group_str is None or group_str not in self.messages:
            return []

        return self.messages[group_str]

    @Slot(str, int)
    def addToGroup(self, addr, port):
        for peer in self.peers:
            if peer.addr == addr and peer.port == port:
                self.group.append(peer)
                self.groupChanged.emit()

                if self.group_to_string(self.group) not in self.messages.keys():
                    self.messages[self.group_to_string(self.group)] = []
                    self.messagesChanged.emit()

                break

    @Slot(str, int)
    def removeFromGroup(self, addr, port):
        for peer in self.peers:
            if peer.addr == addr and peer.port == port:
                self.group.remove(peer)
                self.groupChanged.emit()
                break

    @Slot(str, int)
    def removeFromPeers(self, addr, port):
        for peer in self.peers:
            if peer.addr == addr and peer.port == port:
                self.peers.remove(peer)
                self.peersChanged.emit()
                break

    @Slot(str, str, str)
    def peer(self, addr, port, PKString):
        """
        Creates peer with second device
        :param addr: Second's device IP address
        :param port: Second's device port
        """
        self._peers.append(Peer(addr, int(port), PKString))
        self.peersChanged.emit() #Notify QML

        self.update_encrypted_string(self.public_key, self.random_key)

        for peer in self._peers:
            peer.update_encrypted_string(peer.public_key, self.random_key)

        self.sendEncryptedKeys()

        if self._port == self.drawPerson():
            print(self.public_key_to_pem())

            for peer in self._peers:
                print(peer.PKString)

    @Slot(str)
    def send_mes(self, message):
        """
        Sends message to other device
        :param host_addr: Sender IP address
        :param message: message to be sent
        """
        appended_message = False

        for peer in self.group:
            encrypted_message = self.encryption.encrypt_data_ecb(message, self.useful_key)
            group = self.group_to_string(self.group)

            response = requests.post("http://{}:{}/receive_message".format(peer.addr, peer.port),
                          json={"addr": peer.addr, "port": peer.port, "message": encrypted_message, "group": group})

            if response.status_code == HTTPStatus.OK and not appended_message:
                response = requests.post("http://{}:{}/receive_message".format(self.host, self.port),
                                         json={"addr": self.host, "port": self.port, "message": encrypted_message, "group": group})

                if response.status_code == HTTPStatus.OK:
                    appended_message = True

    @Slot(str, str)
    def get_messages_block(self, host_addr):
        """
        :param host_addr: sender IP address
        :return: messages
        """
        try:
            return requests.get("http://{}:{}/get_messages".format(host_addr, self.port)).json()
        except Exception as e:
            return e

    def generate_random_string(self, n):
        """
        Generates random string
        :param n: length of string
        :return: str
        """
        return ''.join(random.choices(string.ascii_letters + string.digits, k=n))

    def ip(self):
        """
        Gets host machine IP address
        :return: str
        """
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect((global_constants.IP_ADDRESS, global_constants.PORT))  #Doesn't actually send traffic
        ipa = s.getsockname()[0]
        s.close()

        return ipa

    def get_port(self):
        """
        Gets host machine port value from config file
        :return: int
        """
        return random.randint(global_constants.MIN_PORT_VAL, global_constants.MAX_PORT_VAL)

    def update_encrypted_string(self, public_key, random_key):
        self.EncryptedKBytes = self.encryption.encrypt_with_public_key(public_key, random_key)
        self.EncryptedKString = base64.b64encode(self.EncryptedKBytes).decode('utf-8')

    def update_group_session_key(self):
        #Encryption of session key for every user
        self.update_encrypted_string(self.public_key, self.random_key)

        for peer in self._peers:
            peer.EncryptedKBytes = self.encryption.encrypt_with_public_key(peer.public_key, self.random_key)
            self.EncryptedKString = base64.b64encode(peer.EncryptedKBytes).decode('utf-8')

    def consensus(self):
        """
        Checks the correctness of peers and chains
        """
        chains = []

        for peer in self._peers:
            pass  #Get that peer's chain

        for chain in chains:
            self.chain.consensus(chain)

    def get_public_key(self):
        return self.public_key

    def public_key_to_pem(self):
        pem = self.public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
        return pem.decode('utf-8')  #Conversion to text

    def add_block(self):
        """
        Adds block to be sent to other device
        """
        self.chain.add_block(self.staging)

    def add_data(self, data):
        """
        Adds data to the block
        :param data: Data to be sent
        """
        if data != "":
            data += ""

        data = self.encryption.encrypt_data_ecb(data, self.useful_key)
        self.staging.append(data)

    def group_to_string(self, group):
        if not group:
            return None

        group_strings = []
        group_strings.append(str(self.host) + ":" + str(self.port))

        for peer_str in group:
            group_strings.append(str(peer_str.addr) + ":" + str(peer_str.port))

        group_strings.sort()

        group_string = ",".join(group_strings)
        return group_string

    def string_to_group(self, string):
        if not string:
            return None

        group = []
        result = string.split(",")

        for peer_str in result:
            splitted = peer_str.split(":")
            addr = splitted[0]
            port = int(splitted[1])

            for peer in self.peers:
                if peer.addr == addr and peer.port == port:
                    group.append(peer)
                    break

        return group

    def drawPerson(self):
        keyList = []

        for peer in self._peers:
            keyList.append(peer.port)

        keyList.append(self._port)
        keyList.sort()  #Important sort list to make it the same

        keyRaw = " ".join(str(x) for x in keyList)
        self.drawString = keyRaw
        numeric_seed = int.from_bytes(hashlib.sha256(keyRaw.encode('utf-8')).digest())  #String to int
        random.seed(numeric_seed)
        chosen_peer = random.choice(self._peers)

        return chosen_peer

    def sendEncryptedKeys(self):
        drawn_peer = self.drawPerson()

        if self.host == drawn_peer.addr and self.port == drawn_peer.port:
            requests.post("http://{}:{}/receive_pk".format(self.host, self.port),
                          json={"addr": self.host, "port": self.port,
                                "message": global_constants.ENCRYPTED_KEY_BEGIN + "\n" + self.EncryptedKString + "\n"})
            for peer in self._peers:
                requests.post("http://{}:{}/receive_pk".format(peer.addr, peer.port),
                              json={"addr": self.host, "port": self.port,
                                    "message": global_constants.ENCRYPTED_KEY_BEGIN + "\n" + peer.EncryptedKString + "\n"})


    def view_parsed_messages(self, host_addr):
        """
        :param host_addr: sender IP address
        :return: messages string
        """
        try:
            json_messages = requests.get("http://{}:{}/get_messages".format(host_addr, self.port)).json()
            messages = ""

            if json_messages:
                for message in json_messages:
                    decrypted_message = self.encryption.decrypt_data_ecb(message["message"], self.useful_key)
                    messages += message["user"] + " (" + message["date"] + "): " + decrypted_message + "\n"

            return messages

        except Exception as e:
            return e

    def remove_messages_block(self, host_addr):
        """
        :param host_addr: sender IP address
        """
        try:
            return requests.post("http://{}:{}/remove_messages".format(host_addr, self.port))
        except Exception as e:
            return e


    def serve_chain(self, app):
        app.run(global_constants.ZERO_ADDRESS, self.port)

    def check_consensus(self):
        """
        Checks both blockchains (one from the host machine and other from the second device) which one is correct
        """
        while True:
            for peer in self._peers:
                chain = peer.get_chain()

                if self.chain.consensus(chain):
                    print("Checked chain with {}, ours is right".format(
                        (peer.addr, peer.port)))
                else:
                    print("Checked chain with {}, theirs is right".format(
                        (peer.addr, peer.port)))

            time.sleep(global_constants.CHECK_DELAY)

    def add_blocks(self):
        """
        Adds blocks to blockchain
        """
        while True:
            if self.staging:
                print("Mining new block...")
                self.add_block()
                print("Added new block!")
                self.staging = []
            else:
                time.sleep(global_constants.CHECK_DELAY)

    def handle_input(self):
        """
        Steering application in the console
        """
        while True:
            cmd = input("> ").split(";")

            if cmd[0] == "peer":
                self.peer(cmd[1], int(cmd[2]))
            if cmd[0] == "txion":
                self.staging.append(cmd[1])
            if cmd[0] == "chain":
                print([block.data for block in self.chain.blocks])


class Peer(QObject):
    portChanged = Signal()
    addrChanged = Signal()
    nicknameChanged = Signal()
    PKStringChanged = Signal()
    public_keyChanged = Signal()

    def __init__(self, address, port, PKString):
        """
        Creates connection with second device
        :param address: Second device's IP address
        :param port: Second device's port
        """
        super().__init__()

        self._addr = address
        self._port = port
        self._PKString = PKString
        self._public_key = self.encryption.load_public_key_from_pem(PKString)

        self.update_encrypted_string(self.public_key, os.urandom(global_constants.KEY_SIZE))

    @Property(int, notify=portChanged)
    def port(self):
        return self._port

    @Property(str, notify=addrChanged)
    def addr(self):
        return self._addr

    @Property(str, notify=PKStringChanged)
    def PKString(self):
        return self._PKString

    @Property(str, notify=public_keyChanged)
    def public_key(self):
        return self._public_key

    @public_key.setter
    def public_key(self, new_val):
        if self._public_key != new_val:
            self._public_key = new_val
            self.public_keyChanged.emit()

    @PKString.setter
    def PKString(self, new_val):
        if self._PKString != new_val:
            self._PKString = new_val
            self.PKStringChanged.emit()

    @port.setter
    def port(self, new_val):
        if self._port != new_val:
            self._port = new_val
            self.portChanged.emit()

    @addr.setter
    def addr(self, new_val):
        if self._addr != new_val:
            self._addr = new_val
            self.addrChanged.emit()

    def get_chain(self):
        """
        Gets blockchain from the second device
        :return: Blockchain
        """
        print("Fetching chain from {}".format((self._addr, self._port)))

        message = requests.get("http://{}:{}/chain".format(self._addr, self._port)).text

        return self.chain.fromjson(message)

    def update_encrypted_string(self, public_key, random_key):
        self.EncryptedKBytes = self.encryption.encrypt_with_public_key(public_key, random_key)
        self.EncryptedKString = base64.b64encode(self.EncryptedKBytes).decode('utf-8')

