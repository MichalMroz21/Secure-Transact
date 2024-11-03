import socket
import select
import threading
import json
import time
import flask
import requests
import random

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
    s.connect(("40.114.26.190", 80)) # doesn't actually send traffic
    ipa = s.getsockname()[0]
    s.close()
    return ipa


def get_port():
    """
    Gets host machine port value
    :return: int
    """
    return random.randint(1024, 65535)


class Node:
    def __init__(self, port):
        """
        Creates a node
        :param port: Host machine port
        """
        self.peers = []
        self.chain = blockchain.Blockchain()
        self.chain.genesis()
        self.staging = [] # staging data to add to block

        # socket stuff
        self.port = port

    def consensus(self):
        """
        Checks the correctness of peers and chains
        """
        chains = []
        for peer in self.peers:
            pass # get that peer's chain
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

def start(listen_port):
    """
    Starts application threads
    :param listen_port: Port to be listened to
    """
    me = Node(listen_port)

    app = flask.Flask(__name__)

    @app.route("/chain")
    def chain():
        return me.chain.jsonrep()

    server_thread = threading.Thread(target=me.serve_chain, args=(app,))
    consensus_thread = threading.Thread(target=me.check_consensus)
    miner_thread = threading.Thread(target=me.add_blocks)
    #input_thread = threading.Thread(target=me.handle_input)

    server_thread.start()
    consensus_thread.start()
    miner_thread.start()
    #me.handle_input()
    return me

