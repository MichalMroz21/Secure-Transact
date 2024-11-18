import json
import os
import threading
from tkinter import *
import base64
import requests

import encryption
import stake
import start
import restnode
from encryption import decrypt_data_ecb, create_key, encrypt_data_ecb, encrypt_message_block
import traceback

from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes

master = Tk()
if "TITLE" in os.environ:
    master.title("Klient {0}".format(os.environ["TITLE"]))



# TK VARS
message = StringVar()
myAddr = StringVar()
peerHost = StringVar()
publicKeyText = StringVar() #mozliwa zmiana
peerPort = IntVar()
peerPublicKey = StringVar()

# CALLBACKS
def send():
    """
    Add message to the data block and send message

    """
    print("Send message")
    #me.add_data(message.get())
    main_node.send_mes(host, message.get())
    message.set("")


def peer():
    """
    Connect to a second device

    """

    print("Peer with node")
    main_node.peer(peerHost.get(), peerPort.get(), peerPublicKey.get())
    peerHost.set("")
    peerPort.set("")
    peerPublicKey.set("")

def generate_every_key():
    print("Generate every_key")
    main_node.sendEncryptedKeys()

def copy_to_clipboard(text_box):
    # Pobierz tekst z pola tekstowego
    text = text_box.get("1.0", END).strip()  # Pobierz tekst od początku do końca, usuń nadmiarowe białe znaki
    if text:
        master.clipboard_clear()  # Wyczyść schowek
        master.clipboard_append(text)  # Dodaj tekst do schowka
        master.update()  # Uaktualnij zawartość schowka

def paste_from_clipboard(entry_box):
    try:
        text = master.clipboard_get() # Pobierz tekst ze schowka
        entry_box.delete(0, END) # Usuń aktualną zawartość pola Entry
        entry_box.insert(0, text) # Wstaw tekst ze schowka
    except TclError as e:
        print(f"Błąd schowka: {e}")


host = restnode.ip()
port = restnode.get_port()

main_node = restnode.Node(port)
threads = start.start(main_node)

RawPublicKey = main_node.get_public_key()

# UI ELEMENTS
scrollbar = Scrollbar(master)
messagesBlock = Text(master, yscrollcommand=scrollbar.set)
scrollbar.config(command=messagesBlock.yview)
messageBox = Entry(master, textvariable=message)
sendBtn = Button(master, text="Send", command=send)
ipText = Text(master, height=1, width=50)
ipText.insert("1.0", host)
portText = Text(master, height=1, width=50)
portText.insert("1.0", port)
# statusText = Text(master, height=2, width=50)
# statusText.insert("1.0", "Peer: ({host}, {port})".format(host=host, port=port))
publicKeyText = Text(master, height=16, width=50)
publicKeyText.insert("1.0", main_node.public_key_to_pem())
copyIp = Button(master, text="kopiuj", command=lambda: copy_to_clipboard(ipText))
copyPort = Button(master, text="kopiuj", command=lambda: copy_to_clipboard(portText))
copyPublicKey = Button(master, text="kopiuj", command=lambda: copy_to_clipboard(publicKeyText))
ipBox = Entry(master, textvariable=peerHost)
portBox = Entry(master, textvariable=peerPort)
publicKeyBox = Entry(master, textvariable=peerPublicKey, width=50)
pasteIp = Button(master, text="wklej", command=lambda: paste_from_clipboard(ipBox))
pastePort = Button(master, text="wklej", command=lambda: paste_from_clipboard(portBox))
pastePublicKey = Button(master, text="wklej", command=lambda: paste_from_clipboard(publicKeyBox))
peerBtn = Button(master, text="Peer", command=peer)
generateKeysBtn = Button(master, text="Generate keys", command=generate_every_key)
ccLabel = Label(master, text="")

