from tkinter import *
import restnode
from encryption import decrypt_data_ecb, create_key

master = Tk()

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
    me.add_data(message.get())
    message.set("")

def peer():
    """
    Connect to a second device

    """

    print("Peer with node")
    me.peer(peerHost.get(), peerPort.get())
    peerHost.set("")
    peerPort.set("")

# UI ELEMENTS
messagesBlock = Text(master)
messageBox = Entry(master, textvariable=message)
sendBtn = Button(master, text="Send", command=send)
statusLabel = Label(master, textvariable=myAddr)
hostBox = Entry(master, textvariable=peerHost)
portBox = Entry(master, textvariable=peerPort)
peerBtn = Button(master, text="Peer", command=peer)
ccLabel = Label(master, text="")

# UI GRIDDING
messagesBlock.grid(row=0, column=0, columnspan=2, rowspan=4)
messageBox.grid(row=4, column=0)
sendBtn.grid(row=4, column=1)
statusLabel.grid(row=0, column=2)
hostBox.grid(row=1, column=2)
portBox.grid(row=2, column=2)
peerBtn.grid(row=3, column=2)
ccLabel.grid(row=4, column=2)

host = restnode.ip()
port = restnode.get_port()

myAddr.set("Peer: ({host}, {port})".format(host=host, port=port))

me = restnode.start(port)


def updateChatbox():
    """
    Refreshes the chat area

    """
    data = ""
    for block in me.chain.blocks:
        if block.index != 0:
            flatedList = "".join(block.data)
            decryptedBlock = decrypt_data_ecb(flatedList, create_key(me.peers, me.port))
            dataList = [decryptedBlock]
            data += "\n".join(dataList) + "\n"
        else:
            data += "\n".join(block.data)+"\n"
    print(data)
    messagesBlock.delete('1.0', END)
    messagesBlock.insert('1.0', data)
    master.after(100, updateChatbox)

master.after(100, updateChatbox)
master.mainloop()

