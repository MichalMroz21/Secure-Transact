import datetime
import json
import random

import requests


def send_create_block_signal(host_addr, host_port, node):
    """
    Sends signal to everyone in peer nodes that there is a new block to be created
    """
    try:
        date = datetime.datetime.now().strftime("%Y/%m/%d, %H:%M:%S")
        for peer in node.peers:
            requests.post("http://{}:{}/block_notify".format(peer.addr, peer.port),
                          json={"addr": host_addr, "port": host_port, "hash": node.chain.blocks[-1].hash, "date": date})
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
            return response.json()
        else:
            return None
    except Exception as e:
        print(e)
        return None


def send_participation_signal(host_addr, host_port, node, stake):
    """
    Sends signal that user wants to take a part of block creation
    :param node:
    :param host_addr:
    :return:
    """
    try:
        date = datetime.datetime.now().isoformat()
        # inform yourself about being a participant
        response = requests.post("http://{}:{}/participation_signal".format(host_addr, host_port),
                      json={"addr": host_addr, "port": host_port, "hash": node.chain.blocks[-1].hash, "stake": stake,"date": date})
        # inform rest of peers if it could be added
        if response.status_code == 200:
            for peer in node.peers:
                requests.post("http://{}:{}/participation_signal".format(peer.addr, peer.port),
                              json={"addr": host_addr, "port": host_port, "hash": node.chain.blocks[-1].hash, "stake": stake, "date": date})

    except Exception as e:
        print(e)

def get_participants(host_addr, host_port):
    """
    Gets all raffle participants
    :param node:
    :param host_addr:
    :return:
    """
    try:
        response = requests.get("http://{}:{}/get_participants".format(host_addr, host_port))
        if response.status_code == 200:
            return response.json()
        else:
            return None
    except Exception as e:
        print(e)
        return None


def find_common_elemenets_in_dictionaries(list_of_dictionaries):
    try:
        # Tworzymy zbiór z pierwszej listy, zamieniając słowniki na tuple (aby móc użyć z operatorem AND)
        common = set(tuple(sorted(d.items())) for d in list_of_dictionaries[0])

        # Dla każdej kolejnej listy aktualizujemy zbiór, zostawiając tylko wspólne elementy
        for list in list_of_dictionaries[1:]:
            common &= set(tuple(sorted(d.items())) for d in list)

        # Konwertujemy wynikowy zbiór z powrotem na listę słowników
        return [dict(d) for d in common]
    except Exception as e:
        print(e)

def verify_participants_lists(host_addr, host_port, node):
    participants_lists = []
    try:
        participants = get_participants(host_addr, host_port)
        participants_lists.append(participants["participants"])
        for peer in node.peers:
            participants = get_participants(peer.addr, peer.port)
            participants_lists.append(participants["participants"])
        return find_common_elemenets_in_dictionaries(participants_lists)

    except Exception as e:
        print(e)

def participants_raffle(host_addr, host_port, node):
    """
    Raffle participants
    :param node:
    :param host_addr:
    :return: participant who has to create a block
    """
    # get participants list

    participants_list = verify_participants_lists(host_addr, host_port, node)
    #participants_list = get_participants(host_addr, host_port)
    # prepare list of participants stakes and stakes sum
    stakes_list = []
    stake_sum = 0
    for participant in participants_list:
        stake = int(participant["stake"])
        stakes_list.append(stake)
        stake_sum += stake

    # calculated distributor so in the next step function could proceed to weighted raffle
    distributors_list = []
    distributor_sum = 0.0
    for stake in stakes_list:
        distributor_sum += float(stake / stake_sum)
        distributors_list.append(distributor_sum)

    drawn_indexes = []
    # draw 10 random numbers between 0 and 1, then check distributor list which paprticipant won raffle
    # if the drawn number is greater than distributor for given participant then check next one
    # if the drawn number is less than distributor for given participant then return their index
    for i in range(10):
        drawn_number = random.uniform(0,1)
        for index, distributor in enumerate(distributors_list):
            if drawn_number < distributor:
                drawn_indexes.append(index)
    # if somehow it wasn't possible to drawn participant then return the last one
    return drawn_indexes