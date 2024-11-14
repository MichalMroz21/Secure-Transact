import datetime
import sys
import threading

import flask
import requests
from flask import jsonify, request

from restnode import Node


def start(node):
    """
    Starts application threads
    :param listen_port: Port to be listened to
    """

    # messages has information about which user sent which message.
    # ["user": "user_address"],["message", "message_content"]
    messages = []
    block_time_creation = datetime.datetime.now()
    new_block_creation = False
    participants = []
    drawn_indexes = []

    app = flask.Flask(__name__)

    @app.route("/chain")
    def chain():
        return node.chain.jsonrep()

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
        hash = node.chain.blocks[-1].hash
        request_hash = request.json.get("hash")
        nonlocal new_block_creation
        if request_hash == hash:
            nonlocal block_time_creation
            block_time_creation = datetime.datetime.now()
            new_block_creation = True
            return jsonify({"status": "Notified about new block in creation!"}), 200
        else:
            new_block_creation = False
            return jsonify({"error": "Hash mismatch! Aborting creation..."}), 400

    @app.route('/get_new_block_notification', methods=['GET'])
    def get_new_block_notification():
        return jsonify({"status": "Ok", "new_block_creation": new_block_creation, "date": block_time_creation.isoformat()}), 200

    @app.route('/participation_signal', methods=['POST'])
    def participation_signal():
        port = request.json.get("port")
        addr = request.json.get("addr")
        hash = request.json.get("hash")
        date = request.json.get("date")
        stake = request.json.get("stake")

        additional_seconds = 20
        time_delta = block_time_creation + datetime.timedelta(seconds=additional_seconds)
        time_from_request = datetime.datetime.fromisoformat(date)

        if time_delta > time_from_request:
            participants.append({"port": port, "addr": addr, "hash": hash, "date": date, "stake": stake})
            return jsonify({"status": "Participant added!"}), 200
        else:
            return jsonify({"error": "It is too late to add participant!"}), 400

    @app.route('/get_participants', methods=['GET'])
    def get_participants():
        nonlocal participants
        participants.sort(key=lambda x: x["stake"])
        return jsonify({"status": "Ok", "participants": participants}), 200

    @app.route('/send_drawn_indexes', methods=['POST'])
    def send_drawn_indexes():
        drawn_indexes.append(request.json.get("indexes"))
        return jsonify({"status": "Ok"}), 200

    server_thread = threading.Thread(target=node.serve_chain, args=(app,), daemon=True)
    consensus_thread = threading.Thread(target=node.check_consensus, daemon=True)
    miner_thread = threading.Thread(target=node.add_blocks, daemon=True)
    #input_thread = threading.Thread(target=me.handle_input)

    threads = []
    threads.append(server_thread)
    threads.append(consensus_thread)
    threads.append(miner_thread)

    try:
        server_thread.start()
        consensus_thread.start()
        miner_thread.start()
    except (KeyboardInterrupt, SystemExit):
        server_thread.join()
        consensus_thread.join()
        miner_thread.join()
    #me.handle_input()

    return threads