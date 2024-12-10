import datetime
import json
import threading
import flask
import global_constants

from flask import jsonify, request
from http import HTTPStatus
from PySide6.QtCore import QObject

from source.project import Project


class Networking(QObject):
    def __init__(self, user):
        super().__init__()

        self.user = user  #Reference to the User instance
        self.buffered_messages = []
        self.block_time_creation = datetime.datetime.now()
        self.new_block_creation = False
        self.participants = []
        self.drawn_indexes = []

        #Initialize the Flask app as an instance variable
        self.app = flask.Flask(__name__)

        #Register the routes directly as methods of this class
        self.register_routes()

    def register_routes(self):
        """ Register all routes within the class """

        @self.app.route("/chain")
        def chain():
            """
            Sends back a blockchain
            :return: HTTPStatus.OK with str - JSON representation of the chain. | HTTPStatus.IM_USED
            """
            if self.user.buffer is None:
                return self.user.chain.jsonrep()
            else:
                return jsonify({"error": "This peer is currently proceeding adding a new block to its blockchain! Try again later!"}), HTTPStatus.IM_USED

        @self.app.route('/receive_message', methods=['POST'])
        def receive_message():
            """
            Receives a message from the other peer
            :return: HTTPStatus.OK | HTTPStatus.BAD_REQUEST
            """
            message = request.json
            group = message["group"]

            if message:
                try:
                    self.user.messages[group].append(message)
                    if self.user.group_to_string(self.user.group) == group:
                        #Emit signal only if the user is currently displaying given chat group
                        self.user.messagesAppend.emit(self.user.decrypt_single_message(message))
                    self.buffered_messages.append(message)

                    return jsonify({"status": "Message received!"}), HTTPStatus.OK
                except KeyError:
                    return jsonify({"error": "There is no group chat with given key!"}), HTTPStatus.BAD_REQUEST
            else:
                return jsonify({"error": "Got no message"}), HTTPStatus.BAD_REQUEST

        @self.app.route('/receive_pk', methods=['POST'])
        def receive_pk():
            """
            Receives a public key from the other peer
            :return: HTTPStatus.OK | HTTPStatus.BAD_REQUEST
            """
            public_key = request.json
            editedMessage = public_key["message"].replace(global_constants.ENCRYPTED_KEY_BEGIN, "").replace("\n", "")

            self.user.useful_key = self.user.convert_key(editedMessage)

            if public_key:
                return jsonify({"status": "Public key received!"}), HTTPStatus.OK
            else:
                return jsonify({"error": "Got no public key"}), HTTPStatus.BAD_REQUEST

        @self.app.route('/receive_messages_to_be_verified', methods=['POST'])
        def receive_messages_to_be_verified():
            """
            Receives messages block and saves it to the buffer
            :return: HTTPStatus.OK
            """
            json_array = request.json
            self.user.buffer = json_array.get("block")
            group = json_array.get("group")
            self.user.send_digital_signature(group)
            return jsonify({"status": "Messages were successfully saved"}), HTTPStatus.OK

        @self.app.route('/receive_signature', methods=['POST'])
        def receive_signature():
            """
            Receives a signature to use in the creation of the block
            :return: HTTPStatus.OK
            """
            json_array = request.json
            host = json_array.get("host")
            port = json_array.get("port")
            signature = json_array.get("signature")
            print("Przed dodaniem jest tyle blokow: " + str(len(self.user.chain.blocks)))
            self.user.create_a_block(host, port, signature)
            print("Po dodaniu jest tyle blokow: " + str(len(self.user.chain.blocks)))
            return jsonify({"status": "Signature was successfully used"}), HTTPStatus.OK

        @self.app.route('/new_nickname', methods=['POST'])
        def new_nickname():
            json_array = request.json
            host = json_array.get("host")
            port = json_array.get("port")
            nickname = json_array.get("nickname")
            for peer in self.user.peers:
                if peer.host == host and int(peer.port) == int(port):
                    peer.nickname = nickname
                    self.user.nicknameChanged.emit()
                    return jsonify({"status": "Nickname was successfully set"}), HTTPStatus.OK
            return jsonify({"error": "No peer with that IP address and port number was found!"}), HTTPStatus.BAD_REQUEST


        @self.app.route('/add_new_project', methods=['POST'])
        def add_new_project():
            json_str = request.json
            json_array = json.loads(json_str)
            host = json_array.get("host")
            port = json_array.get("port")
            for peer in self.user.peers:
                if peer.host == host and int(peer.port) == int(port):
                    project_str = json_array.get("project")
                    project_to_add = Project().from_JSON(project_str)
                    self.user.projects.append(project_to_add)
                    self.user.projectsChanged.emit()
                    return jsonify({"status": "Project was successfully added"}), HTTPStatus.OK
            return jsonify({"error": "No peer with that IP address was found!"}), HTTPStatus.BAD_REQUEST

        @self.app.route('/reject_me', methods=['GET'])
        def reject_me():
            """
            Reject an invite
            :return: HTTPStatus.OK | HTTPStatus.BAD_REQUEST
            """
            json_array = request.json
            host = json_array.get("host")
            port = json_array.get("port")
            for invite in self.user.invites:
                print(invite)
                if invite["host"] == host and int(invite["port"]) == int(port):
                    print("Usuwam danego uzytkownika z listy zaproszen")
                    self.user.invites.remove(invite)
                    self.user.invitesChanged.emit()
                    break
            return jsonify({"status": "Invitation rejected successfully"}), HTTPStatus.OK

        @self.app.route('/invite_me', methods=['POST'])
        def invite_me():
            """
            Add a new invite
            :return: HTTPStatus.OK | HTTPStatus.BAD_REQUEST
            """
            json_array = request.json
            host = json_array.get("host")
            port = json_array.get("port")
            for invite in self.user.invites:
                if invite["host"] == host and int(invite["port"]) == int(port):
                    return jsonify({"status": "Invitation has been already sent in the past!"}), HTTPStatus.BAD_REQUEST
            #It is a new invitation. Append it to the invites section
            self.user.invites.append({"host": host, "port": port, "received": True})
            print(self.user.invites)
            self.user.invitesChanged.emit()
            if self.user.settings.auto_connection:
                self.user.accept_invitation(host, port)
            return jsonify({"status": "Invitation sent successfully"}), HTTPStatus.OK

        @self.app.route('/establish_a_connection', methods=['GET'])
        def establish_a_connection():
            """
            Etablishes a connection with other peer
            :return: HTTPStatus.OK | HTTPStatus.SERVICE_UNAVAILABLE
            """
            json_array = request.json
            host = json_array.get("host")
            port = json_array.get("port")
            pk = json_array.get("pk")
            nickname = json_array.get("nickname")
            stake = int(json_array.get("stake"))

            try:
                self.user.peer(host, int(port), pk, nickname, stake)
                return jsonify({"status": "Connection established", "pk": self.user.public_key_to_pem(), "nickname": self.user.nickname, "stake": self.user.stake}), HTTPStatus.OK
            except Exception as e:
                return jsonify({"error": str(e)}), HTTPStatus.SERVICE_UNAVAILABLE

    def start(self):
        """
        Starts new threads
        :return: Thread array - Started threads
        """
        server_thread = threading.Thread(target=self.user.serve_chain, args=(self.app,), daemon=True)
        consensus_thread = threading.Thread(target=self.user.check_consensus, daemon=True)
        miner_thread = threading.Thread(target=self.user.add_blocks, daemon=True)

        threads = [server_thread, consensus_thread, miner_thread]

        try:
            server_thread.start()
            consensus_thread.start()
            miner_thread.start()

        except (KeyboardInterrupt, SystemExit):
            server_thread.join()
            consensus_thread.join()
            miner_thread.join()

        return threads
