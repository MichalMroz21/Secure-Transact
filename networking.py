import datetime
import threading
import flask
import requests
import global_constants

from flask import jsonify, request
from http import HTTPStatus
from user import User
from PySide6.QtCore import QObject

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
            return self.user.chain.jsonrep()

        @self.app.route('/send_message', methods=['POST'])
        def send_message():
            port = request.json.get("port")
            addr = request.json.get("addr")
            message = request.json.get("message")

            if not port or not addr or not message:
                return jsonify({"error": "You need to provide address, port and message"}), HTTPStatus.BAD_REQUEST

            try:
                date = datetime.datetime.now().strftime("%Y/%m/%d, %H:%M:%S")
                response = requests.post(f"http://{addr}:{port}/receive_message", json={
                    "user": request.host,
                    "message": message,
                    "date": date,
                    "group": self.user.group_to_string(self.user.group)
                })

                if response.status_code == HTTPStatus.OK:
                    return jsonify({"status": "Message was successfully sent"}), HTTPStatus.OK
                else:
                    return jsonify({"error": "Error occured!"}), response.status_code

            except Exception as e:
                return jsonify({"error": str(e)}), HTTPStatus.INTERNAL_SERVER_ERROR

        @self.app.route('/receive_message', methods=['POST'])
        def receive_message():
            message = request.json

            group = message["group"]
            if message:
                self.user.messages[group].append(message)
                decrypted_message = self.user.encryption.decrypt_data_ecb(message["message"], self.user.useful_key)
                msg_string = str(message["port"]) + " (" + message["date"] + "): " + decrypted_message
                self.user.messagesChanged.emit(msg_string)

                self.buffered_messages.append(message)
                return jsonify({"status": "Message received!"}), HTTPStatus.OK
            else:
                return jsonify({"error": "Got no message"}), HTTPStatus.BAD_REQUEST

        @self.app.route('/receive_pk', methods=['POST'])
        def receive_pk():
            public_key = request.json
            editedMessage = public_key["message"].replace(global_constants.ENCRYPTED_KEY_BEGIN, "").replace("\n", "")
            self.user.useful_key = self.user.convert_key(editedMessage)

            if public_key:
                return jsonify({"status": "Public key received!"}), HTTPStatus.OK
            else:
                return jsonify({"error": "Got no public key"}), HTTPStatus.BAD_REQUEST

        @self.app.route('/establish_a_connection', methods=['GET'])
        def establish_a_connection():
            json_array = request.json
            addr = json_array.get("addr")
            port = json_array.get("port")
            pk = json_array.get("pk")
            nickname = json_array.get("nickname")
            try:
                self.user.peer(addr, int(port), pk, nickname)
                return jsonify({"status": "Connection established", "pk": self.user.public_key_to_pem(), "nickname": self.user.nickname}), HTTPStatus.OK
            except Exception as e:
                return jsonify({"error": str(e)}), HTTPStatus.SERVICE_UNAVAILABLE

        @self.app.route('/get_messages', methods=['GET'])
        def get_messages():
            return jsonify(self.buffered_messages)

        @self.app.route('/remove_messages', methods=['POST'])
        def remove_messages():
            self.buffered_messages.clear()
            if not self.buffered_messages:
                return jsonify({"status": "Messages removed!"}), HTTPStatus.OK
            else:
                return jsonify({"error": "Could not remove messages!"}), HTTPStatus.BAD_REQUEST

        @self.app.route('/block_notify', methods=['POST'])
        def block_notify():
            hash = self.user.chain.blocks[-1].hash
            request_hash = request.json.get("hash")
            self.new_block_creation = (request_hash == hash)

            if request_hash == hash:
                self.block_time_creation = datetime.datetime.now()
                return jsonify({"status": "Notified about new block in creation!"}), HTTPStatus.OK
            else:
                return jsonify({"error": "Hash mismatch! Aborting creation..."}), HTTPStatus.BAD_REQUEST

        @self.app.route('/get_new_block_notification', methods=['GET'])
        def get_new_block_notification():
            return jsonify({
                "status": "Ok",
                "new_block_creation": self.new_block_creation,
                "date": self.block_time_creation.isoformat()
            }), HTTPStatus.OK

        @self.app.route('/participation_signal', methods=['POST'])
        def participation_signal():
            port = request.json.get("port")
            addr = request.json.get("addr")
            hash = request.json.get("hash")
            date = request.json.get("date")
            stake = request.json.get("stake")

            time_delta = self.block_time_creation + datetime.timedelta(seconds=global_constants.PARTICIPATION_ADDITIONAL_SECONDS)
            time_from_request = datetime.datetime.fromisoformat(date)

            if time_delta > time_from_request:
                self.participants.append({
                    "port": port,
                    "addr": addr,
                    "hash": hash,
                    "date": date,
                    "stake": stake
                })
                return jsonify({"status": "Participant added!"}), HTTPStatus.OK
            else:
                return jsonify({"error": "It is too late to add participant!"}), HTTPStatus.BAD_REQUEST

        @self.app.route('/get_participants', methods=['GET'])
        def get_participants():
            self.participants.sort(key=lambda x: x["stake"])
            return jsonify({"status": "Ok", "participants": self.participants}), HTTPStatus.OK

        @self.app.route('/send_drawn_indexes', methods=['POST'])
        def send_drawn_indexes():
            self.drawn_indexes.append(request.json.get("indexes"))
            return jsonify({"status": "Ok"}), HTTPStatus.OK

    def start(self):
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
