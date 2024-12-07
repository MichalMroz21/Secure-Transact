import base64
import datetime
import hashlib
import http
import json
import os
import socket
import time
from enum import verify

import requests
import random
import string

from flask_cors.core import ensure_iterable

import global_constants

from encryption import Encryption
from project import Project
from task import Task

from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from http import HTTPStatus

from blockchain import Blockchain

from PySide6.QtCore import QObject, Signal, Slot, Property


class User(QObject):
    peersChanged = Signal() #Emit if peers are in any way changed
    hostChanged = Signal()
    portChanged = Signal()
    messagesAppend = Signal(str)
    groupChanged = Signal()
    nicknameChanged = Signal()
    projectsChanged = Signal()
    activeChanged = Signal()
    invitesChanged = Signal()

    def __init__(self, encryption, settings, host=None, port=None, active=global_constants.CONNECTION_ATTEMPTS, public_key=None, nickname=None, stake=None):
        super().__init__()
        """
        Creates a user
        :param port: Host machine port
        """


        self.private_key = rsa.generate_private_key(
            public_exponent=global_constants.PRIVATE_KEY_PUBLIC_EXPONENT,
            key_size=global_constants.PRIVATE_KEY_SIZE,
            backend=default_backend()
        )

        self.encryption = encryption
        self.settings = settings

        #Connections with other devices
        self.chain = Blockchain()    #Copy of blockchain
        self.chain.genesis()                    #Initiating first block of blockchain
        self.staging = []                       #Staging data to add to block
        self.buffer = None

        #Socket stuff
        self._port = self.get_port() if port is None else port
        self._host = self.ip() if host is None else host

        #User Variables
        self._projects = [Project()]
        self._messages = {}
        self.indexes = []
        self._group = []
        self._peers = []
        self._active = active
        self._invites = []
        self.stake = stake if stake is not None else global_constants.INITIAL_CURRENCY

        self._nickname = self.generate_random_string(global_constants.MAX_NICKNAME_LENGTH) if nickname is None else nickname

        self.public_key = self.private_key.public_key() if public_key is None else self.encryption.load_public_key_from_pem(public_key)
        self.random_key = os.urandom(global_constants.RANDOM_KEY_SIZE)
        self.useful_key = os.urandom(global_constants.USEFUL_KEY_SIZE)

        self.update_encrypted_string(self.public_key, self.random_key)

        self.drawString = ""

    #QVariantMap is for Dictionaries and keys must be strings
    @Property("QVariantMap", notify=groupChanged)
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

    @Property("QVariantList", notify=projectsChanged)
    def projects(self):
        return self._projects

    @Property(bool, notify=activeChanged)
    def active(self):
        return self._active

    @Property("QVariantList", notify=invitesChanged)
    def invites(self):
        return self._invites

    @invites.setter
    def invites(self, new_val):
        if self._invites != new_val:
            self._invites = new_val
            self.activeChanged.emit()

    @active.setter
    def active(self, new_val):
        if self._active != new_val:
            self._active = new_val
            self.activeChanged.emit()

    @projects.setter
    def projects(self, new_val):
        if self._projects != new_val:
            self._projects = new_val
            self.projectsChanged.emit()

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
            self.nicknameChanged.emit(new_val)

    @Slot(str, str, str)
    def change_peers_nickname(self, host, port, new_val):
        for peer in self.peers:
            if peer.host == host and peer.port == int(port):
                peer.nickname = new_val
                self.peersChanged.emit()

    @Slot(result=list)
    def prepare_conversation_history(self):
        group_str = self.group_to_string(self.group)

        if group_str is None:
            return []
        print(self.messages)

        not_parsed_messages = self.messages[group_str]

        if not_parsed_messages is (None or []):
            return []

        messages = []

        for message in not_parsed_messages:
            messages.append(self.decrypt_single_message(message))

        return messages

    @Slot(int, result=QObject)
    def get_project(self, project_index):
        if project_index is None or project_index < 0 or project_index >= len(self.projects):
            return None
        else:
            return self.projects[project_index]

    @Slot(int, QObject, str, str, str, str)
    def create_a_new_task(self, project_index, assignee, name, priority, due_date, tags):
        parsed_priority = None
        try:
            parsed_priority = int(priority)
            parsed_priority = parsed_priority if -1 < parsed_priority < global_constants.TASK_PRIORITIES_MAX_VALUE else 1
        except ValueError:
            parsed_priority = priority.lower()
            if parsed_priority == "low":
                parsed_priority = 0
            elif parsed_priority == "medium":
                parsed_priority = 1
            elif parsed_priority == "high":
                parsed_priority = 2
            elif parsed_priority == "urgent":
                parsed_priority = 3
            else:
                parsed_priority = 1

        tags_list = tags.split(", ")
        date = datetime.datetime.strptime(due_date, "%Y-%m-%d")
        self.projects[project_index].tasks.append(Task(assignee=assignee, name=name, priority=parsed_priority, due_date=date, tags=tags_list))
        #self.projects[project_index].tasksChanged.emit()
        print(self.projects[project_index].tasks)

    @Slot(str, int)
    def addToGroup(self, host, port):
        for peer in self.peers:
            if peer.host == host and peer.port == port:
                for member in self.group:
                    if member == peer:
                        #Do not add the same member to the group again
                        return None
                self.group.append(peer)

                group_str = self.group_to_string(self.group)

                if group_str not in self.messages:
                    self.messages[group_str] = []

                self.groupChanged.emit()
                break

    @Slot(str, int)
    def removeFromGroup(self, host, port):
        for peer in self.peers:
            if peer.host == host and peer.port == port:
                for member in self.group:
                    if member == peer:
                        #Delete only if the given peer is in the group
                        self.group.remove(peer)
                        self.groupChanged.emit()
                        return None

    @Slot(str, int)
    def removeFromPeers(self, host, port):
        for peer in self.peers:
            if peer.host == host and peer.port == port:
                self.peers.remove(peer)
                self.peersChanged.emit()
                break

    @Slot(str, str, str, str, int)
    def peer(self, host, port, public_key, nickname="User", stake=global_constants.INITIAL_CURRENCY):
        """
        Creates peer with second device
        :param host: Second's device IP address
        :param port: Second's device port
        :param public_key: Second's device public key
        :param nickname: Second's device nickname
        :param stake: Second's device currency
        """
        new_user = User(self.encryption, self.settings, host, int(port), global_constants.CONNECTION_ATTEMPTS, public_key, nickname, stake)
        self._peers.append(new_user)
        self.peersChanged.emit() #Notify QML

        temp_group = [new_user]
        group_str = self.group_to_string(temp_group)

        if group_str not in self.messages:
            #In case if this person was a peer in the past but was deleted from the peers list
            self.messages[group_str] = []

        print(self.group)

        self.update_encrypted_string(self.public_key, self.random_key)

        for peer in self._peers:
            peer.update_encrypted_string(peer.public_key, self.random_key)

        self.send_encrypted_keys()

    @Slot(str, str)
    def send_invitation(self, host, port):
        """
        Sends invitation to user
        :param host: User's IP address
        :param port: User's port
        :return:
        """
        for invite in self.invites:
            if invite["host"] == host and int(invite["port"]) == int(port):
                #Invitation has been already sent to that person
                return None
        # send request to examined peer
        try:
            response = requests.post("http://{}:{}/invite_me".format(host, port),
                                    json={"host": self.host, "port": self.port, "pk": self.public_key_to_pem(),
                                          "nickname": self.nickname, "stake": self.stake})
            if response.status_code == http.HTTPStatus.OK:
                #Remember the user which was invited
                self.invites.append({"host": host, "port": port, "received": False})
                print(self.invites)
        except Exception as e:
            print(e)

    @Slot(str, str)
    def accept_invitation(self, host, port):
        """
        Accepts invitation from the user
        :param host: User's IP address
        :param port: User's port
        :return:
        """
        for invite in self.invites:
            if invite["host"] == host and int(invite["port"]) == int(port):
                if self.verify_peer_connection(host, port):
                    self.invites.remove(invite)
                    self.invitesChanged.emit()
                break

    @Slot(str, str)
    def reject_invitation(self, host, port):
        """
        Rejects invitation from the user
        :param host: User's IP address'
        :param port: User's port'
        :return:
        """
        for invite in self.invites:
            if invite["host"] == host and int(invite["port"]) == int(port):
                requests.get("http://{}:{}/reject_me".format(host, port),
                                         json={"host": self.host, "port": self.port})
                self.invites.remove(invite)
                self.invitesChanged.emit()
                break

    @Slot(str, str, result=bool)
    def verify_peer_connection(self, host, port):
        """
        Verify if given peer is correct.
        :param examined_peer: Peer which connection is tested for
        :return: boolean, str
        """
        try:
            # send request to examined peer
            response = requests.get("http://{}:{}/establish_a_connection".format(host, port),
                                    json={"host": self.host, "port": self.port, "pk": self.public_key_to_pem(), "nickname": self.nickname, "stake": self.stake})
            # check if examined peer responded with a correct status code
            if response.status_code == http.HTTPStatus.OK:
                # add new peer
                self.peer(host, int(port), response.json()["pk"], response.json()["nickname"], int(response.json()["stake"]))
                self.peersChanged.emit()  # notify QML
                return True
            return False
        except Exception as e:
            print(e)
            return False

    @Slot(str, "QVariantList")
    def add_new_project_from_FE(self, name, users):
        #We need to add ourselves to be in the project's users list because in FE we don't need to add ourselves
        new_users_list = [self]
        for user in users:
            new_users_list.append(user)
        self.projects.append(Project(name, new_users_list))

    @Slot(int, "QVariantList")
    def update_project_users(self, index, users):
        print(self.projects[index].name)
        print(len(self.projects[index].users))
        for user in users:
            if user not in self.projects[index].users:
                self.projects[index].users.append(user)
                print(len(self.projects[index].users))


    @Slot(str)
    def send_mes(self, message):
        """
        Sends message to other device
        :param host: Sender IP address
        :param message: message to be sent
        """
        appended_message = False

        date = datetime.datetime.now().isoformat()

        for peer in self.group:
            encrypted_message = self.encryption.encrypt_data_ecb(message, self.useful_key)
            group = self.group_to_string(self.group)

            response = requests.post("http://{}:{}/receive_message".format(peer.host, peer.port),
                                     json={"host": self.host, "port": self.port, "message": encrypted_message,
                                           "date": date, "group": group})

            if response.status_code == HTTPStatus.OK and not appended_message:
                self.messages[self.group_to_string(self.group)].append({"host": self.host, "port": self.port, "message": encrypted_message,
                                               "date": date, "group": group})
                self.messagesAppend.emit(str(self.port) + " (" + date + "): " + message)
                appended_message = True
                if len(self.messages[self.group_to_string(self.group)]) % global_constants.MESSAGES_IN_BLOCK == 0:
                    self.send_block_being_verified()

    @Slot(str, str)
    def get_messages_block(self, host):
        """
        :param host: sender IP address
        :return: messages
        """
        try:
            return requests.get("http://{}:{}/get_messages".format(host, self.port)).json()
        except Exception as e:
            return e

    @Slot(str, str, bool, result=QObject)
    def find_peer(self, host, port, includeMyself=False):
        if includeMyself:
            print("czy tu wszedlem?")
            print(self.host + ":" + str(self.port))
            if self.host == host and int(self.port) == int(port):
                return self
        for peer in self.peers:
            if peer.host == host and int(peer.port) == int(port):
                return peer
        return None

    def decrypt_single_message(self, message_data):
        decrypted_message = self.encryption.decrypt_data_ecb(message_data["message"], self.useful_key)
        return str(message_data["port"]) + " (" + message_data["date"] + "): " + decrypted_message

    def generate_random_string(self, n):
        """
        Generates random string
        :param n: length of string
        :return: str
        """
        return ''.join(random.choices(string.ascii_letters + string.digits, k=n))

    def update_encrypted_string(self, public_key, random_key):
        self.EncryptedKBytes = self.encryption.encrypt_with_public_key(public_key, random_key)
        self.EncryptedKString = base64.b64encode(self.EncryptedKBytes).decode('utf-8')

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
            group_strings.append(str(peer_str.host) + ":" + str(peer_str.port))

        group_strings.sort()
        group_string = ",".join(group_strings)

        return group_string

    def string_to_group(self, string, appendSelf=False):
        if not string:
            return None

        group = []
        result = string.split(",")

        for peer_str in result:
            splitted = peer_str.split(":")
            host = splitted[0]
            port = int(splitted[1])
            if appendSelf:
                if self.host == host and self.port == port:
                    group.append(self)
                    continue
            for peer in self.peers:
                if peer.host == host and peer.port == port:
                    group.append(peer)
                    break

        return group

    def drawPerson(self):
        keyList = []

        for peer in self._peers:
            keyList.append([peer.host, peer.port])

        keyList.append([self.host, self.port])
        keyList.sort(key=lambda x: x[1])  #Important sort list to make it the same

        keyRaw = " ".join(f"{x[0]}:{x[1]}" for x in keyList)

        self.drawString = keyRaw

        numeric_seed = int.from_bytes(hashlib.sha256(keyRaw.encode('utf-8')).digest())  #String to int
        random.seed(numeric_seed)
        chosen_peer = random.choice(keyList)

        return chosen_peer

    def convert_key(self, base64keyEncypted):
        byteKey = base64.b64decode(base64keyEncypted)
        decryptedSessionKey = self.private_key.decrypt(
            byteKey,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            ))

        #sessionKey = user.random_key
        #privateKey = user.private_key
        #pemPrivateKey = encryption.private_key_to_pem(privateKey)
        #publicKey = user.public_key
        #pemPublicKey = encryption.public_key_to_pem(publicKey)
        #encryptedKey = user.EncryptedKBytes
        #encryptedKString = user.EncryptedKString

        print("Convertions")

        return decryptedSessionKey

    @Slot(str)
    def send_block_being_verified(self):
        """
        Send to each connected peer
        :return:
        """
        messages_list = list(self.messages[self.group_to_string(self.group)])[
                        -global_constants.MESSAGES_IN_BLOCK:]
        json_block = json.dumps(messages_list, sort_keys=True, separators=(',', ':'))

        for peer in self.peers:
            if peer.active == global_constants.CONNECTION_ATTEMPTS:
                #This check prevents from sending to the peer that for sure is not connected to the network
                try:
                    #Even with a previous check it is not obvious that the peer is connected to the network
                    requests.post("http://{}:{}/receive_messages_to_be_verified".format(peer.host, peer.port),
                            json={"host": self.host, "port": self.port, "group" : self.group_to_string(self.group), "block": json_block})
                except Exception as e:
                    print(e)
        self.buffer = messages_list
        self.send_digital_signature(self.group_to_string(self.group))

    @Slot(result=QObject)
    def draw_verifier(self, group):
        """
        Draw a person which will verify correctness of data to be included in the block
        :param group: User[] - List of candidates in PoS
        :return: User - Candidate who has to verify data to be included in the block
        """
        person_stake_list = []
        for peer in group:
            person_stake_list.append(peer)
        person_stake_list.sort(key=lambda x: x.port)
        stake_list = [x.stake for x in person_stake_list]
        keyRaw = " ".join(str(x.port) for x in person_stake_list)
        self.drawString = keyRaw
        numeric_seed = int.from_bytes(hashlib.sha256(keyRaw.encode('utf-8')).digest())  # Konwersja stringa na liczbę
        random.seed(numeric_seed)  # zmiana seeda dla losowania weryfikatora
        chosen_peer = random.choices(person_stake_list, weights=stake_list, k=1)[0]
        return chosen_peer

    @Slot(str)
    def send_digital_signature(self, group):
        """
        :param group: str - Key in user.messages[Key]
        """
        print(group)
        grp = self.string_to_group(group, True)
        drawn_verifier = self.draw_verifier(grp)
        print("Drawn Verifier " + str(drawn_verifier.nickname))
        if drawn_verifier == self:
            jsonAString = json.dumps(self.buffer, sort_keys=True, separators=(',', ':'))
            base64Signature = self.encryption.createSignatureBase64(self, jsonAString)
            requests.post("http://{}:{}/receive_signature".format(self.host, self.port),
                          json={"host": self.host, "port": self.port,
                                "signature": base64Signature})
            for peer in self.peers:
                if peer.active == global_constants.CONNECTION_ATTEMPTS:
                    # This check prevents from sending to the peer that for sure is not connected to the network
                    try:
                        # Even with a previous check it is not obvious that the peer is connected to the network
                        requests.post("http://{}:{}/receive_signature".format(peer.host, peer.port),
                                  json={"host": self.host, "port": self.port,
                                        "signature": base64Signature})
                    except Exception as e:
                        print(e)

    @Slot(str, str, str)
    def create_a_block(self, host, port, signature):
        # editedMessage = message["message"].replace("-----BEGIN DIGITAL SIGNATURE-----", "").replace("\n", "")
        # pierwsza_gwiazda = editedMessage.find("*")
        # druga_gwiazda = editedMessage.find("*", pierwsza_gwiazda + 1)
        # numerNadawcy = int(editedMessage[pierwsza_gwiazda + 1:druga_gwiazda])
        # kluczNadawcy = ""
        # for peer in me.peers:
        #     if peer.port == numerNadawcy:
        #         kluczNadawcy = peer.PKString
        # if me.port == numerNadawcy:
        #     kluczNadawcy = me.public_key_to_pem()
        # clearedMessage = editedMessage[druga_gwiazda + 1:].strip()
        # uniqueSignature = True
        # for elem in me.chain.blocks:
        #     if elem.digitalEncryption == clearedMessage:
        #         uniqueSignature = False
        # if uniqueSignature:
        #     czystyKluczNadawcy = kluczNadawcy.replace("-----BEGIN PUBLIC KEY-----", "").replace("\n", "")
        #     me.chain.add_signature_block(currentList, clearedMessage, numerNadawcy, czystyKluczNadawcy)
        #     it = me  # debufowanie
        #     me.remove_messages_block(host)
        #     global last_message_index
        #     last_message_index = 0
        #     global read_from_block
        #     read_from_block = True
        #     parsed_messages += editedMessage + "\n"
        #     print(editedMessage)

        signatory = None
        if self.host == host and int(self.port) == port:
            signatory = self
        if signatory is None:
            for peer in self.peers:
                if peer.host == host and int(peer.port) == int(port):
                    signatory = peer
                    break
        uniqueSignature = True
        for elem in self.chain.blocks:
            if elem.digitalEncryption == signature:
                uniqueSignature = False
                self.buffer = None
        if uniqueSignature:
            public_key = self.encryption.public_key_to_pem(signatory.public_key)
            public_key = public_key.replace("-----BEGIN PUBLIC KEY-----", "").replace("\n", "")
            self.chain.add_signature_block(self.buffer, signature, signatory.host, signatory.port, public_key)
            self.buffer = None




    @Slot(str)
    def sendBlockBeingVerified(self, messages):
        parsed_messages = ""
        messages[:] = [elem for elem in messages if not elem["message"].startswith("-----BEGIN JSON-----")]
        for message in messages:
            editedMessage = message["message"].replace("-----BEGIN JSON-----", "").replace("\n", "")
            ListOfJSON = json.loads(editedMessage)
            ListWithoutKeys = [d for d in ListOfJSON if not d["message"].startswith("-----BEGIN ENCRYPTED KEY-----")]
            global currentList
            currentList = ListWithoutKeys
            self.sendDigitalSignature(ListWithoutKeys, self)
            # me.remove_messages_block(host)
            parsed_messages += "" + "Wyslano JSON" + "\n"
            print(editedMessage)

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


    def sendDigitalSignature(self, ListOfJSON):
        jsonMessages = self.get_messages_block(self.ip()) # to tylko w sieciach lokalnych działa
        # time.sleep(5) do sprawdzenia czy sa nowe wiadomosci
        drawnVerifier = self.drawVerifier()
        print("Drawn Verifier " + str(drawnVerifier))
        if drawnVerifier == self.port:
            self.remove_single_message_JSON(self.ip())
            for count, jsonSingleMessage in enumerate(jsonMessages):
                if jsonMessages[count] == ListOfJSON[0]:
                    length = len(ListOfJSON)
                    identicalResult = jsonMessages[count:count+length] == ListOfJSON
                    if identicalResult:
                        jsonAString = json.dumps(ListOfJSON, sort_keys=True, separators=(',', ':'))
                        base64Signature = self.encryption.createSignatureBase64(jsonAString)
                        requests.post("http://{}:{}/send_message".format(self.ip(), self.port),
                          json={"addr": self.ip(), "port": self.port,
                                "message": "-----BEGIN DIGITAL SIGNATURE-----\n*" + str(drawnVerifier) + "*" + base64Signature + "\n"})
                        for peer in self.peers:
                            requests.post("http://{}:{}/send_message".format(peer.addr, peer.port),
                              json={"addr": peer.addr, "port": peer.port,
                                    "message": "-----BEGIN DIGITAL SIGNATURE-----\n*" + str(drawnVerifier) + "*" + base64Signature + "\n"})


    # def drawPerson(self):
    #     keyList = []
    #     for peer in self.peers:
    #         keyList.append(peer.port)
    #     keyList.append(self.port)
    #     keyList.sort()  # wazne sortuj liste by taka sama byla
    #     keyRaw = " ".join(str(x) for x in keyList)
    #     self.drawString = keyRaw
    #     numeric_seed = int.from_bytes(hashlib.sha256(keyRaw.encode('utf-8')).digest())  # Konwersja stringa na liczbę
    #     random.seed(numeric_seed)
    #     chosen_port = random.choice(keyList)
    #     return chosen_port

    def send_encrypted_keys(self):
        drawn_peer = self.drawPerson()

        if self.host == drawn_peer[0] and self.port == drawn_peer[1]:
            requests.post("http://{}:{}/receive_pk".format(self.host, self.port),
                          json={"host": self.host, "port": self.port,
                                "message": global_constants.ENCRYPTED_KEY_BEGIN + "\n" + self.EncryptedKString + "\n"})

            for peer in self._peers:
                requests.post("http://{}:{}/receive_pk".format(peer.host, peer.port),
                              json={"host": self.host, "port": self.port,
                                    "message": global_constants.ENCRYPTED_KEY_BEGIN + "\n" + peer.EncryptedKString + "\n"})

    def remove_messages_block(self, host):
        """
        :param host: sender IP address
        """
        try:
            return requests.post("http://{}:{}/remove_messages".format(host, self.port))
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
                try:
                    #If peer was not active for at least three times then try to get a chain only every 5th attempt
                    inactive = False

                    if peer.active < 1:
                        if abs(peer.active) == global_constants.RECONNECTION_DELAY:
                            print("Trying to connect with inactive peer {}:{}.".format(peer.host, peer.port))
                            inactive = True
                            peer.active = 0
                            pass
                        else:
                            peer.active -= 1
                            continue

                    print("Fetching chain from {}".format((peer.host, peer.port)))

                    if self.buffer is None:
                        #If there is not an empty buffer then we are in the process of adding a new block so this check prevents this
                        response = requests.get("http://{}:{}/chain".format(peer.host, peer.port))
                        message = response.text
                        if response.status_code == HTTPStatus.OK:
                            chain = self.chain.fromjson(message)

                    peer.active = global_constants.CONNECTION_ATTEMPTS

                    # If the function continues running in this place then it was a successful connection so the peer is active
                    if inactive:
                        print("Inactive peer {}:{} changed its status to active".format(peer.host, peer.port))
                        self.activeChanged.emit()

                    if self.chain.consensus(chain):
                        print("Checked chain with {}, ours is right".format(
                            (peer.host, peer.port)))
                    else:
                        print("Checked chain with {}, theirs is right".format(
                            (peer.host, peer.port)))

                except requests.exceptions.RequestException:
                    if(peer.active == 1):
                        print("That was the last attempt to connect with peer {}:{}. Changing its status to inactive.".format(peer.host, peer.port))
                        peer.active -= 1
                        self.activeChanged.emit()
                        peer.active += 1
                    elif(peer.active == 0):
                        print("Peer {}:{} is still inactive".format(peer.host, peer.port))
                    else:
                        print("Could not receive information from {}:{} {} attempts until it is considered inactive.".format(peer.host, peer.port, (peer.active - 1)))

                    peer.active -= 1

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
