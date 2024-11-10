import requests


def send_create_block_signal(host_addr, host_port, node):
    """
    Sends signal to everyone in peer nodes that there is a new block to be created
    """
    try:
        for peer in node.peers:
            requests.post("http://{}:{}/block_notify".format(peer.addr, peer.port),
                          json={"addr": host_addr, "port": host_port, "hash": node.chain.blocks[-1].hash})
    except Exception as e:
        print(e)

def receive_create_block_signal(host_addr, host_port):
    """
    Receives signal that there is a new block to be created
    :param node:
    :param host_addr:
    :return:
    """
    try:
        response = requests.get("http://{}:{}/get_new_block_notification".format(host_addr, host_port))
        if response.status_code == 200:
            return response.json()["new_block_creation"]
        else:
            return None
    except Exception as e:
        print(e)
        return None


def send_participation_signal(node, host_addr):
    """
    Sends signal that user wants to take a part of block creation
    :param node:
    :param host_addr:
    :return:
    """
    requests.post("http://{}:{}/participation_notify".format(host_addr, node.port))

def get_participants(node, host_addr):
    """
    Gets all raffle participants
    :param node:
    :param host_addr:
    :return:
    """
    requests.get("http://{}:{}/get_messages".format(host_addr, self.port)).json()

def participants_raffle(node, host_addr):
    """
    Raffle participants
    :param node:
    :param host_addr:
    :return: participant who has to create a block
    """

