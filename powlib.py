import hashlib

def check(incrementer):
    """
    Checks if given number is a valid hash
    :param incrementer: Value of which hash is to be check
    :return: bool
    """
    sha256 = hashlib.sha256()
    sha256.update(str(incrementer).encode("utf-8"))

    return sha256.hexdigest().startswith("d3c0d3")

def compute(previous):
    """
    Calculates hash
    :param previous:
    :return:
    """
    incrementer = previous + 1

    while not check(incrementer):
        incrementer += 1

    return incrementer
