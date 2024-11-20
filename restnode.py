import base64
import hashlib
import os
import socket
import time
import requests
import random
import blockchain
import encryption

from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives import serialization

from PySide6.QtCore import QObject, Signal, Slot, Property

"""
PEARSCOIN CHAIN TRANSFER PROTOCOL:

MESSAGE TYPES:

Message     Description         Response
/chain      Get current chain   JSON chain object

"""

def ip():
    """
    Gets host machine IP address
    :return: str
    """
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("40.114.26.190", 80))  # doesn't actually send traffic
    ipa = s.getsockname()[0]
    s.close()
    return ipa

def get_port():
    """
    Gets host machine port value from config file
    :return: int
    """
    return random.randint(1024, 65535)

def private_key_to_pem(private_key):
    pem_private_key = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,  # Kodowanie PEM
        format=serialization.PrivateFormat.TraditionalOpenSSL,  # Format klucza
        encryption_algorithm=serialization.NoEncryption()  # Bez hasła
    )
    return pem_private_key.decode('utf-8')

def public_key_to_pem(public_key):
    pem = public_key.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )

    return pem.decode('utf-8')  # Konwersja do tekstu

def load_public_key_from_pem(pem_data):
    public_key = serialization.load_pem_public_key(
        pem_data.encode('utf-8'),  # Konwersja tekstu na bajty
        backend=default_backend()
    )

    return public_key

def encrypt_with_public_key(public_key, key):
    """Szyfrowanie klucza AES przy użyciu klucza publicznego RSA."""
    return public_key.encrypt(
        key,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )
    )

class Node(QObject):
    peersChanged = Signal() #emit if peers are in any way changed

    def __init__(self, port):
        super().__init__()
        """
        Creates a node
        :param port: Host machine port
        """

        self._peers = []                                     # connections with other devices
        self.chain = blockchain.Blockchain()                # copy of blockchain
        self.chain.genesis()                                # initiating first block of blockchain
        self.staging = []                                   # staging data to add to block

        if "TITLE" in os.environ:
            self.stake = 10000 * int(os.environ["TITLE"])       # currency
        else:
            self.stake = 10000

        self.private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048,
            backend=default_backend()
        )

        self.public_key = self.private_key.public_key()
        self.random_key = os.urandom(32)
        self.EncryptedKBytes = encrypt_with_public_key(self.public_key, self.random_key)
        self.EncryptedKString = encrypted_base64 = base64.b64encode(self.EncryptedKBytes).decode('utf-8')
        self.useful_key = os.urandom(32)
        self.drawString = ""

        # socket stuff
        self.port = port

    @Property("QVariantList", notify=peersChanged)
    def peers(self):
        return self._peers

    def update_group_session_key(self):
        # Szyfrowanie klucza sesji dla każdego użytkownika w grupie
        self.EncryptedKBytes = encrypt_with_public_key(self.public_key, self.random_key)
        self.EncryptedKString = encrypted_base64 = base64.b64encode(self.EncryptedKBytes).decode('utf-8')

        for peer in self._peers:
            peer.EncryptedKBytes = encrypt_with_public_key(peer.PKBytes, self.random_key)
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

    def drawPerson(self):
        keyList = []

        for peer in self._peers:
            keyList.append(peer.port)

        keyList.append(self.port)
        keyList.sort()  # wazne sortuj liste by taka sama byla

        keyRaw = " ".join(str(x) for x in keyList)
        self.drawString = keyRaw
        numeric_seed = int.from_bytes(hashlib.sha256(keyRaw.encode('utf-8')).digest())  # Konwersja stringa na liczbę
        random.seed(numeric_seed)
        chosen_port = random.choice(keyList)

        return chosen_port

    @Slot(str, str, str)
    def peer(self, addr, port, PKString):
        """
        Creates peer with second device
        :param addr: Second's device IP address
        :param port: Second's device port
        """
        self._peers.append(Peer(addr, int(port), PKString))
        self.peersChanged.emit() #notify QML

        self.EncryptedKBytes = encrypt_with_public_key(self.public_key, self.random_key)
        self.EncryptedKString = encrypted_base64 = base64.b64encode(self.EncryptedKBytes).decode('utf-8')

        for peer in self._peers:
            peer.EncryptedKBytes = encrypt_with_public_key(peer.PKBytes, self.random_key)
            peer.EncryptedKString = base64.b64encode(peer.EncryptedKBytes).decode('utf-8')

        self.sendEncryptedKeys()

        if self.port == self.drawPerson():
            print(self.public_key_to_pem())

            for peer in self._peers:
                print(peer.PKString)

        print("dodano")

    # def delete_peer(self, addr, port):
    #     for peer in self._peers:
    #         if peer.port == port and peer.addr == addr:



    def sendEncryptedKeys(self):
        drawnPerson = self.drawPerson()

        if self.port == self.drawPerson():
            requests.post("http://{}:{}/send_message".format(ip(), self.port),
                          json={"addr": ip(), "port": self.port,
                                "message": "-----BEGIN ENCRYPTED KEY-----\n"+self.EncryptedKString+"\n"})
            for peer in self._peers:
                requests.post("http://{}:{}/send_message".format(peer.addr, peer.port),
                              json={"addr": peer.addr, "port": peer.port,
                                    "message": "-----BEGIN ENCRYPTED KEY-----\n"+peer.EncryptedKString+"\n"})

    @Slot(str,str)
    def send_mes(self, host_addr, message):
        """
        Sends message to other device
        :param host_addr: Sender IP address
        :param message: message to be sent
        """
        appended_message = False

        for peer in self._peers:
            encrypted_message = encryption.encrypt_data_ecb(message, self.useful_key)
            response = requests.post("http://{}:{}/send_message".format(host_addr, self.port),
                          json={"addr": peer.addr, "port": peer.port, "message": encrypted_message})

            if response.status_code == 200 and not appended_message:
                response = requests.post("http://{}:{}/send_message".format(host_addr, self.port),
                                         json={"addr": host_addr, "port": self.port, "message": encrypted_message})

                if response.status_code == 200:
                    appended_message = True


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

        self.PKBytes = load_public_key_from_pem(PKString)
        self.EncryptedKBytes = encrypt_with_public_key(self.PKBytes, os.urandom(32))
        self.EncryptedKString = base64.b64encode(self.EncryptedKBytes).decode('utf-8')

    @Property(int)
    def port(self):
        return self._port

    @Property(str)
    def addr(self):
        return self._addr

    @Property(str)
    def nickname(self):
        return self._nickname

    @Property(str)
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

