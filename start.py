import datetime
import sys
import threading

import flask
import requests
from flask import jsonify, request

from restnode import Node


def start(listen_port):
    """
    Starts application threads
    :param listen_port: Port to be listened to
    """
    me = Node(listen_port)

    # messages has information about which user sent which message.
    # ["user": "user_address"],["message", "message_content"]
    messages = []
    new_block_creation = False

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
                          json={"user": request.host, "message": message, "date": date})
            if response.status_code == 200:
                # check if the message was sent to multiple peers (group chat)
                if request.json.get("client_number") == 0:
                    messages.append({"user": request.host, "message": message, "date": date})
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
        print(message)
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

    @app.route('/block_notify', methods=['POST'])
    def block_notify():
        """
        Endpoint do wyslania sygnalu by utworzyc nowy blok
        """

        # Check if the current last block's hash is equal to that sent in resquest
        # This checks if user who wants to notify about block creation has valid blockchain version with others
        hash = me.chain.blocks[-1].hash
        request_hash = request.json.get("hash")
        nonlocal new_block_creation
        if request_hash == hash:
            new_block_creation = True
            return jsonify({"status": "Notified about new block in creation!"}), 200
        else:
            new_block_creation = False
            return jsonify({"error": "Hash mismatch! Aborting creation..."}), 400

    @app.route('/get_new_block_notification', methods=['GET'])
    def get_new_block_notification():
        return jsonify({"status": "Ok", "new_block_creation": new_block_creation}), 200

    server_thread = threading.Thread(target=me.serve_chain, args=(app,))
    consensus_thread = threading.Thread(target=me.check_consensus)
    miner_thread = threading.Thread(target=me.add_blocks)
    #input_thread = threading.Thread(target=me.handle_input)

    try:
        server_thread.start()
        consensus_thread.start()
        miner_thread.start()
    except (KeyboardInterrupt, SystemExit):
        server_thread.join()
        consensus_thread.join()
        miner_thread.join()
    #me.handle_input()

    return me
