import json
from tkinter import *
import os

import requests

import encryption
import stake
import start
import restnode
from encryption import decrypt_data_ecb, create_key, encrypt_data_ecb, encrypt_message_block

master = Tk()
if "TITLE" in os.environ:
    master.title("Klient {0}".format(os.environ["TITLE"]))


# TK VARS
message = StringVar()
myAddr = StringVar()
peerHost = StringVar()
peerPort = IntVar()

# CALLBACKS
def send():
    """
    Add message to the data block and send message

    """
    print("Send message")
    #me.add_data(message.get())
    me.send_mes(host, message.get())
    message.set("")


def peer():
    """
    Connect to a second device

    """

    print("Peer with node")
    me.peer(peerHost.get(), peerPort.get())
    #peerHost.set("")
    peerPort.set("")

# UI ELEMENTS
scrollbar = Scrollbar(master)
messagesBlock = Text(master, yscrollcommand=scrollbar.set)
scrollbar.config(command=messagesBlock.yview)
messageBox = Entry(master, textvariable=message)
sendBtn = Button(master, text="Send", command=send)
statusLabel = Label(master, textvariable=myAddr)
hostBox = Entry(master, textvariable=peerHost)
portBox = Entry(master, textvariable=peerPort)
peerBtn = Button(master, text="Peer", command=peer)
ccLabel = Label(master, text="")

# UI GRIDDING
messagesBlock.grid(row=0, column=0, columnspan=1, rowspan=4)
scrollbar.grid(row=0, column=1, rowspan=4, sticky="ns")
messageBox.grid(row=4, column=0)
sendBtn.grid(row=4, column=1)
statusLabel.grid(row=0, column=2)
hostBox.grid(row=1, column=2)
portBox.grid(row=2, column=2)
peerBtn.grid(row=3, column=2)
ccLabel.grid(row=4, column=2)

# CLICK ENTER EVENT
messageBox.bind("<Return>", lambda event: send())
hostBox.bind("<Return>", lambda event: peer())
portBox.bind("<Return>", lambda event: peer())

host = restnode.ip()
port = restnode.get_port()

peerHost.set(host)

myAddr.set("Peer: ({host}, {port})".format(host=host, port=port))

me = restnode.start(port)

messages = ""


# which index has last message in the current block
last_message_index = 0

# which block was the last read
last_block_index = 0

# it prevents from reading blockchain all the time
read_from_block = True

# it prevents from updating chat all the time
update_chat = False

# string containing chat history
chat_history_from_blocks = ""

# notification about new block
new_block_in_progress = False

def parse_messages(restnode, messages):
    parsed_messages = ""
    for message in messages:
        decrypted_message = encryption.decrypt_data_ecb(message["message"],
                                                        encryption.create_key(restnode.peers, restnode.port))
        parsed_messages += message["user"] + " (" + message["date"] + "): " + decrypted_message + "\n"
    return parsed_messages

def updateChatbox():
    """
    Refreshes the chat area

    """

    # data = ""
    # for block in me.chain.blocks:
    #     if block.index != 0:
    #         flatedList = "".join(block.data)
    #         decryptedBlock = decrypt_data_ecb(flatedList, create_key(me.peers, me.port))
    #         dataList = [decryptedBlock]
    #         data += "\n".join(dataList) + "\n"
    #     else:
    #         data += "\n".join(block.data)+"\n"
    # print(data)
    # messagesBlock.delete('1.0', END)
    # messagesBlock.insert('1.0', data)
    # master.after(100, updateChatbox)
    global last_message_index
    global read_from_block
    global update_chat
    global last_block_index
    global chat_history_from_blocks
    global new_block_in_progress
    data = ""
    if read_from_block:
        for block in me.chain.blocks:
            if block.index != 0:
                data += "/\\/\\DEBUG/\\/\\ Block number {0}\n".format(block.index)
                flatedList = "".join(block.data)
                decryptedBlock = decrypt_data_ecb(flatedList, create_key(me.peers, me.port))
                json_messages_array = decryptedBlock.split("}")
                json_messages_array.pop()
                json_list = []
                for index, message in enumerate(json_messages_array):
                    json_messages_array[index] += "}"
                    json_list.append(json.loads(json_messages_array[index]))
                parsed_messages = parse_messages(me, json_list)
                data += parsed_messages
                if block.index > last_block_index:
                    chat_history_from_blocks += "/\\/\\DEBUG/\\/\\ Block number {0}\n".format(block.index)
                    chat_history_from_blocks += parsed_messages
                    last_block_index = block.index
                    read_from_block = False
                    update_chat = True

    json_messages = me.get_messages_block(host)
    messages = parse_messages(me, json_messages)

    data = chat_history_from_blocks + messages
    # messages = me.view_parsed_messages(host)

    if new_block_in_progress == False:
        new_block_in_progress = stake.receive_create_block_signal(host, port)
        if new_block_in_progress:
            print("New block is being created")

    # this if statement prevents from updating chat all the time for no reason
    if len(json_messages) > last_message_index:
        update_chat = True
    if update_chat:
        # there is at least one new message to show. update chat
        messagesBlock.delete('1.0', END)
        messagesBlock.insert('1.0', data)
        last_message_index = len(json_messages)
        update_chat = False

    if len(json_messages) >= 20:
        data = ""
        for message in json_messages:
            data += json.dumps(message)
        #me.add_data(data)
        #me.remove_messages_block(host)
        stake.send_create_block_signal(host, port, me)
        # reset index of last message
        last_message_index = 0
        read_from_block = True
    master.after(500, updateChatbox)

master.after(500, updateChatbox)
master.mainloop()