# UI GRIDDING
messagesBlock.grid(row=0, column=0, columnspan=1, rowspan=8)
scrollbar.grid(row=0, column=1, rowspan=3, sticky="ns")
messageBox.grid(row=4, column=0)
sendBtn.grid(row=4, column=1)
ipText.grid(row=0, column=2)
portText.grid(row=1, column=2)
#statusText.grid(row=0, column=2)
publicKeyText.grid(row=2, column=2)
ipBox.grid(row=3, column=2)
portBox.grid(row=4, column=2)
publicKeyBox.grid(row=5, column=2)
peerBtn.grid(row=6, column=2)
generateKeysBtn.grid(row=7, column=2)
ccLabel.grid(row=8, column=2)
copyIp.grid(row=0, column=3)
copyPort.grid(row=1, column=3)
copyPublicKey.grid(row=2, column=3)
pasteIp.grid(row=3, column=3)
pastePort.grid(row=4, column=3)
pastePublicKey.grid(row=5, column=3)

# CLICK ENTER EVENT
messageBox.bind("<Return>", lambda event: send())
ipBox.bind("<Return>", lambda event: peer())
portBox.bind("<Return>", lambda event: peer())

peerHost.set(host)

myAddr.set("Peer: ({host}, {port})".format(host=host, port=port))



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

def convert_key(base64keyEncypted):
    byteKey = base64.b64decode(base64keyEncypted)
    decryptedSessionKey = main_node.private_key.decrypt(
        byteKey,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        ))
    sessionKey = main_node.random_key
    privateKey = main_node.private_key
    pemPrivateKey = restnode.private_key_to_pem(privateKey)
    publicKey = main_node.public_key
    pemPublicKey = restnode.public_key_to_pem(publicKey)
    encryptedKey = main_node.EncryptedKBytes
    encryptedKString = main_node.EncryptedKString
    print("Konwersje")
    return decryptedSessionKey

def parse_messages(restnode, messages):
    parsed_messages = ""
    for message in messages:
        print("Poczatek wiadomosci")
        print(message)
        print("Koniec wiadomosci")
        if message["message"].startswith("-----BEGIN ENCRYPTED KEY-----"):
            editedMessage = message["message"].replace("-----BEGIN ENCRYPTED KEY-----", "").replace("\n", "")
            print("Przed konwersja klucza")
            real_key = convert_key(editedMessage)
            main_node.useful_key = real_key
            print("Konwersja klucza")
            editedMessage += "\n"
            parsed_messages += base64.b64encode(real_key).decode('utf-8') + "\n" + main_node.drawString + "\n"
        else:
            decrypted_message = encryption.decrypt_data_ecb(message["message"], main_node.useful_key)
            parsed_messages += message["user"] + " (" + message["date"] + "): " + decrypted_message + "\n"
    return parsed_messages

def updateChatbox():
    """
    Refreshes the chat area

    """
    global last_message_index
    global read_from_block
    global update_chat
    global last_block_index
    global chat_history_from_blocks
    global new_block_in_progress
    data = ""
    if read_from_block:
        for block in main_node.chain.blocks:
            if block.index != 0:
                data += "/\\/\\DEBUG/\\/\\ Block number {0}\n".format(block.index)
                flatedList = "".join(block.data)
                decryptedBlock = decrypt_data_ecb(flatedList, main_node.useful_key)
                json_messages_array = decryptedBlock.split("}")
                json_messages_array.pop()
                json_list = []
                for index, message in enumerate(json_messages_array):
                    json_messages_array[index] += "}"
                    json_list.append(json.loads(json_messages_array[index]))
                parsed_messages = parse_messages(main_node, json_list)
                data += parsed_messages
                if block.index > last_block_index:
                    chat_history_from_blocks += "/\\/\\DEBUG/\\/\\ Block number {0}\n".format(block.index)
                    chat_history_from_blocks += parsed_messages
                    last_block_index = block.index
                    read_from_block = False
                    update_chat = True

    json_messages = main_node.get_messages_block(host)
    messages = parse_messages(main_node, json_messages)

    data = chat_history_from_blocks + messages

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
        main_node.add_data(data)
        main_node.remove_messages_block(host)
        # reset index of last message
        last_message_index = 0
        read_from_block = True
    master.after(500, updateChatbox)

master.after(500, updateChatbox)
master.mainloop()

