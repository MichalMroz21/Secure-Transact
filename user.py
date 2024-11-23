import base64
import datetime
import hashlib
import os
import socket
import time
import requests
import random

from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa

import blockchain
import encryption

from PySide6.QtCore import QObject, Signal, Slot, Property


class User(QObject):
    peersChanged = Signal() #emit if peers are in any way changed
    hostChanged = Signal()
    portChanged = Signal()
    messagesChanged = Signal(str)
    groupChanged = Signal()

    def __init__(self):
        super().__init__()
        """
        Creates a user
        :param port: Host machine port
        """
        if "TITLE" in os.environ:
            self.stake = 10000 * int(os.environ["TITLE"])       # currency
        else: self.stake = 10000

        self.private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048,
            backend=default_backend()
        )

        self._peers = []  # connections with other devices
        self.chain = blockchain.Blockchain()  # copy of blockchain
        self.chain.genesis()  # initiating first block of blockchain
        self.staging = []  # staging data to add to block

        #Socket stuff
        self._port = self.get_port()
        self._host = self.ip()

        #Messages Variables
        self._messages = {}
        self.indexes = []
        self._group = []

        self.public_key = self.private_key.public_key()
        self.random_key = os.urandom(32)
        self.EncryptedKBytes = encryption.encrypt_with_public_key(self.public_key, self.random_key)
        self.EncryptedKString = encrypted_base64 = base64.b64encode(self.EncryptedKBytes).decode('utf-8')
        self.useful_key = os.urandom(32)
        self.drawString = ""

    @Property("QVariantList")
    def messages(self):
        return self._messages

    @Property("QVariantList")
    def group(self):
        return self._group

    @Property("QVariantList")
    def peers(self):
        return self._peers

    @Property(int, notify=portChanged)
    def port(self):
        return self._port

    @Property(str, notify=hostChanged)
    def host(self):
        return self._host

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

    def ip(self):
        """
        Gets host machine IP address
        :return: str
        """
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("40.114.26.190", 80))  # doesn't actually send traffic
        ipa = s.getsockname()[0]
        s.close()
        return ipa

    def get_port(self):
        """
        Gets host machine port value from config file
        :return: int
        """
        return random.randint(1024, 65535)

    @Slot(result=list)
    def get_conversation(self):
        group_str = self.group_to_string(self.group)
        if group_str is None:
            return []
        not_parsed_messages = self.messages[group_str]
        print(self.messages)
        if not_parsed_messages is None:
            return []
        messages_array = []
        for message in not_parsed_messages:
            messages_array.append(str(message["port"]) + " (" + message["date"] + "): " + message["message"])
        return messages_array

    @Slot(str, int)
    def addToGroup(self, addr, port):
        for peer in self.peers:
            if peer.addr == addr and peer.port == port:
                self.group.append(peer)
                self.groupChanged.emit()

                if self.group_to_string(self.group) not in self.messages.keys():
                    self.messages[self.group_to_string(self.group)] = []
                    self.messagesChanged.emit("")
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

    def update_group_session_key(self):
        # Szyfrowanie klucza sesji dla każdego użytkownika w grupie
        self.EncryptedKBytes = encryption.encrypt_with_public_key(self.public_key, self.random_key)
        self.EncryptedKString = encrypted_base64 = base64.b64encode(self.EncryptedKBytes).decode('utf-8')

        for peer in self._peers:
            peer.EncryptedKBytes = encryption.encrypt_with_public_key(peer.PKBytes, self.random_key)
            self.EncryptedKString = encrypted_base64 = base64.b64encode(peer.EncryptedKBytes).decode('utf-8')

    def consensus(self):
        """
        Checks the correctness of peers and chains
        """
        chains = []

        for peer in self._peers:
            pass  # get that peer's chain

        for chain in chains:
            self.chain.consensus(chain)

    def get_public_key(self):
        return self.public_key

    def public_key_to_pem(self):
        pem = self.public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
        return pem.decode('utf-8')  # Konwersja do tekstu

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

        data = encryption.encrypt_data_ecb(data, self.useful_key)
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
        keyList.sort()  # wazne sortuj liste by taka sama byla

        keyRaw = " ".join(str(x) for x in keyList)
        self.drawString = keyRaw
        numeric_seed = int.from_bytes(hashlib.sha256(keyRaw.encode('utf-8')).digest())  # Konwersja stringa na liczbę
        random.seed(numeric_seed)
        chosen_peer = random.choice(self._peers)

        return chosen_peer

    @Slot(str, str, str)
    def peer(self, addr, port, PKString):
        """
        Creates peer with second device
        :param addr: Second's device IP address
        :param port: Second's device port
        """
        self._peers.append(Peer(addr, int(port), PKString))
        self.peersChanged.emit() #notify QML

        self.EncryptedKBytes = encryption.encrypt_with_public_key(self.public_key, self.random_key)
        self.EncryptedKString = encrypted_base64 = base64.b64encode(self.EncryptedKBytes).decode('utf-8')

        for peer in self._peers:
            peer.EncryptedKBytes = encryption.encrypt_with_public_key(peer.PKBytes, self.random_key)
            peer.EncryptedKString = base64.b64encode(peer.EncryptedKBytes).decode('utf-8')

        self.sendEncryptedKeys()

        if self._port == self.drawPerson():
            print(self.public_key_to_pem())

            for peer in self._peers:
                print(peer.PKString)

        print("dodano")

    # def delete_peer(self, addr, port):
    #     for peer in self._peers:
    #         if peer.port == port and peer.addr == addr:

    def sendEncryptedKeys(self):
        drawn_peer = self.drawPerson()

        if self.host == drawn_peer.addr and self.port == drawn_peer.port:
            requests.post("http://{}:{}/receive_pk".format(self.host, self.port),
                          json={"addr": self.host, "port": self.port,
                                "message": "-----BEGIN ENCRYPTED KEY-----\n"+self.EncryptedKString+"\n"})
            for peer in self._peers:
                requests.post("http://{}:{}/receive_pk".format(peer.addr, peer.port),
                              json={"addr": self.host, "port": self.port,
                                    "message": "-----BEGIN ENCRYPTED KEY-----\n"+peer.EncryptedKString+"\n"})

    @Slot(str)
    def send_mes(self, message):
        """
        Sends message to other device
        :param message: message to be sent
        """
        appended_message = False

        date = datetime.datetime.now().isoformat()

        for peer in self.group:
            encrypted_message = encryption.encrypt_data_ecb(message, self.useful_key)
            group = self.group_to_string(self.group)
            print("======================")
            print(group)
            print("======================")
            response = requests.post("http://{}:{}/receive_message".format(peer.addr, peer.port),
                          json={"addr": self.host, "port": self.port, "message": encrypted_message, "date": date, "group": group})

            if response.status_code == 200 and not appended_message:
                response = requests.post("http://{}:{}/receive_message".format(self.host, self.port),
                                         json={"addr": self.host, "port": self.port, "message": encrypted_message, "date": date, "group": group})

                if response.status_code == 200:
                    appended_message = True
                    #self.messagesChanged.emit(message)


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
                    decrypted_message = encryption.decrypt_data_ecb(message["message"], self.useful_key)
                    messages += message["user"] + " (" + message["date"] + "): " + decrypted_message + "\n"
            return messages

        except Exception as e:
            return e

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

    def remove_messages_block(self, host_addr):
        """
        :param host_addr: sender IP address
        """
        try:
            return requests.post("http://{}:{}/remove_messages".format(host_addr, self.port))
        except Exception as e:
            return e


    def serve_chain(self, app):
        app.run("0.0.0.0", self.port)

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
            time.sleep(5)

    def add_blocks(self):
        """
        Adds blocks to blockchain
        """
        while True:

            if len(self.staging) > 0:
                print("Mining new block...")
                self.add_block()
                print("Added new block!")
                self.staging = []
            else:
                time.sleep(5)

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

    def __init__(self, address, port, PKString):
        """
        Creates connection with second device
        :param address: Second device's IP address
        :param port: Second device's port
        """
        super().__init__()

        self._nickname = "user" #narazie stały zeby qml dzialal
        self._addr = address
        self._port = port
        self._PKString = PKString

        self.PKBytes = encryption.load_public_key_from_pem(PKString)
        self.EncryptedKBytes = encryption.encrypt_with_public_key(self.PKBytes, os.urandom(32))
        self.EncryptedKString = base64.b64encode(self.EncryptedKBytes).decode('utf-8')

    @Property(int, notify=portChanged)
    def port(self):
        return self._port

    @Property(str, notify=addrChanged)
    def addr(self):
        return self._addr

    @Property(str, notify=nicknameChanged)
    def nickname(self):
        return self._nickname

    @Property(str, notify=PKStringChanged)
    def PKString(self):
        return self._PKString

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

    @nickname.setter
    def nickname(self, new_val):
        if self._nickname != new_val:
            self._nickname = new_val
            self.nicknameChanged.emit()

    def get_chain(self):
        """
        Gets blockchain from the second device
        :return: Blockchain
        """
        print("Fetching chain from {}".format((self._addr, self._port)))

        message = requests.get("http://{}:{}/chain".format(self._addr, self._port)).text

        return blockchain.Blockchain.fromjson(message)

