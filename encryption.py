import json
import base64

from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives import serialization

"""
PEARSCOIN CHAIN TRANSFER PROTOCOL:

MESSAGE TYPES:

Message     Description         Response
/chain      Get current chain   JSON chain object

"""

# Używamy funkcji hashlib do stworzenia klucza o odpowiedniej długości
# W tym przypadku użyjemy 'qwerty' i dopełnimy go do 16 znaków

def encrypt_data_ecb(data, key):
    """
    Encrypt given data with specified key
    :param data: data to be encrypted
    :param keyRaw:
    :return: Encrypted data
    """
    # Utwórz obiekt szyfrujący AES w trybie ECB z użyciem klucza
    cipher = AES.new(key, AES.MODE_ECB)
    # Zaszyfruj dane (z paddingiem, aby były wielokrotnością 16 bajtów)
    encrypted_data = cipher.encrypt(pad(data.encode(), AES.block_size))
    encrypted_base64 = base64.b64encode(encrypted_data).decode('utf-8')

    return encrypted_base64

def decrypt_data_ecb(encrypted_base64, key):
    """
    Decrypt data from Base64
    :param encrypted_base64: Data encrypted in Base64 format
    :param keyRaw: Key to be used in decryption
    :return: Decrypted data
    """
    encrypted_data = base64.b64decode(encrypted_base64)
    # Utwórz obiekt deszyfrujący AES w trybie ECB z użyciem klucza
    cipher = AES.new(key, AES.MODE_ECB)
    # Odszyfruj dane i usuń padding
    decrypted_data = unpad(cipher.decrypt(encrypted_data), AES.block_size)

    return decrypted_data.decode()

def create_key(friendList, myPort):
    """
    Creates symmetric key unique to host machine and connected device
    :param friendList: List of peers
    :param myPort: Port of host machine
    :return: Symmetric key used to encrypt and decrypt data between host machine and connected device
    """
    keyList = []

    for friend in friendList:
        keyList.append(friend.port)

    keyList.append(myPort)
    keyList.sort() # wazne sortuj liste by taka sama byla
    # for key in keyList:
    #     print(key)
    keyRaw = " ".join(str(x) for x in keyList)
    key = keyRaw.ljust(16)[:16]

    return key

def encrypt_message_block(json_messages, key):
    """
    Encrypts messages in JSON format to the block
    :param json_messages: messages to be encrypted
    :param key:
    :return:
    """
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

def private_key_to_pem(private_key):
    pem_private_key = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,  # Kodowanie PEM
        format=serialization.PrivateFormat.TraditionalOpenSSL,  # Format klucza
        encryption_algorithm=serialization.NoEncryption()  # Bez hasła
    )
    return pem_private_key.decode('utf-8')

def public_key_to_pem(public_key):
    pem = public_key.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )

    return pem.decode('utf-8')  # Konwersja do tekstu

def load_public_key_from_pem(pem_data):
    public_key = serialization.load_pem_public_key(
        pem_data.encode('utf-8'),  # Konwersja tekstu na bajty
        backend=default_backend()
    )

    return public_key

def encrypt_with_public_key(public_key, key):
    """Szyfrowanie klucza AES przy użyciu klucza publicznego RSA."""
    return public_key.encrypt(
        key,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )
    )