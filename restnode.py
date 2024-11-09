import socket
import select
import threading
import json
import time
import datetime

import flask
import requests
import random

from flask import jsonify, request

import blockchain
import encryption

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

    # In the future port number will be stored in a config file.
    # Now for testing purposes program randomizes it so there's no problem with running few instances of the program

    # try:
    #     file = open("cfg.txt", "x")
    #     file.close()
    # except Exception as e:
    #     print(e)
    # try:
    #     f = open("cfg.txt", "r+")
    #     output = f.read()
    #     json_string = ""
    #     if output != "":
    #         json_string = json.loads(output)
    #         if "port" in json_string:
    #             f.close()
    #             return int(json_string["port"])
    #     port = random.randint(1024, 65535)
    #     input = json.dumps({"port": port})
    #     f.write(input)
    #     f.close()
    #     return port
    # except Exception as e:
    #     f.close()
    #     print(e)
    #     return random.randint(1024, 65535)


class Node:
    def __init__(self, port):
        """
        Creates a node
        :param port: Host machine port
        """
        self.peers = []
        self.chain = blockchain.Blockchain()
        self.chain.genesis()
        self.staging = []  # staging data to add to block

        # socket stuff
        self.port = port

    def consensus(self):
        """
        Checks the correctness of peers and chains
        """
        chains = []
        for peer in self.peers:
            pass  # get that peer's chain
        for chain in chains:
            self.chain.consensus(chain)

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
        data = encryption.encrypt_data_ecb(data, encryption.create_key(self.peers, self.port))
        self.staging.append(data)

    def peer(self, addr, port):
        """
        Creates peer with second device
        :param addr: Second's device IP address
        :param port: Second's device port
        """
        self.peers.append(Peer(addr, port))

    def send_mes(self, host_addr, message):
        client_number = 0
        for peer in self.peers:
            encrypted_message = encryption.encrypt_data_ecb(message, encryption.create_key(self.peers, self.port))
            requests.post("http://{}:{}/send_message".format(host_addr, self.port),
                          json={"addr": peer.addr, "port": peer.port, "message": encrypted_message, "client_number": client_number})
            client_number += 1

    def view_parsed_messages(self, host_addr):
        try:
            json_messages = requests.get("http://{}:{}/get_messages".format(host_addr, self.port)).json()
            messages = ""
            if json_messages:
                for message in json_messages:
                    decrypted_message = encryption.decrypt_data_ecb(message["message"], encryption.create_key(self.peers, self.port))
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
    def __init__(self, address, port):
        """
        Creates connection with second device
        :param address: Second device's IP address
        :param port: Second device's port
        """
        self.addr = address
        self.port = port

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

    server_thread = threading.Thread(target=me.serve_chain, args=(app,))
    consensus_thread = threading.Thread(target=me.check_consensus)
    miner_thread = threading.Thread(target=me.add_blocks)
    #input_thread = threading.Thread(target=me.handle_input)

    server_thread.start()
    consensus_thread.start()
    miner_thread.start()
    #me.handle_input()
    return me
