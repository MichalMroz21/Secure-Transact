import hashlib
import json
import base64

from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives import serialization

from PySide6.QtCore import QObject

"""
PEARSCOIN CHAIN TRANSFER PROTOCOL:

MESSAGE TYPES:

Message     Description         Response
/chain      Get current chain   JSON chain object
"""

#We use hashlib to create a key of the appropriate length
#In this case, we use 'qwerty' and pad it to 16 characters

class Encryption(QObject):
    def __init__(self):
        super().__init__()

    def encrypt_data_ecb(self, data, key):
        """
        Encrypt given data with specified key
        :param data: data to be encrypted
        :param keyRaw:
        :return: Encrypted data
        """
        #Create an AES cipher object in ECB mode using the key
        cipher = AES.new(key, AES.MODE_ECB)

        #Encrypt the data (with padding to make it a multiple of 16 bytes)
        encrypted_data = cipher.encrypt(pad(data.encode(), AES.block_size))
        encrypted_base64 = base64.b64encode(encrypted_data).decode('utf-8')

        return encrypted_base64

    def decrypt_data_ecb(self, encrypted_base64, key):
        """
        Decrypt data from Base64
        :param encrypted_base64: Data encrypted in Base64 format
        :param keyRaw: Key to be used in decryption
        :return: Decrypted data
        """
        encrypted_data = base64.b64decode(encrypted_base64)

        #Create an AES cipher object in ECB mode using the key
        cipher = AES.new(key, AES.MODE_ECB)

        #Decrypt the data and remove the padding
        decrypted_data = unpad(cipher.decrypt(encrypted_data), AES.block_size)

        return decrypted_data.decode()

    def create_key(self, friendList, myPort):
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
        keyList.sort()  #It's important to sort the list so it's the same
        keyRaw = " ".join(str(x) for x in keyList)
        key = keyRaw.ljust(16)[:16]

        return key

    def encrypt_message_block(self, json_messages, key):
        """
        Encrypts messages in JSON format to the block
        :param json_messages: messages to be encrypted
        :param key:
        :return:
        """
        encrypted_data = ""

        for message in json_messages:
            data = json.dumps(message)
            encrypted_data += self.encrypt_data_ecb(data, key)

        return encrypted_data

    def decrypt_message_block(self, block, block_key, messages_key):
        """
        Decrypt data from block
        :param block: block to be decrypted
        :param block_key: key to be used in block decryption
        :param messages_key: key to be used in messages decryption
        :return:
        """

    def private_key_to_pem(self, private_key):
        pem_private_key = private_key.private_bytes(
            encoding=serialization.Encoding.PEM, #PEM encoding
            format=serialization.PrivateFormat.TraditionalOpenSSL, #Key format
            encryption_algorithm=serialization.NoEncryption() #No password
        )

        return pem_private_key.decode('utf-8')

    def public_key_to_pem(self, public_key):
        pem = public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )

        return pem.decode('utf-8') #Convert to text

    def load_public_key_from_pem(self, pem_data):
        public_key = serialization.load_pem_public_key(
            pem_data.encode('utf-8'), #Convert text to bytes
            backend=default_backend()
        )

        return public_key

    def encrypt_with_public_key(self, public_key, key):
        """Encrypt the AES key using the RSA public key."""
        try:
            a = public_key.encrypt(
            key,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        )
            return a
        except Exception as e:
            print(e)

    def deterministicHash(self, dataString):
        numeric_seed = int.from_bytes(hashlib.sha256(dataString.encode('utf-8')).digest())
        return numeric_seed

    def createSignature(self, dataStrng):
        data = dataStrng.encode('utf-8')
        signature = self.private_key.sign(
            data,
            padding.PKCS1v15(),  # Deterministyczny algorytm podpisu
            hashes.SHA256()
        )
        return signature

    def createSignatureBase64(self, dataStrng):
        bytesSignature = self.createSignature(dataStrng)
        return base64.b64encode(bytesSignature).decode('utf-8')