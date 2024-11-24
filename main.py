import json
import os
import sys
import base64

from tkinter import *

from user import User
from powlib import Powlib
from networking import Networking
from encryption import Encryption

from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives import hashes

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

import global_constants

powlib = Powlib()
encryption = Encryption()
user = User(powlib, encryption)
network = Networking(user)
threads = network.start()

RawPublicKey = user.get_public_key()

pk = user.public_key_to_pem()

#Tk instantiation
master = Tk()

#TK VARS
message = StringVar()
myAddr = StringVar()
peerHost = StringVar()
publicKeyText = StringVar() #Possible change
peerPort = IntVar()
peerPublicKey = StringVar()

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    #Give variables to QML
    engine.rootContext().setContextProperty("user", user)
    engine.rootContext().setContextProperty("pk", pk)

    engine.load(global_constants.MAIN_QML_PATH)
    #sys.exit(app.exec())

if "TITLE" in os.environ:
    master.title("Client {0}".format(os.environ["TITLE"]))

#CALLBACKS
def send():
    """
    Add message to the data block and send message
    """
    print("Send message")
    #me.add_data(message.get())
    user.send_mes(user.host, message.get())
    message.set("")

def peer():
    """
    Connect to a second device

    """
    print("Peer with node")

    user.peer(peerHost.get(), peerPort.get(), peerPublicKey.get())
    peerHost.set("")
    peerPort.set("")
    peerPublicKey.set("")

def generate_every_key():
    print("Generate every_key")
    user.sendEncryptedKeys()

def copy_to_clipboard(text_box):
    #Get text from text box
    text = text_box.get("1.0", END).strip()  #Get text from the start to the end, remove excess whitespace

    if text:
        master.clipboard_clear()  #Clear the clipboard
        master.clipboard_append(text)  #Append the text to the clipboard
        master.update()  #Update the clipboard content

def paste_from_clipboard(entry_box):
    try:
        text = master.clipboard_get()  #Get text from the clipboard
        entry_box.delete(0, END)  #Remove the current content of the Entry field
        entry_box.insert(0, text)  #Insert the clipboard text

    except TclError as e:
        print(f"Clipboard error: {e}")

#UI ELEMENTS
scrollbar = Scrollbar(master)
messagesBlock = Text(master, yscrollcommand=scrollbar.set)
scrollbar.config(command=messagesBlock.yview)
messageBox = Entry(master, textvariable=message)
sendBtn = Button(master, text="Send", command=send)
ipText = Text(master, height=1, width=50)
ipText.insert("1.0", user._host)
portText = Text(master, height=1, width=50)
portText.insert("1.0", user._port)
#statusText = Text(master, height=2, width=50)
#statusText.insert("1.0", "Peer: ({host}, {port})".format(host=host, port=port))
publicKeyText = Text(master, height=16, width=50)
publicKeyText.insert("1.0", user.public_key_to_pem())
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

#UI GRIDDING
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

#CLICK ENTER EVENT
messageBox.bind("<Return>", lambda event: send())
ipBox.bind("<Return>", lambda event: peer())
portBox.bind("<Return>", lambda event: peer())

#peerHost.set(user.host)
#myAddr.set("Peer: ({host}, {port})".format(host=user.host, port=port))

messages = ""

#Which index has last message in the current block
last_message_index = 0

#Which block was the last read
last_block_index = 0

#It prevents from reading blockchain all the time
read_from_block = True

#It prevents from updating chat all the time
update_chat = False

#String containing chat history
chat_history_from_blocks = ""

#Notification about new block
new_block_in_progress = False

def convert_key(base64keyEncypted):
    byteKey = base64.b64decode(base64keyEncypted)
    decryptedSessionKey = user.private_key.decrypt(
        byteKey,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        ))

    #sessionKey = user.random_key
    #privateKey = user.private_key
    #pemPrivateKey = encryption.private_key_to_pem(privateKey)
    #publicKey = user.public_key
    #pemPublicKey = encryption.public_key_to_pem(publicKey)
    #encryptedKey = user.EncryptedKBytes
    #encryptedKString = user.EncryptedKString

    print("Convertions")

    return decryptedSessionKey

def parse_messages(restnode, messages):
    parsed_messages = ""

    for message in messages:

        print("Beginning of message")
        print(message)
        print("End of message")

        if message["message"].startswith(global_constants.ENCRYPTED_KEY_BEGIN):
            editedMessage = message["message"].replace(global_constants.ENCRYPTED_KEY_BEGIN, "").replace("\n", "")

            print("Before key conversion")

            real_key = convert_key(editedMessage)
            user.useful_key = real_key

            print("Key conversion")

            editedMessage += "\n"
            parsed_messages += base64.b64encode(real_key).decode('utf-8') + "\n" + user.drawString + "\n"
        else:
            decrypted_message = encryption.decrypt_data_ecb(message["message"], user.useful_key)
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
        for block in user.chain.blocks:
            if block.index != 0:
                data += "/\\/\\DEBUG/\\/\\ Block number {0}\n".format(block.index)
                flatedList = "".join(block.data)
                decryptedBlock = encryption.decrypt_data_ecb(flatedList, user.useful_key)
                json_messages_array = decryptedBlock.split("}")
                json_messages_array.pop()
                json_list = []

                for index, message in enumerate(json_messages_array):
                    json_messages_array[index] += "}"
                    json_list.append(json.loads(json_messages_array[index]))

                parsed_messages = parse_messages(user, json_list)
                data += parsed_messages

                if block.index > last_block_index:
                    chat_history_from_blocks += "/\\/\\DEBUG/\\/\\ Block number {0}\n".format(block.index)
                    chat_history_from_blocks += parsed_messages
                    last_block_index = block.index
                    read_from_block = False
                    update_chat = True

    json_messages = user.get_messages_block(user._host)
    messages = parse_messages(user, json_messages)

    data = chat_history_from_blocks + messages

    #This if statement prevents from updating chat all the time for no reason
    if len(json_messages) > last_message_index:
        update_chat = True

    if update_chat:
        #There is at least one new message to show. update chat
        messagesBlock.delete('1.0', END)
        messagesBlock.insert('1.0', data)
        last_message_index = len(json_messages)
        update_chat = False

    if len(json_messages) >= 20:
        data = ""

        for message in json_messages:
            data += json.dumps(message)

        user.add_data(data)
        user.remove_messages_block(user.host)

        #Reset index of last message
        last_message_index = 0
        read_from_block = True

    master.after(500, updateChatbox)

master.after(500, updateChatbox)
master.mainloop()

