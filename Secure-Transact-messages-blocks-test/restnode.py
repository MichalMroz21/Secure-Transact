import socket
import select
import threading
import json
import time
import datetime
import os
import base64

import flask
import requests
import random
import hashlib

from flask import jsonify, request

import blockchain
import encryption

from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives import serialization

import restnode

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
    Gets host machine port value
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

def deterministicHash(dataString):
    numeric_seed = int.from_bytes(hashlib.sha256(dataString.encode('utf-8')).digest())
    return numeric_seed

class Node:
    def __init__(self, port):
        self.peers = []
        self.chain = blockchain.Blockchain()
        self.chain.genesis()
        self.staging = []  # staging data to add to block
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
        self.stake = 10000

        # socket stuff
        self.port = port

    def update_group_session_key(self):
        # Szyfrowanie klucza sesji dla każdego użytkownika w grupie
        self.EncryptedKBytes = encrypt_with_public_key(self.public_key, self.random_key)
        self.EncryptedKString = encrypted_base64 = base64.b64encode(self.EncryptedKBytes).decode('utf-8')
        for peer in self.peers:
            peer.EncryptedKBytes = encrypt_with_public_key(peer.PKBytes, self.random_key)
            self.EncryptedKString = encrypted_base64 = base64.b64encode(peer.EncryptedKBytes).decode('utf-8')

    def consensus(self):
        """
        Checks the correctness of peers and chains
        """
        chains = []
        for peer in self.peers:
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

    def createSignature(self, dataStrng):
        data = dataStrng.encode('utf-8')
        signature = self.private_key.sign(
            data,
            padding.PKCS1v15(),  # Deterministyczny algorytm podpisu
            hashes.SHA256()
        )
        return signature

    def createSignatureBase64(self, dataStrng):
        bytesSignature = self.createSignature(dataStrng)
        return base64.b64encode(bytesSignature).decode('utf-8')

    def add_block(self):
        """
        Adds block to be sent to other device
        """
        self.chain.add_block(self.staging, self)

    def add_data(self, data):
        """
        Adds data to the block
        :param data: Data to be sent
        """
        if data != "":
            data += ""
        #data = encryption.encrypt_data_ecb(data, self.useful_key)
        self.staging.append(data)

    def drawVerifier(self):
        personStakeList = []
        for peer in self.peers:
            personValue = {"port": peer.port, "stake": peer.stake}
            personStakeList.append(personValue)
        myValue = {"port": self.port, "stake": self.stake}
        personStakeList.append(myValue)
        personStakeList.sort(key=lambda x: x["port"])  # wazne sortuj liste by taka sama byla
        portSingleList = [x["port"] for x in personStakeList]
        stakeSingleList = [x["stake"] for x in personStakeList]
        keyRaw = " ".join(str(x["port"]) for x in personStakeList)
        self.drawString = keyRaw
        numeric_seed = int.from_bytes(hashlib.sha256(keyRaw.encode('utf-8')).digest())  # Konwersja stringa na liczbę
        random.seed(numeric_seed) #zmiana seeda dla losowania weryfikatora
        chosen_port = random.choices(portSingleList, weights=stakeSingleList, k=1)[0]
        return chosen_port


    def drawPerson(self):
        keyList = []

        for peer in self.peers:
            keyList.append(peer.port)

        keyList.append(self.port)
        keyList.sort()  # wazne sortuj liste by taka sama byla

        keyRaw = " ".join(str(x) for x in keyList)

        self.drawString = keyRaw

        numeric_seed = int.from_bytes(hashlib.sha256(keyRaw.encode('utf-8')).digest())  # Konwersja stringa na liczbę
        random.seed(numeric_seed)
        chosen_port = random.choice(keyList)
        return chosen_port

    def peer(self, addr, port, PKString):
        """
        Creates peer with second device
        :param addr: Second's device IP address
        :param port: Second's device port
        """
        self.peers.append(Peer(addr, port, PKString))
        self.EncryptedKBytes = encrypt_with_public_key(self.public_key, self.random_key)
        self.EncryptedKString = encrypted_base64 = base64.b64encode(self.EncryptedKBytes).decode('utf-8')
        for peer in self.peers:
            peer.EncryptedKBytes = encrypt_with_public_key(peer.PKBytes, self.random_key)
            peer.EncryptedKString = base64.b64encode(peer.EncryptedKBytes).decode('utf-8')

        self.sendEncryptedKeys()

        if self.port == self.drawPerson():
            print(self.public_key_to_pem())
            for peer in self.peers:
                print(peer.PKString)
        print("dodano")

    def sendBlockData(self, blockDataString):
        print("Udane wyslanie" + str(self.port))
        requests.post("http://{}:{}/send_message".format(ip(), self.port),
                      json={"addr": ip(), "port": self.port,
                            "message": blockDataString + "\n"})
        for peer in self.peers:
            requests.post("http://{}:{}/send_message".format(peer.addr, peer.port),
                          json={"addr": peer.addr, "port": peer.port,
                                "message": blockDataString + "\n"})

    def sendEncryptedKeys(self):
        drawnPerson = self.drawPerson()
        if self.port == self.drawPerson():
            requests.post("http://{}:{}/send_message".format(ip(), self.port),
                          json={"addr": ip(), "port": self.port,
                                "message": "-----BEGIN ENCRYPTED KEY-----\n"+self.EncryptedKString+"\n"})
            for peer in self.peers:
                requests.post("http://{}:{}/send_message".format(peer.addr, peer.port),
                              json={"addr": peer.addr, "port": peer.port,
                                    "message": "-----BEGIN ENCRYPTED KEY-----\n"+peer.EncryptedKString+"\n"})

    def sendDigitalSignature(self, ListOfJSON, me):
        jsonMessages = self.get_messages_block(ip()) # to tylko w sieciach lokalnych działa
        # time.sleep(5) do sprawdzenia czy sa nowe wiadomosci
        drawnVerifier = self.drawVerifier()
        print("Drawn Verifier " + str(drawnVerifier))
        if drawnVerifier == self.port:
            me.remove_single_message_JSON(ip())
            for count, jsonSingleMessage in enumerate(jsonMessages):
                if jsonMessages[count] == ListOfJSON[0]:
                    length = len(ListOfJSON)
                    identicalResult = jsonMessages[count:count+length] == ListOfJSON
                    if identicalResult:
                        jsonAString = json.dumps(ListOfJSON, sort_keys=True, separators=(',', ':'))
                        base64Signature = self.createSignatureBase64(jsonAString)
                        requests.post("http://{}:{}/send_message".format(ip(), self.port),
                          json={"addr": ip(), "port": self.port,
                                "message": "-----BEGIN DIGITAL SIGNATURE-----\n*" + str(drawnVerifier) + "*" + base64Signature + "\n"})
                        for peer in self.peers:
                            requests.post("http://{}:{}/send_message".format(peer.addr, peer.port),
                              json={"addr": peer.addr, "port": peer.port,
                                    "message": "-----BEGIN DIGITAL SIGNATURE-----\n*" + str(drawnVerifier) + "*" + base64Signature + "\n"})

    def send_mes(self, host_addr, message):
        for peer in self.peers:
            encrypted_message = encryption.encrypt_data_ecb(message, self.useful_key)
            requests.post("http://{}:{}/send_message".format(host_addr, self.port),
                          json={"addr": peer.addr, "port": peer.port, "message": encrypted_message})

    def view_parsed_messages(self, host_addr):
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

    def get_messages_block(self, host_addr):
        try:
            return requests.get("http://{}:{}/get_messages".format(host_addr, self.port)).json()
        except Exception as e:
            return e

    def remove_messages_block(self, host_addr):
        try:
            return requests.post("http://{}:{}/remove_messages".format(host_addr, self.port))
        except Exception as e:
            return e

    def remove_single_message_JSON(self, host_addr):
        try:
            return requests.post("http://{}:{}/remove_single_message_JSON".format(host_addr, self.port))
        except Exception as e:
            return e

    def remove_single_message_EncryptedKey(self, host_addr):
        try:
            return requests.post("http://{}:{}/remove_single_message_EncryptedKey".format(host_addr, self.port))
        except Exception as e:
            return e

    def serve_chain(self, app):
        app.run("0.0.0.0", self.port)

    def check_consensus(self):
        """
        Checks both blockchains (one from the host machine and other from the second device) which one is correct
        """
        while True:
            for peer in self.peers:
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


