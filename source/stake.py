import datetime
import random
import requests
import global_constants

from http import HTTPStatus

from PySide6.QtCore import QObject

class Stake(QObject):
    def __init__(self, user):
        super().__init__()

    def send_create_block_signal(self, host, port, node):
        """
        Sends signal to everyone in peer nodes that there is a new block to be created
        """
        try:
            date = datetime.datetime.now().strftime("%Y/%m/%d, %H:%M:%S")

            for peer in node.peers:
                requests.post("http://{}:{}/block_notify".format(peer.host, peer.port),
                              json={"host": host, "port": port, "hash": node.chain.blocks[-1].hash, "date": date})

        except Exception as e:
            print(e)

    def receive_create_block_signal(self, host, port):
        """
        Receives signal that there is a new block to be created
        :param node:
        :param host:
        :return:
        """
        try:
            response = requests.get("http://{}:{}/get_new_block_notification".format(host, port))

            if response.status_code == HTTPStatus.OK:
                return response.json()
            else:
                return None

        except Exception as e:
            print(e)
            return None


    def send_participation_signal(self, host, port, node, stake):
        """
        Sends signal that user wants to take a part of block creation
        :param node:
        :param host:
        :return:
        """
        try:
            date = datetime.datetime.now().isoformat()

            #Inform yourself about being a participant
            response = requests.post("http://{}:{}/participation_signal".format(host, port),
                                     json={"host": host, "port": port, "hash": node.chain.blocks[-1].hash, "stake": stake, "date": date})

            #Inform rest of peers if it could be added
            if response.status_code == HTTPStatus.OK:
                for peer in node.peers:
                    requests.post("http://{}:{}/participation_signal".format(peer.host, peer.port),
                                  json={"host": host, "port": port, "hash": node.chain.blocks[-1].hash, "stake": stake, "date": date})

        except Exception as e:
            print(e)

    def get_participants(self, host, port):
        """
        Gets all raffle participants
        :param node:
        :param host:
        :return:
        """
        try:
            response = requests.get("http://{}:{}/get_participants".format(host, port))

            if response.status_code == HTTPStatus.OK:
                return response.json()
            else:
                return None

        except Exception as e:
            print(e)
            return None


    def find_common_elements_in_dictionaries(self, list_of_dictionaries):
        """
        Checks if all elements in the dictionaries are common elements.
        :param list_of_dictionaries: list of dictionaries to be checked
        :return: list of dictionaries with common elements
        """
        try:
            #Create a set from the first list, converting dictionaries to tuples (to allow using the AND operator)
            common = set(tuple(sorted(d.items())) for d in list_of_dictionaries[0])

            #For each subsequent list, update the set, keeping only common elements
            for lst in list_of_dictionaries[1:]:
                common &= set(tuple(sorted(d.items())) for d in lst)

            #Convert the resulting set back to a list of dictionaries
            return [dict(d) for d in common]

        except Exception as e:
            print(e)


    def verify_participants_lists(self, host, port, node):
        """
        :param host: Host IP address
        :param port: Host port number
        :param node: node from which are taken peers
        :return:
        """
        participants_lists = []

        try:
            participants = self.get_participants(host, port)
            participants_lists.append(participants["participants"])

            for peer in node.peers:
                participants = self.get_participants(peer.host, peer.port)
                participants_lists.append(participants["participants"])

            return self.find_common_elemenets_in_dictionaries(participants_lists)

        except Exception as e:
            print(e)

    def participants_raffle(self, host, port, node):
        """
        Raffle participants
        :param node:
        :param host:
        :return: participant who has to create a block
        """
        #Get participants list
        participants_list = self.verify_participants_lists(host, port, node)

        #participants_list = self.get_participants(host, host_port)
        #Prepare list of participants stakes and stakes sum
        stakes_list = []
        stake_sum = 0

        for participant in participants_list:
            stake = int(participant["stake"])
            stakes_list.append(stake)
            stake_sum += stake

        #Calculated distributor so in the next step function could proceed to weighted raffle
        distributors_list = []
        drawn_indexes = []
        distributor_sum = 0.0

        for stake in stakes_list:
            distributor_sum += float(stake / stake_sum)
            distributors_list.append(distributor_sum)

        #Draw RANDOM_NUMBER_COUNT random numbers between 0 and 1, then check distributor list which paprticipant won raffle
        #If the drawn number is greater than distributor for given participant then check next one
        #If the drawn number is less than distributor for given participant then return their index
        for i in range(global_constants.RANDOM_NUMBER_COUNT):
            drawn_number = random.uniform(0, 1)

            for index, distributor in enumerate(distributors_list):
                if drawn_number < distributor:
                    drawn_indexes.append(index)

        #If somehow it wasn't possible to drawn participant then return the last one
        return drawn_indexes
