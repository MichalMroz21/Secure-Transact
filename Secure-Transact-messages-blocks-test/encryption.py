import json

from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad
import base64

# Używamy funkcji hashlib do stworzenia klucza o odpowiedniej długości
# W tym przypadku użyjemy 'qwerty' i dopełnimy go do 16 znaków

def encrypt_data_ecb(data, key):
    # Utwórz obiekt szyfrujący AES w trybie ECB z użyciem klucza
    cipher = AES.new(key, AES.MODE_ECB)
    # Zaszyfruj dane (z paddingiem, aby były wielokrotnością 16 bajtów)
    encrypted_data = cipher.encrypt(pad(data.encode(), AES.block_size))
    encrypted_base64 = base64.b64encode(encrypted_data).decode('utf-8')
    return encrypted_base64

def decrypt_data_ecb(encrypted_base64, key):
    encrypted_data = base64.b64decode(encrypted_base64)
    # Utwórz obiekt deszyfrujący AES w trybie ECB z użyciem klucza
    cipher = AES.new(key, AES.MODE_ECB)
    # Odszyfruj dane i usuń padding
    decrypted_data = unpad(cipher.decrypt(encrypted_data), AES.block_size)
    return decrypted_data.decode()

def create_key(friendList, myPort):
    keyList = []
    for friend in friendList:
        keyList.append(friend.port)
    keyList.append(myPort)
    keyList.sort() # wazne sortuj liste by taka sama byla
    for key in keyList:
        print(key)
    keyRaw = " ".join(str(x) for x in keyList)
    key = keyRaw.ljust(16)[:16]
    return key

def encrypt_message_block(json_messages, key):
    encrypted_data = ""
    for message in json_messages:
        data = json.dumps(message)
        encrypted_data += encrypt_data_ecb(data, key)
    return encrypted_data

def decrypt_message_block(block, block_key, messages_key):
    """
    Decrypt data from block
    :param block: block to be decrypted
    :param block_key: key to be used in block decryption
    :param messages_key: key to be used in messages decryption
    :return:
    """