class Peer:
    def __init__(self, address, port, PKString):
        """
        Creates connection with second device
        :param address: Second device's IP address
        :param port: Second device's port
        """
        self.addr = address
        self.port = port
        self.stake = 10000
        self.PKString = PKString
        self.PKBytes = load_public_key_from_pem(PKString)
        self.EncryptedKBytes = encrypt_with_public_key(self.PKBytes, os.urandom(32))
        self.EncryptedKString = base64.b64encode(self.EncryptedKBytes).decode('utf-8')

    def get_chain(self):
        """
        Gets blockchain from the second device
        :return: Blockchain
        """
        print("Fetching chain from {}".format((self.addr, self.port)))
        message = requests.get("http://{}:{}/chain".format(self.addr, self.port)).text
        return blockchain.Blockchain.fromjson(message)

    # def send_mes(self, message):
    #
    #     try:
    #         response = requests.post("http://{}:{}/receive_message".format(self.addr, self.port),
    #                                  json={"message": message})
    #         if response.status_code == 200:
    #             print("Message succesfully deployed")
    #             return True
    #         else:
    #             print("Something went wrong")
    #             return False
    #     except Exception as e:
    #         print(e)
    #         return False


def start(listen_port):
    """
    Starts application threads
    :param listen_port: Port to be listened to
    """
    me = Node(listen_port)

    # messages has information about which user sent which message.
    # ["user": "user_address"],["message", "message_content"]
    messages = []

    app = flask.Flask(__name__)

    @app.route("/chain")
    def chain():
        return me.chain.jsonrep()

    @app.route('/send_message', methods=['POST'])
    def send_message():
        """
        Endpoint do wysyłania wiadomości do drugiego użytkownika
        """
        # return Peer("0.0.0.0", listen_port).send_mes()

        port = request.json.get("port")
        addr = request.json.get("addr")
        #target_url = request.json.get("target_url")  # URL serwera odbiorcy
        message = request.json.get("message")  # Wiadomość do wysłania

        if not port or not addr or not message:
            return jsonify({"error": "Musisz podać addr, port i message"}), 400

        try:
            # Wysyłamy wiadomość HTTP POST do endpointu odbiorcy
            date = datetime.datetime.now().strftime("%Y/%m/%d, %H:%M:%S")
            response = requests.post("http://{}:{}/receive_message".format(addr, port),
                          json={"user": request.host, "message": message, "date": date, "ip": addr, "port": port})
            if response.status_code == 200:
                messages.append({"user": request.host, "message": message, "date": date, "ip": addr, "port": port})
                return jsonify({"status": "Message was successfully sent"}), 200
            else:
                return jsonify({"error": "Error occured!"}), response.status_code
        except Exception as e:
            return jsonify({"error": str(e)}), 500


    @app.route('/receive_message', methods=['POST'])
    def receive_message():
        """
        Endpoint do odbierania wiadomości od innego użytkownika
        """
        message = request.json
        print(message.get("message"))
        # print(message)
        if message:
            messages.append(message)
            return jsonify({"status": "Message received!"}), 200
        else:
            return jsonify({"error": "Got no message"}), 400

    @app.route('/get_messages', methods=['GET'])
    def get_messages():
        """
        Endpoint do pobierania wszystkich odebranych wiadomości
        """
        return jsonify(messages)

    @app.route('/remove_messages', methods=['POST'])
    def remove_messages():
        """
        Endpoint do odbierania wiadomości od innego użytkownika
        """
        messages.clear()
        if not messages:
            return jsonify({"status": "Messages removed!"}), 200
        else:
            return jsonify({"error": "Could not remove messages!"}), 400

    @app.route('/remove_single_message_JSON', methods=['POST'])
    def remove_single_message_JSON():
        print(1)
        messages[:] = [elem for elem in messages if not elem["message"].startswith("-----BEGIN JSON-----")]
        print(2)
        if messages:
            return jsonify({"status": "Messages removed!"}), 200
        else:
            return jsonify({"error": "Could not remove messages!"}), 400

    @app.route('/remove_single_message_EncryptedKey', methods=['POST'])
    def remove_single_message_EncryptedKey():
        print(1)
        messages[:] = [elem for elem in messages if not elem["message"].startswith("-----BEGIN ENCRYPTED KEY-----")]
        print(2)
        if messages:
            return jsonify({"status": "Messages removed!"}), 200
        else:
            return jsonify({"error": "Could not remove messages!"}), 400

    server_thread = threading.Thread(target=me.serve_chain, args=(app,))
    consensus_thread = threading.Thread(target=me.check_consensus)
    miner_thread = threading.Thread(target=me.add_blocks)
    #input_thread = threading.Thread(target=me.handle_input)

    server_thread.start()
    consensus_thread.start()
    miner_thread.start()
    #me.handle_input()
    return me
